import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';

class OperationalMasterResult {
  final String resultType;
  final String masterType;
  final String actionType;
  final String? requestId;
  final String? targetRecordId;
  final String message;

  const OperationalMasterResult({
    required this.resultType,
    required this.masterType,
    required this.actionType,
    required this.requestId,
    required this.targetRecordId,
    required this.message,
  });

  factory OperationalMasterResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return OperationalMasterResult(
      resultType:
      map['result_type'] as String? ??
          'unknown',
      masterType:
      map['master_type'] as String? ??
          '',
      actionType:
      map['action_type'] as String? ??
          '',
      requestId:
      map['request_id'] as String?,
      targetRecordId:
      map['target_record_id']
      as String?,
      message:
      map['message'] as String? ??
          'Perubahan Master Data berhasil diproses.',
    );
  }

  bool get isPendingApproval {
    return resultType ==
        'pending_approval';
  }

  bool get isAppliedDirectly {
    return resultType == 'applied';
  }
}

class OperationalMasterRepository {
  final SupabaseClient supabase;

  const OperationalMasterRepository({
    required this.supabase,
  });

  Future<List<Map<String, dynamic>>>
  loadMasterData({
    required String tableName,
  }) async {
    validateTableName(tableName);

    final masterResponse = await supabase
        .from(tableName)
        .select()
        .order(
      'created_at',
      ascending: false,
    );

    final companyResponse = await supabase
        .from('companies')
        .select(
      'id, company_name',
    );

    final jobSiteResponse = await supabase
        .from('job_sites')
        .select(
      'id, site_name',
    );

    final companyNames = <String, String>{};

    for (final rawCompany
    in companyResponse) {
      final company =
      Map<String, dynamic>.from(
        rawCompany,
      );

      final companyId =
      company['id'] as String?;

      final companyName =
      company['company_name']
      as String?;

      if (companyId == null) {
        continue;
      }

      companyNames[companyId] =
          companyName ?? '-';
    }

    final jobSiteNames = <String, String>{};

    for (final rawJobSite
    in jobSiteResponse) {
      final jobSite =
      Map<String, dynamic>.from(
        rawJobSite,
      );

      final jobSiteId =
      jobSite['id'] as String?;

      final siteName =
      jobSite['site_name']
      as String?;

      if (jobSiteId == null) {
        continue;
      }

      jobSiteNames[jobSiteId] =
          siteName ?? '-';
    }

    final records =
    <Map<String, dynamic>>[];

    for (final rawRecord
    in masterResponse) {
      final record =
      Map<String, dynamic>.from(
        rawRecord,
      );

      final companyId =
      record['company_id']
      as String?;

      final jobSiteId =
      record['job_site_id']
      as String?;

      record['companies'] =
      <String, dynamic>{
        'company_name':
        companyNames[companyId] ?? '-',
      };

      record['job_sites'] =
      <String, dynamic>{
        'site_name':
        jobSiteNames[jobSiteId] ?? '-',
      };

      records.add(record);
    }

    return records;
  }

  Future<OperationalMasterResult>
  submitChange({
    required String masterType,
    required String actionType,
    required String companyId,
    String? targetRecordId,
    Map<String, dynamic>? requestedData,
  }) async {
    validateMasterType(masterType);
    validateActionType(actionType);

    if (companyId.trim().isEmpty) {
      throw Exception(
        'Perusahaan wajib tersedia.',
      );
    }

    final response = await supabase.rpc(
      'submit_master_data_change',
      params: {
        'p_master_type': masterType,
        'p_action_type': actionType,
        'p_target_record_id':
        normalizeOptional(
          targetRecordId,
        ),
        'p_company_id': companyId,
        'p_requested_data':
        requestedData,
      },
    );

    return OperationalMasterResult.fromMap(
      normalizeResponse(response),
    );
  }

  void validateMasterType(
      String masterType,
      ) {
    const allowedTypes = <String>{
      'unit',
      'driver',
      'route',
      'job_site',
      'jsa_procedure',
      'control_room',
    };

    if (!allowedTypes.contains(masterType)) {
      throw Exception(
        'Jenis Master Data tidak valid.',
      );
    }
  }

  void validateActionType(
      String actionType,
      ) {
    const allowedActions = <String>{
      'create',
      'update',
      'activate',
      'deactivate',
    };

    if (!allowedActions.contains(actionType)) {
      throw Exception(
        'Jenis perubahan tidak valid.',
      );
    }
  }

  void validateTableName(
      String tableName,
      ) {
    const allowedTables = <String>{
      'units',
      'drivers',
      'routes',
      'job_sites',
      'jsa_procedures',
      'control_rooms',
    };

    if (!allowedTables.contains(tableName)) {
      throw Exception(
        'Tabel Master Data tidak valid.',
      );
    }
  }

  String? normalizeOptional(
      String? value,
      ) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  Map<String, dynamic> normalizeResponse(
      dynamic response,
      ) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(
        response,
      );
    }

    throw Exception(
      'Respons perubahan Master Data '
          'tidak valid.',
    );
  }
}

OperationalMasterRepository
buildOperationalMasterRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return OperationalMasterRepository(
    supabase: supabase,
  );
}

final operationalMasterRepositoryProvider =
Provider<OperationalMasterRepository>(
  buildOperationalMasterRepository,
);

final operationalMasterDataProvider =
FutureProvider.family<
    List<Map<String, dynamic>>,
    String>(
  loadOperationalMasterData,
);

Future<List<Map<String, dynamic>>>
loadOperationalMasterData(
    Ref ref,
    String tableName,
    ) async {
  final repository = ref.watch(
    operationalMasterRepositoryProvider,
  );

  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  final companyAccess = await ref.watch(
    currentCompanyAccessProvider.future,
  );

  final records =
  await repository.loadMasterData(
    tableName: tableName,
  );

  if (hierarchyLayer == 5) {
    return records;
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final filteredRecords =
  <Map<String, dynamic>>[];

  for (final record in records) {
    if (record['company_id'] ==
        companyAccess.companyId) {
      filteredRecords.add(record);
    }
  }

  return filteredRecords;
}