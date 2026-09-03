import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dop/data/dop_list_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/dashboard_models.dart';
import '../../dop/domain/dop_list_item_model.dart';
import 'widgets/dashboard_summary.dart';

class DashboardPage
    extends ConsumerStatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  ConsumerState<DashboardPage> createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState
    extends ConsumerState<DashboardPage> {
  String? selectedCompanyId;
  String? selectedJobSiteId;

  DashboardPeriod selectedPeriod =
      DashboardPeriod.tomorrow;

  void handleCompanyChanged(
      String? companyId,
      ) {
    setState(() {
      selectedCompanyId = companyId;
      selectedJobSiteId = null;
    });
  }

  void handleJobSiteChanged(
      String? jobSiteId,
      ) {
    setState(() {
      selectedJobSiteId = jobSiteId;
    });
  }

  void handlePeriodChanged(
      DashboardPeriod? period,
      ) {
    if (period == null) {
      return;
    }

    setState(() {
      selectedPeriod = period;
    });
  }

  void resetFilters() {
    setState(() {
      selectedCompanyId = null;
      selectedJobSiteId = null;
      selectedPeriod = DashboardPeriod.tomorrow;
    });
  }

  Map<String, String> buildCompanyOptions(
      List<DopListItemModel> dopItems,
      ) {
    final companyOptions = <String, String>{};

    for (final item in dopItems) {
      final companyId =
      item.companyId.toString().trim();

      final companyName =
      item.companyName.toString().trim();

      if (companyId.isEmpty ||
          companyName.isEmpty ||
          companyName == '-') {
        continue;
      }

      companyOptions[companyId] = companyName;
    }

    return companyOptions;
  }

  Map<String, String> buildJobSiteOptions({
    required List<DopListItemModel> dopItems,
    required bool isLayerFive,
    required String? currentCompanyId,
  }) {
    final options = <String, String>{};

    String? activeCompanyId;

    if (isLayerFive) {
      activeCompanyId = selectedCompanyId;
    } else {
      activeCompanyId = currentCompanyId;
    }

    for (final item in dopItems) {
      if (activeCompanyId != null &&
          activeCompanyId.isNotEmpty &&
          item.companyId != activeCompanyId) {
        continue;
      }

      final jobSiteId =
      item.jobSiteId.trim();

      final jobSiteName =
      item.jobSite.trim();

      if (jobSiteId.isEmpty ||
          jobSiteName.isEmpty ||
          jobSiteName == '-') {
        continue;
      }

      options[jobSiteId] = jobSiteName;
    }

    return options;
  }

  List<DropdownMenuItem<String?>>
  buildJobSiteDropdownItems(
      Map<String, String> options,
      ) {
    final items =
    <DropdownMenuItem<String?>>[];

    items.add(
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Job Site'),
      ),
    );

    final jobSiteIds = options.keys.toList();

    jobSiteIds.sort(
          (String firstId, String secondId) {
        final firstName =
            options[firstId] ?? '';

        final secondName =
            options[secondId] ?? '';

        return firstName.compareTo(secondName);
      },
    );

    for (final jobSiteId in jobSiteIds) {
      items.add(
        DropdownMenuItem<String?>(
          value: jobSiteId,
          child: Text(
            options[jobSiteId] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  List<DropdownMenuItem<String?>>
  buildCompanyDropdownItems(
      Map<String, String> companyOptions,
      ) {
    final items =
    <DropdownMenuItem<String?>>[];

    items.add(
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Perusahaan'),
      ),
    );

    final companyIds =
    companyOptions.keys.toList();

    companyIds.sort(
          (String firstId, String secondId) {
        final firstName =
            companyOptions[firstId] ?? '';

        final secondName =
            companyOptions[secondId] ?? '';

        return firstName.compareTo(secondName);
      },
    );

    for (final companyId in companyIds) {
      items.add(
        DropdownMenuItem<String?>(
          value: companyId,
          child: Text(
            companyOptions[companyId] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  List<DropdownMenuItem<DashboardPeriod>>
  buildPeriodDropdownItems() {
    return const [
      DropdownMenuItem<DashboardPeriod>(
        value: DashboardPeriod.all,
        child: Text('Semua Periode'),
      ),
      DropdownMenuItem<DashboardPeriod>(
        value: DashboardPeriod.tomorrow,
        child: Text('Esok Hari'),
      ),
      DropdownMenuItem<DashboardPeriod>(
        value: DashboardPeriod.today,
        child: Text('Hari Ini'),
      ),
      DropdownMenuItem<DashboardPeriod>(
        value: DashboardPeriod.currentWeek,
        child: Text('Pekan ini'),
      ),
      DropdownMenuItem<DashboardPeriod>(
        value: DashboardPeriod.currentMonth,
        child: Text('Bulan Ini'),
      ),
    ];
  }

  Widget buildDashboardFilters({
    required bool isLayerFive,
    required String companyName,
    required Map<String, String> companyOptions,
    required Map<String, String> jobSiteOptions,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 190,
          child: isLayerFive
              ? DropdownButtonFormField<String?>(
            value: selectedCompanyId,
            isExpanded: true,
            iconSize: 18,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: buildFilterDecoration(
              label: 'Perusahaan',
              icon: Icons.business_outlined,
            ),
            items: buildCompanyDropdownItems(
              companyOptions,
            ),
            onChanged: handleCompanyChanged,
          )
              : InputDecorator(
            decoration: buildFilterDecoration(
              label: 'Perusahaan',
              icon: Icons.business_outlined,
            ),
            child: Text(
              companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String?>(
            value: selectedJobSiteId,
            isExpanded: true,
            iconSize: 18,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: buildFilterDecoration(
              label: 'Job Site',
              icon: Icons.location_on_outlined,
            ),
            items: buildJobSiteDropdownItems(
              jobSiteOptions,
            ),
            onChanged: handleJobSiteChanged,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<
              DashboardPeriod>(
            value: selectedPeriod,
            isExpanded: true,
            iconSize: 18,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: buildFilterDecoration(
              label: 'Periode',
              icon: Icons.date_range_outlined,
            ),
            items: buildPeriodDropdownItems(),
            onChanged: handlePeriodChanged,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Reset filter',
          child: SizedBox(
            width: 36,
            height: 36,
            child: OutlinedButton(
              onPressed: resetFilters,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor:
                const Color(0xFF475569),
                side: const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.refresh,
                size: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration buildFilterDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: Icon(
        icon,
        size: 16,
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 9.5,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.25,
        ),
      ),
    );
  }

  bool matchesSelectedPeriod(
      DateTime dopDate,
      ) {
    if (selectedPeriod ==
        DashboardPeriod.all) {
      return true;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final normalizedDopDate = DateTime(
      dopDate.year,
      dopDate.month,
      dopDate.day,
    );

    if (selectedPeriod ==
        DashboardPeriod.tomorrow) {
      final tomorrow = today.add(
        const Duration(days: 1),
      );

      return normalizedDopDate == tomorrow;
    }

    if (selectedPeriod ==
        DashboardPeriod.today) {
      final tomorrow = today.add(
        const Duration(days: 1),
      );

      return normalizedDopDate == today ||
          normalizedDopDate == tomorrow;
    }

    if (selectedPeriod ==
        DashboardPeriod.currentWeek) {
      final daysSinceSunday =
          today.weekday % 7;

      final startOfWeek = today.subtract(
        Duration(days: daysSinceSunday),
      );

      return !normalizedDopDate.isBefore(
        startOfWeek,
      ) &&
          !normalizedDopDate.isAfter(today);
    }

    final firstDateOfMonth = DateTime(
      today.year,
      today.month,
      1,
    );

    final firstDateOfNextMonth = DateTime(
      today.year,
      today.month + 1,
      1,
    );

    return !normalizedDopDate.isBefore(
      firstDateOfMonth,
    ) &&
        normalizedDopDate.isBefore(
          firstDateOfNextMonth,
        );
  }

  DateTime? parseDopDate(
      String value,
      ) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty ||
        normalizedValue == '-') {
      return null;
    }

    return DateTime.tryParse(
      normalizedValue,
    );
  }

  List<DopListItemModel> filterDopItems({
    required List<DopListItemModel> dopItems,
    required bool isLayerFive,
    required String? currentCompanyId,
  }) {
    final filteredItems = <DopListItemModel>[];

    for (final item in dopItems) {
      String? activeCompanyId;

      if (isLayerFive) {
        activeCompanyId =
            selectedCompanyId;
      } else {
        activeCompanyId =
            currentCompanyId;
      }

      if (activeCompanyId != null &&
          activeCompanyId.isNotEmpty &&
          item.companyId != activeCompanyId) {
        continue;
      }

      if (selectedJobSiteId != null &&
          selectedJobSiteId!.isNotEmpty &&
          item.jobSiteId != selectedJobSiteId) {
        continue;
      }

      final dopDate = parseDopDate(
        item.dopDate,
      );

      if (selectedPeriod !=
          DashboardPeriod.all &&
          dopDate == null) {
        continue;
      }

      if (dopDate != null &&
          !matchesSelectedPeriod(dopDate)) {
        continue;
      }

      filteredItems.add(item);
    }

    return filteredItems;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final dopListAsync = ref.watch(
      dopListProvider,
    );

    final companyAccessAsync = ref.watch(
      currentCompanyAccessProvider,
    );

    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final dopItems =
        dopListAsync.value ??
            <DopListItemModel>[];

    final companyAccess =
        companyAccessAsync.asData?.value;

    final hierarchyLayer =
        hierarchyAsync.asData?.value;

    final isLayerFive =
        hierarchyLayer == 5;

    final filteredDopItems = filterDopItems(
      dopItems: dopItems,
      isLayerFive: isLayerFive,
      currentCompanyId:
      companyAccess?.companyId,
    );

    final companyOptions =
    buildCompanyOptions(dopItems);

    final jobSiteOptions = buildJobSiteOptions(
      dopItems: dopItems,
      isLayerFive: isLayerFive,
      currentCompanyId:
      companyAccess?.companyId,
    );

    final currentCompanyName =
        companyAccess?.companyName ??
            'Perusahaan tidak tersedia';

    final calculation =
    DashboardCalculation.calculate(
      dopItems: filteredDopItems,
      now: DateTime.now(),
    );

    final metrics = calculation.metrics;

    final transportAreaCalculation =
    DashboardTransportAreaCalculation
        .calculate(
      dopItems: filteredDopItems,
    );

    final jalanNegaraRows =
        transportAreaCalculation
            .jalanNegaraRows;

    final siteRows =
        transportAreaCalculation.siteRows;

    final complianceRows =
        calculation.complianceRows;

    final totalDop =
        metrics.totalDop;

    final approvedCount =
        metrics.approved;

    final rejectedCount =
        metrics.rejected;

    final pendingLayer3Count =
        metrics.pendingLayer3;

    final pendingLayer4Count =
        metrics.pendingLayer4;

    final revisionStatusCount =
        metrics.revisionRequired;

    final revisionCount =
        metrics.revisionRequired;

    final incompleteCount =
        metrics.incomplete;

    final overdueTwoHours =
        metrics.overdueTwo;

    final overdueTwelveHours =
        metrics.overdueTwelve;

    final approvalRate =
        metrics.approvalRate;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: dopListAsync.isLoading ||
            companyAccessAsync.isLoading ||
            hierarchyAsync.isLoading
            ? const Center(
              child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DOP Online Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Daily Operation Plan - '
                                  'Transportasi Darat',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      buildDashboardFilters(
                        isLayerFive: isLayerFive,
                        companyName: currentCompanyName,
                        companyOptions: companyOptions,
                        jobSiteOptions: jobSiteOptions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _DashboardRunningText(),
                  const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: DashboardMonitoringSection(
                        overdueTwoHours: overdueTwoHours,
                        overdueTwelveHours:
                        overdueTwelveHours,
                        incompleteCount: incompleteCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: DashboardAchievementSection(
                        totalDop: totalDop,
                        approvedCount: approvedCount,
                        rejectedCount: rejectedCount,
                        revisionCount: revisionCount,
                        approvalRate: approvalRate,
                        pendingLayer3Count: pendingLayer3Count,
                        pendingLayer4Count: pendingLayer4Count,
                        revisionStatusCount: revisionStatusCount,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TransportAreaTable(
                      title: 'Area Jalan Negara',
                      rows: jalanNegaraRows,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TransportAreaTable(
                      title: 'Area Site',
                      rows: siteRows,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DopComplianceCard(
                      rows: complianceRows,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DopComplianceCard
    extends StatelessWidget {
  final List<DashboardComplianceRow> rows;

  const _DopComplianceCard({
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              _buildEmptyState()
            else
              for (final row in rows) ...[
                _ComplianceBarRow(
                  row: row,
                ),
                if (row != rows.last)
                  const Divider(
                    height: 14,
                    color: Color(0xFFE2E8F0),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'DOP Compliance',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildLegend(
          'Comply',
          const Color(0xFF22C55E),
        ),
        const SizedBox(width: 8),
        _buildLegend(
          '> 2 Jam',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 8),
        _buildLegend(
          '> 12 Jam',
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildLegend(
      String label,
      Color color,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
            BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 48,
      child: Center(
        child: Text(
          'Belum ada data compliance.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

class _ComplianceBarRow
    extends StatelessWidget {
  final DashboardComplianceRow row;

  const _ComplianceBarRow({
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            row.companyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            row.compliancePercentageText,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: ClipRRect(
            borderRadius:
            BorderRadius.circular(5),
            child: SizedBox(
              height: 28,
              child: Row(
                children: [
                  _buildSegment(
                    value: row.comply,
                    total: row.total,
                    color:
                    const Color(0xFF22C55E),
                  ),
                  _buildSegment(
                    value: row.overdueTwo,
                    total: row.total,
                    color:
                    const Color(0xFFF59E0B),
                  ),
                  _buildSegment(
                    value: row.overdueTwelve,
                    total: row.total,
                    color:
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegment({
    required int value,
    required int total,
    required Color color,
  }) {
    if (value == 0 || total == 0) {
      return const SizedBox.shrink();
    }

    return Expanded(
      flex: value,
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TransportAreaTable extends StatelessWidget {
  final String title;
  final List<DashboardTransportAreaRow> rows;

  const _TransportAreaTable({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    children: [
                      _TableHeaderCell(text: 'Nama Perusahaan'),
                      _TableHeaderCell(text: 'Massal'),
                      _TableHeaderCell(text: 'Non-Massal'),
                    ],
                  ),
                  if (rows.isEmpty)
                    const TableRow(
                      children: [
                        _TableBodyCell(
                          text: 'Belum ada data',
                        ),
                        _TableBodyCell(
                          text: '0',
                        ),
                        _TableBodyCell(
                          text: '0',
                        ),
                      ],
                    ),

                  for (final row in rows)
                    TableRow(
                      children: [
                        _TableBodyCell(
                          text: row.companyName,
                        ),
                        _TableBodyCell(
                          text: row.massal.toString(),
                        ),
                        _TableBodyCell(
                          text: row.nonMassal.toString(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TableBodyCell extends StatelessWidget {
  final String text;

  const _TableBodyCell({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DashboardRunningText
    extends StatefulWidget {
  const _DashboardRunningText();

  @override
  State<_DashboardRunningText> createState() {
    return _DashboardRunningTextState();
  }
}

class _DashboardRunningTextState
    extends State<_DashboardRunningText>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  animationController;

  late final Animation<Offset>
  slideAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: const Offset(-1.2, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );

    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: Color(0xFFD97706),
              size: 16,
            ),
          ),
          Expanded(
            child: ClipRect(
              child: SlideTransition(
                position: slideAnimation,
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _RunningTextItem(),
                    _RunningTextItem(),
                    _RunningTextItem(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunningTextItem extends StatelessWidget {
  const _RunningTextItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFD97706),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Maksimal submit DOP di jam 16:00',
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: Color(0xFF92400E),
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}