import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/dop_list_item_model.dart';

enum DopListPeriod {
  today,
  tomorrow,
  thisWeek,
  thisMonth,
  custom,
}

extension DopListPeriodLabel
on DopListPeriod {
  String get label {
    switch (this) {
      case DopListPeriod.today:
        return 'Hari Ini';
      case DopListPeriod.tomorrow:
        return 'Besok';
      case DopListPeriod.thisWeek:
        return 'Minggu Ini';
      case DopListPeriod.thisMonth:
        return 'Bulan Ini';
      case DopListPeriod.custom:
        return 'Pilih Rentang Tanggal';
    }
  }
}

class DopListDateRange {
  final DateTime from;
  final DateTime to;

  const DopListDateRange({
    required this.from,
    required this.to,
  });
}

class DopListDateFilter {
  final DopListPeriod period;
  final DopListDateRange? customRange;

  const DopListDateFilter({
    required this.period,
    this.customRange,
  });
}

class DopListDateFilterNotifier
    extends Notifier<DopListDateFilter> {
  @override
  DopListDateFilter build() {
    return const DopListDateFilter(
      period: DopListPeriod.thisWeek,
    );
  }

  void setPeriod(DopListPeriod period) {
    state = DopListDateFilter(
      period: period,
      customRange: period ==
          DopListPeriod.custom
          ? state.customRange
          : null,
    );
  }

  void setCustomRange({
    required DateTime from,
    required DateTime to,
  }) {
    final normalizedFrom = DateTime(
      from.year,
      from.month,
      from.day,
    );

    final normalizedTo = DateTime(
      to.year,
      to.month,
      to.day,
    );

    state = DopListDateFilter(
      period: DopListPeriod.custom,
      customRange: DopListDateRange(
        from: normalizedFrom,
        to: normalizedTo,
      ),
    );
  }
}

final dopListDateFilterProvider =
NotifierProvider<
    DopListDateFilterNotifier,
    DopListDateFilter>(
  DopListDateFilterNotifier.new,
);

class DopListPaginationState {
  final int currentPage;
  final int rowsPerPage;

  const DopListPaginationState({
    required this.currentPage,
    required this.rowsPerPage,
  });

  int get offset {
    return (currentPage - 1) *
        rowsPerPage;
  }

  DopListPaginationState copyWith({
    int? currentPage,
    int? rowsPerPage,
  }) {
    return DopListPaginationState(
      currentPage:
      currentPage ?? this.currentPage,
      rowsPerPage:
      rowsPerPage ?? this.rowsPerPage,
    );
  }
}

class DopListPaginationNotifier
    extends Notifier<
        DopListPaginationState> {
  @override
  DopListPaginationState build() {
    return const DopListPaginationState(
      currentPage: 1,
      rowsPerPage: 25,
    );
  }

  void goToPage(int page) {
    if (page < 1) {
      return;
    }

    state = state.copyWith(
      currentPage: page,
    );
  }

  void nextPage(int totalPages) {
    if (state.currentPage >=
        totalPages) {
      return;
    }

    goToPage(
      state.currentPage + 1,
    );
  }

  void previousPage() {
    if (state.currentPage <= 1) {
      return;
    }

    goToPage(
      state.currentPage - 1,
    );
  }

  void setRowsPerPage(int value) {
    if (value != 25 &&
        value != 50 &&
        value != 100) {
      return;
    }

    state = DopListPaginationState(
      currentPage: 1,
      rowsPerPage: value,
    );
  }

  void reset() {
    if (state.currentPage == 1) {
      return;
    }

    state = state.copyWith(
      currentPage: 1,
    );
  }
}

final dopListPaginationProvider =
NotifierProvider<
    DopListPaginationNotifier,
    DopListPaginationState>(
  DopListPaginationNotifier.new,
);

class DopListQueryResult {
  final List<DopListItemModel> items;
  final int totalItems;
  final int currentPage;
  final int rowsPerPage;

  const DopListQueryResult({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.rowsPerPage,
  });

  int get totalPages {
    if (totalItems == 0) {
      return 1;
    }

    return (
        totalItems / rowsPerPage
    ).ceil();
  }

  int get firstItemNumber {
    if (totalItems == 0) {
      return 0;
    }

    return (
        currentPage - 1
    ) *
        rowsPerPage +
        1;
  }

  int get lastItemNumber {
    final calculatedLast =
        currentPage *
            rowsPerPage;

    if (calculatedLast > totalItems) {
      return totalItems;
    }

    return calculatedLast;
  }
}

final dopListProvider =
FutureProvider<DopListQueryResult>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final profile = await ref.watch(
      currentProfileProvider.future,
    );

    final companyAccess = await ref.watch(
      currentCompanyAccessProvider.future,
    );

    final dateFilter = ref.watch(
      dopListDateFilterProvider,
    );

    final pagination = ref.watch(
      dopListPaginationProvider,
    );

    final dateRange = _resolveDateRange(
      dateFilter,
    );

    final dateFrom = _formatDate(
      dateRange.from,
    );

    final dateTo = _formatDate(
      dateRange.to,
    );

    dynamic dataQuery = supabase
        .from('v_dop_list')
        .select()
        .gte(
      'dop_date',
      dateFrom,
    )
        .lte(
      'dop_date',
      dateTo,
    );

    dynamic countQuery = supabase
        .from('v_dop_list')
        .select('detail_id')
        .gte(
      'dop_date',
      dateFrom,
    )
        .lte(
      'dop_date',
      dateTo,
    );

    if (profile?.globalRole !=
        'super_admin') {
      if (companyAccess == null) {
        return DopListQueryResult(
          items: const [],
          totalItems: 0,
          currentPage:
          pagination.currentPage,
          rowsPerPage:
          pagination.rowsPerPage,
        );
      }

      dataQuery = dataQuery.eq(
        'company_id',
        companyAccess.companyId,
      );

      countQuery = countQuery.eq(
        'company_id',
        companyAccess.companyId,
      );
    }

    final countResponse =
    await countQuery.count(
      CountOption.exact,
    );

    final totalItems =
        countResponse.count;

    final totalPages = totalItems == 0
        ? 1
        : (
        totalItems /
            pagination.rowsPerPage
    ).ceil();

    var effectivePage =
        pagination.currentPage;

    if (effectivePage > totalPages) {
      effectivePage = totalPages;
    }

    final offset =
        (effectivePage - 1) *
            pagination.rowsPerPage;

    final rangeEnd =
        offset +
            pagination.rowsPerPage -
            1;

    final response = await dataQuery
        .order(
      'dop_date',
      ascending: false,
    )
        .order(
      'dop_header_id',
      ascending: true,
    )
        .order(
      'start_time',
      ascending: true,
    )
        .range(
      offset,
      rangeEnd,
    );

    final data =
    response as List<dynamic>;

    final items =
    <DopListItemModel>[];

    for (final rawItem in data) {
      items.add(
        DopListItemModel.fromMap(
          rawItem as Map<String, dynamic>,
        ),
      );
    }

    items.sort((
        DopListItemModel first,
        DopListItemModel second,
        ) {
      final firstIsDraft =
          first.status == 'draft';

      final secondIsDraft =
          second.status == 'draft';

      if (firstIsDraft !=
          secondIsDraft) {
        return firstIsDraft ? -1 : 1;
      }

      final dateComparison =
      second.dopDate.compareTo(
        first.dopDate,
      );

      if (dateComparison != 0) {
        return dateComparison;
      }

      final headerComparison =
      first.dopHeaderId.compareTo(
        second.dopHeaderId,
      );

      if (headerComparison != 0) {
        return headerComparison;
      }

      return first.startTime.compareTo(
        second.startTime,
      );
    });

    return DopListQueryResult(
      items: items,
      totalItems: totalItems,
      currentPage: effectivePage,
      rowsPerPage:
      pagination.rowsPerPage,
    );
  },
);

final dashboardDopListProvider =
FutureProvider<List<DopListItemModel>>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final profile = await ref.watch(
      currentProfileProvider.future,
    );

    final companyAccess = await ref.watch(
      currentCompanyAccessProvider.future,
    );

    dynamic query = supabase
        .from('v_dop_list')
        .select();

    if (profile?.globalRole !=
        'super_admin') {
      if (companyAccess == null) {
        return <DopListItemModel>[];
      }

      query = query.eq(
        'company_id',
        companyAccess.companyId,
      );
    }

    final response = await query.order(
      'dop_date',
      ascending: false,
    );

    final data = response as List<dynamic>;

    return data.map((rawItem) {
      return DopListItemModel.fromMap(
        rawItem as Map<String, dynamic>,
      );
    }).toList();
  },
);

DopListDateRange _resolveDateRange(
    DopListDateFilter filter,
    ) {
  final now = DateTime.now();

  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  switch (filter.period) {
    case DopListPeriod.today:
      return DopListDateRange(
        from: today,
        to: today,
      );

    case DopListPeriod.tomorrow:
      final tomorrow = today.add(
        const Duration(days: 1),
      );

      return DopListDateRange(
        from: tomorrow,
        to: tomorrow,
      );

    case DopListPeriod.thisWeek:
      final startOfWeek = today.subtract(
        Duration(
          days: today.weekday - 1,
        ),
      );

      final endOfWeek = startOfWeek.add(
        const Duration(days: 6),
      );

      return DopListDateRange(
        from: startOfWeek,
        to: endOfWeek,
      );

    case DopListPeriod.thisMonth:
      final startOfMonth = DateTime(
        today.year,
        today.month,
        1,
      );

      final endOfMonth = DateTime(
        today.year,
        today.month + 1,
        0,
      );

      return DopListDateRange(
        from: startOfMonth,
        to: endOfMonth,
      );

    case DopListPeriod.custom:
      return filter.customRange ??
          DopListDateRange(
            from: today,
            to: today,
          );
  }
}

String _formatDate(DateTime value) {
  final year = value.year
      .toString()
      .padLeft(4, '0');

  final month = value.month
      .toString()
      .padLeft(2, '0');

  final day = value.day
      .toString()
      .padLeft(2, '0');

  return '$year-$month-$day';
}