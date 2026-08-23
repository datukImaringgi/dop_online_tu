import 'package:flutter/material.dart';

import 'dop_request_widgets.dart';

class DopHeaderForm extends StatelessWidget {
  final String formattedDate;
  final VoidCallback onDateTap;

  final String? selectedJobSiteId;
  final List<Map<String, dynamic>> jobSites;
  final ValueChanged<String?> onJobSiteChanged;

  const DopHeaderForm({
    super.key,
    required this.formattedDate,
    required this.onDateTap,
    required this.selectedJobSiteId,
    required this.jobSites,
    required this.onJobSiteChanged,
  });

  String _buildJobSiteLabel(Map<String, dynamic> item) {
    return item['site_name'] as String? ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return DopSectionCard(
      title: 'Informasi DOP',
      children: [
        Row(
          children: [
            Expanded(
              child: DopDateField(
                label: 'Tanggal DOP',
                value: formattedDate,
                onTap: onDateTap,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: DopDropdownField(
                label: 'Job Site',
                value: selectedJobSiteId,
                items: jobSites,
                valueKey: 'id',
                labelBuilder: _buildJobSiteLabel,
                onChanged: onJobSiteChanged,
                isRequired: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}