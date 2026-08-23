import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dop_form_master_provider.dart';
import '../domain/dop_activity_draft.dart';
import 'widgets/dop_activity_table.dart';
import 'widgets/dop_header_form.dart';
import 'widgets/dop_activity_form.dart';

class DopRequestPage extends ConsumerStatefulWidget {
  const DopRequestPage({super.key});

  @override
  ConsumerState<DopRequestPage> createState() {
    return _DopRequestPageState();
  }
}

class _DopRequestPageState extends ConsumerState<DopRequestPage> {
  final formKey = GlobalKey<FormState>();

  final workPlanController = TextEditingController();
  final observerController = TextEditingController();
  final notesController = TextEditingController();
  final routeController = TextEditingController();
  final unitController = TextEditingController();
  final driverController = TextEditingController();
  final layer1Controller = TextEditingController();
  final layer2Controller = TextEditingController();
  final layer3Controller = TextEditingController();
  final layer4Controller = TextEditingController();

  DateTime selectedDate = DateTime.now().add(
    const Duration(days: 1),
  );
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String? selectedJobSiteId;
  String? selectedUnitId;
  String? selectedDriverId;
  String? selectedRouteId;
  String? selectedJsaId;
  String? selectedControlRoomId;

  String selectedAreaType = 'site';
  String selectedShift = 'Day Shift';

  String? selectedLayer1UserId;
  String? selectedLayer2UserId;
  String? selectedLayer3UserId;
  String? selectedLayer4UserId;

  bool isSubmitting = false;

  final List<DopActivityDraft> activityDrafts = <DopActivityDraft>[];

  String? editingDraftId;

  Map<String, dynamic>? findById(
      List<Map<String, dynamic>> items,
      String? id,
      ) {
    if (id == null) {
      return null;
    }

    for (final item in items) {
      if (item['id'] == id) {
        return item;
      }
    }

    return null;
  }

  String generateLocalId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return days[date.weekday - 1];
  }

  String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String getFormattedHeaderDate() {
    final dayName = getDayName(selectedDate);
    final date = formatDate(selectedDate);

    return '$dayName, $date';
  }

  String getStartTimeText() {
    if (startTime == null) {
      return '-';
    }

    return formatTimeOfDay(startTime!);
  }

  String getEndTimeText() {
    if (endTime == null) {
      return '-';
    }

    return formatTimeOfDay(endTime!);
  }

  String? getEmployeeNameById(
      List<Map<String, dynamic>> employees,
      String? companyUserId,
      ) {
    if (companyUserId == null) {
      return null;
    }

    for (final employee in employees) {
      if (employee['id'] != companyUserId) {
        continue;
      }

      final profile = employee['profiles'] as Map<String, dynamic>?;

      if (profile == null) {
        return null;
      }

      return profile['full_name'] as String?;
    }

    return null;
  }

  int findDraftIndex(String localId) {
    for (var index = 0; index < activityDrafts.length; index++) {
      if (activityDrafts[index].localId == localId) {
        return index;
      }
    }

    return -1;
  }

  int timeToMinutes(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  bool isActivityTimeValid() {
    if (startTime == null || endTime == null) {
      return false;
    }

    return timeToMinutes(startTime!) != timeToMinutes(endTime!);
  }

  bool hasDuplicateActivity(DopActivityDraft candidate) {
    for (final existingDraft in activityDrafts) {
      final isSameDraft = existingDraft.localId == editingDraftId;

      if (isSameDraft) {
        continue;
      }

      if (existingDraft.duplicateKey == candidate.duplicateKey) {
        return true;
      }
    }

    return false;
  }

  bool isAllowedDopDate({
    required DateTime date,
    required DateTime today,
    required DateTime tomorrow,
  }) {
    final normalizedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final isToday = normalizedDate == today;
    final isTomorrow = normalizedDate == tomorrow;

    return isToday || isTomorrow;
  }

  TimeOfDay parseTimeOfDay(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  DateTime normalizeAllowedInitialDate({
    required DateTime selectedDate,
    required DateTime today,
    required DateTime tomorrow,
  }) {
    final normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (normalizedSelectedDate.isBefore(today)) {
      return today;
    }

    if (normalizedSelectedDate.isAfter(tomorrow)) {
      return today;
    }

    return normalizedSelectedDate;
  }

  Future<void> deleteActivity(DopActivityDraft draft) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Aktivitas'),
          content: Text(
            'Hapus aktivitas ${draft.unitNumber}, '
                '${draft.startTime} - ${draft.endTime}, '
                '${draft.routeName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      activityDrafts.removeWhere(
            (item) {
          return item.localId == draft.localId;
        },
      );

      if (editingDraftId == draft.localId) {
        resetActivityFields();
      }
    });

    showMessage('Aktivitas berhasil dihapus');
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrow = today.add(
      const Duration(days: 1),
    );

    final safeInitialDate = normalizeAllowedInitialDate(
      selectedDate: selectedDate,
      today: today,
      tomorrow: tomorrow,
    );

    final result = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: today,
      lastDate: tomorrow,
      selectableDayPredicate: (date) {
        return isAllowedDopDate(
          date: date,
          today: today,
          tomorrow: tomorrow,
        );
      },
      helpText: 'Pilih Tanggal DOP',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedDate = DateTime(
        result.year,
        result.month,
        result.day,
      );
    });
  }

  Future<void> pickStartTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: startTime ?? const TimeOfDay(
        hour: 7,
        minute: 0,
      ),
      initialEntryMode: TimePickerEntryMode.input,
      builder: buildTwentyFourHourTimePicker,
      helpText: 'Masukkan waktu mulai',
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      cancelText: 'Batal',
      confirmText: 'OK',
    );

    if (result == null) {
      return;
    }

    setState(() {
      startTime = result;
    });
  }

  Future<void> pickEndTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: endTime ?? const TimeOfDay(
        hour: 8,
        minute: 0,
      ),
      initialEntryMode: TimePickerEntryMode.input,
      builder: buildTwentyFourHourTimePicker,
      helpText: 'Masukkan waktu akhir',
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      cancelText: 'Batal',
      confirmText: 'OK',
    );

    if (result == null) {
      return;
    }

    setState(() {
      endTime = result;
    });
  }

  @override
  void dispose() {
    workPlanController.dispose();
    observerController.dispose();
    notesController.dispose();
    routeController.dispose();
    unitController.dispose();
    driverController.dispose();
    layer1Controller.dispose();
    layer2Controller.dispose();
    layer3Controller.dispose();
    layer4Controller.dispose();

    super.dispose();
  }

  void resetActivityFields() {
    workPlanController.clear();
    observerController.clear();
    notesController.clear();
    routeController.clear();
    unitController.clear();
    driverController.clear();

    startTime = null;
    endTime = null;

    selectedUnitId = null;
    selectedDriverId = null;
    selectedRouteId = null;
    selectedJsaId = null;
    selectedControlRoomId = null;

    selectedAreaType = 'site';
    selectedShift = 'Day Shift';

    editingDraftId = null;
  }

  void clearActivityForm() {
    setState(resetActivityFields);
  }

  void addOrUpdateActivity({
    required List<Map<String, dynamic>> units,
    required List<Map<String, dynamic>> drivers,
    required List<Map<String, dynamic>> routes,
    required List<Map<String, dynamic>> jsaProcedures,
    required List<Map<String, dynamic>> controlRooms,
    required List<Map<String, dynamic>> employees,
  }) {
    final isFormValid = formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    if (selectedUnitId == null) {
      showMessage('Unit wajib dipilih');
      return;
    }

    if (selectedDriverId == null) {
      showMessage('Driver wajib dipilih');
      return;
    }

    final routeName = routeController.text.trim();
    if (routeName.isEmpty) {
      showMessage('Rute wajib diisi');
      return;
    }

    if (selectedJsaId == null) {
      showMessage('Prosedur/JSA wajib dipilih');
      return;
    }

    if (selectedControlRoomId == null) {
      showMessage('Risk Intervention Centre (RIC) wajib dipilih');
      return;
    }

    if (startTime == null || endTime == null) {
      showMessage('Jam mulai dan akhir wajib diisi');
      return;
    }

    if (!isActivityTimeValid()) {
      showMessage('Jam mulai dan akhir tidak boleh sama');
      return;
    }

    final selectedUnit = findById(units, selectedUnitId);
    final selectedDriver = findById(drivers, selectedDriverId);
    final selectedJsa = findById(jsaProcedures, selectedJsaId);
    final selectedControlRoom = findById(
      controlRooms,
      selectedControlRoomId,
    );

    if (selectedUnit == null ||
        selectedDriver == null ||
        selectedJsa == null ||
        selectedControlRoom == null) {
      showMessage('Data master aktivitas tidak valid');
      return;
    }

    final procedureCode =
        selectedJsa['procedure_code'] as String? ?? '';

    final procedureName =
        selectedJsa['procedure_name'] as String? ?? '';

    final currentLocalId = editingDraftId ?? generateLocalId();

    final draft = DopActivityDraft(
      localId: currentLocalId,
      workPlan: workPlanController.text.trim(),
      areaType: selectedAreaType,
      shift: selectedShift,
      unitId: selectedUnitId!,
      unitType: selectedUnit['unit_type'] as String? ?? '-',
      unitNumber: selectedUnit['unit_number'] as String? ?? '-',
      transportCompany:
      selectedUnit['owner_company'] as String? ?? '-',
      driverId: selectedDriverId!,
      driverName: selectedDriver['driver_name'] as String? ?? '-',
      sid: selectedDriver['sid'] as String?,
      sidExpiredDate: selectedDriver['sid_expired_date'] as String?,
      simperExpiredDate:
      selectedDriver['simper_expired_date'] as String?,
      startTime: formatTimeOfDay(startTime!),
      endTime: formatTimeOfDay(endTime!),
      routeId: selectedRouteId,
      routeName: routeName,
      observer: observerController.text.trim(),
      jsaId: selectedJsaId!,
      jsaProcedure: '$procedureCode - $procedureName',
      controlRoomId: selectedControlRoomId!,
      controlRoomName:
      selectedControlRoom['control_room_name'] as String? ?? '-',
      layer1UserId: selectedLayer1UserId,
      layer2UserId: selectedLayer2UserId,
      layer3UserId: selectedLayer3UserId,
      layer4UserId: selectedLayer4UserId,
      layer1: getEmployeeNameById(
        employees,
        selectedLayer1UserId,
      ),
      layer2: getEmployeeNameById(
        employees,
        selectedLayer2UserId,
      ),
      layer3: getEmployeeNameById(
        employees,
        selectedLayer3UserId,
      ),
      layer4: getEmployeeNameById(
        employees,
        selectedLayer4UserId,
      ),
      notes: notesController.text.trim(),
    );

    if (hasDuplicateActivity(draft)) {
      showMessage(
        'Aktivitas dengan unit, waktu, dan rute yang sama sudah ada.',
      );
      return;
    }

    if (editingDraftId == null) {
      setState(() {
        activityDrafts.add(draft);
        resetActivityFields();
      });

      showMessage('Aktivitas berhasil ditambahkan');
      return;
    }

    final editingIndex = findDraftIndex(editingDraftId!);

    if (editingIndex < 0) {
      showMessage('Draft aktivitas yang diedit tidak ditemukan');
      return;
    }

    setState(() {
      activityDrafts[editingIndex] = draft;
      resetActivityFields();
    });

    showMessage('Aktivitas berhasil diperbarui');
  }

  void editActivity(DopActivityDraft draft) {
    setState(() {
      editingDraftId = draft.localId;

      workPlanController.text = draft.workPlan;
      observerController.text = draft.observer;
      notesController.text = draft.notes;
      routeController.text = draft.routeName;

      selectedAreaType = draft.areaType;
      selectedShift = draft.shift;

      selectedUnitId = draft.unitId;
      unitController.text = '${draft.unitNumber} (${draft.unitType})';
      selectedDriverId = draft.driverId;
      driverController.text = '${draft.driverName} - ${draft.sid ?? '-'}';
      selectedRouteId = draft.routeId;
      selectedJsaId = draft.jsaId;
      selectedControlRoomId = draft.controlRoomId;

      startTime = parseTimeOfDay(draft.startTime);
      endTime = parseTimeOfDay(draft.endTime);

      selectedLayer1UserId = draft.layer1UserId;
      selectedLayer2UserId = draft.layer2UserId;
      selectedLayer3UserId = draft.layer3UserId;
      selectedLayer4UserId = draft.layer4UserId;
    });

    showMessage('Aktivitas siap diedit');
  }

  void duplicateActivity(DopActivityDraft draft) {
    setState(() {
      editingDraftId = null;

      workPlanController.text = draft.workPlan;
      observerController.text = draft.observer;
      notesController.text = draft.notes;

      selectedAreaType = draft.areaType;
      selectedShift = draft.shift;

      startTime = parseTimeOfDay(draft.startTime);
      endTime = parseTimeOfDay(draft.endTime);

      selectedRouteId = draft.routeId;
      routeController.text = draft.routeName;

      selectedJsaId = draft.jsaId;
      selectedControlRoomId = draft.controlRoomId;

      selectedLayer1UserId = draft.layer1UserId;
      selectedLayer2UserId = draft.layer2UserId;
      selectedLayer3UserId = draft.layer3UserId;
      selectedLayer4UserId = draft.layer4UserId;

      selectedUnitId = null;
      selectedDriverId = null;

      unitController.clear();
      driverController.clear();
    });

    showMessage(
      'Aktivitas berhasil disalin. Pilih Unit dan Driver berikutnya.',
    );
  }

  void handleRouteIdChanged(String? value) {
    setState(() {
      selectedRouteId = value;
    });
  }

  void handleAddOrUpdateActivity() {
    final units = ref.read(unitsProvider).value;
    final drivers = ref.read(driversProvider).value;
    final routes = ref.read(routesProvider).value;
    final jsaProcedures = ref.read(jsaProceduresProvider).value;
    final controlRooms = ref.read(controlRoomsProvider).value;
    final employees = ref.read(employeeOptionsProvider).value;

    if (units == null ||
        drivers == null ||
        routes == null ||
        jsaProcedures == null ||
        controlRooms == null ||
        employees == null) {
      showMessage('Master data aktivitas belum siap');
      return;
    }

    addOrUpdateActivity(
      units: units,
      drivers: drivers,
      routes: routes,
      jsaProcedures: jsaProcedures,
      controlRooms: controlRooms,
      employees: employees,
    );
  }

  void handleLayer1Changed(String? value) {
    setState(() {
      selectedLayer1UserId = value;
    });
  }

  void handleLayer2Changed(String? value) {
    setState(() {
      selectedLayer2UserId = value;
    });
  }

  void handleLayer3Changed(String? value) {
    setState(() {
      selectedLayer3UserId = value;
    });
  }

  void handleLayer4Changed(String? value) {
    setState(() {
      selectedLayer4UserId = value;
    });
  }

  void handleJobSiteChanged(String? value) {
    setState(() {
      selectedJobSiteId = value;
    });
  }

  void handleUnitChanged(String? value) {
    setState(() {
      selectedUnitId = value;
    });
  }

  void handleDriverChanged(String? value) {
    setState(() {
      selectedDriverId = value;
    });
  }

  void handleRouteChanged(String? value) {
    setState(() {
      selectedRouteId = value;
    });
  }

  void handleJsaChanged(String? value) {
    setState(() {
      selectedJsaId = value;
    });
  }

  void handleControlRoomChanged(String? value) {
    setState(() {
      selectedControlRoomId = value;
    });
  }

  void handleAreaChanged(String value) {
    setState(() {
      selectedAreaType = value;
    });
  }

  void handleShiftChanged(String value) {
    setState(() {
      selectedShift = value;
    });
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobSitesAsync = ref.watch(jobSitesProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final driversAsync = ref.watch(driversProvider);
    final routesAsync = ref.watch(routesProvider);
    final jsaAsync = ref.watch(jsaProceduresProvider);
    final controlRoomsAsync = ref.watch(controlRoomsProvider);
    final employeesAsync = ref.watch(employeeOptionsProvider);

    final isLoading = jobSitesAsync.isLoading ||
        unitsAsync.isLoading ||
        driversAsync.isLoading ||
        routesAsync.isLoading ||
        jsaAsync.isLoading ||
        controlRoomsAsync.isLoading ||
        employeesAsync.isLoading;

    final hasError = jobSitesAsync.hasError ||
        unitsAsync.hasError ||
        driversAsync.hasError ||
        routesAsync.hasError ||
        jsaAsync.hasError ||
        controlRoomsAsync.hasError ||
        employeesAsync.hasError;

    final jobSites = jobSitesAsync.value ?? <Map<String, dynamic>>[];
    final units = unitsAsync.value ?? <Map<String, dynamic>>[];
    final drivers = driversAsync.value ?? <Map<String, dynamic>>[];
    final routes = routesAsync.value ?? <Map<String, dynamic>>[];
    final jsaProcedures = jsaAsync.value ?? <Map<String, dynamic>>[];
    final controlRooms = controlRoomsAsync.value ?? <Map<String, dynamic>>[];
    final employees = employeesAsync.value ?? <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : hasError
            ? const Center(
          child: Text(
            'Gagal membaca master data request form.',
            style: TextStyle(color: Colors.red),
          ),
        )
            : Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Form DOP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Input Daily Operation Plan Transportasi',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                      context.go('/dop-list');
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    onPressed: isSubmitting || activityDrafts.isEmpty
                        ? null
                        : () {
                      showMessage('Draft siap disubmit. Proses batch submission akan dibuat pada tahap berikutnya.',
                      );
                    },
                    icon: isSubmitting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                           strokeWidth: 2,
                         ),
                        )
                        : const Icon(Icons.send),
                    label: Text(
                      isSubmitting
                          ? 'Submitting...'
                          : 'Submit DOP (${activityDrafts.length})',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DopHeaderForm(
                        formattedDate: getFormattedHeaderDate(),
                        onDateTap: pickDate,
                        selectedJobSiteId: selectedJobSiteId,
                        jobSites: jobSites,
                        onJobSiteChanged: handleJobSiteChanged,
                      ),

                      const SizedBox(height: 16),

                      DopActivityTable(
                        drafts: activityDrafts,
                        editingDraftId: editingDraftId,
                        onEdit: editActivity,
                        onDuplicate: duplicateActivity,
                        onDelete: deleteActivity,
                      ),

                      const SizedBox(height: 16),

                      DopActivityForm(
                        workPlanController: workPlanController,
                        observerController: observerController,
                        notesController: notesController,
                        routeController: routeController,
                        unitController: unitController,
                        driverController: driverController,
                        layer1Controller: layer1Controller,
                        layer2Controller: layer2Controller,
                        layer3Controller: layer3Controller,
                        layer4Controller: layer4Controller,
                        selectedAreaType: selectedAreaType,
                        selectedShift: selectedShift,
                        selectedUnitId: selectedUnitId,
                        selectedDriverId: selectedDriverId,
                        selectedRouteId: selectedRouteId,
                        selectedJsaId: selectedJsaId,
                        selectedControlRoomId: selectedControlRoomId,
                        selectedLayer1UserId: selectedLayer1UserId,
                        selectedLayer2UserId: selectedLayer2UserId,
                        selectedLayer3UserId: selectedLayer3UserId,
                        selectedLayer4UserId: selectedLayer4UserId,
                        startTimeText: getStartTimeText(),
                        endTimeText: getEndTimeText(),
                        units: units,
                        drivers: drivers,
                        routes: routes,
                        jsaProcedures: jsaProcedures,
                        controlRooms: controlRooms,
                        employees: employees,
                        isSubmitting: isSubmitting,
                        isEditing: editingDraftId != null,
                        onAreaChanged: handleAreaChanged,
                        onShiftChanged: handleShiftChanged,
                        onUnitChanged: handleUnitChanged,
                        onDriverChanged: handleDriverChanged,
                        onRouteIdChanged: handleRouteIdChanged,
                        onJsaChanged: handleJsaChanged,
                        onControlRoomChanged: handleControlRoomChanged,
                        onLayer1Changed: handleLayer1Changed,
                        onLayer2Changed: handleLayer2Changed,
                        onLayer3Changed: handleLayer3Changed,
                        onLayer4Changed: handleLayer4Changed,
                        onStartTimeTap: pickStartTime,
                        onEndTimeTap: pickEndTime,
                        onClear: clearActivityForm,
                        onAddOrUpdate: handleAddOrUpdateActivity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTwentyFourHourTimePicker(
    BuildContext context,
    Widget? child,
    ) {
  final mediaQuery = MediaQuery.of(context);

  return MediaQuery(
    data: mediaQuery.copyWith(
      alwaysUse24HourFormat: true,
    ),
    child: child ?? const SizedBox.shrink(),
  );
}