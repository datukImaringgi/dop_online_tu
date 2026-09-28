import 'package:flutter/material.dart';

import '../../domain/dop_excel_import_result.dart';

class DopExcelImportPreviewDialog
    extends StatelessWidget {
  final DopExcelImportResult result;

  const DopExcelImportPreviewDialog({
    super.key,
    required this.result,
  });

  static Future<bool> show({
    required BuildContext context,
    required DopExcelImportResult result,
  }) async {
    final shouldImport =
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DopExcelImportPreviewDialog(
          result: result,
        );
      },
    );

    return shouldImport ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding:
      const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        10,
      ),
      contentPadding:
      const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        12,
      ),
      actionsPadding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      title: const Row(
        children: [
          Icon(
            Icons.preview_outlined,
            color: Color(0xFF2563EB),
            size: 21,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Preview Import Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              result.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total Baris',
                    value:
                    result.totalRows.toString(),
                    color:
                    const Color(0xFF2563EB),
                    icon:
                    Icons.table_rows_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: 'Valid',
                    value: result.validRowCount
                        .toString(),
                    color:
                    const Color(0xFF059669),
                    icon:
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: 'Perlu Diperbaiki',
                    value: result.invalidRowCount
                        .toString(),
                    color:
                    const Color(0xFFDC2626),
                    icon:
                    Icons.error_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (result.hasErrors) ...[
              const Text(
                'Detail Validasi',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 240,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius:
                  BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    const Color(0xFFFECACA),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                  const EdgeInsets.all(10),
                  itemCount:
                  result.errors.length,
                  separatorBuilder: (
                      context,
                      index,
                      ) {
                    return const Divider(
                      height: 12,
                      color:
                      Color(0xFFFECACA),
                    );
                  },
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final error =
                    result.errors[index];

                    return Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.close,
                          size: 15,
                          color:
                          Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            error.displayMessage,
                            style:
                            const TextStyle(
                              color: Color(
                                0xFF991B1B,
                              ),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildImportNotice(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: result.canImport
              ? () {
            Navigator.of(context)
                .pop(true);
          }
              : null,
          icon: const Icon(
            Icons.file_download_done_outlined,
            size: 17,
          ),
          label: Text(
            'Import '
                '${result.validRowCount} '
                'Aktivitas Valid',
          ),
        ),
      ],
    );
  }

  Widget _buildImportNotice() {
    if (!result.hasValidActivities) {
      return const _NoticeBox(
        color: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFECACA),
        icon: Icons.block_outlined,
        message:
        'Tidak ada aktivitas valid yang '
            'dapat diimport. Perbaiki file '
            'Excel lalu upload kembali.',
      );
    }

    if (result.hasErrors) {
      return const _NoticeBox(
        color: Color(0xFFD97706),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFCD34D),
        icon: Icons.warning_amber_outlined,
        message:
        'Hanya aktivitas valid yang akan '
            'dimasukkan ke tabel. Baris yang '
            'memiliki error tidak akan diimport.',
      );
    }

    return const _NoticeBox(
      color: Color(0xFF059669),
      backgroundColor: Color(0xFFECFDF5),
      borderColor: Color(0xFFA7F3D0),
      icon: Icons.check_circle_outline,
      message:
      'Seluruh aktivitas valid dan siap '
          'dimasukkan ke daftar aktivitas DOP.',
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final String message;

  const _NoticeBox({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}