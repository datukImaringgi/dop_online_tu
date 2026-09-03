import 'package:flutter/material.dart';

InputDecoration buildCompactInputDecoration({
  required String label,
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    isDense: true,
    floatingLabelBehavior:
    FloatingLabelBehavior.auto,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 9,
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 10.5,
      height: 1,
    ),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF2563EB),
      fontSize: 10.5,
      height: 1,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 11.5,
    ),
    errorStyle: const TextStyle(
      fontSize: 9.5,
      height: 1,
    ),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(
      minWidth: 34,
      minHeight: 34,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFCBD5E1),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFF2563EB),
        width: 1.25,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
        width: 1.25,
      ),
    ),
  );
}

class DopSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DopSectionCard({
    super.key,
    required this.title,
    required this.children,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class DopGridSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? footer;

  const DopGridSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: children,
            ),
          ),
          if (footer != null) ...[
            const Divider(
              height: 1,
              color: Color(0xFFE2E8F0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              child: footer!,
            ),
          ],
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
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DopFormGridRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flexValues;
  final double spacing;

  const DopFormGridRow({
    super.key,
    required this.children,
    this.flexValues,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final rowChildren = <Widget>[];

    for (var index = 0;
    index < children.length;
    index++) {
      var flex = 1;

      if (flexValues != null &&
          index < flexValues!.length) {
        flex = flexValues![index];
      }

      rowChildren.add(
        Expanded(
          flex: flex,
          child: children[index],
        ),
      );

      if (index < children.length - 1) {
        rowChildren.add(
          SizedBox(width: spacing),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }
}

class DopFormGridDivider extends StatelessWidget {
  final double verticalPadding;

  const DopFormGridDivider({
    super.key,
    this.verticalPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
      ),
      child: const Divider(
        height: 1,
        color: Color(0xFFE2E8F0),
      ),
    );
  }
}

class DopDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> items;
  final String valueKey;
  final String Function(Map<String, dynamic> item) labelBuilder;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const DopDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.valueKey,
    required this.labelBuilder,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      iconSize: 0,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12.5,
      ),
      decoration: buildCompactInputDecoration(
        label: label,
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          size: 17,
        ),
      ),
      items: _buildItems(),
      validator: _validate,
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<String>> _buildItems() {
    final dropdownItems = <DropdownMenuItem<String>>[];

    for (final item in items) {
      final itemValue = item[valueKey] as String?;

      if (itemValue == null) {
        continue;
      }

      dropdownItems.add(
        DropdownMenuItem<String>(
          value: itemValue,
          child: Text(
            labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return dropdownItems;
  }

  String? _validate(String? selectedValue) {
    if (!isRequired) {
      return null;
    }

    if (selectedValue == null || selectedValue.isEmpty) {
      return '$label wajib dipilih';
    }

    return null;
  }
}

class DopSimpleDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  const DopSimpleDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  void _handleChanged(String? selectedValue) {
    if (selectedValue == null) {
      return;
    }

    onChanged(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      iconSize: 0,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12.5,
      ),
      decoration: buildCompactInputDecoration(
        label: label,
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          size: 17,
        ),
      ),
      items: items,
      onChanged: _handleChanged,
    );
  }
}

class DopDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const DopDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: buildCompactInputDecoration(
          label: label,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            size: 17,
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

class DopTimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isRequired;

  const DopTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isRequired = false,
  });

  String? validateTime(String? currentValue) {
    if (!isRequired) {
      return null;
    }

    final latestValue = value.trim();

    if (latestValue.isEmpty ||
        latestValue == '-') {
      return '$label wajib dipilih';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ValueKey<String>(
        '$label-$value',
      ),
      initialValue: value,
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
      validator: validateTime,
      builder: (
          FormFieldState<String> fieldState,
          ) {
        return InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(4),
          child: InputDecorator(
            isEmpty:
            value.isEmpty || value == '-',
            decoration:
            buildCompactInputDecoration(
              label: label,
              suffixIcon: const Icon(
                Icons.schedule_outlined,
                size: 17,
              ),
            ).copyWith(
              errorText:
              fieldState.errorText,
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DopEmployeeDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> employees;
  final ValueChanged<String?> onChanged;

  const DopEmployeeDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.employees,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: _buildItems(),
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<String>> _buildItems() {
    final dropdownItems = <DropdownMenuItem<String>>[];

    for (final employee in employees) {
      final employeeId = employee['id'] as String?;

      if (employeeId == null) {
        continue;
      }

      final profile = employee['profiles'] as Map<String, dynamic>?;
      final fullName = profile?['full_name'] as String? ?? '-';
      final sid = profile?['sid'] as String? ?? '-';

      dropdownItems.add(
        DropdownMenuItem<String>(
          value: employeeId,
          child: Text(
            '$fullName - $sid',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return dropdownItems;
  }
}