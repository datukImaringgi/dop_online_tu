import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class DashboardTransportAreaSection
    extends StatelessWidget {
  final List<DashboardTransportAreaRow>
  jalanNegaraRows;

  final List<DashboardTransportAreaRow>
  siteRows;

  const DashboardTransportAreaSection({
    super.key,
    required this.jalanNegaraRows,
    required this.siteRows,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DashboardTransportAreaTable(
            title: 'Area Jalan Negara',
            rows: jalanNegaraRows,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardTransportAreaTable(
            title: 'Area Site',
            rows: siteRows,
          ),
        ),
      ],
    );
  }
}

class DashboardTransportAreaTable
    extends StatelessWidget {
  final String title;

  final List<DashboardTransportAreaRow>
  rows;

  const DashboardTransportAreaTable({
    super.key,
    required this.title,
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
                  color:
                  const Color(0xFFE2E8F0),
                ),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: buildRows(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> buildRows() {
    final tableRows = <TableRow>[
      const TableRow(
        decoration: BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        children: [
          DashboardTransportHeaderCell(
            text: 'Nama Perusahaan',
          ),
          DashboardTransportHeaderCell(
            text: 'Massal',
          ),
          DashboardTransportHeaderCell(
            text: 'Non-Massal',
          ),
        ],
      ),
    ];

    if (rows.isEmpty) {
      tableRows.add(
        const TableRow(
          children: [
            DashboardTransportBodyCell(
              text: 'Belum ada data',
            ),
            DashboardTransportBodyCell(
              text: '0',
            ),
            DashboardTransportBodyCell(
              text: '0',
            ),
          ],
        ),
      );

      return tableRows;
    }

    for (final row in rows) {
      tableRows.add(
        TableRow(
          children: [
            DashboardTransportBodyCell(
              text: row.companyName,
            ),
            DashboardTransportBodyCell(
              text: row.massal.toString(),
            ),
            DashboardTransportBodyCell(
              text: row.nonMassal.toString(),
            ),
          ],
        ),
      );
    }

    return tableRows;
  }
}

class DashboardTransportHeaderCell
    extends StatelessWidget {
  final String text;

  const DashboardTransportHeaderCell({
    super.key,
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

class DashboardTransportBodyCell
    extends StatelessWidget {
  final String text;

  const DashboardTransportBodyCell({
    super.key,
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