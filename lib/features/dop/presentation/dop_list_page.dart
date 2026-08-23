import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dop_list_provider.dart';
import '../domain/dop_list_item_model.dart';

class DopListPage extends ConsumerStatefulWidget {
  const DopListPage({super.key});

  @override
  ConsumerState<DopListPage> createState() {
    return _DopListPageState();
  }
}

class _DopListPageState extends ConsumerState<DopListPage> {
  String selectedCompany = 'Semua';
  String selectedSite = 'Semua';
  String selectedUnitType = 'Semua';
  String selectedStatus = 'Semua';

  List<String> _buildOptions(List<String> values) {
    final set = <String>{};

    for (final value in values) {
      if (value.trim().isNotEmpty && value != '-') {
        set.add(value);
      }
    }

    final result = set.toList();
    result.sort();

    return ['Semua', ...result];
  }

  @override
  Widget build(BuildContext context) {
    final dopListAsync = ref.watch(dopListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: dopListAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Text(
              'Gagal membaca data DOP: $error',
              style: const TextStyle(color: Colors.red),
            );
          },
          data: (items) {
            final companyOptions = _buildOptions(
              items.map((item) => item.companyName).toList(),
            );

            final siteOptions = _buildOptions(
              items.map((item) => item.jobSite).toList(),
            );

            final unitTypeOptions = _buildOptions(
              items.map((item) => item.unitType).toList(),
            );

            final statusOptions = _buildOptions(
              items.map((item) => item.status).toList(),
            );

            final filteredItems = items.where((item) {
              final matchCompany = selectedCompany == 'Semua' ||
                  item.companyName == selectedCompany;

              final matchSite = selectedSite == 'Semua' ||
                  item.jobSite == selectedSite;

              final matchUnitType = selectedUnitType == 'Semua' ||
                  item.unitType == selectedUnitType;

              final matchStatus = selectedStatus == 'Semua' ||
                  item.status == selectedStatus;

              return matchCompany && matchSite && matchUnitType && matchStatus;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOP List',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Daftar Daily Operation Plan Transportasi',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            context.go('/dop-request');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Request Form'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.invalidate(dopListProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _FilterBar(
                  companyOptions: companyOptions,
                  siteOptions: siteOptions,
                  unitTypeOptions: unitTypeOptions,
                  statusOptions: statusOptions,
                  selectedCompany: selectedCompany,
                  selectedSite: selectedSite,
                  selectedUnitType: selectedUnitType,
                  selectedStatus: selectedStatus,
                  onCompanyChanged: (value) {
                    setState(() {
                      selectedCompany = value;
                    });
                  },
                  onSiteChanged: (value) {
                    setState(() {
                      selectedSite = value;
                    });
                  },
                  onUnitTypeChanged: (value) {
                    setState(() {
                      selectedUnitType = value;
                    });
                  },
                  onStatusChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    child: items.isEmpty
                        ? const Center(
                      child: Text(
                        'Belum ada data DOP.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                : filteredItems.isEmpty
                      ? const Center(
                      child: Text(
                        'Tidak ada data sesuai filter.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ): _DopDataTable(items: filteredItems),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> companyOptions;
  final List<String> siteOptions;
  final List<String> unitTypeOptions;
  final List<String> statusOptions;

  final String selectedCompany;
  final String selectedSite;
  final String selectedUnitType;
  final String selectedStatus;

  final ValueChanged<String> onCompanyChanged;
  final ValueChanged<String> onSiteChanged;
  final ValueChanged<String> onUnitTypeChanged;
  final ValueChanged<String> onStatusChanged;

  const _FilterBar({
    required this.companyOptions,
    required this.siteOptions,
    required this.unitTypeOptions,
    required this.statusOptions,
    required this.selectedCompany,
    required this.selectedSite,
    required this.selectedUnitType,
    required this.selectedStatus,
    required this.onCompanyChanged,
    required this.onSiteChanged,
    required this.onUnitTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Perusahaan',
                value: selectedCompany,
                items: companyOptions,
                onChanged: onCompanyChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Site',
                value: selectedSite,
                items: siteOptions,
                onChanged: onSiteChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Type Unit',
                value: selectedUnitType,
                items: unitTypeOptions,
                onChanged: onUnitTypeChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Status Approval',
                value: selectedStatus,
                items: statusOptions,
                onChanged: onStatusChanged,
                formatLabel: _formatStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatStatus(String status) {
    if (status == 'pending_safety') {
      return 'Pending Safety';
    }

    if (status == 'pending_pjo') {
      return 'Pending PJO';
    }

    if (status == 'approved') {
      return 'Approved';
    }

    if (status == 'rejected') {
      return 'Rejected';
    }

    if (status == 'submitted') {
      return 'Submitted';
    }

    if (status == 'cancelled') {
      return 'Cancelled';
    }

    if (status == 'draft') {
      return 'Draft';
    }

    return status;
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String Function(String value)? formatLabel;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.formatLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            formatLabel == null ? item : formatLabel!(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        onChanged(value);
      },
    );
  }
}

class _DopDataTable extends StatelessWidget {
  final List<DopListItemModel> items;

  const _DopDataTable({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFFF8FAFC),
            ),
            headingTextStyle: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            dataTextStyle: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
            ),
            columnSpacing: 22,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('No. DOP')),
              DataColumn(label: Text('Hari')),
              DataColumn(label: Text('Tanggal')),
              DataColumn(label: Text('Perusahaan')),
              DataColumn(label: Text('Job Site')),
              DataColumn(label: Text('Rencana Pekerjaan')),
              DataColumn(label: Text('Jenis Unit')),
              DataColumn(label: Text('No Lambung')),
              DataColumn(label: Text('Mulai')),
              DataColumn(label: Text('Akhir')),
              DataColumn(label: Text('Nama')),
              DataColumn(label: Text('SID')),
              DataColumn(label: Text('Expired SID')),
              DataColumn(label: Text('Expired SIMPER')),
              DataColumn(label: Text('Rute')),
              DataColumn(label: Text('Observer')),
              DataColumn(label: Text('Kategori Kritis')),
              DataColumn(label: Text('Tingkat Risiko')),
              DataColumn(label: Text('Prosedur/JSA')),
              DataColumn(label: Text('Shift')),
              DataColumn(label: Text('Layer 1')),
              DataColumn(label: Text('Layer 2')),
              DataColumn(label: Text('Layer 3')),
              DataColumn(label: Text('Layer 4')),
              DataColumn(label: Text('RIC')),
              DataColumn(label: Text('Area')),
              DataColumn(label: Text('Perusahaan')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Dibuat Oleh')),
              DataColumn(label: Text('Disetujui Oleh')),
              DataColumn(label: Text('Diketahui Oleh')),
            ],
            rows: _buildRows(),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (final item in items) {
      rows.add(
        DataRow(
          cells: [
            DataCell(SelectableText(item.dopNumber)),
            DataCell(Text(item.dayName)),
            DataCell(Text(item.dopDate)),
            DataCell(Text(item.companyName)),
            DataCell(Text(item.jobSite)),
            DataCell(Text(item.workPlan)),
            DataCell(Text(item.unitType)),
            DataCell(Text(item.unitNumber)),
            DataCell(Text(_formatTime(item.startTime))),
            DataCell(Text(_formatTime(item.endTime))),
            DataCell(Text(item.driverName)),
            DataCell(Text(item.sid)),
            DataCell(Text(item.sidExpiredDate)),
            DataCell(Text(item.simperExpiredDate)),
            DataCell(Text(item.route)),
            DataCell(Text(item.observer)),
            DataCell(Text(item.isCritical ? 'Kritis' : 'Tidak')),
            DataCell(Text(item.riskLevel)),
            DataCell(Text(item.jsaProcedure)),
            DataCell(Text(item.shift)),
            DataCell(Text(item.layer1)),
            DataCell(Text(item.layer2)),
            DataCell(Text(item.layer3)),
            DataCell(Text(item.layer4)),
            DataCell(Text(item.controlRoom)),
            DataCell(Text(_formatArea(item.areaType))),
            DataCell(Text(item.transportCompany)),
            DataCell(_StatusBadge(status: item.status)),
            DataCell(Text(item.createdByName)),
            DataCell(Text(item.approvedByName)),
            DataCell(Text(item.knownByName)),
          ],
        ),
      );
    }

    return rows;
  }

  String _formatArea(String areaType) {
    if (areaType == 'jalan_negara') {
      return 'Area Jalan Negara';
    }

    if (areaType == 'site') {
      return 'Area Site';
    }

    if (areaType == '-') {
      return '-';
    }

    return areaType;
  }

  String _formatTime(String value) {
    if (value == '-') {
      return '-';
    }

    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getColor(status);
    final text = _formatStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    if (status == 'approved') {
      return const Color(0xFF10B981);
    }

    if (status == 'rejected') {
      return const Color(0xFFEF4444);
    }

    if (status == 'pending_safety' || status == 'pending_pjo') {
      return const Color(0xFFF59E0B);
    }

    if (status == 'submitted') {
      return const Color(0xFF0D6EFD);
    }

    if (status == 'cancelled') {
      return const Color(0xFF64748B);
    }

    return const Color(0xFF64748B);
  }

  String _formatStatus(String status) {
    if (status == 'pending_safety') {
      return 'Pending Safety';
    }

    if (status == 'pending_pjo') {
      return 'Pending PJO';
    }

    if (status == 'approved') {
      return 'Approved';
    }

    if (status == 'rejected') {
      return 'Rejected';
    }

    if (status == 'submitted') {
      return 'Submitted';
    }

    if (status == 'cancelled') {
      return 'Cancelled';
    }

    if (status == 'draft') {
      return 'Draft';
    }

    return status;
  }
}