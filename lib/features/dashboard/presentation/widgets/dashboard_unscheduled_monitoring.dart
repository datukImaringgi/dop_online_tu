import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class DashboardUnscheduledMonitoringCard
    extends StatelessWidget {
  final List<DashboardUnscheduledRow> rows;

  const DashboardUnscheduledMonitoringCard({
    super.key,
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
              _buildTwoColumnRows(),
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
            'Scheduled Activity KPI',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildLegend(
          label: 'Scheduled',
          color: const Color(0xFF22C55E),
        ),
        const SizedBox(width: 10),
        _buildLegend(
          label: 'Unscheduled',
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildLegend({
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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
          'Belum ada data Scheduled '
              'atau Unscheduled.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnRows() {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final bool useTwoColumns =
            constraints.maxWidth >= 800;

        if (!useTwoColumns) {
          return _buildColumn(rows);
        }

        final int middleIndex =
        (rows.length / 2).ceil();

        final List<DashboardUnscheduledRow> leftRows =
        rows.sublist(0, middleIndex);

        final List<DashboardUnscheduledRow> rightRows =
        rows.sublist(middleIndex);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildColumn(leftRows),
            ),
            const SizedBox(width: 16),
            Container(
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildColumn(rightRows),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColumn(
      List<DashboardUnscheduledRow> columnRows,
      ) {
    return Column(
      children: [
        for (
        var index = 0;
        index < columnRows.length;
        index++
        ) ...[
          DashboardUnscheduledBarRow(
            row: columnRows[index],
          ),
          if (index < columnRows.length - 1)
            const Divider(
              height: 14,
              color: Color(0xFFE2E8F0),
            ),
        ],
      ],
    );
  }
}

class DashboardUnscheduledBarRow
    extends StatelessWidget {
  final DashboardUnscheduledRow row;

  const DashboardUnscheduledBarRow({
    super.key,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Tooltip(
            message: row.companyName,
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
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Tooltip(
            message:
            '${row.scheduledPercentageText} Scheduled',
            child: Text(
              row.scheduledPercentageText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Tooltip(
            message:
            'Scheduled: '
                '${row.scheduledItems} item\n'
                'Unscheduled: '
                '${row.unscheduledItems} item\n'
                'Total: ${row.totalItems} item',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                height: 28,
                child: row.totalItems == 0
                    ? _buildEmptyBar()
                    : Row(
                  children: [
                    _buildSegment(
                      value: row.scheduledItems,
                      total: row.totalItems,
                      color: const Color(
                        0xFF22C55E,
                      ),
                      label: 'Scheduled',
                    ),
                    _buildSegment(
                      value:
                      row.unscheduledItems,
                      total: row.totalItems,
                      color: const Color(
                        0xFFEF4444,
                      ),
                      label: 'Unscheduled',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBar() {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Text(
        'Data belum tersedia',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 9.5,
        ),
      ),
    );
  }

  Widget _buildSegment({
    required int value,
    required int total,
    required Color color,
    required String label,
  }) {
    if (value == 0 || total == 0) {
      return const SizedBox.shrink();
    }

    final percentage =
        value / total * 100;

    return Expanded(
      flex: value,
      child: Tooltip(
        message:
        '$label: $value item '
            '(${_formatPercentage(percentage)})',
        child: Container(
          color: color,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
          ),
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              if (constraints.maxWidth < 22) {
                return const SizedBox.shrink();
              }

              return Text(
                value.toString(),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPercentage(
      double percentage,
      ) {
    if (percentage ==
        percentage.roundToDouble()) {
      return '${percentage.toStringAsFixed(0)}%';
    }

    return '${percentage.toStringAsFixed(1)}%';
  }
}