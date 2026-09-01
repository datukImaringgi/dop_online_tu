import 'package:flutter/material.dart';

import '../../data/active_companies_provider.dart';

class CompanyAutocompleteField
    extends StatefulWidget {
  final List<ActiveCompanyOption> companies;
  final String? selectedCompanyId;
  final bool enabled;
  final ValueChanged<ActiveCompanyOption>
  onSelected;

  const CompanyAutocompleteField({
    super.key,
    required this.companies,
    required this.selectedCompanyId,
    required this.enabled,
    required this.onSelected,
  });

  @override
  State<CompanyAutocompleteField> createState() {
    return _CompanyAutocompleteFieldState();
  }
}

class _CompanyAutocompleteFieldState
    extends State<CompanyAutocompleteField> {
  final focusNode = FocusNode();
  final textController = TextEditingController();

  bool isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    synchronizeSelectedCompany();
  }

  @override
  void didUpdateWidget(
      CompanyAutocompleteField oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    final selectionChanged =
        oldWidget.selectedCompanyId !=
            widget.selectedCompanyId;

    final companyListChanged =
        oldWidget.companies != widget.companies;

    if (selectionChanged ||
        companyListChanged) {
      synchronizeSelectedCompany();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  void synchronizeSelectedCompany() {
    final selectedCompany =
    findCompanyById(
      widget.selectedCompanyId,
    );

    final nextText =
        selectedCompany?.displayName ?? '';

    if (textController.text == nextText) {
      return;
    }

    isInternalUpdate = true;

    textController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(
        offset: nextText.length,
      ),
    );

    isInternalUpdate = false;
  }

  ActiveCompanyOption? findCompanyById(
      String? companyId,
      ) {
    if (companyId == null ||
        companyId.isEmpty) {
      return null;
    }

    for (final company in widget.companies) {
      if (company.id == companyId) {
        return company;
      }
    }

    return null;
  }

  String displayCompany(
      ActiveCompanyOption company,
      ) {
    return company.displayName;
  }

  Iterable<ActiveCompanyOption>
  buildOptions(
      TextEditingValue textEditingValue,
      ) {
    final query =
    normalizeText(textEditingValue.text);

    if (query.isEmpty) {
      return widget.companies;
    }

    final matches = <ActiveCompanyOption>[];

    for (final company in widget.companies) {
      final normalizedName =
      normalizeText(company.companyName);

      final normalizedCode =
      normalizeText(company.companyCode);

      final normalizedDisplay =
      normalizeText(company.displayName);

      if (normalizedName.contains(query) ||
          normalizedCode.contains(query) ||
          normalizedDisplay.contains(query)) {
        matches.add(company);
      }
    }

    return matches;
  }

  String normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  void handleSelected(
      ActiveCompanyOption company,
      ) {
    textController.value = TextEditingValue(
      text: company.displayName,
      selection: TextSelection.collapsed(
        offset: company.displayName.length,
      ),
    );

    widget.onSelected(company);
  }

  void handleTextChanged(String value) {
    if (isInternalUpdate) {
      return;
    }

    final selectedCompany =
    findCompanyById(
      widget.selectedCompanyId,
    );

    if (selectedCompany == null) {
      return;
    }

    if (value == selectedCompany.displayName) {
      return;
    }
  }

  String? validateCompanyText(
      String? value,
      ) {
    final selectedCompany =
    findCompanyById(
      widget.selectedCompanyId,
    );

    if (value == null ||
        value.trim().isEmpty ||
        selectedCompany == null) {
      return 'Perusahaan wajib dipilih';
    }

    if (value.trim() !=
        selectedCompany.displayName) {
      return 'Pilih perusahaan dari daftar';
    }

    return null;
  }

  Widget buildFieldView(
      BuildContext context,
      TextEditingController controller,
      FocusNode rawFocusNode,
      VoidCallback onFieldSubmitted,
      ) {
    if (controller.text !=
        textController.text) {
      controller.value =
          textController.value;
    }

    return TextFormField(
      controller: controller,
      focusNode: rawFocusNode,
      enabled: widget.enabled,
      onChanged: handleTextChanged,
      validator: validateCompanyText,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: 'Perusahaan',
        hintText:
        'Ketik nama atau kode perusahaan',
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(
          Icons.business_outlined,
          size: 19,
        ),
        prefixIconConstraints:
        const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: const Icon(
          Icons.search,
          size: 18,
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFCBD5E1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF0D6EFD),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget buildOptionsView(
      BuildContext context,
      AutocompleteOnSelected<
          ActiveCompanyOption> onSelected,
      Iterable<ActiveCompanyOption> options,
      ) {
    final optionList = options.toList();

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
            maxHeight: 240,
          ),
          child: optionList.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Perusahaan tidak ditemukan',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          )
              : ListView.builder(
            padding:
            const EdgeInsets.symmetric(
              vertical: 6,
            ),
            shrinkWrap: true,
            itemCount: optionList.length,
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final company =
              optionList[index];

              return ListTile(
                dense: true,
                leading: const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                title: Text(
                  company.companyName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  company.companyCode,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
                onTap: () {
                  onSelected(company);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCompany =
    findCompanyById(
      widget.selectedCompanyId,
    );

    return Autocomplete<ActiveCompanyOption>(
      initialValue: TextEditingValue(
        text:
        selectedCompany?.displayName ?? '',
      ),
      displayStringForOption: displayCompany,
      optionsBuilder: buildOptions,
      onSelected: handleSelected,
      fieldViewBuilder: buildFieldView,
      optionsViewBuilder: buildOptionsView,
    );
  }
}