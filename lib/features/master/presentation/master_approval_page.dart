import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/master_change_request_provider.dart';
import '../domain/master_change_request_model.dart';
import 'widgets/master_change_review_dialog.dart';
import '../../../shared/providers/user_session_provider.dart';

class MasterApprovalPage
    extends ConsumerStatefulWidget {
  const MasterApprovalPage({
    super.key,
  });

  @override
  ConsumerState<MasterApprovalPage> createState() {
    return _MasterApprovalPageState();
  }
}

class _MasterApprovalPageState
    extends ConsumerState<MasterApprovalPage> {
  String selectedStatus = 'pending';
  String? selectedCompanyId;
  String selectedMasterType = 'all';

  void handleStatusChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      selectedStatus = value;
    });
  }

  void handleCompanyChanged(
      String? value,
      ) {
    setState(() {
      selectedCompanyId = value;
    });
  }

  void handleMasterTypeChanged(
      String? value,
      ) {
    if (value == null) {
      return;
    }

    setState(() {
      selectedMasterType = value;
    });
  }

  void refreshData() {
    ref.invalidate(
      masterChangeRequestsProvider,
    );

    ref.invalidate(
      pendingMasterChangeCountProvider,
    );
  }

  void openReviewDialog({
    required MasterChangeRequestModel request,
    required bool canReview,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return MasterChangeReviewDialog(
          request: request,
          allowReview: canReview,
        );
      },
    );
  }

  void openRequestDetail({
    required MasterChangeRequestModel request,
    required bool canReview,
  }) {
    openReviewDialog(
      request: request,
      canReview: canReview,
    );
  }

  Map<String, String> buildCompanyOptions(
      List<MasterChangeRequestModel> requests,
      ) {
    final options = <String, String>{};

    for (final request in requests) {
      final companyId =
      request.companyId.trim();

      final companyName =
      request.companyName.trim();

      if (companyId.isEmpty ||
          companyName.isEmpty ||
          companyName == '-') {
        continue;
      }

      options[companyId] = companyName;
    }

    return options;
  }

  List<DropdownMenuItem<String?>>
  buildCompanyDropdownItems(
      Map<String, String> options,
      ) {
    final items =
    <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Perusahaan'),
      ),
    ];

    final companyIds =
    options.keys.toList();

    companyIds.sort(
          (
          String firstId,
          String secondId,
          ) {
        final firstName =
            options[firstId] ?? '';

        final secondName =
            options[secondId] ?? '';

        return firstName.compareTo(
          secondName,
        );
      },
    );

    for (final companyId in companyIds) {
      items.add(
        DropdownMenuItem<String?>(
          value: companyId,
          child: Text(
            options[companyId] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  List<MasterChangeRequestModel>
  filterRequests(
      List<MasterChangeRequestModel> requests,
      ) {
    final filteredRequests =
    <MasterChangeRequestModel>[];

    for (final request in requests) {
      if (selectedStatus != 'all' &&
          request.status != selectedStatus) {
        continue;
      }

      if (selectedCompanyId != null &&
          selectedCompanyId!.isNotEmpty &&
          request.companyId !=
              selectedCompanyId) {
        continue;
      }

      if (selectedMasterType != 'all' &&
          request.masterType !=
              selectedMasterType) {
        continue;
      }

      filteredRequests.add(request);
    }

    return filteredRequests;
  }

  @override
  Widget build(BuildContext context) {
    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final hierarchyLayer =
        hierarchyAsync.asData?.value;

    final canReview =
        hierarchyLayer == 5;

    final requestsAsync = ref.watch(
      masterChangeRequestsProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildPageHeader(
              canReview: canReview,
              requests:
              requestsAsync.value ??
                  <MasterChangeRequestModel>[],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: requestsAsync.when(
                loading: buildLoading,
                error: buildError,
                data: (
                    List<MasterChangeRequestModel> requests,
                    ) {
                  return buildRequestContent(
                    requests: requests,
                    canReview: canReview,
                  );
                },
              ),
            ),
          ],
        ),
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
      prefixIcon: Icon(
        icon,
        size: 16,
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 9.5,
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
          width: 1.25,
        ),
      ),
    );
  }

  Widget _buildPageHeader({
    required bool canReview,
    required List<MasterChangeRequestModel>
    requests,
  }) {
    final companyOptions =
    buildCompanyOptions(requests);
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canReview
                    ? 'Approval Master Data'
                    : 'Status Pengajuan Master Data',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                canReview
                    ? 'Review perubahan Master Data '
                    'yang diajukan admin perusahaan.'
                    : 'Pantau status perubahan Master Data '
                    'yang diajukan perusahaan Anda.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String?>(
            value: selectedCompanyId,
            isExpanded: true,
            decoration: buildFilterDecoration(
              label: 'Perusahaan',
              icon: Icons.business_outlined,
            ),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            items: buildCompanyDropdownItems(
              companyOptions,
            ),
            onChanged: handleCompanyChanged,
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: selectedMasterType,
            isExpanded: true,
            decoration: buildFilterDecoration(
              label: 'Master Type',
              icon: Icons.storage_outlined,
            ),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              DropdownMenuItem<String>(
                value: 'all',
                child: Text('Semua Master'),
              ),
              DropdownMenuItem<String>(
                value: 'user_assignment',
                child: Text('User & Hierarchy'),
              ),
              DropdownMenuItem<String>(
                value: 'unit',
                child: Text('Unit'),
              ),
              DropdownMenuItem<String>(
                value: 'driver',
                child: Text('Driver'),
              ),
              DropdownMenuItem<String>(
                value: 'route',
                child: Text('Rute'),
              ),
              DropdownMenuItem<String>(
                value: 'job_site',
                child: Text('Job Site'),
              ),
              DropdownMenuItem<String>(
                value: 'jsa_procedure',
                child: Text('JSA'),
              ),
              DropdownMenuItem<String>(
                value: 'control_room',
                child: Text('RIC'),
              ),
            ],
            onChanged: handleMasterTypeChanged,
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: selectedStatus,
            isExpanded: true,
            decoration: buildFilterDecoration(
              label: 'Status',
              icon: Icons.filter_alt_outlined,
            ),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              DropdownMenuItem<String>(
                value: 'pending',
                child: Text(
                  'Menunggu Approval',
                ),
              ),
              DropdownMenuItem<String>(
                value: 'approved',
                child: Text('Disetujui'),
              ),
              DropdownMenuItem<String>(
                value: 'rejected',
                child: Text('Ditolak'),
              ),
              DropdownMenuItem<String>(
                value: 'cancelled',
                child: Text('Dibatalkan'),
              ),
              DropdownMenuItem<String>(
                value: 'all',
                child: Text('Semua Status'),
              ),
            ],
            onChanged: handleStatusChanged,
          ),
        ),

        const SizedBox(width: 8),
        Tooltip(
          message: 'Refresh data',
          child: SizedBox(
            width: 36,
            height: 36,
            child: OutlinedButton(
              onPressed: refreshData,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor:
                const Color(0xFF475569),
                side: const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.refresh,
                size: 17,
              ),
            ),
          ),
        ),
      ],
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
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 520,
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
              size: 30,
            ),
            const SizedBox(height: 8),
            const Text(
              'Gagal membaca Approval Master',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRequestContent({
    required List<MasterChangeRequestModel>
    requests,
    required bool canReview,
  }) {
    final filteredRequests =
    filterRequests(requests);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildCardHeader(
            filteredRequests.length,
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: filteredRequests.isEmpty
                ? buildEmptyState()
                : _MasterApprovalTable(
              requests: filteredRequests,
              canReview: canReview,
              onReview: (
                  MasterChangeRequestModel request,
                  ) {
                openRequestDetail(
                  request: request,
                  canReview: canReview,
                );
              },
            ),  
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(int total) {
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
              color:
              const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.approval_outlined,
              color: Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Daftar Pengajuan Perubahan',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
              const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(999),
            ),
            child: Text(
              '$total Request',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Color(0xFF94A3B8),
            size: 34,
          ),
          SizedBox(height: 8),
          Text(
            'Tidak ada pengajuan pada status ini',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Pengajuan baru akan tampil '
                'setelah dikirim admin perusahaan.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterApprovalTable
    extends StatefulWidget {
  final bool canReview;
  final List<MasterChangeRequestModel>
  requests;

  final ValueChanged<
      MasterChangeRequestModel> onReview;

  const _MasterApprovalTable({
    required this.requests,
    required this.canReview,
    required this.onReview,
  });

  @override
  State<_MasterApprovalTable> createState() {
    return _MasterApprovalTableState();
  }
}

class _MasterApprovalTableState
    extends State<_MasterApprovalTable> {
  final horizontalController =
  ScrollController();

  final verticalController =
  ScrollController();

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
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
                headingRowHeight: 36,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 44,
                horizontalMargin: 12,
                columnSpacing: 22,
                headingRowColor:
                WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                headingTextStyle:
                const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
                dataTextStyle:
                const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 10.5,
                ),
                columns: const [
                  DataColumn(
                    label: Text('Tanggal'),
                  ),
                  DataColumn(
                    label: Text('Perusahaan'),
                  ),
                  DataColumn(
                    label: Text('Master'),
                  ),
                  DataColumn(
                    label: Text('Perubahan'),
                  ),
                  DataColumn(
                    label: Text('Target'),
                  ),
                  DataColumn(
                    label: Text('Diajukan Oleh'),
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

    for (final request in widget.requests) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(
                formatDateTime(
                  request.requestedAt,
                ),
              ),
            ),
            DataCell(
              Text(request.companyName),
            ),
            DataCell(
              Text(request.masterTypeLabel),
            ),
            DataCell(
              Text(request.actionTypeLabel),
            ),
            DataCell(
              Text(request.targetDisplayName),
            ),
            DataCell(
              Text(request.requestedByName),
            ),
            DataCell(
              _MasterRequestStatusBadge(
                request: request,
              ),
            ),
            DataCell(
              request.isPending && widget.canReview
                  ? SizedBox(
                height: 28,
                child:
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onReview(
                      request,
                    );
                  },
                  style:
                  OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 8,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(7),
                    ),
                  ),
                  icon: const Icon(
                    Icons
                        .rate_review_outlined,
                    size: 14,
                  ),
                  label: const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              )
                  : IconButton(
                onPressed: () {
                  widget.onReview(
                    request,
                  );
                },
                tooltip: 'Lihat detail',
                visualDensity:
                VisualDensity.compact,
                icon: const Icon(
                  Icons
                      .visibility_outlined,
                  color:
                  Color(0xFF64748B),
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

  String formatDateTime(DateTime value) {
    final localValue = value.toLocal();

    final year =
    localValue.year.toString();

    final month = localValue.month
        .toString()
        .padLeft(2, '0');

    final day = localValue.day
        .toString()
        .padLeft(2, '0');

    final hour = localValue.hour
        .toString()
        .padLeft(2, '0');

    final minute = localValue.minute
        .toString()
        .padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }
}

class _MasterRequestStatusBadge
    extends StatelessWidget {
  final MasterChangeRequestModel request;

  const _MasterRequestStatusBadge({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(999),
      ),
      child: Text(
        request.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color getStatusColor() {
    if (request.status == 'pending') {
      return const Color(0xFFD97706);
    }

    if (request.status == 'approved') {
      return const Color(0xFF059669);
    }

    if (request.status == 'rejected') {
      return const Color(0xFFDC2626);
    }

    return const Color(0xFF64748B);
  }
}