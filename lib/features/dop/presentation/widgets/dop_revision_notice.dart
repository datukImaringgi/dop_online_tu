import 'package:flutter/material.dart';

import '../../domain/dop_revision_data.dart';

class DopRevisionNotice extends StatelessWidget {
  final DopRevisionData revisionData;

  const DopRevisionNotice({
    super.key,
    required this.revisionData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          buildHeader(),
          const Divider(
            height: 1,
            color: Color(0xFFFDE68A),
          ),
          buildRevisionNote(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.assignment_return_outlined,
              color: Color(0xFFB45309),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOP Dikembalikan untuk Revisi',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  buildDocumentInformation(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          buildRevisionBadge(),
        ],
      ),
    );
  }

  Widget buildRevisionNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 34,
            child: Icon(
              Icons.notes_outlined,
              color: Color(0xFFD97706),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan dari Approver',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  revisionData.revisionNote,
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRevisionBadge() {
    return Container(
        padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
        ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
        color: const Color(0xFFFDBA74),
        ),
      ),
      child: Text(
        revisionLabel,
        maxLines: 1, 
        style: const TextStyle(
          color: Color(0xFFC2410C),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String buildDocumentInformation() {
    return '${revisionData.dopNumber} • '
        '${revisionData.dayName}, '
        '${formatDate(revisionData.dopDate)}';
  }

  String get revisionLabel {
    final nextRevisionNumber =
        revisionData.revisionNumber + 1;

    return 'Revisi $nextRevisionNumber';
  }

  String formatDate(DateTime date) {
    final year = date.year
        .toString()
        .padLeft(4, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    final day = date.day
        .toString()
        .padLeft(2, '0');

    return '$year-$month-$day';
  }
}