import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';

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
  String dopNumberSearchQuery = '';
  final dopNumberSearchController = TextEditingController();

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

  void handleDopNumberSearchChanged(String value) {
    setState(() {
      dopNumberSearchQuery = normalizeSearchText(value);
    });
  }

  void clearDopNumberSearch() {
    dopNumberSearchController.clear();

    setState(() {
      dopNumberSearchQuery = '';
    });
  }

  String normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void dispose() {
    dopNumberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dopListAsync = ref.watch(dopListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
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

              final normalizedDopNumber = normalizeSearchText(
                  item.dopNumber,
              );

              final matchDopNumber =
              dopNumberSearchQuery.isEmpty ||
              normalizedDopNumber.contains(
                  dopNumberSearchQuery,
              );

              return matchCompany &&
                  matchSite &&
                  matchUnitType &&
                  matchStatus &&
                  matchDopNumber;
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
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Daftar Daily Operation Plan Transportasi',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                          ),
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

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 420,
                    child: TextField(
                      controller: dopNumberSearchController,
                      onChanged: handleDopNumberSearchChanged,
                      decoration: InputDecoration(
                        labelText: 'Cari No. DOP',
                        hintText: 'Contoh: 20260824-001',
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 38,
                        ),
                        suffixIcon: dopNumberSearchQuery.isEmpty
                            ? null
                            : IconButton(
                          onPressed: clearDopNumberSearch,
                          tooltip: 'Hapus pencarian',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                          ),
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 12),

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
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Site',
                value: selectedSite,
                items: siteOptions,
                onChanged: onSiteChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Type Unit',
                value: selectedUnitType,
                items: unitTypeOptions,
                onChanged: onUnitTypeChanged,
              ),
            ),
            const SizedBox(width: 10),
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
    if (status == 'pending_layer_3') {
      return 'Approval Layer 3';
    }

    if (status == 'pending_layer_4') {
      return 'Approval Layer 4';
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
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 19,
      ),
      iconSize: 19,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF94A3B8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF0D6EFD),
            width: 1.4,
          ),
        ),
      ),
      items: _buildDropdownItems(),
      onChanged: _handleChanged,
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final dropdownItems = <DropdownMenuItem<String>>[];

    for (final item in items) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: item,
          child: Text(
            formatLabel == null ? item : formatLabel!(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return dropdownItems;
  }

  void _handleChanged(String? selectedValue) {
    if (selectedValue == null) {
      return;
    }

    onChanged(selectedValue);
  }
}

class _DopDataTable extends StatefulWidget {
  final List<DopListItemModel> items;

  const _DopDataTable({
    required this.items,
  });

  @override
  State<_DopDataTable> createState() {
    return _DopDataTableState();
  }
}

class _DopDataTableState extends State<_DopDataTable> {
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      scrollController: verticalScrollController,
      horizontalScrollController: horizontalScrollController,

      fixedTopRows: 1,

      isVerticalScrollBarVisible: true,
      isHorizontalScrollBarVisible: true,

      minWidth: 4200,

      headingRowHeight: 30,
      dataRowHeight: 34,

      columnSpacing: 16,
      horizontalMargin: 12,

      dividerThickness: 0.8,

      headingRowColor: WidgetStateProperty.all(
        const Color(0xFFF8FAFC),
      ),

      headingTextStyle: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w700,
        fontSize: 11,
        height: 1.1,
      ),

      dataTextStyle: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 11,
        height: 1.15,
      ),

      columns: const [
        DataColumn2(
          label: Text('No. DOP'),
          fixedWidth: 235,
        ),
        DataColumn2(
          label: Text('Hari'),
          fixedWidth: 70,
        ),
        DataColumn2(
          label: Text('Tanggal'),
          fixedWidth: 95,
        ),
        DataColumn2(
          label: Text('Perusahaan'),
          fixedWidth: 145,
        ),
        DataColumn2(
          label: Text('Job Site'),
          fixedWidth: 145,
        ),
        DataColumn2(
          label: Text('Rencana Pekerjaan'),
          fixedWidth: 260,
        ),
        DataColumn2(
          label: Text('Jenis Unit'),
          fixedWidth: 85,
        ),
        DataColumn2(
          label: Text('No Lambung'),
          fixedWidth: 110,
        ),
        DataColumn2(
          label: Text('Mulai'),
          fixedWidth: 70,
        ),
        DataColumn2(
          label: Text('Akhir'),
          fixedWidth: 70,
        ),
        DataColumn2(
          label: Text('Nama'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('SID'),
          fixedWidth: 85,
        ),
        DataColumn2(
          label: Text('Expired SID'),
          fixedWidth: 105,
        ),
        DataColumn2(
          label: Text('Expired SIMPER'),
          fixedWidth: 120,
        ),
        DataColumn2(
          label: Text('Rute'),
          fixedWidth: 170,
        ),
        DataColumn2(
          label: Text('Observer'),
          fixedWidth: 130,
        ),
        DataColumn2(
          label: Text('Kategori Kritis'),
          fixedWidth: 115,
        ),
        DataColumn2(
          label: Text('Tingkat Risiko'),
          fixedWidth: 105,
        ),
        DataColumn2(
          label: Text('Prosedur/JSA'),
          fixedWidth: 190,
        ),
        DataColumn2(
          label: Text('Shift'),
          fixedWidth: 90,
        ),
        DataColumn2(
          label: Text('Layer 1'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('Layer 2'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('Layer 3'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('Layer 4'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('RIC'),
          fixedWidth: 150,
        ),
        DataColumn2(
          label: Text('Area'),
          fixedWidth: 125,
        ),
        DataColumn2(
          label: Text('Perusahaan Transportasi'),
          fixedWidth: 175,
        ),
        DataColumn2(
          label: Text('Status'),
          fixedWidth: 115,
        ),
        DataColumn2(
          label: Text('Dibuat Oleh'),
          fixedWidth: 145,
        ),
        DataColumn2(
          label: Text('Disetujui Oleh'),
          fixedWidth: 145,
        ),
        DataColumn2(
          label: Text('Diketahui Oleh'),
          fixedWidth: 145,
        ),
      ],

      rows: _buildRows(),
    );
  }

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (final item in widget.items) {
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
        horizontal: 8,
        vertical: 4,
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
          fontSize: 10.5,
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

    if (status == 'pending_layer_3' || status == 'pending_layer_4') {
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
    if (status == 'pending_layer_3') {
      return 'Approval Layer 3';
    }

    if (status == 'pending_layer_4') {
      return 'Approval Layer 4';
    }

    if (status == 'revision_required') {
      return 'Perlu Revisi';
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