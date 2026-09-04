import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class DashboardFilters extends StatelessWidget {
  final bool isLayerFive;
  final String companyName;
  final String? selectedCompanyId;
  final String? selectedJobSiteId;
  final DashboardPeriod selectedPeriod;
  final Map<String, String> companyOptions;
  final Map<String, String> jobSiteOptions;
  final ValueChanged<String?> onCompanyChanged;
  final ValueChanged<String?> onJobSiteChanged;
  final ValueChanged<DashboardPeriod?>
  onPeriodChanged;
  final VoidCallback onReset;

  const DashboardFilters({
    super.key,
    required this.isLayerFive,
    required this.companyName,
    required this.selectedCompanyId,
    required this.selectedJobSiteId,
    required this.selectedPeriod,
    required this.companyOptions,
    required this.jobSiteOptions,
    required this.onCompanyChanged,
    required this.onJobSiteChanged,
    required this.onPeriodChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 190,
          child: buildCompanyField(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: buildJobSiteField(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: buildPeriodField(),
        ),
        const SizedBox(width: 8),
        buildResetButton(),
      ],
    );
  }

  Widget buildCompanyField() {
    if (!isLayerFive) {
      return InputDecorator(
        decoration: buildDecoration(
          label: 'Perusahaan',
          icon: Icons.business_outlined,
        ),
        child: Text(
          companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String?>(
      value: selectedCompanyId,
      isExpanded: true,
      iconSize: 18,
      style: fieldTextStyle,
      decoration: buildDecoration(
        label: 'Perusahaan',
        icon: Icons.business_outlined,
      ),
      items: buildCompanyItems(),
      onChanged: onCompanyChanged,
    );
  }

  Widget buildJobSiteField() {
    return DropdownButtonFormField<String?>(
      value: selectedJobSiteId,
      isExpanded: true,
      iconSize: 18,
      style: fieldTextStyle,
      decoration: buildDecoration(
        label: 'Job Site',
        icon: Icons.location_on_outlined,
      ),
      items: buildJobSiteItems(),
      onChanged: onJobSiteChanged,
    );
  }

  Widget buildPeriodField() {
    return DropdownButtonFormField<
        DashboardPeriod>(
      value: selectedPeriod,
      isExpanded: true,
      iconSize: 18,
      style: fieldTextStyle,
      decoration: buildDecoration(
        label: 'Periode',
        icon: Icons.date_range_outlined,
      ),
      items: const [
        DropdownMenuItem<DashboardPeriod>(
          value: DashboardPeriod.all,
          child: Text('Semua Periode'),
        ),
        DropdownMenuItem<DashboardPeriod>(
          value: DashboardPeriod.tomorrow,
          child: Text('Esok Hari'),
        ),
        DropdownMenuItem<DashboardPeriod>(
          value: DashboardPeriod.today,
          child: Text('Hari Ini'),
        ),
        DropdownMenuItem<DashboardPeriod>(
          value: DashboardPeriod.currentWeek,
          child: Text('Pekan Ini'),
        ),
        DropdownMenuItem<DashboardPeriod>(
          value: DashboardPeriod.currentMonth,
          child: Text('Bulan Ini'),
        ),
      ],
      onChanged: onPeriodChanged,
    );
  }

  Widget buildResetButton() {
    return Tooltip(
      message: 'Reset filter',
      child: SizedBox(
        width: 36,
        height: 36,
        child: OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor:
            const Color(0xFF475569),
            side: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
          child: const Icon(
            Icons.refresh,
            size: 17,
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String?>>
  buildCompanyItems() {
    final items =
    <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Perusahaan'),
      ),
    ];

    final companyIds =
    companyOptions.keys.toList();

    companyIds.sort(
      compareCompanyNames,
    );

    for (final companyId in companyIds) {
      items.add(
        DropdownMenuItem<String?>(
          value: companyId,
          child: Text(
            companyOptions[companyId] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  int compareCompanyNames(
      String firstId,
      String secondId,
      ) {
    final firstName =
        companyOptions[firstId] ?? '';

    final secondName =
        companyOptions[secondId] ?? '';

    return firstName.compareTo(secondName);
  }

  List<DropdownMenuItem<String?>>
  buildJobSiteItems() {
    final items =
    <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Semua Job Site'),
      ),
    ];

    final jobSiteIds =
    jobSiteOptions.keys.toList();

    jobSiteIds.sort(
      compareJobSiteNames,
    );

    for (final jobSiteId in jobSiteIds) {
      items.add(
        DropdownMenuItem<String?>(
          value: jobSiteId,
          child: Text(
            jobSiteOptions[jobSiteId] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  int compareJobSiteNames(
      String firstId,
      String secondId,
      ) {
    final firstName =
        jobSiteOptions[firstId] ?? '';

    final secondName =
        jobSiteOptions[secondId] ?? '';

    return firstName.compareTo(secondName);
  }

  InputDecoration buildDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: Icon(
        icon,
        size: 16,
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 9.5,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.25,
        ),
      ),
    );
  }

  TextStyle get fieldTextStyle {
    return const TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
    );
  }
}