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
FutureProvider<List<Map<String, dynamic>>>(
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

    final response = await supabase
        .from('company_users')
        .select(
      'id, '
          'user_id, '
          'role, '
          'hierarchy_layer, '
          'position, '
          'department, '
          'profiles(full_name, sid)',
    )
        .eq(
      'company_id',
      companyAccess.companyId,
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
    )
        .order(
      'hierarchy_layer',
      ascending: true,
    );

    return List<Map<String, dynamic>>.from(
      response,
    );
  },
);