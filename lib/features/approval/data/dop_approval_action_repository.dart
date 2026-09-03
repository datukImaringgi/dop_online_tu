import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';

class DopApprovalActionRepository {
  final SupabaseClient supabase;

  const DopApprovalActionRepository({
    required this.supabase,
  });

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