import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';

final jobSitesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('job_sites')
        .select()
        .eq('is_active', true)
        .order('site_name');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('job_sites')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('site_name');

  return List<Map<String, dynamic>>.from(response);
});

final unitsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('units')
        .select()
        .eq('is_active', true)
        .order('unit_number');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('units')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('unit_number');

  return List<Map<String, dynamic>>.from(response);
});

final driversProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('drivers')
        .select()
        .eq('is_active', true)
        .order('driver_name');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('drivers')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('driver_name');

  return List<Map<String, dynamic>>.from(response);
});

final routesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('routes')
        .select()
        .eq('is_active', true)
        .order('route_name');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('routes')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('route_name');

  return List<Map<String, dynamic>>.from(response);
});

final jsaProceduresProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('jsa_procedures')
        .select()
        .eq('is_active', true)
        .order('procedure_code');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('jsa_procedures')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('procedure_code');

  return List<Map<String, dynamic>>.from(response);
});

final controlRoomsProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (profile?.globalRole == 'super_admin') {
    final response = await supabase
        .from('control_rooms')
        .select()
        .eq('is_active', true)
        .order('control_room_name');

    return List<Map<String, dynamic>>.from(response);
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final response = await supabase
      .from('control_rooms')
      .select()
      .eq('company_id', companyAccess.companyId)
      .eq('is_active', true)
      .order('control_room_name');

  return List<Map<String, dynamic>>.from(response);
});

final employeeOptionsProvider =
FutureProvider<
    List<Map<String, dynamic>>>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final companyAccess = await ref.watch(
      currentCompanyAccessProvider.future,
    );

    if (companyAccess == null) {
      return <Map<String, dynamic>>[];
    }

    final ownCompanyId =
        companyAccess.companyId;

    // Layer 1 sampai Layer 4 internal.
    final ownCompanyResponse =
    await supabase
        .from('company_users')
        .select(
      'id, '
          'user_id, '
          'company_id, '
          'role, '
          'hierarchy_layer, '
          'position, '
          'department, '
          'companies(company_name), '
          'profiles(full_name, sid)',
    )
        .eq(
      'company_id',
      ownCompanyId,
    )
        .eq(
      'is_active',
      true,
    )
        .not(
      'hierarchy_layer',
      'is',
      null,
    )
        .gte(
      'hierarchy_layer',
      1,
    )
        .lte(
      'hierarchy_layer',
      4,
    );

    final ownCompanyEmployees =
    List<Map<String, dynamic>>.from(
      ownCompanyResponse,
    );

    // Cari perusahaan yang tergabung dengan
    // perusahaan user saat ini.
    final groupResponse = await supabase
        .from('company_layer_4_groups')
        .select(
      'company_1_id, company_2_id',
    )
        .eq(
      'is_active',
      true,
    )
        .or(
      'company_1_id.eq.$ownCompanyId,'
          'company_2_id.eq.$ownCompanyId',
    );

    final groupRecords =
    List<Map<String, dynamic>>.from(
      groupResponse,
    );

    final pairedCompanyIds = <String>{};

    for (final group in groupRecords) {
      final company1Id =
      group['company_1_id']
          ?.toString()
          .trim();

      final company2Id =
      group['company_2_id']
          ?.toString()
          .trim();

      if (company1Id == ownCompanyId &&
          company2Id != null &&
          company2Id.isNotEmpty) {
        pairedCompanyIds.add(company2Id);
      }

      if (company2Id == ownCompanyId &&
          company1Id != null &&
          company1Id.isNotEmpty) {
        pairedCompanyIds.add(company1Id);
      }
    }

    final combinedEmployees =
    <Map<String, dynamic>>[
      ...ownCompanyEmployees,
    ];

    if (pairedCompanyIds.isNotEmpty) {
      final groupedLayer4Response =
      await supabase.rpc(
        'get_grouped_layer_4_candidates',
        params: {
          'p_target_company_id':
          ownCompanyId,
        },
      );

      final groupedLayer4Records =
      List<Map<String, dynamic>>.from(
        groupedLayer4Response,
      );

      for (final record
      in groupedLayer4Records) {
        combinedEmployees.add({
          'id':
          record['company_user_id'],
          'user_id':
          record['candidate_user_id'],
          'company_id':
          record['candidate_company_id'],
          'role':
          record['candidate_role'],
          'hierarchy_layer':
          record['hierarchy_layer'],
          'position':
          record['position_name'],
          'department':
          record['department_name'],
          'companies': {
            'company_name':
            record['company_name'],
          },
          'profiles': {
            'full_name':
            record['full_name'],
            'sid':
            record['sid'],
          },
        });
      }
    }

    // Hilangkan kemungkinan duplikasi berdasarkan
    // company_users.id.
    final uniqueEmployees =
    <String, Map<String, dynamic>>{};

    for (final employee
    in combinedEmployees) {
      final companyUserId =
      employee['id']
          ?.toString()
          .trim();

      if (companyUserId == null ||
          companyUserId.isEmpty) {
        continue;
      }

      uniqueEmployees[companyUserId] =
          employee;
    }

    final result =
    uniqueEmployees.values.toList();

    result.sort((first, second) {
      final firstLayer =
          first['hierarchy_layer'] as int? ??
              99;

      final secondLayer =
          second['hierarchy_layer'] as int? ??
              99;

      final layerComparison =
      firstLayer.compareTo(secondLayer);

      if (layerComparison != 0) {
        return layerComparison;
      }

      final firstProfile =
      first['profiles'];

      final secondProfile =
      second['profiles'];

      final firstName =
      firstProfile is Map
          ? firstProfile['full_name']
          ?.toString() ??
          ''
          : '';

      final secondName =
      secondProfile is Map
          ? secondProfile['full_name']
          ?.toString() ??
          ''
          : '';

      return firstName.compareTo(
        secondName,
      );
    });

    return result;
  },
);