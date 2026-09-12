import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/master_change_request_provider.dart';
import '../../data/master_unit_provider.dart';
import '../../domain/master_change_request_model.dart';
import '../../data/company_user_hierarchy_provider.dart';

class MasterChangeReviewDialog
    extends ConsumerStatefulWidget {
  final MasterChangeRequestModel request;
  final bool allowReview;

  const MasterChangeReviewDialog({
    super.key,
    required this.request,
    required this.allowReview,
  });

  @override
  ConsumerState<MasterChangeReviewDialog>
  createState() {
    return _MasterChangeReviewDialogState();
  }
}

class _MasterChangeReviewDialogState extends ConsumerState< MasterChangeReviewDialog> {
  final reviewNoteController =
  TextEditingController();

  bool isProcessing = false;

  bool get canReview {
    return widget.allowReview &&
        widget.request.isPending;
  }

  String formatReviewDateTime(
      DateTime? value,
      ) {
    if (value == null) {
      return '-';
    }

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

  @override
  void initState() {
    super.initState();

    final reviewNote =
    widget.request.reviewNote?.trim();

    if (reviewNote != null &&
        reviewNote.isNotEmpty) {
      reviewNoteController.text = reviewNote;
    }
  }

  @override
  void dispose() {
    reviewNoteController.dispose();
    super.dispose();
  }

  void closeDialog() {
    if (isProcessing) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> approveRequest() async {
    await processRequest(
      decision: 'approved',
    );
  }

  Future<void> rejectRequest() async {
    final reviewNote =
    reviewNoteController.text.trim();

    if (reviewNote.isEmpty) {
      showMessage(
        message:
        'Catatan wajib diisi untuk menolak perubahan.',
        isError: true,
      );

      return;
    }

    await processRequest(
      decision: 'rejected',
    );
  }

  Future<void> processRequest({
    required String decision,
  }) async {
    if (isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final repository = ref.read(
        masterChangeRequestRepositoryProvider,
      );

      final result =
      await repository.reviewRequest(
        requestId: widget.request.id,
        masterType:
        widget.request.masterType,
        decision: decision,
        reviewNote:
        reviewNoteController.text.trim(),
      );

      ref.invalidate(
        masterChangeRequestsProvider,
      );

      ref.invalidate(
        pendingMasterChangeCountProvider,
      );

      ref.invalidate(
        masterUnitsProvider,
      );

      ref.invalidate(
        companyUserHierarchyProvider,
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          decision == 'approved'
              ? const Color(0xFF059669)
              : const Color(0xFFD97706),
          content: Text(result.message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        message:
        'Gagal memproses request: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void showMessage({
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        12,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.approval_outlined,
              color: Color(0xFF2563EB),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Review Perubahan Master',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildHeaderStatusBadge(),
        ],
      ),
      content: SizedBox(
        width: 780,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildRequestInformation(),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                    ) {
                  final oldPanel = _MasterDataPanel(
                    title: 'Data Sebelumnya',
                    data:
                    widget.request.displayOldData,
                    emptyMessage:
                    'Data baru, belum memiliki data sebelumnya.',
                    color: const Color(0xFF64748B),
                  );

                  final requestedPanel =
                  _MasterDataPanel(
                    title: 'Data Diajukan',
                    data: widget.request
                        .displayRequestedData,
                    emptyMessage:
                    'Tidak ada payload perubahan.',
                    color: const Color(0xFF2563EB),
                  );

                  if (constraints.maxWidth < 650) {
                    return Column(
                      children: [
                        oldPanel,
                        const SizedBox(height: 12),
                        requestedPanel,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(child: oldPanel),
                      const SizedBox(width: 12),
                      Expanded(child: requestedPanel),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              if (canReview)
                _buildEditableReviewNote()
              else
                _buildReviewResultCard(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
          isProcessing ? null : closeDialog,
          child: const Text('Tutup'),
        ),
        if (canReview)
          OutlinedButton.icon(
            onPressed:
            isProcessing ? null : rejectRequest,
            style: OutlinedButton.styleFrom(
              foregroundColor:
              const Color(0xFFDC2626),
              backgroundColor:
              const Color(0xFFFEF2F2),
              side: const BorderSide(
                color: Color(0xFFFCA5A5),
              ),
            ),
            icon: const Icon(
              Icons.close,
              size: 16,
            ),
            label: const Text('Tolak'),
          ),
        if (canReview)
          FilledButton.icon(
            onPressed:
            isProcessing ? null : approveRequest,
            style: FilledButton.styleFrom(
              backgroundColor:
              const Color(0xFF059669),
            ),
            icon: isProcessing
                ? const SizedBox(
              width: 14,
              height: 14,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.check,
              size: 16,
            ),
            label: Text(
              isProcessing
                  ? 'Memproses...'
                  : 'Setujui',
            ),
          ),
      ],
    );
  }

  Color get statusColor {
    if (widget.request.status == 'approved') {
      return const Color(0xFF059669);
    }

    if (widget.request.status == 'rejected') {
      return const Color(0xFFDC2626);
    }

    return const Color(0xFFD97706);
  }

  IconData get statusIcon {
    if (widget.request.status == 'approved') {
      return Icons.check_circle_outline;
    }

    if (widget.request.status == 'rejected') {
      return Icons.cancel_outlined;
    }

    return Icons.schedule_outlined;
  }

  Widget _buildHeaderStatusBadge() {
    final color = statusColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            widget.request.statusLabel,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableReviewNote() {
    return TextField(
      controller: reviewNoteController,
      enabled: !isProcessing,
      minLines: 3,
      maxLines: 5,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12.5,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: 'Catatan Review',
        hintText:
        'Wajib diisi jika request ditolak',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(
            Icons.notes_outlined,
            size: 18,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildReviewResultCard() {
    final color = statusColor;
    final reviewNote =
    widget.request.reviewNote?.trim();

    final note = reviewNote == null ||
        reviewNote.isEmpty
        ? 'Tidak ada catatan review.'
        : reviewNote;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notes_outlined,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Hasil Review',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  note,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRequestInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _RequestInformationItem(
            label: 'Perusahaan',
            value: widget.request.companyName,
          ),
          _RequestInformationItem(
            label: 'Master',
            value: widget.request.masterTypeLabel,
          ),
          _RequestInformationItem(
            label: 'Perubahan',
            value: widget.request.actionTypeLabel,
          ),
          _RequestInformationItem(
            label: 'Target',
            value: widget.request.targetDisplayName,
          ),
          _RequestInformationItem(
            label: 'Diajukan Oleh',
            value: widget.request.requestedByName,
          ),
          _RequestInformationItem(
            label: 'Status',
            value: widget.request.statusLabel,
          ),
          if (!widget.request.isPending)
            _RequestInformationItem(
              label: 'Direview Oleh',
              value: widget.request.reviewedByName,
            ),
          if (!widget.request.isPending)
            _RequestInformationItem(
              label: 'Waktu Review',
              value: formatReviewDateTime(
                widget.request.reviewedAt,
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestInformationItem
    extends StatelessWidget {
  final String label;
  final String value;

  const _RequestInformationItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterDataPanel
    extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? data;
  final String emptyMessage;
  final Color color;

  const _MasterDataPanel({
    required this.title,
    required this.data,
    required this.emptyMessage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data?.entries
        .where(
          (entry) =>
      entry.value != null &&
          entry.key != 'company_id',
    )
        .toList() ??
        <MapEntry<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.05,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
              ),
            )
          else
            for (final entry in entries)
              _MasterDataRow(
                label: _formatKey(
                  entry.key,
                ),
                value: _formatValue(
                  entry.key,
                  entry.value,
                ),
              ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    if (key == 'unit_number') {
      return 'Nomor Unit';
    }

    if (key == 'unit_type') {
      return 'Kategori';
    }

    if (key == 'owner_company') {
      return 'Perusahaan Pemilik';
    }

    if (key == 'job_site') {
      return 'Job Site';
    }

    if (key == 'is_active') {
      return 'Status';
    }

    if (key == 'full_name') {
      return 'Nama Lengkap';
    }

    if (key == 'sid') {
      return 'SID';
    }

    if (key == 'password') {
      return 'Password Sementara';
    }

    if (key == 'notification_email') {
      return 'Email Notifikasi';
    }

    if (key == 'hierarchy_layer') {
      return 'Hierarchy';
    }

    if (key == 'position') {
      return 'Position';
    }

    if (key == 'department') {
      return 'Department';
    }

    if (key == 'auth_email') {
      return 'Email Login';
    }

    if (key == 'stop_name') {
      return 'Nama Halte';
    }

    if (key == 'description') {
      return 'Keterangan';
    }

    if (key == 'origin') {
      return 'Asal';
    }

    if (key == 'transit_1') {
      return 'Transit 1';
    }

    if (key == 'transit_2') {
      return 'Transit 2';
    }

    if (key == 'destination') {
      return 'Tujuan';
    }

    if (key == 'route_name') {
      return 'Nama Rute';
    }

    if (key == 'area_type') {
      return 'Area Tujuan';
    }

    return key;
  }

  String _formatValue(
      String key,
      dynamic value,
      ) {
    if (value == null) {
      return '-';
    }

    if (key == 'hierarchy_layer') {
      return 'Layer $value';
    }

    if (key == 'unit_type') {
      final unitType =
      value.toString().toUpperCase();

      if (unitType == 'BUS') {
        return 'Massal';
      }

      if (unitType == 'LV') {
        return 'Non-Massal';
      }
    }

    if (key == 'is_active') {
      return value == true
          ? 'Aktif'
          : 'Nonaktif';
    }

    return value.toString();
  }
}

class _MasterDataRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _MasterDataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}