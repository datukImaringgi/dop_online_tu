import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/company_user_hierarchy_provider.dart';
import '../domain/company_user_hierarchy_model.dart';
import '../../../shared/providers/user_session_provider.dart';
import 'widgets/edit_user_assignment_dialog.dart';
import 'widgets/add_company_user_dialog.dart';
import '../domain/master_unit_model.dart';
import 'widgets/master_unit_dialog.dart';
import 'widgets/master_unit_section.dart';
import '../domain/operational_master_config.dart';
import 'widgets/operational_master_section.dart';
import 'widgets/company_layer_4_group_section.dart';

class MasterPage
    extends ConsumerStatefulWidget {
  const MasterPage({
    super.key,
  });

  @override
  ConsumerState<MasterPage> createState() {
    return _MasterPageState();
  }
}

class _MasterPageState
    extends ConsumerState<MasterPage> {
  int selectedMenuIndex = 0;
  String? selectedFilterCompanyId;
  int? selectedFilterHierarchyLayer;

  OperationalMasterConfig?
  getSelectedOperationalConfig() {
    if (selectedMenuIndex == 0) {
      return OperationalMasterConfig.jobSite;
    }

    if (selectedMenuIndex == 3) {
      return OperationalMasterConfig.driver;
    }

    if (selectedMenuIndex == 4) {
      return OperationalMasterConfig.busStop;
    }

    if (selectedMenuIndex == 5) {
      return OperationalMasterConfig.route;
    }

    if (selectedMenuIndex == 6) {
      return OperationalMasterConfig.jsa;
    }

    if (selectedMenuIndex == 7) {
      return OperationalMasterConfig.ric;
    }

    return null;
  }

  void handleCompanyFilterChanged(
      String? companyId,
      ) {
    setState(() {
      selectedFilterCompanyId = companyId;
    });
  }

  void handleHierarchyFilterChanged(
      int? hierarchyLayer,
      ) {
    setState(() {
      selectedFilterHierarchyLayer =
          hierarchyLayer;
    });
  }

  List<CompanyUserHierarchyModel>
  filterUsers(
      List<CompanyUserHierarchyModel> users,
      ) {
    return users.where((user) {
      final matchesCompany =
          selectedFilterCompanyId == null ||
              user.companyId ==
                  selectedFilterCompanyId;

      final matchesLayer =
          selectedFilterHierarchyLayer ==
              null ||
              user.hierarchyLayer ==
                  selectedFilterHierarchyLayer;

      return matchesCompany &&
          matchesLayer;
    }).toList();
  }

  List<DropdownMenuItem<String?>>
  buildCompanyFilterItems(
      List<CompanyUserHierarchyModel> users,
      ) {
    final companyNames = <String, String>{};

    for (final user in users) {
      companyNames[user.companyId] =
          user.companyName;
    }

    final entries = companyNames.entries.toList();

    entries.sort(
      compareCompanyEntries,
    );

    final items =
    <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Perusahaan'),
      ),
    ];

    for (final entry in entries) {
      items.add(
        DropdownMenuItem<String?>(
          value: entry.key,
          child: Text(
            entry.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  int compareCompanyEntries(
      MapEntry<String, String> first,
      MapEntry<String, String> second,
      ) {
    return first.value
        .toLowerCase()
        .compareTo(
      second.value.toLowerCase(),
    );
  }

  Widget buildCompanyFilter(
      List<CompanyUserHierarchyModel> users,
      ) {
    return SizedBox(
      width: 210,
      height: 34,
      child: DropdownButtonFormField<String?>(
        value: selectedFilterCompanyId,
        isExpanded: true,
        items: buildCompanyFilterItems(users),
        onChanged: handleCompanyFilterChanged,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Perusahaan',
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
          ),
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHierarchyFilter() {
    return SizedBox(
      width: 150,
      height: 34,
      child: DropdownButtonFormField<int?>(
        value:
        selectedFilterHierarchyLayer,
        isExpanded: true,
        items: const [
          DropdownMenuItem<int?>(
            value: null,
            child: Text('Semua Layer'),
          ),
          DropdownMenuItem<int?>(
            value: 1,
            child: Text('Layer 1'),
          ),
          DropdownMenuItem<int?>(
            value: 2,
            child: Text('Layer 2'),
          ),
          DropdownMenuItem<int?>(
            value: 3,
            child: Text('Layer 3'),
          ),
          DropdownMenuItem<int?>(
            value: 4,
            child: Text('Layer 4'),
          ),
          DropdownMenuItem<int?>(
            value: 5,
            child: Text('Layer 5'),
          ),
        ],
        onChanged:
        handleHierarchyFilterChanged,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Layer',
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF2563EB),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditUser(
      BuildContext context,
      CompanyUserHierarchyModel user,
      ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return EditUserAssignmentDialog(
          user: user,
        );
      },
    );
  }

  void _handleAddUser(
      BuildContext context,
      int? currentHierarchyLayer,
      String? currentCompanyId,
      String? currentCompanyName,
      ) {
    if (currentHierarchyLayer == null ||
        currentHierarchyLayer < 3) {
      return;
    }

    final isPlatformSuperAdmin =
        currentHierarchyLayer == 5;

    if (!isPlatformSuperAdmin &&
        (currentCompanyId == null ||
            currentCompanyId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Company admin tidak ditemukan.',
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );

      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AddCompanyUserDialog(
          actorHierarchyLayer:
          currentHierarchyLayer,
          fixedCompanyId:
          isPlatformSuperAdmin
              ? null
              : currentCompanyId,
          fixedCompanyName:
          isPlatformSuperAdmin
              ? null
              : currentCompanyName,
        );
      },
    );
  }

  void _handleAddUnit({
    required BuildContext context,
    required int? hierarchyLayer,
    required String? companyId,
    required String? companyName,
  }) {
    if (hierarchyLayer == null ||
        hierarchyLayer < 3) {
      return;
    }

    final isLayerFive =
        hierarchyLayer == 5;

    if (!isLayerFive &&
        (companyId == null ||
            companyId.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
          Color(0xFFDC2626),
          content: Text(
            'Perusahaan admin tidak ditemukan.',
          ),
        ),
      );

      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return MasterUnitDialog(
          unit: null,
          actorHierarchyLayer:
          hierarchyLayer,
          fixedCompanyId: isLayerFive
              ? null
              : companyId,
          fixedCompanyName: isLayerFive
              ? null
              : companyName,
        );
      },
    );
  }

  void _handleEditUnit({
    required BuildContext context,
    required MasterUnitModel unit,
    required int? hierarchyLayer,
    required String? companyId,
    required String? companyName,
  }) {
    if (hierarchyLayer == null ||
        hierarchyLayer < 3) {
      return;
    }

    final isLayerFive =
        hierarchyLayer == 5;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return MasterUnitDialog(
          unit: unit,
          actorHierarchyLayer:
          hierarchyLayer,
          fixedCompanyId: isLayerFive
              ? null
              : companyId,
          fixedCompanyName: isLayerFive
              ? null
              : companyName,
        );
      },
    );
  }

  Widget buildSelectedMasterContent({
    required BuildContext context,
    required AsyncValue<
        List<CompanyUserHierarchyModel>>
    usersAsync,
    required bool canRegisterUser,
    required int? hierarchyLayer,
    required String? companyId,
    required String? companyName,
  }) {
    if (selectedMenuIndex == 8) {
      if (hierarchyLayer != 5) {
        return const Center(
          child: Text(
            'Gabung Layer 4 hanya dapat '
                'dikelola oleh Layer 5.',
          ),
        );
      }

      return const CompanyLayer4GroupSection();
    }

    if (selectedMenuIndex == 1) {
      return usersAsync.when(
        loading: _buildLoading,
        error: _buildError,
        data: (
            List<CompanyUserHierarchyModel>
            users,
            ) {
          return _buildContent(
            context: context,
            users: users,
            canRegisterUser:
            canRegisterUser,
            currentHierarchyLayer:
            hierarchyLayer,
            currentCompanyId: companyId,
            currentCompanyName:
            companyName,
          );
        },
      );
    }

    if (selectedMenuIndex == 2) {
      return MasterUnitSection(
        onAdd: () {
          _handleAddUnit(
            context: context,
            hierarchyLayer:
            hierarchyLayer,
            companyId: companyId,
            companyName: companyName,
          );
        },
        onEdit: (
            MasterUnitModel unit,
            ) {
          _handleEditUnit(
            context: context,
            unit: unit,
            hierarchyLayer:
            hierarchyLayer,
            companyId: companyId,
            companyName: companyName,
          );
        },
      );
    }

    final config =
    getSelectedOperationalConfig();

    if (config == null ||
        hierarchyLayer == null ||
        hierarchyLayer < 3) {
      return const Center(
        child: Text(
          'Master Data tidak tersedia.',
        ),
      );
    }

    return OperationalMasterSection(
      config: config,
      actorHierarchyLayer:
      hierarchyLayer,
      fixedCompanyId:
      hierarchyLayer == 5
          ? null
          : companyId,
      fixedCompanyName:
      hierarchyLayer == 5
          ? null
          : companyName,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final usersAsync = ref.watch(
      companyUserHierarchyProvider,
    );
    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final companyAccessAsync = ref.watch(
      currentCompanyAccessProvider,
    );

    final companyAccess =
        companyAccessAsync.asData?.value;

    final currentHierarchyLayer =
        hierarchyAsync.asData?.value;

    final canRegisterUser =
        currentHierarchyLayer != null &&
            currentHierarchyLayer >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildMasterMenu(
              currentHierarchyLayer:
              currentHierarchyLayer,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: buildSelectedMasterContent(
                context: context,
                usersAsync: usersAsync,
                canRegisterUser: canRegisterUser,
                hierarchyLayer:
                currentHierarchyLayer,
                companyId:
                companyAccess?.companyId,
                companyName:
                companyAccess?.companyName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterMenu({
    required int? currentHierarchyLayer,
  }) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3F8),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMasterMenuButton(
                index: 0,
                label: 'Job Site Mitra',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 1,
                label: 'User & Hierarchy',
                icon: Icons.manage_accounts_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 2,
                label: 'Master Unit',
                icon: Icons.directions_bus_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 3,
                label: 'Driver',
                icon: Icons.person_pin_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 4,
                label: 'Halte',
                icon: Icons.directions_bus_filled_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 5,
                label: 'Rute',
                icon: Icons.route_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 6,
                label: 'JSA',
                icon: Icons.fact_check_outlined,
              ),
              const SizedBox(width: 4),
              _buildMasterMenuButton(
                index: 7,
                label: 'RIC',
                icon: Icons.support_agent_outlined,
              ),
              if (currentHierarchyLayer == 5) ...[
                const SizedBox(width: 4),
                _buildMasterMenuButton(
                  index: 8,
                  label: 'Gabung Layer 4',
                  icon: Icons.link_outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterMenuButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected =
        selectedMenuIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMenuIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Master Data',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 26,
            height: 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Kelola user, hierarchy, '
              'dan master operasional.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(
      Object error,
      StackTrace stackTrace,
      ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFECACA),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFDC2626),
              size: 34,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gagal membaca Master User',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required List<CompanyUserHierarchyModel>
    users,
    required bool canRegisterUser,
    required int? currentHierarchyLayer,
    required String? currentCompanyId,
    required String? currentCompanyName,
  }) {
    final isLayerFive =
        currentHierarchyLayer == 5;

    final displayedUsers = filterUsers(users);

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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
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
                    color:
                    const Color(0xFFEFF6FF),
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons
                        .manage_accounts_outlined,
                    color: Color(0xFF2563EB),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'User & Hierarchy',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                if (isLayerFive) ...[
                  buildCompanyFilter(users),
                  const SizedBox(width: 8),
                ],
                buildHierarchyFilter(),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(
                      companyUserHierarchyProvider,
                    );
                  },
                  style:
                  OutlinedButton.styleFrom(
                    minimumSize:
                    const Size(0, 34),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    textStyle:
                    const TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                      FontWeight.w600,
                    ),
                    shape:
                    RoundedRectangleBorder(
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
                if (canRegisterUser) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      _handleAddUser(
                        context,
                        currentHierarchyLayer,
                        currentCompanyId,
                        currentCompanyName,
                      );
                    },
                    style:
                    FilledButton.styleFrom(
                      minimumSize:
                      const Size(0, 34),
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 11,
                      ),
                      backgroundColor:
                      const Color(
                        0xFF2563EB,
                      ),
                      textStyle:
                      const TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w600,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons
                          .person_add_alt_1_outlined,
                      size: 16,
                    ),
                    label:
                    const Text('Tambah User'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: displayedUsers.isEmpty
                ? _buildEmptyState(
              hasActiveFilter:
              selectedFilterCompanyId !=
                  null ||
                  selectedFilterHierarchyLayer !=
                      null,
            )
                : _UserHierarchyTable(
              users: displayedUsers,
              onEdit: (
                  CompanyUserHierarchyModel user,
                  ) {
                _handleEditUser(
                  context,
                  user,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    bool hasActiveFilter = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.manage_accounts_outlined,
              size: 42,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            Text(
              hasActiveFilter
                  ? 'Data user tidak ditemukan'
                  : 'Belum ada data user',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasActiveFilter
                  ? 'Tidak ada user yang sesuai '
                  'dengan filter Perusahaan '
                  'dan Layer.'
                  : 'Klik Tambah User untuk '
                  'mendaftarkan user baru.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserHierarchyTable extends StatefulWidget {
  final List<CompanyUserHierarchyModel> users;
  final ValueChanged<CompanyUserHierarchyModel> onEdit;

  const _UserHierarchyTable({
    required this.users,
    required this.onEdit,
  });

  @override
  State<_UserHierarchyTable> createState() {
    return _UserHierarchyTableState();
  }
}

class _UserHierarchyTableState
    extends State<_UserHierarchyTable> {
  final ScrollController horizontalScrollController =
  ScrollController();

  final ScrollController verticalScrollController =
  ScrollController();

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          controller: verticalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 44,
              horizontalMargin: 14,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              headingTextStyle: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11.5,
              ),
              columns: const [
                DataColumn(
                  label: Text('Nama'),
                ),
                DataColumn(
                  label: Text('SID'),
                ),
                DataColumn(
                  label: Text('Perusahaan'),
                ),
                DataColumn(
                  label: Text('Hierarchy'),
                ),
                DataColumn(
                  label: Text('Position'),
                ),
                DataColumn(
                  label: Text('Department'),
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
              rows: _buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (final user in widget.users) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(user.fullName),
            ),
            DataCell(
              Text(user.sid),
            ),
            DataCell(
              Text(user.companyName),
            ),
            DataCell(
              _HierarchyBadge(
                layer: user.hierarchyLayer,
              ),
            ),
            DataCell(
              Text(user.position),
            ),
            DataCell(
              Text(user.department),
            ),
            DataCell(
              Text(user.jobSite),
            ),
            DataCell(
              _ActiveStatusBadge(
                isActive: user.isActive,
              ),
            ),
            DataCell(
              IconButton(
                onPressed: () {
                  widget.onEdit(user);
                },
                tooltip: 'Edit assignment',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF0D6EFD),
                  size: 19,
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

class _HierarchyBadge extends StatelessWidget {
  final int? layer;

  const _HierarchyBadge({
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    final label = layer == null
        ? 'Belum Diatur'
        : 'Layer $layer';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7C3AED),
          fontSize: 10.5,
          height: 1.1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActiveStatusBadge extends StatelessWidget {
  final bool isActive;

  const _ActiveStatusBadge({
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);

    final label = isActive
        ? 'Aktif'
        : 'Nonaktif';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          height: 1.1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}