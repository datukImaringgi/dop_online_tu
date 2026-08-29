import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/dop_approval_list_item.dart';

Future<List<DopApprovalListItem>>
loadDopApprovalList(
    Ref ref,
    ) async {
  final supabase = ref.watch(
    supabaseProvider,
  );

  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  final companyAccess = await ref.watch(
    currentCompanyAccessProvider.future,
  );

  if (hierarchyLayer == null) {
    return <DopApprovalListItem>[];
  }

  if (hierarchyLayer < 3) {
    return <DopApprovalListItem>[];
  }

  dynamic response;

  if (hierarchyLayer == 3) {
    if (companyAccess == null) {
      return <DopApprovalListItem>[];
    }

    response = await supabase
        .from('v_dop_approval_list')
        .select()
        .eq(
      'company_id',
      companyAccess.companyId,
    )
        .eq(
      'status',
      'pending_layer_3',
    )
        .eq(
      'approval_level',
      3,
    )
        .eq(
      'approval_status',
      'pending',
    )
        .order(
      'submitted_at',
      ascending: true,
    );
  } else if (hierarchyLayer == 4) {
    if (companyAccess == null) {
      return <DopApprovalListItem>[];
    }

    response = await supabase
        .from('v_dop_approval_list')
        .select()
        .eq(
      'company_id',
      companyAccess.companyId,
    )
        .eq(
      'status',
      'pending_layer_4',
    )
        .eq(
      'approval_level',
      4,
    )
        .eq(
      'approval_status',
      'pending',
    )
        .order(
      'submitted_at',
      ascending: true,
    );
  } else if (hierarchyLayer == 5) {
    response = await supabase
        .from('v_dop_approval_list')
        .select()
        .eq(
      'approval_status',
      'pending',
    )
        .inFilter(
      'approval_level',
      <int>[3, 4],
    )
        .order(
      'submitted_at',
      ascending: true,
    );
  } else {
    return <DopApprovalListItem>[];
  }

  final rawItems = response as List<dynamic>;
  final approvalItems =
  <DopApprovalListItem>[];

  for (final rawItem in rawItems) {
    approvalItems.add(
      DopApprovalListItem.fromMap(
        Map<String, dynamic>.from(
          rawItem as Map,
        ),
      ),
    );
  }

  return approvalItems;
}

final dopApprovalListProvider =
FutureProvider<List<DopApprovalListItem>>(
  loadDopApprovalList,
);

final pendingApprovalCountProvider =
Provider<AsyncValue<int>>(
      (ref) {
    final approvalsAsync = ref.watch(
      dopApprovalListProvider,
    );

    return approvalsAsync.whenData(
          (items) {
        return items.length;
      },
    );
  },
);