import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/providers/supabase_provider.dart';

class DopApprovalActionRepository {
  final SupabaseClient supabase;

  const DopApprovalActionRepository({
    required this.supabase,
  });

  Future<void> sendDopNotification({
    required String eventType,
    required String dopHeaderId,
    String? reviewNote,
  }) async {
    try {
      final body = <String, dynamic>{
        'eventType': eventType,
        'dopHeaderId': dopHeaderId,
      };

      final normalizedNote =
          reviewNote?.trim() ?? '';

      if (normalizedNote.isNotEmpty) {
        body['reviewNote'] = normalizedNote;
      }

      final response =
      await supabase.functions.invoke(
        'send-dop-notification',
        body: body,
      );

      final responseData = response.data;

      if (responseData is Map) {
        final success =
            responseData['success'] as bool? ??
                false;

        if (!success) {
          debugPrint(
            'Notifikasi DOP gagal: '
                '${responseData['message']}',
          );
        }
      }
    } catch (error) {
      debugPrint(
        'Notifikasi DOP tidak terkirim: '
            '$error',
      );
    }
  }

  Future<void> approveLayer3({
    required String dopHeaderId,
    String? note,
  }) async {
    final cleanedDopHeaderId =
    dopHeaderId.trim();

    final cleanedNote =
    note?.trim();

    if (cleanedDopHeaderId.isEmpty) {
      throw Exception(
        'DOP yang akan disetujui tidak valid.',
      );
    }

    await supabase.rpc(
      'approve_dop_layer_3',
      params: {
        'p_dop_header_id':
        cleanedDopHeaderId,
        'p_note':
        cleanedNote == null ||
            cleanedNote.isEmpty
            ? null
            : cleanedNote,
      },
    );

    await sendDopNotification(
      eventType: 'layer_3_approved',
      dopHeaderId: cleanedDopHeaderId,
      reviewNote: cleanedNote,
    );
  }

  Future<void> approveLayer4({
    required String dopHeaderId,
    String? note,
  }) async {
    final cleanedDopHeaderId =
    dopHeaderId.trim();

    final cleanedNote =
    note?.trim();

    if (cleanedDopHeaderId.isEmpty) {
      throw Exception(
        'DOP yang akan disetujui tidak valid.',
      );
    }

    await supabase.rpc(
      'approve_dop_layer_4',
      params: {
        'p_dop_header_id':
        cleanedDopHeaderId,
        'p_note':
        cleanedNote == null ||
            cleanedNote.isEmpty
            ? null
            : cleanedNote,
      },
    );

    await sendDopNotification(
      eventType: 'layer_4_approved',
      dopHeaderId: cleanedDopHeaderId,
      reviewNote: cleanedNote,
    );
  }

  Future<void> returnForRevision({
    required String dopHeaderId,
    required String note,
  }) async {
    final cleanedDopHeaderId =
    dopHeaderId.trim();

    final cleanedNote =
    note.trim();

    if (cleanedDopHeaderId.isEmpty) {
      throw Exception(
        'DOP yang akan dikembalikan tidak valid.',
      );
    }

    if (cleanedNote.isEmpty) {
      throw Exception(
        'Catatan revisi wajib diisi.',
      );
    }

    await supabase.rpc(
      'return_dop_for_revision',
      params: {
        'p_dop_header_id':
        cleanedDopHeaderId,
        'p_note':
        cleanedNote,
      },
    );

    await sendDopNotification(
      eventType: 'revision_required',
      dopHeaderId: cleanedDopHeaderId,
      reviewNote: cleanedNote,
    );
  }

  Future<void> rejectDop({
    required String dopHeaderId,
    required String note,
  }) async {
    final cleanedDopHeaderId =
    dopHeaderId.trim();

    final cleanedNote =
    note.trim();

    if (cleanedDopHeaderId.isEmpty) {
      throw Exception(
        'DOP yang akan ditolak tidak valid.',
      );
    }

    if (cleanedNote.isEmpty) {
      throw Exception(
        'Alasan Reject DOP wajib diisi.',
      );
    }

    await supabase.rpc(
      'reject_dop_final',
      params: {
        'p_dop_header_id':
        cleanedDopHeaderId,
        'p_note': cleanedNote,
      },
    );

    await sendDopNotification(
      eventType: 'rejected',
      dopHeaderId: cleanedDopHeaderId,
      reviewNote: cleanedNote,
    );
  }
}

DopApprovalActionRepository
buildDopApprovalActionRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return DopApprovalActionRepository(
    supabase: supabase,
  );
}

final dopApprovalActionRepositoryProvider =
Provider<DopApprovalActionRepository>(
  buildDopApprovalActionRepository,
);