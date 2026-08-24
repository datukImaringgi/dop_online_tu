import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/user_session_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final companyAccessAsync = ref.watch(currentCompanyAccessProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: profileAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Text(
              'Gagal membaca profile: $error',
              style: const TextStyle(
                color: Colors.red,
              ),
            );
          },
          data: (profile) {
            if (profile == null) {
              return const Text('Profile tidak ditemukan');
            }

            return companyAccessAsync.when(
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stackTrace) {
                return Text(
                  'Gagal membaca company access: $error',
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                );
              },
              data: (companyAccess) {
                if (companyAccess == null) {
                  return const Text(
                    'User belum memiliki akses company aktif.',
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      _CurrentUserAccessCard(
                        fullName: profile.fullName,
                        sid: profile.sid ?? '-',
                        notificationEmail: profile.notificationEmail ?? '-',
                        companyName: companyAccess.companyName ?? '-',
                        companyCode: companyAccess.companyCode ?? '-',
                        role: companyAccess.role,
                        hierarchyLayer: companyAccess.hierarchyLayer,
                        position: companyAccess.position ?? '-',
                        department: companyAccess.department ?? '-',
                      ),

                      const SizedBox(height: 28),

                      const SizedBox(height: 24),

                      const Text(
                        'Monitoring Approval',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: const [
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

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(
                            child: _TransportAreaTable(
                              title: 'Area Jalan Negara',
                              rows: [
                                _TransportAreaRow(
                                  companyName: 'PT Trakindo Utama',
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
                                  companyName: 'PT Trakindo Utama',
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CurrentUserAccessCard extends StatelessWidget {
  final String fullName;
  final String sid;
  final String notificationEmail;
  final String companyName;
  final String companyCode;
  final String role;
  final int? hierarchyLayer;
  final String position;
  final String department;

  const _CurrentUserAccessCard({
    required this.fullName,
    required this.sid,
    required this.notificationEmail,
    required this.companyName,
    required this.companyCode,
    required this.role,
    required this.hierarchyLayer,
    required this.position,
    required this.department,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF0D6EFD).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF0D6EFD),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Current User Access',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AccessSection(
                    title: 'User Information',
                    children: [
                      _CompactInfoRow(
                        label: 'Nama',
                        value: fullName,
                      ),
                      _CompactInfoRow(
                        label: 'SID',
                        value: sid,
                      ),
                      _CompactInfoRow(
                        label: 'Hierarchy',
                        value: hierarchyLayer == null
                            ? '-'
                            : 'Layer $hierarchyLayer',
                      ),
                      _CompactInfoRow(
                        label: 'Email Notifikasi',
                        value: notificationEmail,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 1,
                  height: 102,
                  color: const Color(0xFFE2E8F0),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _AccessSection(
                    title: 'Access Information',
                    children: [
                      _CompactInfoRow(
                        label: 'Company',
                        value: companyName,
                      ),
                      _CompactInfoRow(
                        label: 'Company Code',
                        value: companyCode,
                      ),
                      _CompactInfoRow(
                        label: 'Role',
                        value: role,
                      ),
                      _CompactInfoRow(
                        label: 'Position',
                        value: position,
                      ),
                      _CompactInfoRow(
                        label: 'Department',
                        value: department,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AccessSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompactInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            ':',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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