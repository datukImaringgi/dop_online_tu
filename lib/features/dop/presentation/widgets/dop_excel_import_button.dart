import 'package:flutter/material.dart';

class DopExcelImportButton
    extends StatelessWidget {
  final bool isProcessing;
  final bool isEnabled;

  final Future<void> Function()
  onDownloadTemplate;

  final Future<void> Function()
  onUploadTemplate;

  const DopExcelImportButton({
    super.key,
    required this.isProcessing,
    required this.isEnabled,
    required this.onDownloadTemplate,
    required this.onUploadTemplate,
  });

  bool get isDisabled {
    return !isEnabled || isProcessing;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(
        0,
        4,
      ),
      style: MenuStyle(
        backgroundColor:
        const WidgetStatePropertyAll(
          Colors.white,
        ),
        elevation:
        const WidgetStatePropertyAll(
          6,
        ),
        padding:
        const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: 6,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
        ),
      ),
      menuChildren: [
        SizedBox(
          width: 260,
          child: MenuItemButton(
            onPressed: isDisabled
                ? null
                : () async {
              await onDownloadTemplate();
            },
            leadingIcon: const Icon(
              Icons.download_outlined,
              size: 18,
              color: Color(0xFF2563EB),
            ),
            child: const _ImportMenuContent(
              title: 'Download Template',
              subtitle:
              'Unduh template aktivitas XLSX',
            ),
          ),
        ),
        const Divider(
          height: 1,
          color: Color(0xFFE2E8F0),
        ),
        SizedBox(
          width: 260,
          child: MenuItemButton(
            onPressed: isDisabled
                ? null
                : () async {
              await onUploadTemplate();
            },
            leadingIcon: const Icon(
              Icons.upload_file_outlined,
              size: 18,
              color: Color(0xFF059669),
            ),
            child: const _ImportMenuContent(
              title: 'Upload Template',
              subtitle:
              'Pilih file aktivitas XLSX',
            ),
          ),
        ),
      ],
      builder: (
          BuildContext context,
          MenuController controller,
          Widget? child,
          ) {
        return OutlinedButton.icon(
          onPressed: isDisabled
              ? null
              : () {
            if (controller.isOpen) {
              controller.close();
              return;
            }

            controller.open();
          },
          style: OutlinedButton.styleFrom(
            minimumSize:
            const Size(0, 36),
            maximumSize:
            const Size(
              double.infinity,
              36,
            ),
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            foregroundColor:
            const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            disabledForegroundColor:
            const Color(0xFF94A3B8),
            disabledBackgroundColor:
            const Color(0xFFF1F5F9),
            side: BorderSide(
              color: isDisabled
                  ? const Color(
                0xFFCBD5E1,
              )
                  : const Color(
                0xFF2563EB,
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 11.5,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
          icon: isProcessing
              ? const SizedBox(
            width: 15,
            height: 15,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color:
              Color(0xFF2563EB),
            ),
          )
              : const Icon(
            Icons.table_view_outlined,
            size: 16,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isProcessing
                    ? 'Memproses Excel...'
                    : 'Import Aktivitas',
              ),
              if (!isProcessing) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ImportMenuContent
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ImportMenuContent({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}