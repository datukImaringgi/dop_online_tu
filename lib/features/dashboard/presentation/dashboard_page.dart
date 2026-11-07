import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dop/data/dop_list_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../domain/dashboard_models.dart';
import '../../dop/domain/dop_list_item_model.dart';
import 'widgets/dashboard_summary.dart';
import 'widgets/dashboard_running_text.dart';
import 'widgets/dashboard_transport_area.dart';
import 'widgets/dashboard_compliance.dart';
import 'widgets/dashboard_filters.dart';
import 'widgets/dashboard_unit_availability.dart';
import 'widgets/dashboard_unscheduled_monitoring.dart';

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

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? selectedCompanyId;
  String? selectedJobSiteId;

  DashboardPeriod selectedPeriod = DashboardPeriod.tomorrow;

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
    final dopListAsync = ref.watch(dashboardDopListProvider);
    final companyAccessAsync = ref.watch(currentCompanyAccessProvider);
    final hierarchyAsync = ref.watch(currentHierarchyLayerProvider);

    final dopItems = dopListAsync.value ?? <DopListItemModel>[];
    final companyAccess = companyAccessAsync.asData?.value;
    final hierarchyLayer = hierarchyAsync.asData?.value;
    final isLayerFive = hierarchyLayer == 5;

    final filteredDopItems = filterDopItems(
      dopItems: dopItems,
      isLayerFive: isLayerFive,
      currentCompanyId:
      companyAccess?.companyId,
    );

    final companyOptions = buildCompanyOptions(dopItems);

    final jobSiteOptions = buildJobSiteOptions(
      dopItems: dopItems,
      isLayerFive: isLayerFive,
      currentCompanyId:
      companyAccess?.companyId,
    );

    final currentCompanyName = companyAccess?.companyName ?? 'Perusahaan tidak tersedia';

    final calculation = DashboardCalculation.calculate(
      dopItems: filteredDopItems,
      now: DateTime.now(),
    );

    final transportAreaCalculation = DashboardTransportAreaCalculation.calculate(
      dopItems: filteredDopItems,
    );

    final unscheduledCalculation =
    DashboardUnscheduledCalculation.calculate(
      dopItems: filteredDopItems,
    );

    final metrics = calculation.metrics;

    final incompleteCount = metrics.incomplete;
    final overdueTwoHours = metrics.overdueTwo;
    final overdueTwelveHours = metrics.overdueTwelve;

    final pendingLayer3Count = metrics.pendingLayer3;
    final pendingLayer4Count = metrics.pendingLayer4;
    final revisionStatusCount = metrics.revisionRequired;
    final revisionCount = metrics.revisionRequired;
    final approvalRate = metrics.approvalRate;

    final jalanNegaraRows = transportAreaCalculation.jalanNegaraRows;
    final siteRows = transportAreaCalculation.siteRows;

    final complianceRows = calculation.complianceRows;
    final unscheduledRows = unscheduledCalculation.rows;
    final totalDop = metrics.totalDop;
    final approvedCount = metrics.approved;
    final rejectedCount = metrics.rejected;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: dopListAsync.isLoading || companyAccessAsync.isLoading || hierarchyAsync.isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
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
                  DashboardFilters(
                    isLayerFive: isLayerFive,
                    companyName: currentCompanyName,
                    selectedCompanyId: selectedCompanyId,
                    selectedJobSiteId: selectedJobSiteId,
                    selectedPeriod: selectedPeriod,
                    companyOptions: companyOptions,
                    jobSiteOptions: jobSiteOptions,
                    onCompanyChanged: handleCompanyChanged,
                    onJobSiteChanged: handleJobSiteChanged,
                    onPeriodChanged: handlePeriodChanged,
                    onReset: resetFilters,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const DashboardRunningText(),
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
              DashboardComplianceCard(
                rows: complianceRows,
              ),

              const SizedBox(height: 12),

              DashboardUnscheduledMonitoringCard(
                rows: unscheduledRows,
              ),
              const SizedBox(height: 12),
              DashboardTransportAreaSection(
                jalanNegaraRows: jalanNegaraRows,
                siteRows: siteRows,
              ),
              const SizedBox(height: 12),
              const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                    DashboardUnitAvailabilityCard(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
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