import 'package:flutter/material.dart';
import 'dop_request_widgets.dart';

class DopMasterAutocomplete extends StatefulWidget {
  final String label;
  final String hintText;

  final TextEditingController controller;
  final List<Map<String, dynamic>> items;

  final String? selectedId;
  final String idKey;

  final String Function(Map<String, dynamic> item) displayBuilder;
  final String Function(Map<String, dynamic> item) searchBuilder;
  final Widget Function(
      BuildContext context,
      Map<String, dynamic> item,
      ) suggestionBuilder;

  final ValueChanged<Map<String, dynamic>> onSelected;
  final VoidCallback onSelectionCleared;

  final bool isRequired;

  const DopMasterAutocomplete({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.items,
    required this.selectedId,
    required this.idKey,
    required this.displayBuilder,
    required this.searchBuilder,
    required this.suggestionBuilder,
    required this.onSelected,
    required this.onSelectionCleared,
    this.isRequired = false,
  });

  @override
  State<DopMasterAutocomplete> createState() {
    return _DopMasterAutocompleteState();
  }
}

class _DopMasterAutocompleteState
    extends State<DopMasterAutocomplete> {
  final FocusNode focusNode = FocusNode();

  bool isSynchronizingController = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(handleTextChanged);
    synchronizeSelectedValue();
  }

  @override
  void didUpdateWidget(
      covariant DopMasterAutocomplete oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(handleTextChanged);
      widget.controller.addListener(handleTextChanged);
    }

    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.items != widget.items) {
      synchronizeSelectedValue();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(handleTextChanged);
    focusNode.dispose();
    super.dispose();
  }

  Map<String, dynamic>? findSelectedItem() {
    if (widget.selectedId == null) {
      return null;
    }

    for (final item in widget.items) {
      if (item[widget.idKey] == widget.selectedId) {
        return item;
      }
    }

    return null;
  }

  void synchronizeSelectedValue() {
    final selectedItem = findSelectedItem();

    if (selectedItem == null) {
      return;
    }

    final expectedText = widget.displayBuilder(selectedItem);

    if (widget.controller.text == expectedText) {
      return;
    }

    isSynchronizingController = true;

    widget.controller.value = TextEditingValue(
      text: expectedText,
      selection: TextSelection.collapsed(
        offset: expectedText.length,
      ),
    );

    isSynchronizingController = false;
  }

  void handleTextChanged() {
    if (isSynchronizingController) {
      return;
    }

    if (widget.selectedId == null) {
      return;
    }

    final selectedItem = findSelectedItem();

    if (selectedItem == null) {
      widget.onSelectionCleared();
      return;
    }

    final selectedText = widget.displayBuilder(selectedItem);
    final currentText = widget.controller.text.trim();

    if (currentText != selectedText.trim()) {
      widget.onSelectionCleared();
    }
  }

  Iterable<Map<String, dynamic>> buildSuggestions(
      TextEditingValue inputValue,
      ) {
    final query = normalizeText(inputValue.text);

    if (query.isEmpty) {
      return widget.items.take(20);
    }

    final results = <Map<String, dynamic>>[];

    for (final item in widget.items) {
      final searchableText = normalizeText(
        widget.searchBuilder(item),
      );

      if (searchableText.contains(query)) {
        results.add(item);
      }

      if (results.length >= 20) {
        break;
      }
    }

    return results;
  }

  String normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String displayStringForOption(
      Map<String, dynamic> item,
      ) {
    return widget.displayBuilder(item);
  }

  void handleSelected(Map<String, dynamic> item) {
    final displayText = widget.displayBuilder(item);

    isSynchronizingController = true;

    widget.controller.value = TextEditingValue(
      text: displayText,
      selection: TextSelection.collapsed(
        offset: displayText.length,
      ),
    );

    isSynchronizingController = false;

    widget.onSelected(item);
  }

  String? validateSelection(String? value) {
    if (!widget.isRequired &&
        (value == null || value.trim().isEmpty)) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return '${widget.label} wajib dipilih';
    }

    if (widget.selectedId == null) {
      return 'Pilih ${widget.label} dari daftar';
    }

    final selectedItem = findSelectedItem();

    if (selectedItem == null) {
      return 'Pilihan ${widget.label} tidak valid';
    }

    final selectedText = widget.displayBuilder(selectedItem);

    if (selectedText.trim() != value.trim()) {
      return 'Pilih ${widget.label} dari daftar';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Map<String, dynamic>>(
      textEditingController: widget.controller,
      focusNode: focusNode,
      displayStringForOption: displayStringForOption,
      optionsBuilder: buildSuggestions,
      onSelected: handleSelected,
      fieldViewBuilder: buildField,
      optionsViewBuilder: buildOptionsView,
    );
  }

  Widget buildField(
      BuildContext context,
      TextEditingController textController,
      FocusNode fieldFocusNode,
      VoidCallback onFieldSubmitted,
      ) {
    return TextFormField(
      controller: textController,
      focusNode: fieldFocusNode,
      validator: validateSelection,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF0F172A),
      ),
      decoration: buildCompactInputDecoration(
        label: widget.label,
        hintText: widget.hintText,
        suffixIcon: const Icon(
          Icons.search,
          size: 17,
        ),
      ),
    );
  }

  Widget buildOptionsView(
      BuildContext context,
      AutocompleteOnSelected<Map<String, dynamic>> onSelected,
      Iterable<Map<String, dynamic>> options,
      ) {
    final optionList = options.toList();

    if (optionList.isEmpty) {
      return buildEmptySuggestion();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 280,
            maxWidth: 460,
            maxHeight: 240,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            shrinkWrap: true,
            itemCount: optionList.length,
            separatorBuilder: buildSeparator,
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final item = optionList[index];

              return InkWell(
                onTap: () {
                  onSelected(item);
                },
                child: widget.suggestionBuilder(
                  context,
                  item,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSeparator(
      BuildContext context,
      int index,
      ) {
    return const Divider(
      height: 1,
      color: Color(0xFFE2E8F0),
    );
  }

  Widget buildEmptySuggestion() {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 360,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Data tidak ditemukan.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}