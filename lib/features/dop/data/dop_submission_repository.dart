import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../domain/dop_activity_draft.dart';
import '../domain/dop_submission_result.dart';
import '../../../shared/providers/supabase_provider.dart';

final dopSubmissionRepositoryProvider =
Provider<DopSubmissionRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return DopSubmissionRepository(
    supabase: supabase,
  );
});

class DopSubmissionRepository {
  final SupabaseClient supabase;

  const DopSubmissionRepository({
    required this.supabase,
  });

  Future<DopSubmissionResult> submitDop({
    required String jobSiteId,
    required DateTime dopDate,
    required String dayName,
    required List<DopActivityDraft> activities,
  }) async {
    if (jobSiteId.trim().isEmpty) {
      throw Exception('Job Site wajib dipilih');
    }

    if (activities.isEmpty) {
      throw Exception(
        'Minimal satu aktivitas kendaraan wajib ditambahkan',
      );
    }

    final activityPayloads = <Map<String, dynamic>>[];

    for (final activity in activities) {
      activityPayloads.add(
        activity.toSubmissionPayload(),
      );
    }

    final response = await supabase.rpc(
      'submit_dop_request',
      params: {
        'p_job_site_id': jobSiteId,
        'p_dop_date': formatDate(dopDate),
        'p_day_name': dayName,
        'p_activities': activityPayloads,
      },
    );

    final resultMap =
    extractResultMap(response);

    final result =
    DopSubmissionResult.fromMap(
      resultMap,
    );

    await sendDopNotification(
      eventType: 'dop_submitted',
      dopHeaderId: result.dopHeaderId,
    );

    return result;

  }

  Future<String> saveDraft({
    String? dopHeaderId,
    required String jobSiteId,
    required DateTime dopDate,
    required String dayName,
    required List<DopActivityDraft> activities,
  }) async {
    final cleanedJobSiteId =
    jobSiteId.trim();

    if (cleanedJobSiteId.isEmpty) {
      throw Exception(
        'Job Site wajib dipilih.',
      );
    }

    if (activities.isEmpty) {
      throw Exception(
        'Minimal satu aktivitas kendaraan '
            'diperlukan untuk menyimpan draft.',
      );
    }

    final activityPayloads =
    <Map<String, dynamic>>[];

    for (final activity in activities) {
      activityPayloads.add(
        activity.toSubmissionPayload(),
      );
    }

    final cleanedDopHeaderId =
    dopHeaderId?.trim();

    final response = await supabase.rpc(
      'save_dop_draft',
      params: {
        'p_dop_header_id':
        cleanedDopHeaderId == null ||
            cleanedDopHeaderId.isEmpty
            ? null
            : cleanedDopHeaderId,
        'p_job_site_id':
        cleanedJobSiteId,
        'p_dop_date':
        formatDate(dopDate),
        'p_day_name':
        dayName.trim(),
        'p_activities':
        activityPayloads,
      },
    );

    final resultMap =
    extractResultMap(response);

    final draftHeaderId =
    resultMap['dop_header_id'];

    if (draftHeaderId is! String ||
        draftHeaderId.trim().isEmpty) {
      throw Exception(
        'RPC tidak mengembalikan ID Draft DOP.',
      );
    }

    return draftHeaderId.trim();
  }

  Future<DopSubmissionResult> submitDraft({
    required String dopHeaderId,
  }) async {
    final cleanedHeaderId =
    dopHeaderId.trim();

    if (cleanedHeaderId.isEmpty) {
      throw Exception(
        'Draft DOP tidak valid.',
      );
    }

    final response = await supabase.rpc(
      'submit_dop_draft',
      params: {
        'p_dop_header_id':
        cleanedHeaderId,
      },
    );

    final resultMap =
    extractResultMap(response);

    final result =
    DopSubmissionResult.fromMap(
      resultMap,
    );

    await sendDopNotification(
      eventType: 'dop_submitted',
      dopHeaderId: result.dopHeaderId,
    );

    return result;
  }

  Future<DopSubmissionResult> resubmitRevision({
    required String dopHeaderId,
    required String jobSiteId,
    required DateTime dopDate,
    required String dayName,
    required List<DopActivityDraft> activities,
  }) async {
    if (dopHeaderId.trim().isEmpty) {
      throw Exception('DOP revisi tidak valid');
    }

    if (jobSiteId.trim().isEmpty) {
      throw Exception('Job Site wajib dipilih');
    }

    if (activities.isEmpty) {
      throw Exception(
        'Minimal satu aktivitas kendaraan wajib ditambahkan',
      );
    }

    final activityPayloads =
    <Map<String, dynamic>>[];

    for (final activity in activities) {
      activityPayloads.add(
        activity.toSubmissionPayload(),
      );
    }

    final response = await supabase.rpc(
      'resubmit_dop_revision',
      params: {
        'p_dop_header_id': dopHeaderId,
        'p_job_site_id': jobSiteId,
        'p_dop_date': formatDate(dopDate),
        'p_day_name': dayName,
        'p_activities': activityPayloads,
      },
    );

    final resultMap =
    extractResultMap(response);

    final result =
    DopSubmissionResult.fromMap(
      resultMap,
    );

    await sendDopNotification(
      eventType: 'dop_submitted',
      dopHeaderId: result.dopHeaderId,
    );

    return result;
  }

  Map<String, dynamic> extractResultMap(dynamic response) {
    if (response is List) {
      if (response.isEmpty) {
        throw Exception(
          'RPC tidak mengembalikan hasil submission',
        );
      }

      final firstItem = response.first;

      if (firstItem is Map<String, dynamic>) {
        return firstItem;
      }

      if (firstItem is Map) {
        return Map<String, dynamic>.from(firstItem);
      }
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception(
      'Format hasil RPC tidak dikenali',
    );
  }

  Future<void> sendDopNotification({
    required String eventType,
    required String dopHeaderId,
  }) async {
    try {
      final response =
      await supabase.functions.invoke(
        'send-dop-notification',
        body: {
          'eventType': eventType,
          'dopHeaderId': dopHeaderId,
        },
      );

      final data = response.data;

      if (data is Map) {
        final success =
            data['success'] as bool? ?? false;

        if (!success) {
          debugPrint(
            'Notifikasi DOP gagal: '
                '${data['message']}',
          );
        }
      }
    } catch (error) {
      debugPrint(
        'Notifikasi DOP tidak terkirim: $error',
      );
    }
  }

  String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}