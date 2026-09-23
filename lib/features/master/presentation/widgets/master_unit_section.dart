import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/master_unit_provider.dart';
import '../../domain/master_unit_model.dart';

class MasterUnitSection
    extends ConsumerStatefulWidget {
  final VoidCallback onAdd;
  final ValueChanged<MasterUnitModel> onEdit;

  const MasterUnitSection({
    super.key,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  ConsumerState<MasterUnitSection>
  createState() {
    return _MasterUnitSectionState();
  }
}

class _MasterUnitSectionState
    extends ConsumerState<
        MasterUnitSection> {
  final unitNumberController =
  TextEditingController();

  String? selectedCompanyId;
  String unitNumberQuery = '';

  @override
  void dispose() {
    unitNumberController.dispose();
    super.dispose();
  }

  void handleRefresh(WidgetRef ref) {
    ref.invalidate(masterUnitsProvider);
  }

  Future<void> handleStatusChanged({
    required BuildContext context,
    required WidgetRef ref,
    required MasterUnitModel unit,
    required bool isActive,
  }) async {
    try {
      final repository = ref.read(
        masterUnitRepositoryProvider,
      );

      final result =
      await repository.updateUnitStatus(
        unitId: unit.id,
        isActive: isActive,
      );

      ref.invalidate(masterUnitsProvider);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
          result.isPendingApproval
              ? const Color(0xFFD97706)
              : const Color(0xFF059669),
          content: Text(result.message),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
          const Color(0xFFDC2626),
          content: Text(
            'Gagal mengubah status unit: $error',
          ),
        ),
      );
    }
  }

  Map<String, String> buildCompanyOptions(
      List<MasterUnitModel> units,
      ) {
    final options = <String, String>{};

    for (final unit in units) {
      final companyId =
      unit.companyId.trim();

      final companyName =
      unit.companyName.trim();

      if (companyId.isEmpty ||
          companyName.isEmpty ||
          companyName == '-') {
        continue;
      }

      options[companyId] = companyName;
    }

    return options;
  }

  List<MasterUnitModel> filterUnits(
      List<MasterUnitModel> units,
      ) {
    final normalizedQuery =
    unitNumberQuery.trim().toLowerCase();

    return units.where((unit) {
      final matchesCompany =
          selectedCompanyId == null ||
              unit.companyId ==
                  selectedCompanyId;

      final matchesUnitNumber =
          normalizedQuery.isEmpty ||
              unit.unitNumber
                  .toLowerCase()
                  .contains(normalizedQuery);

      return matchesCompany &&
          matchesUnitNumber;
    }).toList();
  }

  void handleCompanyChanged(
      String? companyId,
      ) {
    setState(() {
      selectedCompanyId = companyId;
    });
  }

  void handleUnitNumberChanged(
      String value,
      ) {
    setState(() {
      unitNumberQuery =
          value.trim().toLowerCase();
    });
  }

  void clearUnitNumberSearch() {
    unitNumberController.clear();

    setState(() {
      unitNumberQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(
      masterUnitsProvider,
    );

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
          _buildHeader(
            ref,
            unitsAsync.value ??
                <MasterUnitModel>[],
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: unitsAsync.when(
              loading: buildLoading,
              error: buildError,
                data: (units) {
                  final filteredUnits =
                  filterUnits(units);

                  return Column(
                    children: [
                      Expanded(
                        child: units.isEmpty
                            ? buildContent(
                          context: context,
                          ref: ref,
                          units: units,
                        )
                            : filteredUnits.isEmpty
                            ? const Center(
                          child: Text(
                            'Tidak ada unit yang '
                                'sesuai dengan filter.',
                            style: TextStyle(
                              color:
                              Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        )
                            : buildContent(
                          context: context,
                          ref: ref,
                          units: filteredUnits,
                        ),
                      ),
                    ],
                  );
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      WidgetRef ref,
      List<MasterUnitModel> units,
      ) {
    final companyOptions =
    buildCompanyOptions(units);

    final companyIds =
    companyOptions.keys.toList();

    companyIds.sort((first, second) {
      return (companyOptions[first] ?? '')
          .compareTo(
        companyOptions[second] ?? '',
      );
    });

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
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              color: Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Master Unit',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 210,
            child:
            DropdownButtonFormField<String?>(
              value: selectedCompanyId,
              isExpanded: true,
              decoration:
              buildFilterDecoration(
                label: 'Perusahaan',
                icon:
                Icons.business_outlined,
              ),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Semua Perusahaan',
                  ),
                ),
                for (
                final companyId
                in companyIds
                )
                  DropdownMenuItem<String?>(
                    value: companyId,
                    child: Text(
                      companyOptions[
                      companyId] ??
                          '-',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged:
              handleCompanyChanged,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 190,
            child: TextField(
              controller:
              unitNumberController,
              onChanged:
              handleUnitNumberChanged,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11.5,
              ),
              decoration:
              buildFilterDecoration(
                label: 'Nomor Unit',
                icon: Icons.search,
              ).copyWith(
                hintText: 'Cari unit',
                suffixIcon:
                unitNumberQuery.isEmpty
                    ? null
                    : IconButton(
                  onPressed:
                  clearUnitNumberSearch,
                  tooltip:
                  'Hapus pencarian',
                  visualDensity:
                  VisualDensity.compact,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              handleRefresh(ref);
            },
            style: OutlinedButton.styleFrom(
              minimumSize:
              const Size(0, 34),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.refresh,
              size: 16,
            ),
            label: const Text('Refresh'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: widget.onAdd,
            style: FilledButton.styleFrom(
              minimumSize:
              const Size(0, 34),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 11,
              ),
              backgroundColor:
              const Color(0xFF2563EB),
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.add,
              size: 16,
            ),
            label:
            const Text('Tambah Unit'),
          ),
        ],
      ),
    );
  }

  InputDecoration buildFilterDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        icon,
        size: 17,
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.3,
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError(
      Object error,
      StackTrace stackTrace,
      ) {
    return Center(
      child: Text(
        'Gagal membaca Master Unit: $error',
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required List<MasterUnitModel> units,
  }) {
    if (units.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data unit.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 42,
          horizontalMargin: 12,
          columnSpacing: 18,
          headingRowColor:
          WidgetStateProperty.all(
            const Color(0xFFF8FAFC),
          ),
          headingTextStyle: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 10.5,
          ),
          columns: const [
            DataColumn(
              label: Text('Nomor Unit'),
            ),
            DataColumn(
              label: Text('Kategori'),
            ),
            DataColumn(
              label: Text('Perusahaan'),
            ),
            DataColumn(
              label: Text('Job Site'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Action'),
            ),
          ],
          rows: buildRows(
            context: context,
            ref: ref,
            units: units,
          ),
        ),
      ),
    );
  }

  List<DataRow> buildRows({
    required BuildContext context,
    required WidgetRef ref,
    required List<MasterUnitModel> units,
  }) {
    final rows = <DataRow>[];

    for (final unit in units) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(unit.unitNumber),
            ),
            DataCell(
              _UnitCategoryBadge(
                label: unit.categoryLabel,
                unitType: unit.unitType,
              ),
            ),
            DataCell(
              Text(unit.companyName),
            ),
            DataCell(
              Text(unit.jobSiteName),
            ),
            DataCell(
              _UnitStatusSwitch(
                unit: unit,
                onChanged: (bool value) {
                  handleStatusChanged(
                    context: context,
                    ref: ref,
                    unit: unit,
                    isActive: value,
                  );
                },
              ),
            ),
            DataCell(
              IconButton(
                onPressed: () {
                  widget.onEdit(unit);
                },
                tooltip: 'Edit unit',
                visualDensity:
                VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF2563EB),
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}

class _UnitCategoryBadge
    extends StatelessWidget {
  final String label;
  final String unitType;

  const _UnitCategoryBadge({
    required this.label,
    required this.unitType,
  });

  @override
  Widget build(BuildContext context) {
    final isMassal =
        unitType.trim().toUpperCase() == 'BUS';

    final color = isMassal
        ? const Color(0xFF2563EB)
        : const Color(0xFF7C3AED);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UnitStatusSwitch
    extends StatelessWidget {
  final MasterUnitModel unit;
  final ValueChanged<bool> onChanged;

  const _UnitStatusSwitch({
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: unit.isActive,
          onChanged: onChanged,
        ),
        Text(
          unit.statusLabel,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}