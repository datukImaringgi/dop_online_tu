import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/master_unit_model.dart';

final masterUnitRepositoryProvider =
Provider<MasterUnitRepository>(
  createMasterUnitRepository,
);

MasterUnitRepository
createMasterUnitRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return MasterUnitRepository(
    supabase: supabase,
  );
}

final masterUnitsProvider =
FutureProvider<List<MasterUnitModel>>(
  loadMasterUnits,
);

Future<List<MasterUnitModel>>
loadMasterUnits(
    Ref ref,
    ) async {
  final repository = ref.watch(
    masterUnitRepositoryProvider,
  );

  final companyAccess = await ref.watch(
    currentCompanyAccessProvider.future,
  );

  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  if (hierarchyLayer == null) {
    return <MasterUnitModel>[];
  }

  if (hierarchyLayer == 5) {
    return repository.getUnits(
      companyId: null,
    );
  }

  if (companyAccess == null) {
    return <MasterUnitModel>[];
  }

  return repository.getUnits(
    companyId: companyAccess.companyId,
  );
}

class MasterUnitRepository {
  final SupabaseClient supabase;

  const MasterUnitRepository({
    required this.supabase,
  });

  Future<List<MasterUnitModel>> getUnits({
    required String? companyId,
  }) async {
    var query = supabase
        .from('units')
        .select(
      'id, '
          'company_id, '
          'job_site_id, '
          'unit_number, '
          'unit_type, '
          'owner_company, '
          'is_active, '
          'companies(company_name), '
          'job_sites(site_name)',
    );

    if (companyId != null &&
        companyId.isNotEmpty) {
      query = query.eq(
        'company_id',
        companyId,
      );
    }

    final response = await query.order(
      'unit_number',
      ascending: true,
    );

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    final units = <MasterUnitModel>[];

    for (final record in records) {
      units.add(
        MasterUnitModel.fromMap(record),
      );
    }

    return units;
  }

  Future<MasterUnitChangeResult> createUnit({
    required String companyId,
    required String jobSiteId,
    required String unitNumber,
    required String unitType,
    required String ownerCompany,
    required bool isActive,
  }) async {
    final response = await supabase.rpc(
      'submit_master_unit_change',
      params: {
        'p_action_type': 'create',
        'p_target_unit_id': null,
        'p_company_id': companyId,
        'p_job_site_id': jobSiteId,
        'p_unit_number':
        unitNumber.trim().toUpperCase(),
        'p_unit_type':
        unitType.trim().toUpperCase(),
        'p_owner_company':
        ownerCompany.trim(),
        'p_is_active': isActive,
      },
    );

    return parseChangeResult(response);
  }

  Future<MasterUnitChangeResult> updateUnit({
    required String unitId,
    required String jobSiteId,
    required String unitNumber,
    required String unitType,
    required String ownerCompany,
    required bool isActive,
  }) async {
    final response = await supabase.rpc(
      'submit_master_unit_change',
      params: {
        'p_action_type': 'update',
        'p_target_unit_id': unitId,
        'p_company_id': null,
        'p_job_site_id': jobSiteId,
        'p_unit_number':
        unitNumber.trim().toUpperCase(),
        'p_unit_type':
        unitType.trim().toUpperCase(),
        'p_owner_company':
        ownerCompany.trim(),
        'p_is_active': isActive,
      },
    );

    return parseChangeResult(response);
  }

  Future<MasterUnitChangeResult>
  updateUnitStatus({
    required String unitId,
    required bool isActive,
  }) async {
    final actionType = isActive
        ? 'activate'
        : 'deactivate';

    final response = await supabase.rpc(
      'submit_master_unit_change',
      params: {
        'p_action_type': actionType,
        'p_target_unit_id': unitId,
        'p_company_id': null,
        'p_job_site_id': null,
        'p_unit_number': null,
        'p_unit_type': null,
        'p_owner_company': null,
        'p_is_active': isActive,
      },
    );

    return parseChangeResult(response);
  }

  MasterUnitChangeResult parseChangeResult(
      dynamic response,
      ) {
    if (response is Map<String, dynamic>) {
      return MasterUnitChangeResult.fromMap(
        response,
      );
    }

    if (response is Map) {
      final normalizedResponse =
      <String, dynamic>{};

      for (final entry in response.entries) {
        normalizedResponse[
        entry.key.toString()
        ] = entry.value;
      }

      return MasterUnitChangeResult.fromMap(
        normalizedResponse,
      );
    }

    throw Exception(
      'Respons perubahan Master Unit tidak valid.',
    );
  }
}