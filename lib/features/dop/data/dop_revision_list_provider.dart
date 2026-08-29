import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../domain/dop_revision_list_item.dart';

Future<List<DopRevisionListItem>> loadDopRevisionList(
    Ref ref,
    ) async {
  final supabase = ref.watch(
    supabaseProvider,
  );

  final currentUser =
      supabase.auth.currentUser;

  if (currentUser == null) {
    return <DopRevisionListItem>[];
  }

  final response = await supabase
      .from('v_dop_revision_list')
      .select()
      .eq(
    'created_by',
    currentUser.id,
  )
      .eq(
    'status',
    'revision_required',
  )
      .order(
    'rejected_at',
    ascending: false,
  );

  final rawItems =
  response as List<dynamic>;

  final revisionItems =
  <DopRevisionListItem>[];

  for (final rawItem in rawItems) {
    revisionItems.add(
      DopRevisionListItem.fromMap(
        Map<String, dynamic>.from(
          rawItem as Map,
        ),
      ),
    );
  }

  return revisionItems;
}

final dopRevisionListProvider =
FutureProvider<
    List<DopRevisionListItem>>(
  loadDopRevisionList,
);

final dopRevisionCountProvider =
Provider<AsyncValue<int>>(
  buildDopRevisionCount,
);

AsyncValue<int> buildDopRevisionCount(
    Ref ref,
    ) {
  final revisionsAsync = ref.watch(
    dopRevisionListProvider,
  );

  return revisionsAsync.whenData(
    readRevisionCount,
  );
}

int readRevisionCount(
    List<DopRevisionListItem> items,
    ) {
  return items.length;
}