import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../dop/domain/dop_list_item_model.dart';

Future<List<DopListItemModel>>
loadDopApprovalDetails(
    Ref ref,
    String dopHeaderId,
    ) async {
  if (dopHeaderId.trim().isEmpty) {
    return <DopListItemModel>[];
  }

  final supabase = ref.watch(
    supabaseProvider,
  );

  final response = await supabase
      .from('v_dop_list')
      .select()
      .eq(
    'dop_header_id',
    dopHeaderId,
  )
      .order(
    'start_time',
    ascending: true,
  )
      .order(
    'unit_number',
    ascending: true,
  );

  final rawItems = response as List<dynamic>;
  final details = <DopListItemModel>[];

  for (final rawItem in rawItems) {
    details.add(
      DopListItemModel.fromMap(
        Map<String, dynamic>.from(
          rawItem as Map,
        ),
      ),
    );
  }

  return details;
}

final dopApprovalDetailProvider =
FutureProvider.family<
    List<DopListItemModel>,
    String>(
  loadDopApprovalDetails,
);