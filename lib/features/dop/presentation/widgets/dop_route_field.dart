import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dop_request_widgets.dart';

class DopRouteField extends StatefulWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> routes;
  final String? selectedRouteId;
  final ValueChanged<String?> onRouteIdChanged;

  const DopRouteField({
    super.key,
    required this.controller,
    required this.routes,
    required this.selectedRouteId,
    required this.onRouteIdChanged,
  });

  @override
  State<DopRouteField> createState() {
    return _DopRouteFieldState();
  }
}

class _DopRouteFieldState extends State<DopRouteField> {
  final FocusNode routeFocusNode = FocusNode();

  Iterable<Map<String, dynamic>> buildSuggestions(
      TextEditingValue inputValue,
      ) {
    final query = inputValue.text.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.routes;
    }

    final matches = <Map<String, dynamic>>[];

    for (final route in widget.routes) {
      final routeName = route['route_name'] as String? ?? '';

      if (routeName.toLowerCase().contains(query)) {
        matches.add(route);
      }
    }

    return matches;
  }

  String displayRoute(Map<String, dynamic> route) {
    return route['route_name'] as String? ?? '';
  }

  Map<String, dynamic>? findSelectedRoute() {
    if (widget.selectedRouteId == null) {
      return null;
    }

    for (final route in widget.routes) {
      if (route['id'] ==
          widget.selectedRouteId) {
        return route;
      }
    }

    return null;
  }

  bool hasValidRouteSelection() {
    final selectedRoute =
    findSelectedRoute();

    if (selectedRoute == null) {
      return false;
    }

    final selectedRouteName =
    displayRoute(selectedRoute);

    return widget.controller.text.trim() ==
        selectedRouteName.trim();
  }

  Map<String, dynamic>?
  findFirstVisibleRoute() {
    final suggestions = buildSuggestions(
      widget.controller.value,
    );

    for (final route in suggestions) {
      return route;
    }

    return null;
  }

  KeyEventResult handleKeyboardEvent(
      FocusNode node,
      KeyEvent event,
      ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isEnter =
        event.logicalKey ==
            LogicalKeyboardKey.enter ||
            event.logicalKey ==
                LogicalKeyboardKey.numpadEnter;

    final isTab =
        event.logicalKey ==
            LogicalKeyboardKey.tab;

    if (!isEnter && !isTab) {
      return KeyEventResult.ignored;
    }

    if (hasValidRouteSelection()) {
      return KeyEventResult.ignored;
    }

    final firstRoute =
    findFirstVisibleRoute();

    if (firstRoute == null) {
      return KeyEventResult.ignored;
    }

    handleRouteSelected(firstRoute);

    if (isEnter) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void handleRouteSelected(Map<String, dynamic> route) {
    final routeId = route['id'] as String?;
    final routeName = route['route_name'] as String? ?? '';

    widget.controller.text = routeName;
    widget.onRouteIdChanged(routeId);
  }

  void handleTextChanged() {
    final currentText =
    widget.controller.text.trim();

    if (widget.selectedRouteId == null) {
      return;
    }

    final selectedRoute =
    findSelectedRoute();

    if (selectedRoute == null) {
      widget.onRouteIdChanged(null);
      return;
    }

    final selectedRouteName =
    displayRoute(selectedRoute);

    if (currentText !=
        selectedRouteName.trim()) {
      widget.onRouteIdChanged(null);
    }
  }

  String? validateRoute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rute wajib diisi';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant DopRouteField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(handleTextChanged);
    widget.controller.addListener(handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(handleTextChanged);
    routeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onKeyEvent: handleKeyboardEvent,
      child: RawAutocomplete< Map<String, dynamic>>(
        textEditingController: widget.controller,
        focusNode: routeFocusNode,
        displayStringForOption: displayRoute,
        optionsBuilder: buildSuggestions,
        onSelected: handleRouteSelected,
        fieldViewBuilder: buildField,
        optionsViewBuilder: buildOptionsView,
      ),
    );
  }

  Widget buildField(
      BuildContext context,
      TextEditingController textController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
      ) {
    return TextFormField(
      controller: textController,
      focusNode: focusNode,
      validator: validateRoute,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF0F172A),
      ),
      decoration: buildCompactInputDecoration(
        label: 'Rute',
        hintText: 'Pilih suggestion atau ketik rute baru',
        suffixIcon: const Icon(
          Icons.route_outlined,
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
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
            maxHeight: 220,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: optionList.length,
            itemBuilder: (context, index) {
              final route = optionList[index];
              final routeName =
                  route['route_name'] as String? ?? '-';

              return ListTile(
                dense: true,
                onTap: () {
                  onSelected(route);
                },
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                leading: const Icon(
                  Icons.route_outlined,
                  size: 17,
                ),
                title: Text(
                  routeName,
                  style: const TextStyle(
                    fontSize: 11.5,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}