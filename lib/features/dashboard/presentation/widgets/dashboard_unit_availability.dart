import 'package:flutter/material.dart';

class DashboardUnitAvailabilityCard
    extends StatelessWidget {
  const DashboardUnitAvailabilityCard({
    super.key,
  });

  Widget _headerCell(
      String text, {
        TextAlign textAlign = TextAlign.center,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bodyCell(
      String text, {
        TextAlign textAlign = TextAlign.center,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

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
            const Text(
              'Unit Availability',
              style: TextStyle(
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
                borderRadius:
                BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                    ),
                    children: [
                      _headerCell(
                        'Nama Perusahaan',
                        textAlign: TextAlign.left,
                      ),
                      _headerCell('Total Unit'),
                      _headerCell('Ready'),
                      _headerCell('BD'),
                      _headerCell('PM Check'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _bodyCell(
                        'Data belum tersedia',
                        textAlign: TextAlign.left,
                      ),
                      _bodyCell('-'),
                      _bodyCell('-'),
                      _bodyCell('-'),
                      _bodyCell('-'),
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