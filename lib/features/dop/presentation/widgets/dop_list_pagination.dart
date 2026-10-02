import 'package:flutter/material.dart';

class DopListPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int firstItemNumber;
  final int lastItemNumber;
  final int rowsPerPage;

  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  const DopListPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.firstItemNumber,
    required this.lastItemNumber,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment:
        WrapCrossAlignment.center,
        runSpacing: 8,
        spacing: 12,
        children: [
          _buildInformation(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRowsPerPage(),
              const SizedBox(width: 14),
              _buildPageNavigation(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformation() {
    final information = totalItems == 0
        ? 'Tidak ada aktivitas'
        : 'Menampilkan $firstItemNumber-'
        '$lastItemNumber dari '
        '$totalItems aktivitas';

    return Text(
      information,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRowsPerPage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Baris:',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          height: 32,
          child: DropdownButtonFormField<int>(
            value: rowsPerPage,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(7),
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(7),
                borderSide:
                const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ),
            items: const [
              DropdownMenuItem<int>(
                value: 25,
                child: Text('25'),
              ),
              DropdownMenuItem<int>(
                value: 50,
                child: Text('50'),
              ),
              DropdownMenuItem<int>(
                value: 100,
                child: Text('100'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onRowsPerPageChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageNavigation() {
    final visiblePages = _buildVisiblePages();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavigationButton(
          tooltip: 'Halaman sebelumnya',
          icon: Icons.chevron_left,
          isEnabled: currentPage > 1,
          onPressed: () {
            onPageChanged(currentPage - 1);
          },
        ),
        const SizedBox(width: 4),
        for (var index = 0;
        index < visiblePages.length;
        index++) ...[
          if (visiblePages[index] == null)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: Text(
                '...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            _PageNumberButton(
              page: visiblePages[index]!,
              isSelected:
              visiblePages[index] ==
                  currentPage,
              onPressed: () {
                onPageChanged(
                  visiblePages[index]!,
                );
              },
            ),
          if (index <
              visiblePages.length - 1)
            const SizedBox(width: 4),
        ],
        const SizedBox(width: 4),
        _NavigationButton(
          tooltip: 'Halaman berikutnya',
          icon: Icons.chevron_right,
          isEnabled:
          currentPage < totalPages,
          onPressed: () {
            onPageChanged(currentPage + 1);
          },
        ),
      ],
    );
  }

  List<int?> _buildVisiblePages() {
    if (totalPages <= 7) {
      return [
        for (
        var page = 1;
        page <= totalPages;
        page++
        )
          page,
      ];
    }

    if (currentPage <= 4) {
      return [
        1,
        2,
        3,
        4,
        5,
        null,
        totalPages,
      ];
    }

    if (currentPage >= totalPages - 3) {
      return [
        1,
        null,
        totalPages - 4,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages,
      ];
    }

    return [
      1,
      null,
      currentPage - 1,
      currentPage,
      currentPage + 1,
      null,
      totalPages,
    ];
  }
}

class _PageNumberButton
    extends StatelessWidget {
  final int page;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: isSelected
              ? Colors.white
              : const Color(0xFF334155),
          backgroundColor: isSelected
              ? const Color(0xFF2563EB)
              : Colors.white,
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFCBD5E1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(7),
          ),
        ),
        child: Text(
          page.toString(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NavigationButton
    extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.tooltip,
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: OutlinedButton(
          onPressed:
          isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(7),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
          ),
        ),
      ),
    );
  }
}