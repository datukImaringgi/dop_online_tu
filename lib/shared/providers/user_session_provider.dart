import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/company_user_model.dart';
import '../models/profile_model.dart';
import 'supabase_provider.dart';

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null;
  }

  final response = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  return ProfileModel.fromMap(response);
});

final userCompaniesProvider = FutureProvider<List<CompanyUserModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    return <CompanyUserModel>[];
  }

  final response = await supabase
      .from('company_users')
      .select('*, companies(company_name, company_code)')
      .eq('user_id', user.id)
      .eq('is_active', true);

  final data = response as List<dynamic>;

  final companies = <CompanyUserModel>[];

  for (final item in data) {
    companies.add(
      CompanyUserModel.fromMap(item as Map<String, dynamic>),
    );
  }

  return companies;
});

final currentCompanyAccessProvider = FutureProvider<CompanyUserModel?>((ref) async {
  final companies = await ref.watch(userCompaniesProvider.future);

  if (companies.isEmpty) {
    return null;
  }

  return companies.first;
});

final currentRoleProvider = FutureProvider<String?>((ref) async {
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  if (companyAccess == null) {
    return null;
  }

  return companyAccess.role;
});

final currentHierarchyLayerProvider =
FutureProvider<int?>((ref) async {
  final companyAccess = await ref.watch(
    currentCompanyAccessProvider.future,
  );

  if (companyAccess == null) {
    return null;
  }

  return companyAccess.hierarchyLayer;
});

final canCreateDopProvider = FutureProvider<bool>((ref) async {
  final layer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  if (layer == null) {
    return false;
  }

  return layer >= 1 && layer <= 5;
});

final canManageCompanyMasterProvider =
FutureProvider<bool>((ref) async {
  final layer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  if (layer == null) {
    return false;
  }

  return layer >= 3;
});

final canApproveLayer3Provider =
FutureProvider<bool>((ref) async {
  final layer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  return layer == 3;
});

final canApproveLayer4Provider =
FutureProvider<bool>((ref) async {
  final layer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  return layer == 4;
});

final isPlatformSuperAdminProvider =
FutureProvider<bool>((ref) async {
  final layer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  return layer == 5;
});