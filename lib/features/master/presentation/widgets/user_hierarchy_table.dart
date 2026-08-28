import 'package:flutter/material.dart';

import '../../domain/company_user_hierarchy_model.dart';

class UserHierarchyTable extends StatefulWidget {
  final List<CompanyUserHierarchyModel> users;
  final ValueChanged<CompanyUserHierarchyModel> onEdit;

  const UserHierarchyTable({
    super.key,
    required this.users,
    required this.onEdit,
  });

  @override
  State<UserHierarchyTable> createState() {
    return _UserHierarchyTableState();
  }
}

class _UserHierarchyTableState
    extends State<UserHierarchyTable> {
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

  void handleEdit(
      CompanyUserHierarchyModel user,
      ) {
    widget.onEdit(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      scrollbarOrientation:
      ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          controller: verticalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation:
          ScrollbarOrientation.right,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 44,
              horizontalMargin: 14,
              columnSpacing: 24,
              headingRowColor:
              WidgetStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              headingTextStyle:
              const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle:
              const TextStyle(
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
              rows: buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> buildRows() {
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
              UserHierarchyBadge(
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
              UserActiveStatusBadge(
                isActive: user.isActive,
              ),
            ),
            DataCell(
              _UserEditButton(
                user: user,
                onEdit: handleEdit,
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}

class _UserEditButton extends StatelessWidget {
  final CompanyUserHierarchyModel user;

  final ValueChanged<CompanyUserHierarchyModel>
  onEdit;

  const _UserEditButton({
    required this.user,
    required this.onEdit,
  });

  void handlePressed() {
    onEdit(user);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: handlePressed,
      tooltip: 'Edit assignment',
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.edit_outlined,
        color: Color(0xFF0D6EFD),
        size: 19,
      ),
    );
  }
}

class UserHierarchyBadge extends StatelessWidget {
  final int? layer;

  const UserHierarchyBadge({
    super.key,
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

class UserActiveStatusBadge
    extends StatelessWidget {
  final bool isActive;

  const UserActiveStatusBadge({
    super.key,
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