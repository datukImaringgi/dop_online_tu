import 'package:flutter/material.dart';

import '../../domain/dop_activity_draft.dart';

class DopActivityTable extends StatelessWidget {
  final List<DopActivityDraft> drafts;
  final String? editingDraftId;
  final ValueChanged<DopActivityDraft> onEdit;
  final ValueChanged<DopActivityDraft> onDelete;
  final ValueChanged<DopActivityDraft> onDuplicate;

  const DopActivityTable({
    super.key,
    required this.drafts,
    required this.editingDraftId,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Aktivitas Kendaraan',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Review seluruh aktivitas sebelum Submit DOP.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        _DraftCountBadge(
          count: drafts.length,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (drafts.isEmpty) {
      return const _EmptyDraftState();
    }

    return _ActivityDataTable(
      drafts: drafts,
      editingDraftId: editingDraftId,
      onEdit: onEdit,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
    );
  }
}

class _DraftCountBadge extends StatelessWidget {
  final int count;

  const _DraftCountBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD).withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count Aktivitas',
        style: const TextStyle(
          color: Color(0xFF0D6EFD),
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyDraftState extends StatelessWidget {
  const _EmptyDraftState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 26,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 6),
          Text(
            'Belum ada aktivitas kendaraan',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Isi form aktivitas, lalu klik Tambah Aktivitas.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDataTable extends StatelessWidget {
  final List<DopActivityDraft> drafts;
  final String? editingDraftId;
  final ValueChanged<DopActivityDraft> onEdit;
  final ValueChanged<DopActivityDraft> onDelete;
  final ValueChanged<DopActivityDraft> onDuplicate;

  const _ActivityDataTable({
    required this.drafts,
    required this.editingDraftId,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 38,
              headingRowColor:
              WidgetStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              headingTextStyle:
              const TextStyle(
                color: Color(0xFF334155),
                fontSize: 10.5,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
              dataTextStyle:
              const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 10.5,
                height: 1.1,
              ),
              dividerThickness: 0.7,
              horizontalMargin: 8,
              columnSpacing: 14,
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Action')),
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Driver')),
                DataColumn(label: Text('Mulai')),
                DataColumn(label: Text('Akhir')),
                DataColumn(label: Text('Rute')),
                DataColumn(label: Text('Area')),
                DataColumn(label: Text('Shift')),
                DataColumn(label: Text('RIC')),
              ],
              rows: _buildRows(),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (var index = 0; index < drafts.length; index++) {
      final draft = drafts[index];
      final isEditing = draft.localId == editingDraftId;

      rows.add(
        DataRow(
          color: isEditing
              ? WidgetStateProperty.all(
            const Color(0xFFEFF6FF),
          )
              : null,
          cells: [
            DataCell(
              Text('${index + 1}'),
            ),
            DataCell(
              _DraftActionButtons(
                draft: draft,
                onEdit: onEdit,
                onDelete: onDelete,
                onDuplicate: onDuplicate,
              ),
            ),
            DataCell(
              Text(draft.unitNumber),
            ),
            DataCell(
              Text(draft.unitType),
            ),
            DataCell(
              Text(draft.driverName),
            ),
            DataCell(
              Text(draft.startTime),
            ),
            DataCell(
              Text(draft.endTime),
            ),
            DataCell(
              Text(draft.routeName),
            ),
            DataCell(
              Text(draft.areaDisplayName),
            ),
            DataCell(
              Text(draft.shift),
            ),
            DataCell(
              Text(draft.controlRoomName),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}

class _DraftActionButtons extends StatelessWidget {
  final DopActivityDraft draft;
  final ValueChanged<DopActivityDraft> onEdit;
  final ValueChanged<DopActivityDraft> onDelete;
  final ValueChanged<DopActivityDraft> onDuplicate;

  const _DraftActionButtons({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  void _handleEdit() {
    onEdit(draft);
  }

  void _handleDelete() {
    onDelete(draft);
  }

  void _handleDuplicate() {
    onDuplicate(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          tooltip: 'Edit aktivitas',
          icon: Icons.edit_outlined,
          color: const Color(0xFF0D6EFD),
          onPressed: _handleEdit,
        ),
        _buildActionButton(
          tooltip: 'Duplikat aktivitas',
          icon: Icons.copy_outlined,
          color: const Color(0xFF7C3AED),
          onPressed: _handleDuplicate,
        ),
        _buildActionButton(
          tooltip: 'Hapus aktivitas',
          icon: Icons.delete_outline,
          color: const Color(0xFFEF4444),
          onPressed: _handleDelete,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
        visualDensity: VisualDensity.compact,
        splashRadius: 14,
        icon: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}