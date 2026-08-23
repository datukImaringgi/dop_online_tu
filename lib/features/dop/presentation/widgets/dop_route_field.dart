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

  void handleRouteSelected(Map<String, dynamic> route) {
    final routeId = route['id'] as String?;
    final routeName = route['route_name'] as String? ?? '';

    widget.controller.text = routeName;
    widget.onRouteIdChanged(routeId);
  }

  void handleTextChanged() {
    final currentText = widget.controller.text.trim();

    if (widget.selectedRouteId == null) {
      return;
    }

    Map<String, dynamic>? selectedRoute;

    for (final route in widget.routes) {
      if (route['id'] == widget.selectedRouteId) {
        selectedRoute = route;
        break;
      }
    }

    if (selectedRoute == null) {
      widget.onRouteIdChanged(null);
      return;
    }

    final selectedRouteName =
        selectedRoute['route_name'] as String? ?? '';

    if (currentText != selectedRouteName) {
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
    return RawAutocomplete<Map<String, dynamic>>(
      textEditingController: widget.controller,
      focusNode: routeFocusNode,
      displayStringForOption: displayRoute,
      optionsBuilder: buildSuggestions,
      onSelected: handleRouteSelected,
      fieldViewBuilder: buildField,
      optionsViewBuilder: buildOptionsView,
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
        fontSize: 14,
        color: Color(0xFF0F172A),
      ),
      decoration: buildCompactInputDecoration(
        label: 'Rute',
        hintText: 'Pilih suggestion atau ketik rute baru',
        suffixIcon: const Icon(
          Icons.route_outlined,
          size: 20,
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
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 240,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            itemCount: optionList.length,
            itemBuilder: (context, index) {
              final route = optionList[index];
              final routeName =
                  route['route_name'] as String? ?? '-';

              return ListTile(
                dense: true,
                leading: const Icon(Icons.route_outlined),
                title: Text(routeName),
                onTap: () {
                  onSelected(route);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}