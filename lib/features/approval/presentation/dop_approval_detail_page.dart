import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dop/domain/dop_list_item_model.dart';
import '../data/dop_approval_detail_provider.dart';
import '../domain/dop_approval_list_item.dart';
import 'package:data_table_2/data_table_2.dart';
import '../data/dop_approval_action_repository.dart';
import '../data/dop_approval_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../../dop/data/dop_list_provider.dart';

class DopApprovalDetailPage
    extends ConsumerWidget {
  final DopApprovalListItem approvalItem;

  const DopApprovalDetailPage({
    super.key,
    required this.approvalItem,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final detailsAsync = ref.watch(
      dopApprovalDetailProvider(
        approvalItem.dopHeaderId,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            buildPageHeader(
              context,
              ref,
            ),
            const SizedBox(height: 16),
            buildDocumentSummary(),
            const SizedBox(height: 16),
            detailsAsync.when(
              loading: buildLoading,
              error: buildError,
              data: buildDetailsContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageHeader(
      BuildContext context,
      WidgetRef ref,
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
              const Text(
                'Review DOP',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                approvalItem.dopNumber,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            context.go('/approval');
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
          ),
          label: const Text('Kembali'),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(
              dopApprovalDetailProvider(
                approvalItem.dopHeaderId,
              ),
            );
          },
          icon: const Icon(
            Icons.refresh,
            size: 18,
          ),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget buildDocumentSummary() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              if (constraints.maxWidth >= 900) {
                return buildDesktopSummary();
              }

              if (constraints.maxWidth >= 600) {
                return buildTabletSummary();
              }

              return buildMobileSummary();
            },
          ),
        ),
      ),
    );
  }

  Widget buildDesktopSummary() {
    return Column(
      children: [
        buildSummaryRow(
          items: [
            buildSummaryItem(
              label: 'Perusahaan',
              value: approvalItem.companyName,
              icon: Icons.business_outlined,
            ),
            buildSummaryItem(
              label: 'Job Site',
              value: approvalItem.jobSite,
              icon: Icons.location_on_outlined,
            ),
            buildSummaryItem(
              label: 'Tanggal DOP',
              value:
              '${approvalItem.dayName}, '
                  '${approvalItem.dopDate}',
              icon: Icons.calendar_today_outlined,
            ),
            buildStatusSummaryItem(),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
        buildSummaryRow(
          items: [
            buildSummaryItem(
              label: 'Requestor',
              value:
              '${approvalItem.createdByName} '
                  '(${approvalItem.createdBySid})',
              icon: Icons.person_outline,
            ),
            buildSummaryItem(
              label: 'Jumlah Aktivitas',
              value:
              '${approvalItem.totalActivities} aktivitas',
              icon: Icons.local_shipping_outlined,
            ),
            buildSummaryItem(
              label: 'Waktu Menunggu',
              value: approvalItem.waitingTimeLabel,
              icon: Icons.timer_outlined,
            ),
            buildSummaryItem(
              label: 'Tahap Persetujuan',
              value:
              'Layer '
                  '${approvalItem.approvalLevel ?? '-'}',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSummaryRow({
    required List<Widget> items,
  }) {
    final children = <Widget>[];

    for (var index = 0;
    index < items.length;
    index++) {
      children.add(
        Expanded(
          child: items[index],
        ),
      );

      if (index < items.length - 1) {
        children.add(
          buildSummaryDivider(),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatusSummaryItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.pending_actions_outlined,
            color: Color(0xFFEA580C),
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Text(
                    approvalItem.statusLabel,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFFC2410C),
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTabletSummary() {
    return buildWrappedSummary(
      itemWidth: 260,
    );
  }

  Widget buildMobileSummary() {
    return buildWrappedSummary(
      itemWidth: double.infinity,
    );
  }

  Widget buildWrappedSummary({
    required double itemWidth,
  }) {
    final items = <Widget>[
      buildSummaryItem(
        label: 'Perusahaan',
        value: approvalItem.companyName,
        icon: Icons.business_outlined,
      ),
      buildSummaryItem(
        label: 'Job Site',
        value: approvalItem.jobSite,
        icon: Icons.location_on_outlined,
      ),
      buildSummaryItem(
        label: 'Tanggal DOP',
        value:
        '${approvalItem.dayName}, '
            '${approvalItem.dopDate}',
        icon: Icons.calendar_today_outlined,
      ),
      buildStatusSummaryItem(),
      buildSummaryItem(
        label: 'Requestor',
        value:
        '${approvalItem.createdByName} '
            '(${approvalItem.createdBySid})',
        icon: Icons.person_outline,
      ),
      buildSummaryItem(
        label: 'Jumlah Aktivitas',
        value:
        '${approvalItem.totalActivities} aktivitas',
        icon: Icons.local_shipping_outlined,
      ),
      buildSummaryItem(
        label: 'Waktu Menunggu',
        value: approvalItem.waitingTimeLabel,
        icon: Icons.timer_outlined,
      ),
      buildSummaryItem(
        label: 'Tahap Persetujuan',
        value:
        'Layer ${approvalItem.approvalLevel ?? '-'}',
        icon: Icons.account_tree_outlined,
      ),
    ];

    final wrappedItems = <Widget>[];

    for (final item in items) {
      wrappedItems.add(
        SizedBox(
          width: itemWidth,
          child: item,
        ),
      );
    }

    return Wrap(
      spacing: 22,
      runSpacing: 18,
      children: wrappedItems,
    );
  }

  Widget buildSummaryDivider() {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget buildLoading() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildError(
      Object error,
      StackTrace stackTrace,
      ) {
    return SizedBox(
      height: 220,
      child: Center(
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
                'Gagal membaca aktivitas DOP',
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
      ),
    );
  }

  Widget buildDetailsContent(
      List<DopListItemModel> details,
      ) {
    if (details.isEmpty) {
      return const Card(
        elevation: 0,
        color: Colors.white,
        child: Center(
          child: Text(
            'Aktivitas DOP tidak ditemukan.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
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
              horizontal: 16,
              vertical: 10,
            ),
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                final title = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.list_alt_outlined,
                      color: Color(0xFF0D6EFD),
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'Daftar Aktivitas '
                            '(${details.length})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );

                final actionBar =
                DopApprovalActionBar(
                  approvalItem: approvalItem,
                );

                if (constraints.maxWidth >= 980) {
                  return Row(
                    children: [
                      Expanded(
                        child: title,
                      ),
                      const SizedBox(width: 12),
                      actionBar,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionBar,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          DopApprovalActivityTable(
            details: details,
          ),
        ],
      ),
    );
  }
}

class DopApprovalActivityTable
    extends StatelessWidget {
  final List<DopListItemModel> details;

  const DopApprovalActivityTable({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    const headingHeight = 40.0;
    const rowHeight = 44.0;

    final tableHeight =
        headingHeight +
            (details.length * rowHeight) +
            2;

    return SizedBox(
      height: tableHeight,
      child: DataTable2(
        minWidth: 2850,
        headingRowHeight: headingHeight,
        dataRowHeight: rowHeight,
        horizontalMargin: 12,
        columnSpacing: 14,
        dividerThickness: 0.8,
        isVerticalScrollBarVisible: false,
        isHorizontalScrollBarVisible: true,
        headingRowColor:
        WidgetStateProperty.all(
          const Color(0xFFF8FAFC),
        ),
        headingTextStyle:
        const TextStyle(
          color: Color(0xFF334155),
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle:
        const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11,
          height: 1.15,
        ),
        columns: const [
          DataColumn2(
            label: Text('No.'),
            fixedWidth: 45,
          ),
          DataColumn2(
            label: Text('Rencana Pekerjaan'),
            fixedWidth: 230,
          ),
          DataColumn2(
            label: Text('Unit'),
            fixedWidth: 110,
          ),
          DataColumn2(
            label: Text('Type'),
            fixedWidth: 75,
          ),
          DataColumn2(
            label: Text('Driver'),
            fixedWidth: 155,
          ),
          DataColumn2(
            label: Text('SID'),
            fixedWidth: 85,
          ),
          DataColumn2(
            label: Text('Mulai'),
            fixedWidth: 65,
          ),
          DataColumn2(
            label: Text('Akhir'),
            fixedWidth: 65,
          ),
          DataColumn2(
            label: Text('Rute'),
            fixedWidth: 175,
          ),
          DataColumn2(
            label: Text('Tujuan'),
            fixedWidth: 115,
          ),
          DataColumn2(
            label: Text('Shift'),
            fixedWidth: 90,
          ),
          DataColumn2(
            label: Text('Observer'),
            fixedWidth: 130,
          ),
          DataColumn2(
            label: Text('Prosedur / JSA'),
            fixedWidth: 220,
          ),
          DataColumn2(
            label: Text('RIC'),
            fixedWidth: 150,
          ),
          DataColumn2(
            label: Text('Layer 1'),
            fixedWidth: 145,
          ),
          DataColumn2(
            label: Text('Layer 2'),
            fixedWidth: 145,
          ),
          DataColumn2(
            label: Text('Layer 3'),
            fixedWidth: 145,
          ),
          DataColumn2(
            label: Text('Layer 4'),
            fixedWidth: 145,
          ),
          DataColumn2(
            label: Text(
              'Perusahaan Transportasi',
            ),
            fixedWidth: 180,
          ),
        ],
        rows: buildRows(),
      ),
    );
  }

  List<DataRow> buildRows() {
    final rows = <DataRow>[];

    for (
    var index = 0;
    index < details.length;
    index++
    ) {
      final detail = details[index];

      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(
                '${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataCell(
              buildText(detail.workPlan),
            ),
            DataCell(
              buildText(
                detail.unitNumber,
                isBold: true,
              ),
            ),
            DataCell(
              buildText(detail.unitType),
            ),
            DataCell(
              buildText(detail.driverName),
            ),
            DataCell(
              buildText(detail.sid),
            ),
            DataCell(
              buildText(
                formatTime(detail.startTime),
              ),
            ),
            DataCell(
              buildText(
                formatTime(detail.endTime),
              ),
            ),
            DataCell(
              buildText(detail.route),
            ),
            DataCell(
              buildText(
                formatArea(detail.areaType),
              ),
            ),
            DataCell(
              buildText(detail.shift),
            ),
            DataCell(
              buildText(detail.observer),
            ),
            DataCell(
              buildText(detail.jsaProcedure),
            ),
            DataCell(
              buildText(detail.controlRoom),
            ),
            DataCell(
              buildText(detail.layer1),
            ),
            DataCell(
              buildText(detail.layer2),
            ),
            DataCell(
              buildText(detail.layer3),
            ),
            DataCell(
              buildText(detail.layer4),
            ),
            DataCell(
              buildText(
                detail.transportCompany,
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  Widget buildText(
  String value, {
        bool isBold = false,
      }) {
    return Tooltip(
      message: value,
      waitDuration: const Duration(
        milliseconds: 500,
      ),
      child: Text(
        value,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: 11,
          height: 1.15,
          fontWeight: isBold
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
    );
  }

  String formatTime(String value) {
    if (value == '-') {
      return '-';
    }

    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }

  String formatArea(String value) {
    if (value == 'jalan_negara') {
      return 'Jalan Negara';
    }

    if (value == 'site') {
      return 'Area Site';
    }

    if (value.trim().isEmpty) {
      return '-';
    }

    return value;
  }
}

class DopApprovalActionBar
    extends ConsumerStatefulWidget {
  final DopApprovalListItem approvalItem;

  const DopApprovalActionBar({
    super.key,
    required this.approvalItem,
  });

  @override
  ConsumerState<DopApprovalActionBar>
  createState() {
    return _DopApprovalActionBarState();
  }
}

class _DopApprovalActionBarState extends ConsumerState<DopApprovalActionBar> {
  bool isProcessing = false;

  Future<void> handleApprove() async {
    if (isProcessing) {
      return;
    }

    final hierarchyLayer = ref.read(
      currentHierarchyLayerProvider,
    ).asData?.value;

    if (hierarchyLayer != 3 &&
        hierarchyLayer != 4) {
      showErrorMessage(
        'Anda tidak memiliki akses untuk menyetujui DOP ini.',
      );
      return;
    }

    final approvalLayer = hierarchyLayer!;

    final shouldApprove =
    await showApprovalConfirmation(
      approvalLayer,
    );

    if (!shouldApprove) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final repository = ref.read(
        dopApprovalActionRepositoryProvider,
      );

      if (approvalLayer == 3) {
        await repository.approveLayer3(
          dopHeaderId:
          widget.approvalItem.dopHeaderId,
        );
      } else {
        await repository.approveLayer4(
          dopHeaderId:
          widget.approvalItem.dopHeaderId,
        );
      }

      ref.invalidate(
        dopApprovalListProvider,
      );

      ref.invalidate(
        dopApprovalDetailProvider(
          widget.approvalItem.dopHeaderId,
        ),
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      context.go('/approval');

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          const Color(0xFF059669),
          duration: const Duration(
            seconds: 5,
          ),
          content: Text(
            approvalLayer == 3
                ? 'DOP ${widget.approvalItem.dopNumber} '
                'berhasil disetujui dan diteruskan '
                'ke Approval Layer 4.'
                : 'DOP ${widget.approvalItem.dopNumber} '
                'telah disetujui sepenuhnya.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<bool> showApprovalConfirmation(
      int hierarchyLayer,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return buildConfirmationDialog(
          dialogContext,
          hierarchyLayer,
        );
      },
    );

    return result ?? false;
  }

  Future<void> handleReturnForRevision() async {
    if (isProcessing) {
      return;
    }

    final revisionNote =
    await showRevisionDialog();

    if (revisionNote == null) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final repository = ref.read(
        dopApprovalActionRepositoryProvider,
      );

      await repository.returnForRevision(
        dopHeaderId:
        widget.approvalItem.dopHeaderId,
        note: revisionNote,
      );

      ref.invalidate(
        dopApprovalListProvider,
      );

      ref.invalidate(
        dopApprovalDetailProvider(
          widget.approvalItem.dopHeaderId,
        ),
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      context.go('/approval');

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          const Color(0xFFF59E0B),
          duration: const Duration(
            seconds: 5,
          ),
          content: Text(
            'DOP ${widget.approvalItem.dopNumber} '
                'dikembalikan untuk revisi.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> handleRejectDop() async {
    if (isProcessing) {
      return;
    }

    final rejectionNote =
    await showRejectDialog();

    if (rejectionNote == null) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final repository = ref.read(
        dopApprovalActionRepositoryProvider,
      );

      await repository.rejectDop(
        dopHeaderId:
        widget.approvalItem.dopHeaderId,
        note: rejectionNote,
      );

      ref.invalidate(
        dopApprovalListProvider,
      );

      ref.invalidate(
        pendingApprovalCountProvider,
      );

      ref.invalidate(
        dopApprovalDetailProvider(
          widget.approvalItem.dopHeaderId,
        ),
      );

      ref.invalidate(
        dopListProvider,
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      context.go('/approval');

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          const Color(0xFFDC2626),
          duration: const Duration(
            seconds: 5,
          ),
          content: Text(
            'DOP ${widget.approvalItem.dopNumber} '
                'telah ditolak.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<String?> showRevisionDialog() async {
    final noteController =
    TextEditingController();

    final formKey =
    GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Kembalikan untuk Revisi',
          ),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOP ${widget.approvalItem.dopNumber} '
                        'akan dikembalikan kepada requestor.',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Catatan Revisi',
                      hintText:
                      'Jelaskan bagian yang perlu diperbaiki',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    validator: (
                        String? value,
                        ) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Catatan revisi wajib diisi';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                final isValid =
                    formKey.currentState
                        ?.validate() ??
                        false;

                if (!isValid) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  noteController.text.trim(),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFF59E0B),
                foregroundColor:
                const Color(0xFF172033),
              ),
              icon: const Icon(
                Icons.assignment_return_outlined,
                size: 18,
              ),
              label: const Text(
                'Kembalikan',
              ),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<String?> showRejectDialog() async {
    final noteController =
    TextEditingController();

    final formKey =
    GlobalKey<FormState>();

    final result =
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: Color(0xFFDC2626),
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Reject DOP',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFFEF2F2),
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                        color:
                        const Color(0xFFFECACA),
                      ),
                    ),
                    child: Text(
                      'DOP ${widget.approvalItem.dopNumber} '
                          'akan ditolak secara final dan tidak '
                          'dapat dikirim ulang melalui menu Revisi DOP.',
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization:
                    TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText:
                      'Alasan Reject DOP',
                      hintText:
                      'Jelaskan alasan DOP ditolak',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    validator: validateRejectNote,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                final isValid =
                    formKey.currentState
                        ?.validate() ??
                        false;

                if (!isValid) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  noteController.text.trim(),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.cancel_outlined,
                size: 18,
              ),
              label: const Text(
                'Reject DOP',
              ),
            ),
          ],
        );
      },
    );

    noteController.dispose();

    return result;
  }

  String? validateRejectNote(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Alasan Reject DOP wajib diisi';
    }

    if (value.trim().length < 5) {
      return 'Alasan reject minimal 5 karakter';
    }

    return null;
  }

  Widget buildConfirmationDialog(
      BuildContext dialogContext,
      int hierarchyLayer,
      ) {
    final isLayer3 =
        hierarchyLayer == 3;

    final title = isLayer3
        ? 'Setujui Approval Layer 3'
        : 'Setujui Approval Layer 4';

    final description = isLayer3
        ? 'Setujui ${widget.approvalItem.dopNumber}?\n\n'
        'DOP akan diteruskan ke Approval Layer 4.'
        : 'Setujui ${widget.approvalItem.dopNumber}?\n\n'
        'Persetujuan ini akan menyelesaikan '
        'seluruh proses approval DOP.';

    final buttonLabel = isLayer3
        ? 'Setujui Layer 3'
        : 'Setujui Layer 4';

    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(
              dialogContext,
            ).pop(false);
          },
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(
              dialogContext,
            ).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor:
            const Color(0xFF059669),
          ),
          icon: const Icon(
            Icons.check_circle_outline,
            size: 18,
          ),
          label: Text(buttonLabel),
        ),
      ],
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFFDC2626),
        content: Text(message),
      ),
    );
  }

  String extractErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    const prefix =
        'PostgrestException(message: ';

    if (message.startsWith(prefix)) {
      final cleanedMessage =
      message.replaceFirst(prefix, '');

      final commaIndex =
      cleanedMessage.indexOf(',');

      if (commaIndex > 0) {
        return cleanedMessage
            .substring(0, commaIndex)
            .trim();
      }
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final hierarchyLayer =
        hierarchyAsync.asData?.value;

    final canApproveLayer3 =
        hierarchyLayer == 3 &&
            widget.approvalItem.headerStatus ==
                'pending_layer_3' &&
            widget.approvalItem.approvalLevel == 3 &&
            widget.approvalItem.approvalStatus ==
                'pending';

    final canApproveLayer4 =
        hierarchyLayer == 4 &&
            widget.approvalItem.headerStatus ==
                'pending_layer_4' &&
            widget.approvalItem.approvalLevel == 4 &&
            widget.approvalItem.approvalStatus ==
                'pending';

    if (!canApproveLayer3 &&
        !canApproveLayer4) {
      return const SizedBox.shrink();
    }

    final buttonLabel = canApproveLayer3
        ? 'Setujui Layer 3'
        : 'Setujui Layer 4';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 720,
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment:
        WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF64748B),
                size: 17,
              ),
              SizedBox(width: 7),
              Text(
                'Pastikan seluruh aktivitas '
                    'telah diperiksa.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: isProcessing
                ? null
                : handleReturnForRevision,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              foregroundColor:
              const Color(0xFFB45309),
              side: const BorderSide(
                color: Color(0xFFF59E0B),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(
              Icons.assignment_return_outlined,
              size: 17,
            ),
            label: const Text(
              'Kembalikan untuk Revisi',
            ),
          ),
          OutlinedButton.icon(
            onPressed: isProcessing
                ? null
                : handleRejectDop,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              foregroundColor:
              const Color(0xFFDC2626),
              backgroundColor:
              const Color(0xFFFEF2F2),
              side: const BorderSide(
                color: Color(0xFFFCA5A5),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(
              Icons.cancel_outlined,
              size: 17,
            ),
            label: const Text(
              'Reject DOP',
            ),
          ),
          FilledButton.icon(
            onPressed:
            isProcessing ? null : handleApprove,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              backgroundColor:
              const Color(0xFF059669),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: isProcessing
                ? const SizedBox(
              width: 15,
              height: 15,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.check_circle_outline,
              size: 17,
            ),
            label: Text(
              isProcessing
                  ? 'Memproses...'
                  : buttonLabel,
            ),
          ),
        ],
      ),
    );
  }
}