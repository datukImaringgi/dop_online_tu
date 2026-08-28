import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/company_user_hierarchy_model.dart';

final companyUserHierarchyProvider =
FutureProvider<List<CompanyUserHierarchyModel>>(
      (ref) async {
    final supabase = ref.watch(supabaseProvider);

    final companyAccess = await ref.watch(
      currentCompanyAccessProvider.future,
    );

    if (companyAccess == null) {
      return <CompanyUserHierarchyModel>[];
    }

    final hierarchyLayer =
        companyAccess.hierarchyLayer;

    dynamic response;

    if (hierarchyLayer == 5) {
      response = await supabase
          .from('v_company_user_hierarchy')
          .select()
          .order('company_name')
          .order('hierarchy_layer')
          .order('full_name');
    } else {
      response = await supabase
          .from('v_company_user_hierarchy')
          .select()
          .eq(
        'company_id',
        companyAccess.companyId,
      )
          .order('hierarchy_layer')
          .order('full_name');
    }

    final data = response as List<dynamic>;
    final users = <CompanyUserHierarchyModel>[];

    for (final item in data) {
      users.add(
        CompanyUserHierarchyModel.fromMap(
          item as Map<String, dynamic>,
        ),
      );
    }

    return users;
  },
);