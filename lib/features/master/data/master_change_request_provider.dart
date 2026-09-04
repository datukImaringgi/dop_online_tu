import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/master_change_request_model.dart';

final masterChangeRequestRepositoryProvider =
Provider<MasterChangeRequestRepository>(
  createMasterChangeRequestRepository,
);

MasterChangeRequestRepository
createMasterChangeRequestRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return MasterChangeRequestRepository(
    supabase: supabase,
  );
}

final masterChangeRequestsProvider =
FutureProvider<
    List<MasterChangeRequestModel>>(
  loadMasterChangeRequests,
);

Future<List<MasterChangeRequestModel>>
loadMasterChangeRequests(
    Ref ref,
    ) async {
  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  if (hierarchyLayer == null ||
      hierarchyLayer < 3) {
    return <MasterChangeRequestModel>[];
  }

  final repository = ref.watch(
    masterChangeRequestRepositoryProvider,
  );

  return repository.getRequests();
}

final pendingMasterChangeCountProvider =
FutureProvider<int>(
  loadPendingMasterChangeCount,
);

Future<int> loadPendingMasterChangeCount(
    Ref ref,
    ) async {
  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  final canAccess =
      hierarchyLayer == 3 ||
          hierarchyLayer == 4 ||
          hierarchyLayer == 5;

  if (!canAccess) {
    return 0;
  }

  final repository = ref.watch(
    masterChangeRequestRepositoryProvider,
  );

  return repository.getPendingCount();
}

class MasterChangeRequestRepository {
  final SupabaseClient supabase;

  const MasterChangeRequestRepository({
    required this.supabase,
  });

  Future<List<MasterChangeRequestModel>>
  getRequests() async {
    final response = await supabase
        .from('master_change_requests')
        .select(
      'id, '
          'company_id, '
          'master_type, '
          'action_type, '
          'target_record_id, '
          'old_data, '
          'requested_data, '
          'status, '
          'requested_by, '
          'requested_at, '
          'reviewed_by, '
          'reviewed_at, '
          'review_note, '
          'companies(company_name)',
    )
        .order(
      'requested_at',
      ascending: false,
    );

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    final profileNames =
    await loadProfileNames(records);

    final jobSiteNames =
    await loadJobSiteNames(records);

    final requests =
    <MasterChangeRequestModel>[];

    for (final record in records) {
      requests.add(
        MasterChangeRequestModel.fromMap(
          record,
          profileNames: profileNames,
          jobSiteNames: jobSiteNames,
        ),
      );
    }

    return requests;
  }

  Future<Map<String, String>>
  loadProfileNames(
      List<Map<String, dynamic>> records,
      ) async {
    final userIds = <String>{};

    for (final record in records) {
      final requestedBy =
      record['requested_by'] as String?;

      final reviewedBy =
      record['reviewed_by'] as String?;

      if (requestedBy != null &&
          requestedBy.isNotEmpty) {
        userIds.add(requestedBy);
      }

      if (reviewedBy != null &&
          reviewedBy.isNotEmpty) {
        userIds.add(reviewedBy);
      }
    }

    if (userIds.isEmpty) {
      return <String, String>{};
    }

    final response = await supabase
        .from('profiles')
        .select(
      'id, full_name, sid',
    )
        .inFilter(
      'id',
      userIds.toList(),
    );

    final profiles =
    List<Map<String, dynamic>>.from(
      response,
    );

    final profileNames =
    <String, String>{};

    for (final profile in profiles) {
      final id =
      profile['id'] as String?;

      if (id == null || id.isEmpty) {
        continue;
      }

      final fullName =
          profile['full_name']
          as String? ??
              '-';

      final sid =
          profile['sid'] as String? ??
              '-';

      profileNames[id] =
      '$fullName - $sid';
    }

    return profileNames;
  }

  Future<Map<String, String>>
  loadJobSiteNames(
      List<Map<String, dynamic>> records,
      ) async {
    final jobSiteIds = <String>{};

    for (final record in records) {
      collectJobSiteId(
        record['old_data'],
        jobSiteIds,
      );

      collectJobSiteId(
        record['requested_data'],
        jobSiteIds,
      );
    }

    if (jobSiteIds.isEmpty) {
      return <String, String>{};
    }

    final response = await supabase
        .from('job_sites')
        .select(
      'id, site_name',
    )
        .inFilter(
      'id',
      jobSiteIds.toList(),
    );

    final recordsData =
    List<Map<String, dynamic>>.from(
      response,
    );

    final result = <String, String>{};

    for (final jobSite in recordsData) {
      final id =
      jobSite['id'] as String?;

      final siteName =
      jobSite['site_name'] as String?;

      if (id == null ||
          id.isEmpty ||
          siteName == null ||
          siteName.trim().isEmpty) {
        continue;
      }

      result[id] = siteName;
    }

    return result;
  }

  void collectJobSiteId(
      dynamic rawData,
      Set<String> jobSiteIds,
      ) {
    if (rawData is! Map) {
      return;
    }

    final jobSiteId =
    rawData['job_site_id'];

    if (jobSiteId == null) {
      return;
    }

    final normalizedId =
    jobSiteId.toString().trim();

    if (normalizedId.isEmpty) {
      return;
    }

    jobSiteIds.add(normalizedId);
  }

  Future<int> getPendingCount() async {
    final response = await supabase
        .from('master_change_requests')
        .select('id')
        .eq('status', 'pending');

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    return records.length;
  }

  Future<MasterChangeReviewResult>
  reviewOperationalRequest({
    required String requestId,
    required String decision,
    String? reviewNote,
  }) async {
    final response = await supabase.rpc(
      'review_master_change_request',
      params: {
        'p_request_id': requestId,
        'p_decision': decision,
        'p_review_note': reviewNote,
      },
    );

    return parseReviewResult(response);
  }

  Future<MasterChangeReviewResult>
  reviewUserRequest({
    required String requestId,
    required String decision,
    String? reviewNote,
  }) async {
    final response =
    await supabase.functions.invoke(
      'review-master-user',
      body: {
        'requestId': requestId,
        'decision': decision,
        'reviewNote': reviewNote,
      },
    );

    final responseData =
    extractFunctionResponse(
      response.data,
    );

    final success =
        responseData['success'] as bool? ??
            false;

    if (!success) {
      final message =
          responseData['message']
          as String? ??
              'Approval Master User gagal.';

      throw Exception(message);
    }

    return parseReviewResult(
      responseData,
    );
  }

  Map<String, dynamic>
  extractFunctionResponse(
      dynamic response,
      ) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      final normalized =
      <String, dynamic>{};

      for (final entry in response.entries) {
        normalized[
        entry.key.toString()
        ] = entry.value;
      }

      return normalized;
    }

    throw Exception(
      'Respons Approval Master User '
          'tidak valid.',
    );
  }

  Future<MasterChangeReviewResult>
  reviewRequest({
    required String requestId,
    required String masterType,
    required String decision,
    String? reviewNote,
  }) async {
    if (masterType == 'user_assignment') {
      return reviewUserRequest(
        requestId: requestId,
        decision: decision,
        reviewNote: reviewNote,
      );
    }

    const operationalMasterTypes = <String>{
      'unit',
      'driver',
      'route',
      'job_site',
      'jsa_procedure',
      'control_room',
    };

    if (operationalMasterTypes.contains(
      masterType,
    )) {
      return reviewOperationalRequest(
        requestId: requestId,
        decision: decision,
        reviewNote: reviewNote,
      );
    }

    throw Exception(
      'Jenis Master Data $masterType '
          'belum didukung.',
    );
  }

  MasterChangeReviewResult parseReviewResult(
      dynamic response,
      ) {
    if (response
    is Map<String, dynamic>) {
      return MasterChangeReviewResult
          .fromMap(
        response,
      );
    }

    if (response is Map) {
      final normalized =
      <String, dynamic>{};

      for (final entry
      in response.entries) {
        normalized[
        entry.key.toString()
        ] = entry.value;
      }

      return MasterChangeReviewResult
          .fromMap(
        normalized,
      );
    }

    throw Exception(
      'Respons Approval Master tidak valid.',
    );
  }
}