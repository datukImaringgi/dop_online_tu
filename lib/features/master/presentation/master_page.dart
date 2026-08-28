import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/company_user_hierarchy_provider.dart';
import '../domain/company_user_hierarchy_model.dart';
import '../../../shared/providers/user_session_provider.dart';
import 'widgets/edit_user_assignment_dialog.dart';
import 'widgets/add_company_user_dialog.dart';

class MasterPage extends ConsumerWidget {
  const MasterPage({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildHeader(
              context,
              ref,
              canRegisterUser,
              currentHierarchyLayer,
              companyAccess?.companyId,
              companyAccess?.companyName,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: usersAsync.when(
                loading: _buildLoading,
                error: _buildError,
                data: (users) {
                  return _buildContent(
                    context,
                    users,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      WidgetRef ref,
      bool canRegisterUser,
      int? currentHierarchyLayer,
      String? currentCompanyId,
      String? currentCompanyName,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Kelola user, hierarchy, dan master operasional.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (canRegisterUser) ...[
          ElevatedButton.icon(
            onPressed: () {
              _handleAddUser(
                context,
                currentHierarchyLayer,
                currentCompanyId,
                currentCompanyName,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(
              Icons.person_add_alt_1_outlined,
              size: 18,
            ),
            label: const Text('Tambah User'),
          ),
          const SizedBox(width: 10),
        ],
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(
              companyUserHierarchyProvider,
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(
            Icons.refresh,
            size: 18,
          ),
          label: const Text('Refresh'),
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

  Widget _buildContent(
      BuildContext context,
      List<CompanyUserHierarchyModel> users,
      ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.manage_accounts_outlined,
                  color: Color(0xFF0D6EFD),
                  size: 21,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'User & Hierarchy',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: users.isEmpty
                ? _buildEmptyState()
                : _UserHierarchyTable(
              users: users,
              onEdit: (user) {
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

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_accounts_outlined,
              size: 42,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 10),
            Text(
              'Belum ada data user',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tambahkan akun testing melalui Supabase Dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
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