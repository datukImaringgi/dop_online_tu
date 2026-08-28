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
        DopSectionCard(
          title: 'Detail Pekerjaan',
          children: [
            TextFormField(
              controller: workPlanController,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              decoration: buildCompactInputDecoration(
                label: 'Rencana Pekerjaan',
              ),
              validator: _validateWorkPlan,
            ),
            const SizedBox(height: 12),
            _buildResponsiveActivityFields(),
          ],
        ),
        const SizedBox(height: 16),
        DopSectionCard(
          title: 'Layer & Catatan',
          children: [
            const SizedBox(height: 6),
            buildLayers(),
            const SizedBox(height: 12),
            TextFormField(
              controller: notesController,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              decoration: buildCompactInputDecoration(
                label: 'Catatan',
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
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF0D6EFD),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unitNumber,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
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
                    fontSize: 12,
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
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF10B981),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SID $sid',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
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
                    fontSize: 11,
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
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_search_outlined,
              color: Color(0xFF7C3AED),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
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
                    fontSize: 13,
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
                    fontSize: 12,
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
    const spacing = 14.0;
    const minimumFieldWidth = 210.0;

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
      runSpacing: 14,
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
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white
          ),
          onPressed: isSubmitting ? null : onClear,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
          ),
          onPressed: isSubmitting ? null : onAddOrUpdate,
          icon: Icon(
            isEditing ? Icons.save_outlined : Icons.add,
          ),
          label: Text(
            isEditing ? 'Update Aktivitas' : 'Tambah Aktivitas',
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
        Row(
          children: [
            Expanded(
              child: _buildAreaField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildShiftField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildUnitField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDriverField(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStartTimeField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildEndTimeField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: _buildRouteField(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildObserverField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: _buildJsaField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: _buildRicField(),
            ),
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
            const SizedBox(width: 14),
            Expanded(
              child: _buildShiftField(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUnitField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDriverField(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStartTimeField(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildEndTimeField(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRouteField(),
        const SizedBox(height: 12),
        _buildObserverField(),
        const SizedBox(height: 12),
        _buildJsaField(),
        const SizedBox(height: 12),
        _buildRicField(),
      ],
    );
  }

  Widget _buildMobileActivityFields() {
    return Column(
      children: [
        _buildAreaField(),
        const SizedBox(height: 12),
        _buildShiftField(),
        const SizedBox(height: 12),
        _buildUnitField(),
        const SizedBox(height: 12),
        _buildDriverField(),
        const SizedBox(height: 12),
        _buildStartTimeField(),
        const SizedBox(height: 12),
        _buildEndTimeField(),
        const SizedBox(height: 12),
        _buildRouteField(),
        const SizedBox(height: 12),
        _buildObserverField(),
        const SizedBox(height: 12),
        _buildJsaField(),
        const SizedBox(height: 12),
        _buildRicField(),
      ],
    );
  }

  Widget _buildAreaField() {
    return DopSimpleDropdown(
      label: 'Area',
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
          value: 'Day Shift',
          child: Text('Day Shift'),
        ),
        DropdownMenuItem<String>(
          value: 'Night Shift',
          child: Text('Night Shift'),
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
      label: 'Mulai',
      value: startTimeText,
      onTap: onStartTimeTap,
    );
  }

  Widget _buildEndTimeField() {
    return DopTimeField(
      label: 'Akhir',
      value: endTimeText,
      onTap: onEndTimeTap,
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
        fontSize: 14,
        color: Color(0xFF0F172A),
      ),
      decoration: buildCompactInputDecoration(
        label: 'Observer',
      ),
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