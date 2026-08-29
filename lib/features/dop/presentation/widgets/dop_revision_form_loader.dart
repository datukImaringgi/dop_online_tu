import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/dop_revision_data.dart';
import '../controllers/dop_revision_form_controller.dart';
import 'dop_revision_notice.dart';

class DopRevisionFormLoader
    extends ConsumerStatefulWidget {
  final String dopHeaderId;

  final ValueChanged<DopRevisionData>
  onRevisionLoaded;

  const DopRevisionFormLoader({
    super.key,
    required this.dopHeaderId,
    required this.onRevisionLoaded,
  });

  @override
  ConsumerState<DopRevisionFormLoader>
  createState() {
    return _DopRevisionFormLoaderState();
  }
}

class _DopRevisionFormLoaderState
    extends ConsumerState<DopRevisionFormLoader> {
  bool hasDeliveredRevision = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      handleInitialLoad,
    );
  }

  @override
  void didUpdateWidget(
      covariant DopRevisionFormLoader oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dopHeaderId ==
        widget.dopHeaderId) {
      return;
    }

    hasDeliveredRevision = false;

    WidgetsBinding.instance.addPostFrameCallback(
      handleHeaderChanged,
    );
  }

  void handleInitialLoad(
      Duration timeStamp,
      ) {
    if (!mounted) {
      return;
    }

    loadRevision();
  }

  void handleHeaderChanged(
      Duration timeStamp,
      ) {
    if (!mounted) {
      return;
    }

    reloadRevision();
  }

  Future<void> loadRevision() async {
    await ref
        .read(
      dopRevisionFormControllerProvider(
        widget.dopHeaderId,
      ).notifier,
    )
        .loadRevision();
  }

  Future<void> reloadRevision() async {
    await ref
        .read(
      dopRevisionFormControllerProvider(
        widget.dopHeaderId,
      ).notifier,
    )
        .reloadRevision();
  }

  void deliverRevisionData(
      DopRevisionData revisionData,
      ) {
    if (hasDeliveredRevision) {
      return;
    }

    hasDeliveredRevision = true;

    WidgetsBinding.instance.addPostFrameCallback(
          (Duration timeStamp) {
        if (!mounted) {
          return;
        }

        widget.onRevisionLoaded(
          revisionData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final revisionState = ref.watch(
      dopRevisionFormControllerProvider(
        widget.dopHeaderId,
      ),
    );

    if (revisionState.isLoading) {
      return buildLoadingState();
    }

    final errorMessage =
        revisionState.errorMessage;

    if (errorMessage != null) {
      return buildErrorState(
        errorMessage,
      );
    }

    final revisionData =
        revisionState.revisionData;

    if (revisionData == null) {
      return buildWaitingState();
    }

    deliverRevisionData(
      revisionData,
    );

    return DopRevisionNotice(
      revisionData: revisionData,
    );
  }

  Widget buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Memuat data revisi DOP...',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWaitingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Text(
        'Menyiapkan data revisi DOP...',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildErrorState(
      String message,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFDC2626),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gagal memuat data revisi',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 13,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: reloadRevision,
            style: OutlinedButton.styleFrom(
              foregroundColor:
              const Color(0xFFB91C1C),
              side: const BorderSide(
                color: Color(0xFFFCA5A5),
              ),
            ),
            icon: const Icon(
              Icons.refresh,
              size: 17,
            ),
            label: const Text(
              'Coba Lagi',
            ),
          ),
        ],
      ),
    );
  }
}