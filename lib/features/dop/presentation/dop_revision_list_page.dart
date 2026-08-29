import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../data/dop_revision_list_provider.dart';
import '../domain/dop_revision_list_item.dart';

class DopRevisionListPage extends ConsumerWidget {
  const DopRevisionListPage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final revisionsAsync = ref.watch(
      dopRevisionListProvider,
    );

    final supabase = ref.watch(
      supabaseProvider,
    );

    final currentUserId =
        supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(ref),
            const SizedBox(height: 18),
            Expanded(
              child: revisionsAsync.when(
                loading: _buildLoading,
                error: _buildError,
                data: (
                    List<DopRevisionListItem> items,
                    ) {
                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _RevisionDocumentList(
                    items: items,
                    currentUserId: currentUserId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Revisi DOP',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Daftar DOP yang dikembalikan '
                    'untuk diperbaiki.',
                style: TextStyle(
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
              dopRevisionListProvider,
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

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(
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
              'Gagal membaca daftar revisi',
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

  Widget _buildEmptyState() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: 44,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 12),
            Text(
              'Tidak ada DOP yang perlu direvisi',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'DOP yang dikembalikan approver '
                  'akan muncul pada halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevisionDocumentList
    extends StatelessWidget {
  final List<DopRevisionListItem> items;
  final String? currentUserId;

  const _RevisionDocumentList({
    required this.items,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (
          BuildContext context,
          int index,
          ) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        return _RevisionDocumentCard(
          item: items[index],
          currentUserId: currentUserId,
        );
      },
    );
  }
}

class _RevisionDocumentCard
    extends StatelessWidget {
  final DopRevisionListItem item;
  final String? currentUserId;

  const _RevisionDocumentCard({
    required this.item,
    required this.currentUserId,
  });

  void handleEdit(BuildContext context) {
    context.go(
      '/dop-request',
      extra: item.dopHeaderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit =
    item.canEdit(currentUserId);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    item.dopNumber,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _RevisionStatusBadge(
                  label: item.statusLabel,
                ),
                if (canEdit) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      handleEdit(context);
                    },
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(0xFFB45309),
                      side: const BorderSide(
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    icon: const Icon(
                      Icons.edit_note_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Edit Revisi',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: [
                _RevisionInfo(
                  label: 'Tanggal DOP',
                  value:
                  '${item.dayName}, ${item.dopDate}',
                ),
                _RevisionInfo(
                  label: 'Perusahaan',
                  value: item.companyName,
                ),
                _RevisionInfo(
                  label: 'Job Site',
                  value: item.jobSite,
                ),
                _RevisionInfo(
                  label: 'Requestor',
                  value:
                  '${item.createdByName} '
                      '(${item.createdBySid})',
                ),
                _RevisionInfo(
                  label: 'Aktivitas',
                  value:
                  '${item.totalActivities} aktivitas',
                ),
                _RevisionInfo(
                  label: 'Tahap Revisi',
                  value: item.revisionLabel,
                ),
                _RevisionInfo(
                  label: 'Dikembalikan Oleh',
                  value:
                  '${item.returnedByLayerLabel} - '
                      '${item.returnedByName}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius:
                BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                ),
              ),
              child: Text(
                'Catatan Revisi: '
                    '${item.revisionNote}',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevisionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _RevisionInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionStatusBadge
    extends StatelessWidget {
  final String label;

  const _RevisionStatusBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius:
        BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC2410C),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}