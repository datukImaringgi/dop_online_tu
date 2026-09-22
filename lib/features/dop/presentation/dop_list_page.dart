import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';

import '../data/dop_list_provider.dart';
import '../domain/dop_list_item_model.dart';
import 'widgets/dop_list_filter_bar.dart';
import '../data/dop_pdf_repository.dart';

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
  String selectedUnitNumber = 'Semua';
  String selectedAreaType = 'Semua';
  String selectedShift = 'Semua';
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

            final unitNumberOptions = _buildOptions(
              items.map((item) {
                return item.unitNumber;
              }).toList(),
            );

            final areaTypeOptions = _buildOptions(
              items.map((item) {
                return item.areaType;
              }).toList(),
            );

            final shiftOptions = _buildOptions(
              items.map((item) {
                return item.shift;
              }).toList(),
            );

            final statusOptions = _buildOptions(
              items.map((item) => item.status).toList(),
            );

            final filteredItems = items.where((item) {
              final matchUnitNumber =
                  selectedUnitNumber == 'Semua' ||
                      item.unitNumber == selectedUnitNumber;

              final matchAreaType =
                  selectedAreaType == 'Semua' ||
                      item.areaType == selectedAreaType;

              final matchShift =
                  selectedShift == 'Semua' ||
                      item.shift == selectedShift;

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
                  matchUnitNumber &&
                  matchAreaType &&
                  matchShift &&
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
                              fontSize: 24,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Daftar Daily Operation Plan Transportasi',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              height: 1.2,
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: SizedBox(
                      width: 250,
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
                            size: 16,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 34,
                            minHeight: 34,
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
                            horizontal: 10,
                            vertical: 7,
                          ),
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            maxHeight: 44,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                DopListFilterBar(
                  companyOptions: companyOptions,
                  siteOptions: siteOptions,
                  unitTypeOptions: unitTypeOptions,
                  unitNumberOptions: unitNumberOptions,
                  areaTypeOptions: areaTypeOptions,
                  shiftOptions: shiftOptions,
                  statusOptions: statusOptions,

                  selectedCompany: selectedCompany,
                  selectedSite: selectedSite,
                  selectedUnitType: selectedUnitType,
                  selectedUnitNumber: selectedUnitNumber,
                  selectedAreaType: selectedAreaType,
                  selectedShift: selectedShift,
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
                  onUnitNumberChanged: (value) {
                    setState(() {
                      selectedUnitNumber = value;
                    });
                  },
                  onAreaTypeChanged: (value) {
                    setState(() {
                      selectedAreaType = value;
                    });
                  },
                  onShiftChanged: (value) {
                    setState(() {
                      selectedShift = value;
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
                    ): _DopDataTable(
                      items: filteredItems,
                      onContinueDraft: (
                          DopListItemModel item,
                          ) {
                        context.go(
                          '/dop-request',
                          extra: {
                            'draftDopHeaderId':
                            item.dopHeaderId,
                          },
                        );
                      },
                      onDownloadPdf: (
                          DopListItemModel item,
                          ) async {
                        final activities =
                        items.where((row) {
                          return row.dopHeaderId ==
                              item.dopHeaderId;
                        }).toList();
                        try {
                          await ref
                              .read(
                            dopPdfRepositoryProvider,
                          )
                              .downloadDopPdf(
                            headerItem: item,
                            activities: activities,
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                error
                                    .toString()
                                    .replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
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

class _DopDataTable extends StatefulWidget {
  final List<DopListItemModel> items;
  final ValueChanged<DopListItemModel> onContinueDraft;
  final ValueChanged<DopListItemModel> onDownloadPdf;

  const _DopDataTable({
    required this.items,
    required this.onContinueDraft,
    required this.onDownloadPdf,
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

  Widget _singleLineText(String value) {
    return Tooltip(
      message: value,
      child: Text(
        value,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
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
          label: Text('Action'),
          fixedWidth: 48,
        ),
        DataColumn2(
          label: Text('Status'),
          fixedWidth: 80,
        ),
        DataColumn2(
          label: Text('No. DOP'),
          fixedWidth: 120,
        ),
        DataColumn2(
          label: Text('Hari'),
          fixedWidth: 60,
        ),
        DataColumn2(
          label: Text('Tanggal'),
          fixedWidth: 80,
        ),
        DataColumn2(
          label: Text('Perusahaan'),
          fixedWidth: 130,
        ),
        DataColumn2(
          label: Text('Job Site'),
          fixedWidth: 100,
        ),
        DataColumn2(
          label: Text('Rencana Pekerjaan'),
          fixedWidth: 200,
        ),
        DataColumn2(
          label: Text('No Lambung'),
          fixedWidth: 110,
        ),
        DataColumn2(
          label: Text('Mulai'),
          fixedWidth: 50,
        ),
        DataColumn2(
          label: Text('Akhir'),
          fixedWidth: 50,
        ),
        DataColumn2(
          label: Text('Nama'),
          fixedWidth: 100,
        ),
        DataColumn2(
          label: Text('SID'),
          fixedWidth: 60,
        ),
        DataColumn2(
          label: Text('Expired SID'),
          fixedWidth: 100,
        ),
        DataColumn2(
          label: Text('Expired SIMPER'),
          fixedWidth: 100,
        ),
        DataColumn2(
          label: Text('Rute'),
          fixedWidth: 100,
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
            DataCell(
              PopupMenuButton<String>(
                tooltip: 'Action DOP',
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF475569),
                ),
                onSelected: (String action) {
                  if (action == 'continue') {
                    widget.onContinueDraft(item);
                    return;
                  }

                  if (action == 'reference') {
                    context.go(
                      '/dop-request',
                      extra: {
                        'referenceDopHeaderId':
                        item.dopHeaderId,
                      },
                    );
                    return;
                  }

                  if (action == 'pdf') {
                    widget.onDownloadPdf(item);
                  }
                },
                itemBuilder: (context) {
                  if (item.status == 'draft') {
                    return const [
                      PopupMenuItem<String>(
                        value: 'continue',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 17,
                              color: Color(0xFF2563EB),
                            ),
                            SizedBox(width: 9),
                            Text('Lanjutkan Draft'),
                          ],
                        ),
                      ),
                    ];
                  }

                  return const [
                    PopupMenuItem<String>(
                      value: 'reference',
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy_all_outlined,
                            size: 17,
                            color: Color(0xFF7C3AED),
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Buat dari Referensi',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 17,
                            color: Color(0xFFDC2626),
                          ),
                          SizedBox(width: 9),
                          Text('Download PDF'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ),
            DataCell(
              _StatusBadge(
                status: item.status,
              ),
            ),
            DataCell(_singleLineText(item.dopNumber)),
            DataCell(_singleLineText(item.dayName)),
            DataCell(_singleLineText(item.dopDate)),
            DataCell(_singleLineText(item.companyName)),
            DataCell(_singleLineText(item.jobSite)),
            DataCell(_singleLineText(item.workPlan)),
            DataCell(_singleLineText(item.unitNumber)),
            DataCell(_singleLineText(
              _formatTime(item.startTime),
            )),
            DataCell(_singleLineText(
              _formatTime(item.endTime),
            )),
            DataCell(_singleLineText(item.driverName)),
            DataCell(_singleLineText(item.sid)),
            DataCell(_singleLineText(item.sidExpiredDate)),
            DataCell(_singleLineText(
              item.simperExpiredDate,
            )),
            DataCell(_singleLineText(item.route)),
            DataCell(_singleLineText(item.observer)),
            DataCell(_singleLineText(
              item.isCritical ? 'Kritis' : 'Tidak',
            )),
            DataCell(_singleLineText(item.riskLevel)),

            // Khusus Prosedur/JSA boleh wrap.
            DataCell(
              Text(item.jsaProcedure),
            ),

            DataCell(_singleLineText(item.shift)),
            DataCell(_singleLineText(item.layer1)),
            DataCell(_singleLineText(item.layer2)),
            DataCell(_singleLineText(item.layer3)),
            DataCell(_singleLineText(item.layer4)),
            DataCell(_singleLineText(item.controlRoom)),
            DataCell(_singleLineText(
              _formatArea(item.areaType),
            )),
            DataCell(_singleLineText(
              item.transportCompany,
            )),
            DataCell(_singleLineText(item.createdByName)),
            DataCell(_singleLineText(
              item.approvedByName,
            )),
            DataCell(_singleLineText(item.knownByName)),
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    if (status == 'draft') {
      return const Color(0xFFD97706);
    }

    if (status == 'approved') {
      return const Color(0xFF10B981);
    }

    if (status == 'rejected') {
      return const Color(0xFFEF4444);
    }

    if (status == 'pending_layer_3') {
      return const Color(0xFF470570);
    }

    if (status == 'pending_layer_4') {
      return const Color(0xFF64748B);
    }

    if (status == 'revision_required') {
      return const Color(0xFFF59E0B);
    }

    if (status == 'submitted') {
      return const Color(0xFF0D6EFD);
    }

    if (status == 'cancelled') {
      return const Color(0xFFEF4444);
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