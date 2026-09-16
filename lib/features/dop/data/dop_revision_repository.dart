import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../domain/dop_activity_draft.dart';
import '../domain/dop_revision_data.dart';

class DopRevisionRepository {
  final SupabaseClient supabase;

  const DopRevisionRepository({
    required this.supabase,
  });

  Future<DopRevisionData> loadRevision({
    required String dopHeaderId,
  }) async {
    final cleanedHeaderId =
    dopHeaderId.trim();

    if (cleanedHeaderId.isEmpty) {
      throw Exception(
        'DOP revisi tidak valid.',
      );
    }

    final currentUser =
        supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'User belum login.',
      );
    }

    final headerResponse = await supabase
        .from('dop_headers')
        .select(
      'id, '
          'dop_number, '
          'company_id, '
          'job_site_id, '
          'dop_date, '
          'day_name, '
          'status, '
          'created_by, '
          'revision_number',
    )
        .eq(
      'id',
      cleanedHeaderId,
    )
        .maybeSingle();

    if (headerResponse == null) {
      throw Exception(
        'DOP tidak ditemukan.',
      );
    }

    final header =
    Map<String, dynamic>.from(
      headerResponse,
    );

    final status =
        header['status'] as String? ?? '';

    if (status != 'revision_required') {
      throw Exception(
        'DOP tidak sedang menunggu revisi.',
      );
    }

    final createdBy =
    header['created_by'] as String?;

    if (createdBy != currentUser.id) {
      throw Exception(
        'Hanya pembuat DOP yang dapat '
            'melakukan revisi.',
      );
    }

    final companyId =
    header['company_id'] as String?;

    final jobSiteId =
    header['job_site_id'] as String?;

    if (companyId == null ||
        companyId.isEmpty) {
      throw Exception(
        'Perusahaan DOP tidak valid.',
      );
    }

    if (jobSiteId == null ||
        jobSiteId.isEmpty) {
      throw Exception(
        'Job Site DOP tidak valid.',
      );
    }

    final detailsResponse = await supabase
        .from('dop_details')
        .select(
      'id, '
          'work_plan, '
          'area_type, '
          'shift, '
          'unit_id, '
          'unit_type, '
          'unit_number, '
          'transport_company, '
          'driver_id, '
          'driver_name, '
          'sid, '
          'sid_expired_date, '
          'simper_expired_date, '
          'start_time, '
          'end_time, '
          'route_id, '
          'route, '
          'observer, '
          'jsa_id, '
          'jsa_procedure, '
          'control_room_id, '
          'control_room, '
          'layer_1_user_id, '
          'layer_2_user_id, '
          'layer_3_user_id, '
          'layer_4_user_id, '
          'layer_1, '
          'layer_2, '
          'layer_3, '
          'layer_4, '
          'notes',
    )
        .eq(
      'dop_header_id',
      cleanedHeaderId,
    )
        .eq(
      'is_active',
      true,
    )
        .order(
      'created_at',
      ascending: true,
    );

    final rawDetails =
    detailsResponse as List<dynamic>;

    if (rawDetails.isEmpty) {
      throw Exception(
        'Aktivitas DOP tidak ditemukan.',
      );
    }

    final activities =
    <DopActivityDraft>[];

    for (final rawDetail in rawDetails) {
      final detailMap =
      Map<String, dynamic>.from(
        rawDetail as Map,
      );

      final record =
      DopRevisionDetailRecord.fromMap(
        detailMap,
      );

      activities.add(
        record.toDraft(),
      );
    }

    final revisionNote =
    await loadLatestRevisionNote(
      dopHeaderId: cleanedHeaderId,
    );

    final dopDateText =
    header['dop_date']?.toString();

    if (dopDateText == null ||
        dopDateText.isEmpty) {
      throw Exception(
        'Tanggal DOP tidak valid.',
      );
    }

    final dopDate =
    DateTime.tryParse(dopDateText);

    if (dopDate == null) {
      throw Exception(
        'Format tanggal DOP tidak valid.',
      );
    }

    return DopRevisionData(
      dopHeaderId: cleanedHeaderId,
      dopNumber:
      header['dop_number']
      as String? ??
          '-',
      companyId: companyId,
      jobSiteId: jobSiteId,
      dopDate: dopDate,
      dayName:
      header['day_name']
      as String? ??
          '-',
      revisionNumber:
      readInteger(
        header['revision_number'],
      ),
      revisionNote: revisionNote,
      activities: activities,
    );
  }

  Future<DopRevisionData> loadDraft({
    required String dopHeaderId,
  }) async {
    final cleanedHeaderId =
    dopHeaderId.trim();

    if (cleanedHeaderId.isEmpty) {
      throw Exception(
        'Draft DOP tidak valid.',
      );
    }

    final currentUser =
        supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'User belum login.',
      );
    }

    final headerResponse = await supabase
        .from('dop_headers')
        .select(
      'id, '
          'dop_number, '
          'company_id, '
          'job_site_id, '
          'dop_date, '
          'day_name, '
          'status, '
          'created_by, '
          'revision_number',
    )
        .eq('id', cleanedHeaderId)
        .maybeSingle();

    if (headerResponse == null) {
      throw Exception(
        'Draft DOP tidak ditemukan.',
      );
    }

    final header =
    Map<String, dynamic>.from(
      headerResponse,
    );

    if (header['status'] != 'draft') {
      throw Exception(
        'DOP ini bukan berstatus Draft.',
      );
    }

    if (header['created_by'] !=
        currentUser.id) {
      throw Exception(
        'Hanya pembuat Draft DOP yang '
            'dapat melanjutkannya.',
      );
    }

    final companyId =
    header['company_id'] as String?;

    final jobSiteId =
    header['job_site_id'] as String?;

    if (companyId == null ||
        companyId.isEmpty ||
        jobSiteId == null ||
        jobSiteId.isEmpty) {
      throw Exception(
        'Perusahaan atau Job Site Draft '
            'tidak valid.',
      );
    }

    final detailsResponse = await supabase
        .from('dop_details')
        .select(
      'id, '
          'work_plan, '
          'area_type, '
          'shift, '
          'unit_id, '
          'unit_type, '
          'unit_number, '
          'transport_company, '
          'driver_id, '
          'driver_name, '
          'sid, '
          'sid_expired_date, '
          'simper_expired_date, '
          'start_time, '
          'end_time, '
          'route_id, '
          'route, '
          'observer, '
          'jsa_id, '
          'jsa_procedure, '
          'control_room_id, '
          'control_room, '
          'layer_1_user_id, '
          'layer_2_user_id, '
          'layer_3_user_id, '
          'layer_4_user_id, '
          'layer_1, '
          'layer_2, '
          'layer_3, '
          'layer_4, '
          'notes',
    )
        .eq(
      'dop_header_id',
      cleanedHeaderId,
    )
        .eq('is_active', true)
        .order(
      'created_at',
      ascending: true,
    );

    final rawDetails =
    detailsResponse as List<dynamic>;

    if (rawDetails.isEmpty) {
      throw Exception(
        'Aktivitas Draft DOP tidak ditemukan.',
      );
    }

    final activities =
    <DopActivityDraft>[];

    for (final rawDetail in rawDetails) {
      final detailMap =
      Map<String, dynamic>.from(
        rawDetail as Map,
      );

      final detailRecord =
      DopRevisionDetailRecord.fromMap(
        detailMap,
      );

      activities.add(
        detailRecord.toDraft(),
      );
    }

    final dopDateText =
    header['dop_date']?.toString();

    final dopDate =
    dopDateText == null
        ? null
        : DateTime.tryParse(
      dopDateText,
    );

    if (dopDate == null) {
      throw Exception(
        'Tanggal Draft DOP tidak valid.',
      );
    }

    return DopRevisionData(
      dopHeaderId: cleanedHeaderId,
      dopNumber: 'DRAFT',
      companyId: companyId,
      jobSiteId: jobSiteId,
      dopDate: dopDate,
      dayName:
      header['day_name'] as String? ??
          '-',
      revisionNumber: 0,
      revisionNote: '',
      activities: activities,
    );
  }

  Future<DopRevisionData> loadReference({
    required String dopHeaderId,
  }) async {
    final cleanedHeaderId =
    dopHeaderId.trim();

    if (cleanedHeaderId.isEmpty) {
      throw Exception(
        'Referensi DOP tidak valid.',
      );
    }

    final currentUser =
        supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'User belum login.',
      );
    }

    final headerResponse = await supabase
        .from('dop_headers')
        .select(
      'id, '
          'dop_number, '
          'company_id, '
          'job_site_id, '
          'dop_date, '
          'day_name, '
          'status, '
          'revision_number',
    )
        .eq('id', cleanedHeaderId)
        .eq('is_active', true)
        .maybeSingle();

    if (headerResponse == null) {
      throw Exception(
        'DOP referensi tidak ditemukan.',
      );
    }

    final header =
    Map<String, dynamic>.from(
      headerResponse,
    );

    final status =
        header['status'] as String? ?? '';

    if (status == 'draft') {
      throw Exception(
        'Draft tidak dapat digunakan melalui '
            'fitur referensi. Gunakan Lanjutkan Draft.',
      );
    }

    final companyId =
    header['company_id'] as String?;

    final jobSiteId =
    header['job_site_id'] as String?;

    if (companyId == null ||
        companyId.isEmpty ||
        jobSiteId == null ||
        jobSiteId.isEmpty) {
      throw Exception(
        'Perusahaan atau Job Site referensi '
            'tidak valid.',
      );
    }

    final detailsResponse = await supabase
        .from('dop_details')
        .select(
      'id, '
          'work_plan, '
          'area_type, '
          'shift, '
          'unit_id, '
          'unit_type, '
          'unit_number, '
          'transport_company, '
          'driver_id, '
          'driver_name, '
          'sid, '
          'sid_expired_date, '
          'simper_expired_date, '
          'start_time, '
          'end_time, '
          'route_id, '
          'route, '
          'observer, '
          'jsa_id, '
          'jsa_procedure, '
          'control_room_id, '
          'control_room, '
          'layer_1_user_id, '
          'layer_2_user_id, '
          'layer_3_user_id, '
          'layer_4_user_id, '
          'layer_1, '
          'layer_2, '
          'layer_3, '
          'layer_4, '
          'notes',
    )
        .eq(
      'dop_header_id',
      cleanedHeaderId,
    )
        .eq('is_active', true)
        .order(
      'created_at',
      ascending: true,
    );

    final rawDetails =
    detailsResponse as List<dynamic>;

    if (rawDetails.isEmpty) {
      throw Exception(
        'Aktivitas DOP referensi '
            'tidak ditemukan.',
      );
    }

    final activities =
    <DopActivityDraft>[];

    for (final rawDetail in rawDetails) {
      final detailMap =
      Map<String, dynamic>.from(
        rawDetail as Map,
      );

      final detailRecord =
      DopRevisionDetailRecord.fromMap(
        detailMap,
      );

      final originalDraft =
      detailRecord.toDraft();

      activities.add(
        DopActivityDraft(
          localId: DateTime.now()
              .microsecondsSinceEpoch
              .toString() +
              activities.length.toString(),
          workPlan: originalDraft.workPlan,
          areaType: originalDraft.areaType,
          shift: originalDraft.shift,
          unitId: originalDraft.unitId,
          unitType: originalDraft.unitType,
          unitNumber: originalDraft.unitNumber,
          transportCompany:
          originalDraft.transportCompany,
          driverId: originalDraft.driverId,
          driverName: originalDraft.driverName,
          sid: originalDraft.sid,
          sidExpiredDate:
          originalDraft.sidExpiredDate,
          simperExpiredDate:
          originalDraft.simperExpiredDate,
          startTime: originalDraft.startTime,
          endTime: originalDraft.endTime,
          routeId: originalDraft.routeId,
          routeName: originalDraft.routeName,
          observer: originalDraft.observer,
          jsaId: originalDraft.jsaId,
          jsaProcedure:
          originalDraft.jsaProcedure,
          controlRoomId:
          originalDraft.controlRoomId,
          controlRoomName:
          originalDraft.controlRoomName,
          layer1UserId:
          originalDraft.layer1UserId,
          layer2UserId:
          originalDraft.layer2UserId,
          layer3UserId:
          originalDraft.layer3UserId,
          layer4UserId:
          originalDraft.layer4UserId,
          layer1: originalDraft.layer1,
          layer2: originalDraft.layer2,
          layer3: originalDraft.layer3,
          layer4: originalDraft.layer4,
          notes: originalDraft.notes,
        ),
      );
    }

    final now = DateTime.now();

    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(
      const Duration(days: 1),
    );

    return DopRevisionData(
      dopHeaderId: cleanedHeaderId,
      dopNumber:
      header['dop_number'] as String? ??
          '-',
      companyId: companyId,
      jobSiteId: jobSiteId,
      dopDate: tomorrow,
      dayName: '',
      revisionNumber: 0,
      revisionNote: '',
      activities: activities,
    );
  }

  Future<String> loadLatestRevisionNote({
    required String dopHeaderId,
  }) async {
    final response = await supabase
        .from('dop_approvals')
        .select(
      'note, rejected_at, updated_at',
    )
        .eq(
      'dop_header_id',
      dopHeaderId,
    )
        .eq(
      'status',
      'rejected',
    )
        .order(
      'rejected_at',
      ascending: false,
    )
        .limit(1);

    final rows = response as List<dynamic>;

    if (rows.isEmpty) {
      return '-';
    }

    final row =
    Map<String, dynamic>.from(
      rows.first as Map,
    );

    final note =
    row['note'] as String?;

    if (note == null ||
        note.trim().isEmpty) {
      return '-';
    }

    return note.trim();
  }

  int readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}

DopRevisionRepository
buildDopRevisionRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return DopRevisionRepository(
    supabase: supabase,
  );
}

final dopRevisionRepositoryProvider =
Provider<DopRevisionRepository>(
  buildDopRevisionRepository,
);

Future<DopRevisionData>
loadDopRevisionData(
    Ref ref,
    String dopHeaderId,
    ) async {
  final repository = ref.watch(
    dopRevisionRepositoryProvider,
  );

  return repository.loadRevision(
    dopHeaderId: dopHeaderId,
  );
}

final dopRevisionDataProvider =
FutureProvider.family<
    DopRevisionData,
    String>(
  loadDopRevisionData,
);

Future<DopRevisionData>
loadDopDraftData(
    Ref ref,
    String dopHeaderId,
    ) async {
  final repository = ref.watch(
    dopRevisionRepositoryProvider,
  );

  return repository.loadDraft(
    dopHeaderId: dopHeaderId,
  );
}

final dopDraftDataProvider =
FutureProvider.family<
    DopRevisionData,
    String>(
  loadDopDraftData,
);

Future<DopRevisionData>
loadDopReferenceData(
    Ref ref,
    String dopHeaderId,
    ) async {
  final repository = ref.watch(
    dopRevisionRepositoryProvider,
  );

  return repository.loadReference(
    dopHeaderId: dopHeaderId,
  );
}

final dopReferenceDataProvider =
FutureProvider.family<
    DopRevisionData,
    String>(
  loadDopReferenceData,
);