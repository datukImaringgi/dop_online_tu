import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'DOP Online Dashboard',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Daily Operation Plan - Transportasi Darat',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Monitoring Approval',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _CompactKpiCard(
                      title: 'Overdue > 2 Jam',
                      value: '0',
                      subtitle: 'Approval pending',
                      icon: Icons.timer_outlined,
                      color: Color(0xFFF97316),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _CompactKpiCard(
                      title: 'Overdue > 12 Jam',
                      value: '0',
                      subtitle: 'Approval critical',
                      icon: Icons.warning_amber_outlined,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _CompactKpiCard(
                      title: 'Incomplete Status',
                      value: '0',
                      subtitle: 'Status belum approved',
                      icon: Icons.pending_actions_outlined,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TransportAreaTable(
                      title: 'Area Jalan Negara',
                      rows: [
                        _TransportAreaRow(
                          companyName:
                          'PT Trakindo Utama',
                          massal: 0,
                          nonMassal: 0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _TransportAreaTable(
                      title: 'Area Site',
                      rows: [
                        _TransportAreaRow(
                          companyName:
                          'PT Trakindo Utama',
                          massal: 0,
                          nonMassal: 0,
                        ),
                      ],
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
}

class _CompactKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CompactKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
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
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(12),
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
                  for (final row in rows)
                    TableRow(
                      children: [
                        _TableBodyCell(text: row.companyName),
                        _TableBodyCell(text: row.massal.toString()),
                        _TableBodyCell(text: row.nonMassal.toString()),
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
        horizontal: 10,
        vertical: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 12,
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
        horizontal: 10,
        vertical: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}