import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class DashboardComplianceCard
    extends StatelessWidget {
  final List<DashboardComplianceRow> rows;

  const DashboardComplianceCard({
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
        borderRadius:
        BorderRadius.circular(12),
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
            buildHeader(),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              buildEmptyState()
            else
              for (var index = 0;
              index < rows.length;
              index++) ...[
                DashboardComplianceBarRow(
                  row: rows[index],
                ),
                if (index <
                    rows.length - 1)
                  const Divider(
                    height: 14,
                    color:
                    Color(0xFFE2E8F0),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
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
        buildLegend(
          label: 'Comply',
          color: const Color(0xFF22C55E),
        ),
        const SizedBox(width: 8),
        buildLegend(
          label: '> 2 Jam',
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 8),
        buildLegend(
          label: '> 12 Jam',
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget buildLegend({
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

  Widget buildEmptyState() {
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

class DashboardComplianceBarRow
    extends StatelessWidget {
  final DashboardComplianceRow row;

  const DashboardComplianceBarRow({
    super.key,
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
                  buildSegment(
                    value: row.comply,
                    total: row.total,
                    color:
                    const Color(0xFF22C55E),
                  ),
                  buildSegment(
                    value: row.overdueTwo,
                    total: row.total,
                    color:
                    const Color(0xFFF59E0B),
                  ),
                  buildSegment(
                    value:
                    row.overdueTwelve,
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

  Widget buildSegment({
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