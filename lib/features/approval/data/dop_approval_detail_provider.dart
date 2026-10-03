import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../dop/domain/dop_list_item_model.dart';

Future<List<DopListItemModel>>
loadDopApprovalDetails(
    Ref ref,
    String dopHeaderId,
    ) async {
  final cleanedHeaderId =
  dopHeaderId.trim();

  if (cleanedHeaderId.isEmpty) {
    return <DopListItemModel>[];
  }

  final supabase = ref.watch(
    supabaseProvider,
  );

  final response = await supabase.rpc(
    'get_dop_approval_detail',
    params: {
      'p_dop_header_id':
      cleanedHeaderId,
    },
  );

  final rawItems =
  List<Map<String, dynamic>>.from(
    response,
  );

  final details =
  <DopListItemModel>[];

  for (final rawItem in rawItems) {
    details.add(
      DopListItemModel.fromMap(
        rawItem,
      ),
    );
  }

  details.sort((
      DopListItemModel first,
      DopListItemModel second,
      ) {
    final startTimeComparison =
    first.startTime.compareTo(
      second.startTime,
    );

    if (startTimeComparison != 0) {
      return startTimeComparison;
    }

    return first.unitNumber.compareTo(
      second.unitNumber,
    );
  });

  return details;
}

final dopApprovalDetailProvider =
FutureProvider.family<
    List<DopListItemModel>,
    String>(
  loadDopApprovalDetails,
);