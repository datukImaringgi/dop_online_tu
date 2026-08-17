import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/dop_list_item_model.dart';

final dopListProvider = FutureProvider<List<DopListItemModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  final companyAccess = await ref.watch(currentCompanyAccessProvider.future);

  dynamic response;

  if (profile?.globalRole == 'super_admin') {
    response = await supabase
        .from('v_dop_list')
        .select()
        .order('dop_date', ascending: false);
  } else {
    if (companyAccess == null) {
      return <DopListItemModel>[];
    }

    response = await supabase
        .from('v_dop_list')
        .select()
        .eq('company_id', companyAccess.companyId)
        .order('dop_date', ascending: false);
  }

  final data = response as List<dynamic>;
  final items = <DopListItemModel>[];

  for (final item in data) {
    items.add(
      DopListItemModel.fromMap(item as Map<String, dynamic>),
    );
  }

  return items;
});