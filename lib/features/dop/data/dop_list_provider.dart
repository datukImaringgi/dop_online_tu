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

class DopListQueryFilter {
  final String companyName;
  final String jobSite;
  final String unitType;
  final String unitNumber;
  final String areaType;
  final String shift;
  final String status;
  final String dopNumberQuery;

  const DopListQueryFilter({
    this.companyName = 'Semua',
    this.jobSite = 'Semua',
    this.unitType = 'Semua',
    this.unitNumber = 'Semua',
    this.areaType = 'Semua',
    this.shift = 'Semua',
    this.status = 'Semua',
    this.dopNumberQuery = '',
  });

  DopListQueryFilter copyWith({
    String? companyName,
    String? jobSite,
    String? unitType,
    String? unitNumber,
    String? areaType,
    String? shift,
    String? status,
    String? dopNumberQuery,
  }) {
    return DopListQueryFilter(
      companyName:
      companyName ?? this.companyName,
      jobSite:
      jobSite ?? this.jobSite,
      unitType:
      unitType ?? this.unitType,
      unitNumber:
      unitNumber ?? this.unitNumber,
      areaType:
      areaType ?? this.areaType,
      shift:
      shift ?? this.shift,
      status:
      status ?? this.status,
      dopNumberQuery:
      dopNumberQuery ??
          this.dopNumberQuery,
    );
  }
}

class DopListQueryFilterNotifier
    extends Notifier<DopListQueryFilter> {
  @override
  DopListQueryFilter build() {
    return const DopListQueryFilter();
  }

  void setCompany(String value) {
    state = state.copyWith(
      companyName: value,
      jobSite: 'Semua',
      unitNumber: 'Semua',
    );
  }

  void setJobSite(String value) {
    state = state.copyWith(
      jobSite: value,
      unitNumber: 'Semua',
    );
  }

  void setUnitType(String value) {
    state = state.copyWith(
      unitType: value,
    );
  }

  void setUnitNumber(String value) {
    state = state.copyWith(
      unitNumber: value,
    );
  }

  void setAreaType(String value) {
    state = state.copyWith(
      areaType: value,
    );
  }

  void setShift(String value) {
    state = state.copyWith(
      shift: value,
    );
  }

  void setStatus(String value) {
    state = state.copyWith(
      status: value,
    );
  }

  void setDopNumberQuery(String value) {
    state = state.copyWith(
      dopNumberQuery: value.trim(),
    );
  }

  void reset() {
    state = const DopListQueryFilter();
  }
}

final dopListQueryFilterProvider =
NotifierProvider<
    DopListQueryFilterNotifier,
    DopListQueryFilter>(
  DopListQueryFilterNotifier.new,
);

class DopListFilterOptions {
  final List<String> companies;
  final List<String> jobSites;
  final List<String> unitTypes;
  final List<String> unitNumbers;
  final List<String> areaTypes;
  final List<String> shifts;
  final List<String> statuses;

  const DopListFilterOptions({
    required this.companies,
    required this.jobSites,
    required this.unitTypes,
    required this.unitNumbers,
    required this.areaTypes,
    required this.shifts,
    required this.statuses,
  });

  static const empty = DopListFilterOptions(
    companies: <String>[],
    jobSites: <String>[],
    unitTypes: <String>[],
    unitNumbers: <String>[],
    areaTypes: <String>[],
    shifts: <String>[],
    statuses: <String>[],
  );
}

final dopListFilterOptionsProvider =
FutureProvider<DopListFilterOptions>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final dateFilter = ref.watch(
      dopListDateFilterProvider,
    );

    final dateRange = _resolveDateRange(
      dateFilter,
    );

    final response = await supabase.rpc(
      'get_dop_list_filter_options',
      params: {
        'p_date_from': _formatDate(
          dateRange.from,
        ),
        'p_date_to': _formatDate(
          dateRange.to,
        ),
      },
    );

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    final values =
    <String, Set<String>>{};

    for (final record in records) {
      final type = record['filter_type']
          ?.toString()
          .trim();

      final value = record['filter_value']
          ?.toString()
          .trim();

      if (type == null ||
          type.isEmpty ||
          value == null ||
          value.isEmpty) {
        continue;
      }

      values
          .putIfAbsent(
        type,
            () => <String>{},
      )
          .add(value);
    }

    List<String> readOptions(
        String type,
        ) {
      final result =
          values[type]?.toList() ??
              <String>[];

      result.sort(
            (first, second) =>
            first.toLowerCase().compareTo(
              second.toLowerCase(),
            ),
      );

      return result;
    }

    return DopListFilterOptions(
      companies:
      readOptions('company_name'),
      jobSites:
      readOptions('job_site'),
      unitTypes:
      readOptions('unit_type'),
      unitNumbers:
      readOptions('unit_number'),
      areaTypes:
      readOptions('area_type'),
      shifts:
      readOptions('shift'),
      statuses:
      readOptions('status'),
    );
  },
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

    final queryFilter = ref.watch(
      dopListQueryFilterProvider,
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

    dataQuery = applyDopListQueryFilter(
      dataQuery,
      queryFilter,
    );

    countQuery = applyDopListQueryFilter(
      countQuery,
      queryFilter,
    );

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

dynamic applyDopListQueryFilter(
    dynamic query,
    DopListQueryFilter filter,
    ) {
  if (filter.companyName != 'Semua') {
    query = query.eq(
      'company_name',
      filter.companyName,
    );
  }

  if (filter.jobSite != 'Semua') {
    query = query.eq(
      'job_site',
      filter.jobSite,
    );
  }

  if (filter.unitType != 'Semua') {
    query = query.eq(
      'unit_type',
      filter.unitType,
    );
  }

  if (filter.unitNumber != 'Semua') {
    query = query.eq(
      'unit_number',
      filter.unitNumber,
    );
  }

  if (filter.areaType != 'Semua') {
    query = query.eq(
      'area_type',
      filter.areaType,
    );
  }

  if (filter.shift != 'Semua') {
    query = query.eq(
      'shift',
      filter.shift,
    );
  }

  if (filter.status != 'Semua') {
    query = query.eq(
      'status',
      filter.status,
    );
  }

  final dopNumberQuery =
  filter.dopNumberQuery.trim();

  if (dopNumberQuery.isNotEmpty) {
    query = query.ilike(
      'dop_number',
      '%$dopNumberQuery%',
    );
  }

  return query;
}

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