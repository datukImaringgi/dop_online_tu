import 'package:flutter/material.dart';

class DashboardMonitoringSection
    extends StatelessWidget {
  final int overdueTwoHours;
  final int overdueTwelveHours;
  final int incompleteCount;

  const DashboardMonitoringSection({
    super.key,
    required this.overdueTwoHours,
    required this.overdueTwelveHours,
    required this.incompleteCount,
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
            child: _buildMonitoringGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          _SectionIcon(),
          SizedBox(width: 8),
          Text(
            'Monitoring Approval',
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

  Widget _buildMonitoringGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _MonitoringKpiItem(
                  title: 'Overdue > 2 Jam',
                  value: overdueTwoHours.toString(),
                  icon: Icons.timer_outlined,
                  color: const Color(0xFFF97316),
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _MonitoringKpiItem(
                  title: 'Overdue > 12 Jam',
                  value:
                  overdueTwelveHours.toString(),
                  icon:
                  Icons.warning_amber_outlined,
                  color: const Color(0xFFEF4444),
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
          child: _MonitoringKpiItem(
            title: 'Incomplete Status',
            value: incompleteCount.toString(),
            icon:
            Icons.assignment_late_outlined,
            color: const Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.pending_actions_outlined,
        color: Color(0xFF2563EB),
        size: 14,
      ),
    );
  }
}

class _MonitoringKpiItem
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MonitoringKpiItem({
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
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(8),
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
                  overflow:
                  TextOverflow.ellipsis,
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

class _VerticalDivider
    extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class DashboardAchievementSection extends StatelessWidget {
  final int totalDop;
  final int approvedCount;
  final int revisionCount;
  final double approvalRate;
  final int pendingLayer3Count;
  final int pendingLayer4Count;
  final int revisionStatusCount;

  const DashboardAchievementSection({
    super.key,
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
              // ignore: deprecated_member_use
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