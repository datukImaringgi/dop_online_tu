import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dop/data/dop_list_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final dopListAsync = ref.watch(
      dopListProvider,
    );

    final dopItems = dopListAsync.value ?? [];

    final uniqueDopItems =
    <String, dynamic>{};

    for (final item in dopItems) {
      uniqueDopItems[item.dopHeaderId] =
          item;
    }

    var approvedCount = 0;
    var pendingLayer3Count = 0;
    var pendingLayer4Count = 0;
    var revisionStatusCount = 0;
    var incompleteCount = 0;

    for (final item in uniqueDopItems.values) {
      final status = item.status;
      if (status == 'approved') {
        approvedCount++;
      }

      if (status == 'pending_layer_3') {
        pendingLayer3Count++;
      }

      if (status == 'pending_layer_4') {
        pendingLayer4Count++;
      }

      if (status == 'revision_required') {
        revisionStatusCount++;
      }

      if (status == 'pending_layer_3' ||
          status == 'pending_layer_4' ||
          status == 'revision_required') {
        incompleteCount++;
      }
    }

    var overdueTwoHours = 0;
    var overdueTwelveHours = 0;

    final now = DateTime.now();

    for (final item in uniqueDopItems.values) {
      if (item.status == 'approved') {
        continue;
      }

      final DateTime? submittedAt =
          item.submittedAt;

      if (submittedAt == null) {
        continue;
      }

      final localSubmittedAt =
      submittedAt.toLocal();

      final benchmark = DateTime(
        localSubmittedAt.year,
        localSubmittedAt.month,
        localSubmittedAt.day,
        16,
      );

      final overdueDuration =
      now.difference(benchmark);

      if (overdueDuration >
          const Duration(hours: 12)) {
        overdueTwelveHours++;
        continue;
      }

      if (overdueDuration >
          const Duration(hours: 2)) {
        overdueTwoHours++;
      }
    }

    final totalDop = uniqueDopItems.length;

    final revisionCount = revisionStatusCount;

    final approvalRate = totalDop == 0
        ? 0.0
        : approvedCount / totalDop * 100;

    final jalanNegaraRows = buildTransportAreaRows(
      dopItems: dopItems,
      areaType: 'jalan_negara',
    );

    final siteRows =
    buildTransportAreaRows(
      dopItems: dopItems,
      areaType: 'site',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: dopListAsync.isLoading
            ? const Center(
              child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DOP Online Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daily Operation Plan - Transportasi Darat',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 18),
              SizedBox(
                height: 220,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _DashboardKpiSection(
                        title: 'Monitoring Approval',
                        icon: Icons.pending_actions_outlined,
                        layout: _DashboardKpiLayout.monitoring,
                        items: [
                          _DashboardKpiItem(
                            title: 'Overdue > 2 Jam',
                            value: overdueTwoHours.toString(),
                            icon: Icons.timer_outlined,
                            color: const Color(0xFFF97316),
                          ),
                          _DashboardKpiItem(
                            title: 'Overdue > 12 Jam',
                            value: overdueTwelveHours.toString(),
                            icon: Icons.warning_amber_outlined,
                            color: const Color(0xFFEF4444),
                          ),
                          _DashboardKpiItem(
                            title: 'Incomplete Status',
                            value: incompleteCount.toString(),
                            icon: Icons.assignment_late_outlined,
                            color: const Color(0xFF7C3AED),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: _AchievementSection(
                        totalDop: totalDop,
                        approvedCount: approvedCount,
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
            ],
          ),
        ),
      ),
    );
  }

  List<_TransportAreaRow> buildTransportAreaRows({
    required List<dynamic> dopItems,
    required String areaType,
  }) {
    final companyCounters =
    <String, _TransportAreaCounter>{};

    for (final item in dopItems) {
      final normalizedAreaType =
      item.areaType.trim().toLowerCase();

      if (normalizedAreaType != areaType) {
        continue;
      }

      final companyName =
      item.companyName.trim().isEmpty
          ? '-'
          : item.companyName.trim();

      final normalizedUnitType =
      item.unitType.trim().toUpperCase();

      final counter = companyCounters.putIfAbsent(
        companyName,
        createTransportAreaCounter,
      );

      if (normalizedUnitType == 'BUS') {
        counter.massal++;
      }

      if (normalizedUnitType == 'LV') {
        counter.nonMassal++;
      }
    }

    final companyNames =
    companyCounters.keys.toList();

    companyNames.sort();

    final rows = <_TransportAreaRow>[];

    for (final companyName in companyNames) {
      final counter =
      companyCounters[companyName]!;

      rows.add(
        _TransportAreaRow(
          companyName: companyName,
          massal: counter.massal,
          nonMassal: counter.nonMassal,
        ),
      );
    }

    return rows;
  }

  _TransportAreaCounter
  createTransportAreaCounter() {
    return _TransportAreaCounter();
  }
}

enum _DashboardKpiLayout {
  monitoring,
}

class _DashboardKpiSection
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DashboardKpiItem> items;
  final _DashboardKpiLayout layout;

  const _DashboardKpiSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: layout ==
                _DashboardKpiLayout.monitoring
                ? _buildMonitoringGrid()
                : _buildAchievementGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: items[0],
              ),
              _buildVerticalDivider(),
              Expanded(
                child: items[1],
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          color: Color(0xFFE2E8F0),
        ),
        Expanded(
          child: items[2],
        ),
      ],
    );
  }

  Widget _buildAchievementGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: items[0]),
              _buildVerticalDivider(),
              Expanded(child: items[1]),
            ],
          ),
        ),
        const Divider(
          height: 1,
          color: Color(0xFFE2E8F0),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: items[2]),
              _buildVerticalDivider(),
              Expanded(child: items[3]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _DashboardKpiItem
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardKpiItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementSection extends StatelessWidget {
  final int totalDop;
  final int approvedCount;
  final int revisionCount;
  final double approvalRate;
  final int pendingLayer3Count;
  final int pendingLayer4Count;
  final int revisionStatusCount;

  const _AchievementSection({
    required this.totalDop,
    required this.approvedCount,
    required this.revisionCount,
    required this.approvalRate,
    required this.pendingLayer3Count,
    required this.pendingLayer4Count,
    required this.revisionStatusCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactKpi(
                    label: 'Total DOP',
                    value: totalDop.toString(),
                    color: const Color(0xFF2563EB),
                    icon: Icons.description_outlined,
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildCompactKpi(
                    label: 'Approved',
                    value: approvedCount.toString(),
                    color: const Color(0xFF059669),
                    icon: Icons.task_alt_outlined,
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildCompactKpi(
                    label: 'Perlu Revisi',
                    value: revisionCount.toString(),
                    color: const Color(0xFFD97706),
                    icon: Icons.edit_note_outlined,
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildCompactKpi(
                    label: 'Approval Rate',
                    value:
                    '${approvalRate.toStringAsFixed(1)}%',
                    color: const Color(0xFF0891B2),
                    icon: Icons.analytics_outlined,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _AchievementStatusChart(
              approved: approvedCount,
              pendingLayer3: pendingLayer3Count,
              pendingLayer4: pendingLayer4Count,
              revision: revisionStatusCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.insights_outlined,
              color: Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Achievement',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactKpi({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9.5,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _AchievementStatusChart
    extends StatelessWidget {
  final int approved;
  final int pendingLayer3;
  final int pendingLayer4;
  final int revision;

  const _AchievementStatusChart({
    required this.approved,
    required this.pendingLayer3,
    required this.pendingLayer4,
    required this.revision,
  });

  @override
  Widget build(BuildContext context) {
    var maximumValue = approved;

    if (pendingLayer3 > maximumValue) {
      maximumValue = pendingLayer3;
    }

    if (pendingLayer4 > maximumValue) {
      maximumValue = pendingLayer4;
    }

    if (revision > maximumValue) {
      maximumValue = revision;
    }

    if (maximumValue <= 0) {
      maximumValue = 1;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        9,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary Status DOP',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                _buildBar(
                  label: 'Approved',
                  value: approved,
                  maximumValue: maximumValue,
                  color: const Color(0xFF059669),
                ),
                _buildBar(
                  label: 'Waiting Layer 3',
                  value: pendingLayer3,
                  maximumValue: maximumValue,
                  color: const Color(0xFFF59E0B),
                ),
                _buildBar(
                  label: 'Waiting Layer 4',
                  value: pendingLayer4,
                  maximumValue: maximumValue,
                  color: const Color(0xFF7C3AED),
                ),
                _buildBar(
                  label: 'Revisi',
                  value: revision,
                  maximumValue: maximumValue,
                  color: const Color(0xFFEA580C),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required int value,
    required int maximumValue,
    required Color color,
  }) {
    final ratio = value / maximumValue;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.end,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor:
                  ratio <= 0 ? 0.03 : ratio,
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportAreaCounter {
  int massal;
  int nonMassal;

  _TransportAreaCounter({
    this.massal = 0,
    this.nonMassal = 0,
  });
}

class _TransportAreaRow {
  final String companyName;
  final int massal;
  final int nonMassal;

  const _TransportAreaRow({
    required this.companyName,
    required this.massal,
    required this.nonMassal,
  });
}

class _TransportAreaTable extends StatelessWidget {
  final String title;
  final List<_TransportAreaRow> rows;

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