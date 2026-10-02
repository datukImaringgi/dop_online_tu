import 'package:flutter/material.dart';

import '../../data/dop_list_provider.dart';

class DopListFilterBar extends StatelessWidget {
  final List<String> companyOptions;
  final List<String> siteOptions;
  final List<String> unitTypeOptions;
  final List<String> unitNumberOptions;
  final List<String> areaTypeOptions;
  final List<String> shiftOptions;
  final List<String> statusOptions;

  final String selectedCompany;
  final String selectedSite;
  final String selectedUnitType;
  final String selectedUnitNumber;
  final String selectedAreaType;
  final String selectedShift;
  final String selectedStatus;
  final DopListPeriod selectedPeriod;
  final String customDateRangeLabel;

  final ValueChanged<DopListPeriod>
  onPeriodChanged;

  final VoidCallback onCustomDateRangeTap;

  final ValueChanged<String> onCompanyChanged;
  final ValueChanged<String> onSiteChanged;
  final ValueChanged<String> onUnitTypeChanged;
  final ValueChanged<String> onUnitNumberChanged;
  final ValueChanged<String> onAreaTypeChanged;
  final ValueChanged<String> onShiftChanged;
  final ValueChanged<String> onStatusChanged;

  const DopListFilterBar({
    super.key,
    required this.companyOptions,
    required this.siteOptions,
    required this.unitTypeOptions,
    required this.unitNumberOptions,
    required this.areaTypeOptions,
    required this.shiftOptions,
    required this.statusOptions,
    required this.selectedCompany,
    required this.selectedSite,
    required this.selectedUnitType,
    required this.selectedUnitNumber,
    required this.selectedAreaType,
    required this.selectedShift,
    required this.selectedStatus,
    required this.selectedPeriod,
    required this.customDateRangeLabel,
    required this.onCompanyChanged,
    required this.onPeriodChanged,
    required this.onCustomDateRangeTap,
    required this.onSiteChanged,
    required this.onUnitTypeChanged,
    required this.onUnitNumberChanged,
    required this.onAreaTypeChanged,
    required this.onShiftChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: buildFilterLayout,
        ),
      ),
    );
  }

  Widget buildFilterLayout(
      BuildContext context,
      BoxConstraints constraints,
      ) {
    final fieldWidth = calculateFieldWidth(
      constraints.maxWidth,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        buildPeriodField(
          width: fieldWidth,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Perusahaan',
          value: selectedCompany,
          items: companyOptions,
          onChanged: onCompanyChanged,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Site',
          value: selectedSite,
          items: siteOptions,
          onChanged: onSiteChanged,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Type Unit',
          value: selectedUnitType,
          items: unitTypeOptions,
          onChanged: onUnitTypeChanged,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Nomor Kendaraan',
          value: selectedUnitNumber,
          items: unitNumberOptions,
          onChanged: onUnitNumberChanged,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Area Type',
          value: selectedAreaType,
          items: areaTypeOptions,
          onChanged: onAreaTypeChanged,
          formatLabel: formatAreaType,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Shift',
          value: selectedShift,
          items: shiftOptions,
          onChanged: onShiftChanged,
        ),
        buildFieldBox(
          width: fieldWidth,
          label: 'Status Approval',
          value: selectedStatus,
          items: statusOptions,
          onChanged: onStatusChanged,
          formatLabel: formatStatus,
        ),
      ],
    );
  }

  double calculateFieldWidth(double availableWidth) {
    if (availableWidth < 600) {
      return availableWidth;
    }

    return (availableWidth - 56) / 8;
  }

  Widget buildFieldBox({
    required double width,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String Function(String value)? formatLabel,
  }) {
    return SizedBox(
      width: width,
      child: _DopListFilterAutocomplete(
        label: label,
        value: value,
        items: items,
        onChanged: onChanged,
        formatLabel: formatLabel,
      ),
    );
  }

  Widget buildPeriodField({
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<
          DopListPeriod>(
        value: selectedPeriod,
        isExpanded: true,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Periode',
          labelStyle: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
          ),
          prefixIcon: const Icon(
            Icons.date_range_outlined,
            size: 15,
          ),
          prefixIconConstraints:
          const BoxConstraints(
            minWidth: 30,
            minHeight: 30,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF0D6EFD),
            ),
          ),
        ),
        items: [
          for (final period
          in DopListPeriod.values)
            DropdownMenuItem<DopListPeriod>(
              value: period,
              child: Text(
                period ==
                    DopListPeriod.custom &&
                    customDateRangeLabel
                        .isNotEmpty
                    ? customDateRangeLabel
                    : period.label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (period) {
          if (period == null) {
            return;
          }

          onPeriodChanged(period);

          if (period ==
              DopListPeriod.custom) {
            onCustomDateRangeTap();
          }
        },
      ),
    );
  }

  String formatAreaType(String value) {
    if (value == 'jalan_negara') {
      return 'Area Jalan Negara';
    }

    if (value == 'site') {
      return 'Area Site';
    }

    return value;
  }

  String formatStatus(String value) {
    if (value == 'pending_layer_3') {
      return 'Approval Layer 3';
    }

    if (value == 'pending_layer_4') {
      return 'Approval Layer 4';
    }

    if (value == 'revision_required') {
      return 'Perlu Revisi';
    }

    if (value == 'approved') {
      return 'Approved';
    }

    if (value == 'rejected') {
      return 'Rejected';
    }

    if (value == 'submitted') {
      return 'Submitted';
    }

    if (value == 'cancelled') {
      return 'Cancelled';
    }

    if (value == 'draft') {
      return 'Draft';
    }

    return value;
  }
}

class _DopListFilterAutocomplete
    extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String Function(String value)? formatLabel;

  const _DopListFilterAutocomplete({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.formatLabel,
  });

  String displayOption(String option) {
    if (formatLabel == null) {
      return option;
    }

    return formatLabel!(option);
  }

  Iterable<String> buildOptions(
      TextEditingValue inputValue,
      ) {
    final query =
    inputValue.text.trim().toLowerCase();

    if (query.isEmpty) {
      return items.take(8);
    }

    final results = <String>[];

    for (final item in items) {
      final searchableText =
      displayOption(item).toLowerCase();

      if (searchableText.contains(query)) {
        results.add(item);
      }

      if (results.length >= 8) {
        break;
      }
    }

    return results;
  }

  void handleSelected(String selectedValue) {
    onChanged(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: ValueKey<String>(
        '$label-$value',
      ),
      initialValue: TextEditingValue(
        text: displayOption(value),
      ),
      displayStringForOption: displayOption,
      optionsBuilder: buildOptions,
      optionsViewBuilder: buildOptionsView,
      onSelected: handleSelected,
      fieldViewBuilder: buildField,
    );
  }

  Widget buildOptionsView(
      BuildContext context,
      AutocompleteOnSelected<String> onSelected,
      Iterable<String> options,
      ) {
    final optionList = options.toList();
    final optionWidgets = <Widget>[];

    for (final option in options) {
      optionWidgets.add(
        InkWell(
          onTap: () {
            onSelected(option);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Text(
              displayOption(option),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 145,
            maxWidth: 240,
            maxHeight: 220,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            shrinkWrap: true,
            itemCount: optionList.length,
            itemBuilder: (
                BuildContext itemContext,
                int index,
                ) {
              final option = optionList[index];

              final highlightedIndex =
              AutocompleteHighlightedOption.of(
                itemContext,
              );

              final isHighlighted =
                  highlightedIndex == index;

              return Material(
                color: isHighlighted
                    ? const Color(0xFFE0F2FE)
                    : Colors.white,
                child: InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Text(
                      displayOption(option),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildField(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
      ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTap: controller.clear,
      onSubmitted: (value) {
        onFieldSubmitted();
      },
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 11,
        height: 1,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 10,
          color: Color(0xFF64748B),
        ),
        suffixIcon: const Icon(
          Icons.search,
          size: 15,
        ),
        suffixIconConstraints:
        const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 7,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFFCBD5E1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFF0D6EFD),
          ),
        ),
      ),
    );
  }

  void handleSubmitted(String submittedText) {
    final normalizedText =
    submittedText.trim().toLowerCase();

    for (final item in items) {
      final normalizedOption =
      displayOption(item)
          .trim()
          .toLowerCase();

      if (normalizedOption ==
          normalizedText) {
        onChanged(item);
        return;
      }
    }
  }
}