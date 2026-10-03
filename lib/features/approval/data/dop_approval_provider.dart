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

  if (hierarchyLayer == null ||
      hierarchyLayer < 3) {
    return <DopApprovalListItem>[];
  }

  dynamic response;

  if (hierarchyLayer == 3 ||
      hierarchyLayer == 4) {
    response = await supabase.rpc(
      'get_my_dop_approval_list',
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

  final rawItems =
  List<Map<String, dynamic>>.from(
    response,
  );

  final approvalItems =
  <DopApprovalListItem>[];

  for (final rawItem in rawItems) {
    approvalItems.add(
      DopApprovalListItem.fromMap(
        rawItem,
      ),
    );
  }

  approvalItems.sort((
      DopApprovalListItem first,
      DopApprovalListItem second,
      ) {
    return first.submittedAt.compareTo(
      second.submittedAt,
    );
  });

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