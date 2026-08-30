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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.assignment_return_outlined,
              color: Color(0xFFB45309),
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOP Dikembalikan untuk Revisi',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  buildDocumentInformation(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          buildRevisionBadge(),
        ],
      ),
    );
  }

  Widget buildRevisionNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 26,
            child: Icon(
              Icons.notes_outlined,
              color: Color(0xFFD97706),
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF78350F),
                  fontSize: 11,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(
                    text: 'Catatan Approver: ',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: revisionData.revisionNote,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRevisionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
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
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w700,
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