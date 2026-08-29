import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/user_session_provider.dart';
import '../data/dop_approval_provider.dart';
import '../domain/dop_approval_list_item.dart';

class ApprovalPage extends ConsumerWidget {
  const ApprovalPage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final approvalsAsync = ref.watch(
      dopApprovalListProvider,
    );

    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final hierarchyLayer =
        hierarchyAsync.asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            buildHeader(
              ref,
              hierarchyLayer,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: approvalsAsync.when(
                loading: buildLoading,
                error: buildError,
                data: (
                    List<DopApprovalListItem> items,
                    ) {
                  return buildContent(
                    context,
                    items,
                    hierarchyLayer,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(
      WidgetRef ref,
      int? hierarchyLayer,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                buildPageTitle(
                  hierarchyLayer,
                ),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                buildPageSubtitle(
                  hierarchyLayer,
                ),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(
              dopApprovalListProvider,
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding:
            const EdgeInsets.symmetric(
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

  String buildPageTitle(
      int? hierarchyLayer,
      ) {
    if (hierarchyLayer == 3) {
      return 'Approval Layer 3';
    }

    if (hierarchyLayer == 4) {
      return 'Approval Layer 4';
    }

    if (hierarchyLayer == 5) {
      return 'Monitoring Approval';
    }

    return 'Approval DOP';
  }

  String buildPageSubtitle(
      int? hierarchyLayer,
      ) {
    if (hierarchyLayer == 3) {
      return 'Review DOP yang menunggu '
          'persetujuan Layer 3.';
    }

    if (hierarchyLayer == 4) {
      return 'Review DOP yang telah disetujui '
          'Layer 3 dan menunggu Layer 4.';
    }

    if (hierarchyLayer == 5) {
      return 'Monitoring approval seluruh '
          'perusahaan pada platform.';
    }

    return 'Daftar dokumen DOP yang '
        'memerlukan persetujuan.';
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
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 560,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius:
          BorderRadius.circular(12),
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
              'Gagal membaca daftar approval',
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

  Widget buildContent(
      BuildContext context,
      List<DopApprovalListItem> items,
      int? hierarchyLayer,
      ) {
    if (hierarchyLayer == null ||
        hierarchyLayer < 3) {
      return buildNoAccessState();
    }

    if (items.isEmpty) {
      return buildEmptyState(
        hierarchyLayer,
      );
    }

    return ApprovalDocumentTable(
      items: items,
      onReview: (
          DopApprovalListItem item,
          ) {
        handleReview(
          context,
          item,
        );
      },
    );
  }

  Widget buildNoAccessState() {
    return const _ApprovalStateCard(
      icon: Icons.lock_outline,
      title: 'Akses approval tidak tersedia',
      subtitle:
      'Approval hanya tersedia untuk '
          'Layer 3 dan Layer 4.',
    );
  }

  Widget buildEmptyState(
      int? hierarchyLayer,
      ) {
    String subtitle;

    if (hierarchyLayer == 5) {
      subtitle =
      'Tidak ada approval pending '
          'dari seluruh perusahaan.';
    } else {
      subtitle =
      'Tidak ada DOP yang menunggu '
          'persetujuan Anda.';
    }

    return _ApprovalStateCard(
      icon: Icons.task_alt_outlined,
      title: 'Tidak ada approval pending',
      subtitle: subtitle,
    );
  }

  void handleReview(
      BuildContext context,
      DopApprovalListItem item,
      ) {
    context.go(
      '/approval/review',
      extra: item,
    );
  }
}

class ApprovalDocumentTable extends StatefulWidget {
  final List<DopApprovalListItem> items;
  final ValueChanged<DopApprovalListItem> onReview;

  const ApprovalDocumentTable({
    super.key,
    required this.items,
    required this.onReview,
  });

  @override
  State<ApprovalDocumentTable> createState() {
    return _ApprovalDocumentTableState();
  }
}

class _ApprovalDocumentTableState
    extends State<ApprovalDocumentTable> {
  final ScrollController horizontalController =
  ScrollController();

  final ScrollController verticalController =
  ScrollController();

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scrollbar(
        controller: horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        scrollbarOrientation:
        ScrollbarOrientation.bottom,
        child: SingleChildScrollView(
          controller: horizontalController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: verticalController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            scrollbarOrientation:
            ScrollbarOrientation.right,
            child: SingleChildScrollView(
              controller: verticalController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 42,
                dataRowMaxHeight: 46,
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
                    label: Text('No. DOP'),
                  ),
                  DataColumn(
                    label: Text('Tanggal'),
                  ),
                  DataColumn(
                    label: Text('Perusahaan'),
                  ),
                  DataColumn(
                    label: Text('Job Site'),
                  ),
                  DataColumn(
                    label: Text('Requestor'),
                  ),
                  DataColumn(
                    label: Text('Aktivitas'),
                  ),
                  DataColumn(
                    label: Text('Waktu Menunggu'),
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
      ),
    );
  }

  List<DataRow> buildRows() {
    final rows = <DataRow>[];

    for (final item in widget.items) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              SelectableText(
                item.dopNumber,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              Text(
                '${item.dayName}, ${item.dopDate}',
              ),
            ),
            DataCell(
              Text(item.companyName),
            ),
            DataCell(
              Text(item.jobSite),
            ),
            DataCell(
              Text(
                '${item.createdByName} '
                    '(${item.createdBySid})',
              ),
            ),
            DataCell(
              Text(
                item.totalActivities.toString(),
              ),
            ),
            DataCell(
              Text(item.waitingTimeLabel),
            ),
            DataCell(
              _ApprovalStatusBadge(
                label: item.statusLabel,
                approvalLevel:
                item.approvalLevel,
              ),
            ),
            DataCell(
              _ReviewButton(
                item: item,
                onReview: widget.onReview,
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}

class _ReviewButton extends StatelessWidget {
  final DopApprovalListItem item;
  final ValueChanged<DopApprovalListItem> onReview;

  const _ReviewButton({
    required this.item,
    required this.onReview,
  });

  void handlePressed() {
    onReview(item);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: handlePressed,
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('Review'),
    );
  }
}

class _ApprovalStatusBadge extends StatelessWidget {
  final String label;
  final int? approvalLevel;

  const _ApprovalStatusBadge({
    required this.label,
    required this.approvalLevel,
  });

  @override
  Widget build(BuildContext context) {
    final color = approvalLevel == 4
        ? const Color(0xFF7C3AED)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
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

class _ApprovalStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ApprovalStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 44,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}