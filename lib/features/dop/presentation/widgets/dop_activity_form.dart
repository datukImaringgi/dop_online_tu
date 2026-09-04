import 'package:flutter/material.dart';

import 'dop_request_widgets.dart';
import 'dop_route_field.dart';
import 'dop_master_autocomplete.dart';

class DopActivityForm extends StatelessWidget {
  final TextEditingController workPlanController;
  final TextEditingController observerController;
  final TextEditingController notesController;
  final TextEditingController routeController;
  final TextEditingController unitController;
  final TextEditingController driverController;
  final TextEditingController layer1Controller;
  final TextEditingController layer2Controller;
  final TextEditingController layer3Controller;
  final TextEditingController layer4Controller;

  final String selectedAreaType;
  final String selectedShift;

  final String? selectedUnitId;
  final String? selectedDriverId;
  final String? selectedRouteId;
  final String? selectedJsaId;
  final String? selectedControlRoomId;

  final String? selectedLayer1UserId;
  final String? selectedLayer2UserId;
  final String? selectedLayer3UserId;
  final String? selectedLayer4UserId;

  final String startTimeText;
  final String endTimeText;

  final List<Map<String, dynamic>> units;
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> routes;
  final List<Map<String, dynamic>> jsaProcedures;
  final List<Map<String, dynamic>> controlRooms;
  final List<Map<String, dynamic>> employees;

  final bool isSubmitting;
  final bool isEditing;

  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onShiftChanged;

  final ValueChanged<String?> onUnitChanged;
  final ValueChanged<String?> onDriverChanged;
  final ValueChanged<String?> onRouteIdChanged;
  final ValueChanged<String?> onJsaChanged;
  final ValueChanged<String?> onControlRoomChanged;

  final ValueChanged<String?> onLayer1Changed;
  final ValueChanged<String?> onLayer2Changed;
  final ValueChanged<String?> onLayer3Changed;
  final ValueChanged<String?> onLayer4Changed;

  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final VoidCallback onClear;
  final VoidCallback onAddOrUpdate;

  const DopActivityForm({
    super.key,
    required this.workPlanController,
    required this.observerController,
    required this.notesController,
    required this.routeController,
    required this.unitController,
    required this.driverController,
    required this.layer1Controller,
    required this.layer2Controller,
    required this.layer3Controller,
    required this.layer4Controller,
    required this.onRouteIdChanged,
    required this.selectedAreaType,
    required this.selectedShift,
    required this.selectedUnitId,
    required this.selectedDriverId,
    required this.selectedRouteId,
    required this.selectedJsaId,
    required this.selectedControlRoomId,
    required this.selectedLayer1UserId,
    required this.selectedLayer2UserId,
    required this.selectedLayer3UserId,
    required this.selectedLayer4UserId,
    required this.startTimeText,
    required this.endTimeText,
    required this.units,
    required this.drivers,
    required this.routes,
    required this.jsaProcedures,
    required this.controlRooms,
    required this.employees,
    required this.isSubmitting,
    required this.isEditing,
    required this.onAreaChanged,
    required this.onShiftChanged,
    required this.onUnitChanged,
    required this.onDriverChanged,
    required this.onJsaChanged,
    required this.onControlRoomChanged,
    required this.onLayer1Changed,
    required this.onLayer2Changed,
    required this.onLayer3Changed,
    required this.onLayer4Changed,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onClear,
    required this.onAddOrUpdate,
  });

  bool isExpired(String? dateValue) {
    if (dateValue == null || dateValue.trim().isEmpty) {
      return false;
    }

    final date = DateTime.tryParse(dateValue);

    if (date == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiredDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return expiredDate.isBefore(today);
  }

  String? validateObserver(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Observer wajib diisi';
    }

    return null;
  }

  String _buildJsaLabel(Map<String, dynamic> item) {
    final code = item['procedure_code'] as String? ?? '-';
    final name = item['procedure_name'] as String? ?? '-';

    return '$code - $name';
  }

  String _buildControlRoomLabel(Map<String, dynamic> item) {
    return item['control_room_name'] as String? ?? '-';
  }

  String? _validateWorkPlan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rencana pekerjaan wajib diisi';
    }

    return null;
  }

  String buildUnitDisplay(
      Map<String, dynamic> item,
      ) {
    final unitNumber =
        item['unit_number'] as String? ?? '-';

    final unitType =
        item['unit_type'] as String? ?? '-';

    return '$unitNumber ($unitType)';
  }

  String buildUnitSearch(
      Map<String, dynamic> item,
      ) {
    final unitNumber =
        item['unit_number'] as String? ?? '';

    final unitType =
        item['unit_type'] as String? ?? '';

    final ownerCompany =
        item['owner_company'] as String? ?? '';

    return '$unitNumber $unitType $ownerCompany';
  }

  String buildDriverDisplay(
      Map<String, dynamic> item,
      ) {
    final driverName =
        item['driver_name'] as String? ?? '-';

    final sid =
        item['sid'] as String? ?? '-';

    return '$driverName - $sid';
  }

  String buildDriverSearch(
      Map<String, dynamic> item,
      ) {
    final driverName =
        item['driver_name'] as String? ?? '';

    final sid =
        item['sid'] as String? ?? '';

    final vendorCompany =
        item['vendor_company'] as String? ?? '';

    return '$driverName $sid $vendorCompany';
  }

  String buildEmployeeDisplay(
      Map<String, dynamic> employee,
      ) {
    final profile =
    employee['profiles'] as Map<String, dynamic>?;

    final fullName =
        profile?['full_name'] as String? ?? '-';

    final sid =
        profile?['sid'] as String? ?? '-';

    return '$fullName - $sid';
  }

  String buildEmployeeSearch(
      Map<String, dynamic> employee,
      ) {
    final profile =
    employee['profiles'] as Map<String, dynamic>?;

    final fullName =
        profile?['full_name'] as String? ?? '';

    final sid =
        profile?['sid'] as String? ?? '';

    final position =
        employee['position'] as String? ?? '';

    final role =
        employee['role'] as String? ?? '';

    final department =
        employee['department'] as String? ?? '';

    return '$fullName $sid $position $role $department';
  }

  void handleUnitSelected(
      Map<String, dynamic> item,
      ) {
    final unitId = item['id'] as String?;
    onUnitChanged(unitId);
  }

  void handleUnitSelectionCleared() {
    onUnitChanged(null);
  }

  void handleDriverSelected(
      Map<String, dynamic> item,
      ) {
    final driverId = item['id'] as String?;

    onDriverChanged(driverId);
  }

  void handleDriverSelectionCleared() {
    onDriverChanged(null);
  }

  void handleLayer1Selected(
      Map<String, dynamic> employee,
      ) {
    final employeeId = employee['id'] as String?;
    onLayer1Changed(employeeId);
  }

  void handleLayer2Selected(
      Map<String, dynamic> employee,
      ) {
    final employeeId = employee['id'] as String?;
    onLayer2Changed(employeeId);
  }

  void handleLayer3Selected(
      Map<String, dynamic> employee,
      ) {
    final employeeId = employee['id'] as String?;
    onLayer3Changed(employeeId);
  }

  void handleLayer4Selected(
      Map<String, dynamic> employee,
      ) {
    final employeeId = employee['id'] as String?;
    onLayer4Changed(employeeId);
  }

  void handleLayer1Cleared() {
    onLayer1Changed(null);
  }

  void handleLayer2Cleared() {
    onLayer2Changed(null);
  }

  void handleLayer3Cleared() {
    onLayer3Changed(null);
  }

  void handleLayer4Cleared() {
    onLayer4Changed(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButtons(),
        const SizedBox(height: 6),
        DopGridSectionCard(
          title: 'Detail Pekerjaan',
          icon: Icons.assignment_outlined,
          children: [
            TextFormField(
              controller: workPlanController,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0F172A),
              ),
              decoration: buildCompactInputDecoration(
                label: 'Rencana Pekerjaan',
                hintText:
                'Masukkan rencana pekerjaan',
              ),
              validator: _validateWorkPlan,
            ),
            const DopFormGridDivider(),
            _buildResponsiveActivityFields(),
          ],
        ),
        const SizedBox(height: 12),
        DopGridSectionCard(
          title: 'Layer & Catatan',
          icon: Icons.account_tree_outlined,
          children: [
            buildLayers(),
            const DopFormGridDivider(),
            TextFormField(
              controller: notesController,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0F172A),
              ),
              decoration: buildCompactInputDecoration(
                label: 'Catatan',
                hintText:
                'Tambahkan catatan jika diperlukan',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildUnitSuggestion(
      BuildContext context,
      Map<String, dynamic> item,
      ) {
    final unitNumber =
        item['unit_number'] as String? ?? '-';

    final unitType =
        item['unit_type'] as String? ?? '-';

    final ownerCompany =
        item['owner_company'] as String? ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF0D6EFD),
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unitNumber,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$unitType • $ownerCompany',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDriverSuggestion(
      BuildContext context,
      Map<String, dynamic> item,
      ) {
    final sidExpired = isExpired(
      item['sid_expired_date'] as String?,
    );

    final simperExpired = isExpired(
      item['simper_expired_date'] as String?,
    );

    final isDriverExpired =
        sidExpired || simperExpired;

    final driverName =
        item['driver_name'] as String? ?? '-';

    final sid =
        item['sid'] as String? ?? '-';

    final sidExpiredDate =
        item['sid_expired_date'] as String? ?? '-';

    final simperExpiredDate =
        item['simper_expired_date'] as String? ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF10B981),
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDriverExpired
                      ? '$driverName [EXPIRED]'
                      : driverName,
                  style: TextStyle(
                    color: isDriverExpired
                        ? Colors.red
                        : const Color(0xFF0F172A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SID $sid',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Expired SID: $sidExpiredDate'
                      ' • SIMPER: $simperExpiredDate',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmployeeSuggestion(
      BuildContext context,
      Map<String, dynamic> employee,
      ) {
    final profile =
    employee['profiles'] as Map<String, dynamic>?;

    final fullName =
        profile?['full_name'] as String? ?? '-';

    final sid =
        profile?['sid'] as String? ?? '-';

    final position =
        employee['position'] as String? ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_search_outlined,
              color: Color(0xFF7C3AED),
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sid • $position',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>>
  buildEmployeesByLayer(int layer) {
    final filteredEmployees =
    <Map<String, dynamic>>[];

    for (final employee in employees) {
      final hierarchyLayer =
      employee['hierarchy_layer'];

      if (hierarchyLayer == layer) {
        filteredEmployees.add(employee);
      }
    }

    return filteredEmployees;
  }

  Widget buildLayers() {
    return LayoutBuilder(
      builder: buildLayerLayout,
    );
  }

  Widget buildLayerLayout(
      BuildContext context,
      BoxConstraints constraints,
      ) {
    const spacing = 10.0;
    const minimumFieldWidth = 190.0;

    var fieldWidth =
        (constraints.maxWidth - (spacing * 3)) / 4;

    if (fieldWidth < minimumFieldWidth) {
      fieldWidth =
          (constraints.maxWidth - spacing) / 2;
    }

    if (fieldWidth < minimumFieldWidth) {
      fieldWidth = constraints.maxWidth;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: 10,
      children: [
        SizedBox(
          width: fieldWidth,
          child: buildLayer1Field(),
        ),
        SizedBox(
          width: fieldWidth,
          child: buildLayer2Field(),
        ),
        SizedBox(
          width: fieldWidth,
          child: buildLayer3Field(),
        ),
        SizedBox(
          width: fieldWidth,
          child: buildLayer4Field(),
        ),
      ],
    );
  }

  Widget buildLayer1Field() {
    return DopMasterAutocomplete(
      isRequired: true,
      label: 'Layer 1',
      hintText: 'Cari nama atau SID',
      controller: layer1Controller,
      items: buildEmployeesByLayer(1),
      selectedId: selectedLayer1UserId,
      idKey: 'id',
      displayBuilder: buildEmployeeDisplay,
      searchBuilder: buildEmployeeSearch,
      suggestionBuilder: buildEmployeeSuggestion,
      onSelected: handleLayer1Selected,
      onSelectionCleared: handleLayer1Cleared,
    );
  }

  Widget buildLayer2Field() {
    return DopMasterAutocomplete(
      isRequired: true,
      label: 'Layer 2',
      hintText: 'Cari nama atau SID',
      controller: layer2Controller,
      items: buildEmployeesByLayer(2),
      selectedId: selectedLayer2UserId,
      idKey: 'id',
      displayBuilder: buildEmployeeDisplay,
      searchBuilder: buildEmployeeSearch,
      suggestionBuilder: buildEmployeeSuggestion,
      onSelected: handleLayer2Selected,
      onSelectionCleared: handleLayer2Cleared,
    );
  }

  Widget buildLayer3Field() {
    return DopMasterAutocomplete(
      isRequired: true,
      label: 'Layer 3',
      hintText: 'Cari nama atau SID',
      controller: layer3Controller,
      items: buildEmployeesByLayer(3),
      selectedId: selectedLayer3UserId,
      idKey: 'id',
      displayBuilder: buildEmployeeDisplay,
      searchBuilder: buildEmployeeSearch,
      suggestionBuilder: buildEmployeeSuggestion,
      onSelected: handleLayer3Selected,
      onSelectionCleared: handleLayer3Cleared,
    );
  }

  Widget buildLayer4Field() {
    return DopMasterAutocomplete(
      isRequired: true,
      label: 'Layer 4',
      hintText: 'Cari nama atau SID',
      controller: layer4Controller,
      items: buildEmployeesByLayer(4),
      selectedId: selectedLayer4UserId,
      idKey: 'id',
      displayBuilder: buildEmployeeDisplay,
      searchBuilder: buildEmployeeSearch,
      suggestionBuilder: buildEmployeeSuggestion,
      onSelected: handleLayer4Selected,
      onSelectionCleared: handleLayer4Cleared,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: isSubmitting
              ? null
              : onClear,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            foregroundColor:
            const Color(0xFF475569),
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
            textStyle: const TextStyle(
              fontSize: 11.5,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(
            Icons.clear,
            size: 16,
          ),
          label: const Text('Clear'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: isSubmitting
              ? null
              : onAddOrUpdate,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            backgroundColor:
            const Color(0xFFFFB238),
            foregroundColor:
            const Color(0xFF172033),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 11.5,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            isEditing
                ? Icons.save_outlined
                : Icons.add,
            size: 16,
          ),
          label: Text(
            isEditing
                ? 'Update Aktivitas'
                : 'Tambah Aktivitas',
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveActivityFields() {
    return LayoutBuilder(
      builder: _buildActivityFieldLayout,
    );
  }

  Widget _buildActivityFieldLayout(
      BuildContext context,
      BoxConstraints constraints,
      ) {
    if (constraints.maxWidth >= 850) {
      return _buildDesktopActivityFields();
    }

    if (constraints.maxWidth >= 600) {
      return _buildTabletActivityFields();
    }

    return _buildMobileActivityFields();
  }

  Widget _buildDesktopActivityFields() {
    return Column(
      children: [
        DopFormGridRow(
          children: [
            _buildAreaField(),
            _buildShiftField(),
            _buildUnitField(),
            _buildDriverField(),
          ],
        ),
        const DopFormGridDivider(),
        DopFormGridRow(
          flexValues: const [
            1,
            1,
            2,
          ],
          children: [
            _buildStartTimeField(),
            _buildEndTimeField(),
            _buildRouteField(),
          ],
        ),
        const DopFormGridDivider(),
        DopFormGridRow(
          flexValues: const [
            1,
            2,
            2,
          ],
          children: [
            _buildObserverField(),
            _buildJsaField(),
            _buildRicField(),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletActivityFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAreaField(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShiftField(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildUnitField(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDriverField(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStartTimeField(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEndTimeField(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildRouteField(),
        const SizedBox(height: 10),
        _buildObserverField(),
        const SizedBox(height: 10),
        _buildJsaField(),
        const SizedBox(height: 10),
        _buildRicField(),
      ],
    );
  }

  Widget _buildMobileActivityFields() {
    return Column(
      children: [
        _buildAreaField(),
        const SizedBox(height: 10),
        _buildShiftField(),
        const SizedBox(height: 10),
        _buildUnitField(),
        const SizedBox(height: 10),
        _buildDriverField(),
        const SizedBox(height: 10),
        _buildStartTimeField(),
        const SizedBox(height: 10),
        _buildEndTimeField(),
        const SizedBox(height: 10),
        _buildRouteField(),
        const SizedBox(height: 10),
        _buildObserverField(),
        const SizedBox(height: 10),
        _buildJsaField(),
        const SizedBox(height: 10),
        _buildRicField(),
      ],
    );
  }

  Widget _buildAreaField() {
    return DopSimpleDropdown(
      label: 'Lokasi Tujuan',
      value: selectedAreaType,
      items: const [
        DropdownMenuItem<String>(
          value: 'jalan_negara',
          child: Text('Area Jalan Negara'),
        ),
        DropdownMenuItem<String>(
          value: 'site',
          child: Text('Area Site'),
        ),
      ],
      onChanged: onAreaChanged,
    );
  }

  Widget _buildShiftField() {
    return DopSimpleDropdown(
      label: 'Shift',
      value: selectedShift,
      items: const [
        DropdownMenuItem<String>(
          value: 'Shift 1',
          child: Text('Shift 1'),
        ),
        DropdownMenuItem<String>(
          value: 'Shift 2',
          child: Text('Shift 2'),
        ),
      ],
      onChanged: onShiftChanged,
    );
  }

  Widget _buildUnitField() {
    return DopMasterAutocomplete(
      label: 'Unit',
      hintText: 'Cari no lambung atau type',
      controller: unitController,
      items: units,
      selectedId: selectedUnitId,
      idKey: 'id',
      displayBuilder: buildUnitDisplay,
      searchBuilder: buildUnitSearch,
      suggestionBuilder: buildUnitSuggestion,
      onSelected: handleUnitSelected,
      onSelectionCleared: handleUnitSelectionCleared,
      isRequired: true,
    );
  }

  Widget _buildDriverField() {
    return DopMasterAutocomplete(
      label: 'Driver',
      hintText: 'Cari nama atau SID',
      controller: driverController,
      items: drivers,
      selectedId: selectedDriverId,
      idKey: 'id',
      displayBuilder: buildDriverDisplay,
      searchBuilder: buildDriverSearch,
      suggestionBuilder: buildDriverSuggestion,
      onSelected: handleDriverSelected,
      onSelectionCleared: handleDriverSelectionCleared,
      isRequired: true,
    );
  }

  Widget _buildStartTimeField() {
    return DopTimeField(
      key: ValueKey<String>(
        'start-$startTimeText',
      ),
      label: 'Mulai',
      value: startTimeText,
      onTap: onStartTimeTap,
      isRequired: true,
    );
  }

  Widget _buildEndTimeField() {
    return DopTimeField(
      key: ValueKey<String>(
        'end-$endTimeText',
      ),
      label: 'Akhir',
      value: endTimeText,
      onTap: onEndTimeTap,
      isRequired: true,
    );
  }

  Widget _buildRouteField() {
    return DopRouteField(
      controller: routeController,
      routes: routes,
      selectedRouteId: selectedRouteId,
      onRouteIdChanged: onRouteIdChanged,
    );
  }

  Widget _buildObserverField() {
    return TextFormField(
      controller: observerController,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF0F172A),
      ),
      decoration: buildCompactInputDecoration(
        label: 'Observer',
      ),
      validator: validateObserver,
    );
  }

  Widget _buildJsaField() {
    return DopDropdownField(
      label: 'Prosedur / JSA Terkait',
      value: selectedJsaId,
      items: jsaProcedures,
      valueKey: 'id',
      labelBuilder: _buildJsaLabel,
      onChanged: onJsaChanged,
      isRequired: true,
    );
  }

  Widget _buildRicField() {
    return DopDropdownField(
      label: 'Risk Intervention Centre (RIC)',
      value: selectedControlRoomId,
      items: controlRooms,
      valueKey: 'id',
      labelBuilder: _buildControlRoomLabel,
      onChanged: onControlRoomChanged,
      isRequired: true,
    );
  }


}