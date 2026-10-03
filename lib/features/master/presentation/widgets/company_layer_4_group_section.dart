import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/company_layer_4_group_provider.dart';
import '../../domain/company_layer_4_group_model.dart';
import 'company_layer_4_group_dialog.dart';

class CompanyLayer4GroupSection
    extends ConsumerStatefulWidget {
  const CompanyLayer4GroupSection({
    super.key,
  });

  @override
  ConsumerState<CompanyLayer4GroupSection>
  createState() {
    return _CompanyLayer4GroupSectionState();
  }
}

class _CompanyLayer4GroupSectionState
    extends ConsumerState<
        CompanyLayer4GroupSection> {
  String? processingGroupId;

  bool get isProcessing {
    return processingGroupId != null;
  }

  Future<void> openAddDialog() async {
    if (isProcessing) {
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const CompanyLayer4GroupDialog();
      },
    );

    if (saved != true || !mounted) {
      return;
    }

    showMessage(
      'Gabungan Layer 4 berhasil disimpan.',
    );
  }

  Future<void> updateGroupStatus({
    required CompanyLayer4GroupModel group,
  }) async {
    if (isProcessing) {
      return;
    }

    final nextStatus = !group.isActive;

    final shouldContinue =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            nextStatus
                ? 'Aktifkan Gabungan'
                : 'Nonaktifkan Gabungan',
          ),
          content: Text(
            nextStatus
                ? 'Aktifkan kembali Gabungan '
                'Layer 4 antara '
                '${group.company1Name} dan '
                '${group.company2Name}?'
                : 'Nonaktifkan Gabungan '
                'Layer 4 antara '
                '${group.company1Name} dan '
                '${group.company2Name}?\n\n'
                'Gabungan yang dinonaktifkan '
                'tidak tersedia untuk DOP baru.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                nextStatus
                    ? 'Aktifkan'
                    : 'Nonaktifkan',
              ),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true ||
        !mounted) {
      return;
    }

    setState(() {
      processingGroupId = group.id;
    });

    try {
      final repository = ref.read(
        companyLayer4GroupRepositoryProvider,
      );

      await repository.updateStatus(
        groupId: group.id,
        isActive: nextStatus,
      );

      ref.invalidate(
        companyLayer4GroupsProvider,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        nextStatus
            ? 'Gabungan Layer 4 diaktifkan.'
            : 'Gabungan Layer 4 dinonaktifkan.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingGroupId = null;
        });
      }
    }
  }

  void refresh() {
    ref.invalidate(
      companyLayer4GroupsProvider,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(
      companyLayer4GroupsProvider,
    );

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
          buildHeader(),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: groupsAsync.when(
              loading: () {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              },
              error: (error, stackTrace) {
                return buildError(error);
              },
              data: (groups) {
                if (groups.isEmpty) {
                  return buildEmptyState();
                }

                return buildTable(groups);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
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
              color: const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.link_outlined,
              size: 14,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Gabung Layer 4',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed:
            isProcessing ? null : refresh,
            icon: const Icon(
              Icons.refresh,
              size: 16,
            ),
            label: const Text('Refresh'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isProcessing
                ? null
                : openAddDialog,
            icon: const Icon(
              Icons.add,
              size: 16,
            ),
            label: const Text(
              'Tambah Gabungan',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTable(
      List<CompanyLayer4GroupModel> groups,
      ) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor:
          const WidgetStatePropertyAll(
            Color(0xFFF8FAFC),
          ),
          columns: const [
            DataColumn(
              label: Text('Perusahaan 1'),
            ),
            DataColumn(
              label: Text('Perusahaan 2'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Dibuat Oleh'),
            ),
            DataColumn(
              label: Text('Action'),
            ),
          ],
          rows: groups.map((group) {
            final rowIsProcessing =
                processingGroupId == group.id;

            return DataRow(
              cells: [
                DataCell(
                  Text(group.company1Name),
                ),
                DataCell(
                  Text(group.company2Name),
                ),
                DataCell(
                  buildStatusBadge(group),
                ),
                DataCell(
                  Text(group.createdByName),
                ),
                DataCell(
                  Tooltip(
                    message: group.isActive
                        ? 'Nonaktifkan Gabungan'
                        : 'Aktifkan Gabungan',
                    child: IconButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                        updateGroupStatus(
                          group: group,
                        );
                      },
                      icon: rowIsProcessing
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(
                        group.isActive
                            ? Icons
                            .link_off_outlined
                            : Icons
                            .link_outlined,
                        size: 18,
                        color: group.isActive
                            ? const Color(
                          0xFFDC2626,
                        )
                            : const Color(
                          0xFF059669,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildStatusBadge(
      CompanyLayer4GroupModel group,
      ) {
    final color = group.isActive
        ? const Color(0xFF059669)
        : const Color(0xFF64748B);

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
        BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Text(
        group.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link_off_outlined,
              size: 42,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada Gabungan Layer 4',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Klik Tambah Gabungan untuk '
                  'menghubungkan kandidat Layer 4 '
                  'antara dua perusahaan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: openAddDialog,
              icon: const Icon(
                Icons.add,
                size: 16,
              ),
              label: const Text(
                'Tambah Gabungan',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 36,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 9),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: refresh,
              icon: const Icon(
                Icons.refresh,
                size: 16,
              ),
              label: const Text(
                'Coba Lagi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
