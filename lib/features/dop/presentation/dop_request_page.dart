import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dop_form_master_provider.dart';
import '../domain/dop_activity_draft.dart';
import 'widgets/dop_activity_table.dart';
import 'widgets/dop_header_form.dart';
import 'widgets/dop_activity_form.dart';
import '../data/dop_list_provider.dart';
import '../data/dop_submission_repository.dart';
import '../domain/dop_revision_data.dart';
import 'widgets/dop_revision_form_loader.dart';
import '../data/dop_revision_list_provider.dart';
import '../../approval/data/dop_approval_provider.dart';
import '../data/dop_revision_repository.dart';

class DopRequestPage
    extends ConsumerStatefulWidget {
  final String? revisionDopHeaderId;
  final String? draftDopHeaderId;

  const DopRequestPage({
    super.key,
    this.revisionDopHeaderId,
    this.draftDopHeaderId,
  });

  bool get isRevisionMode {
    return revisionDopHeaderId != null &&
        revisionDopHeaderId!
            .trim()
            .isNotEmpty;
  }

  bool get isDraftMode {
    return draftDopHeaderId != null &&
        draftDopHeaderId!
            .trim()
            .isNotEmpty;
  }

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

  final List<DopActivityDraft> activityDrafts = <DopActivityDraft>[];

  bool hasAppliedRevisionData = false;
  bool hasAppliedDraftData = false;

  bool get isDraftMode {
    return widget.isDraftMode;
  }

  String? get draftDopHeaderId {
    return widget.draftDopHeaderId;
  }

  String activeRevisionDopNumber = '';

  int activeRevisionNumber = 0;

  DateTime selectedDate = DateTime.now().add(
    const Duration(days: 1),
  );
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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

  String? selectedJobSiteId;
  String? selectedUnitId;
  String? selectedDriverId;
  String? selectedRouteId;
  String? selectedJsaId;
  String? selectedControlRoomId;

  String selectedAreaType = 'site';
  String selectedShift = 'Shift 1';

  String? selectedLayer1UserId;
  String? selectedLayer2UserId;
  String? selectedLayer3UserId;
  String? selectedLayer4UserId;

  String? editingDraftId;

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

  DateTime? parseExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  bool isExpiredDate(DateTime expiryDate) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final normalizedExpiry = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );

    return normalizedExpiry.isBefore(today);
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

  String extractSubmissionError(Object error) {
    final message = error.toString();

    const postgrestPrefix = 'PostgrestException(message: ';

    if (message.startsWith(postgrestPrefix)) {
      final withoutPrefix = message.replaceFirst(
        postgrestPrefix,
        '',
      );

      final commaIndex = withoutPrefix.indexOf(',');

      if (commaIndex > 0) {
        return withoutPrefix.substring(0, commaIndex);
      }
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  int findDraftIndex(String localId) {
    for (var index = 0; index < activityDrafts.length; index++) {
      if (activityDrafts[index].localId == localId) {
        return index;
      }
    }

    return -1;
  }

  String? normalizeSelectedId(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  int timeToMinutes(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  bool isSubmitting = false;
  bool isSavingDraft = false;
  String? activeDraftHeaderId;

  bool get isRevisionMode {
    return widget.isRevisionMode;
  }

  String? get revisionDopHeaderId {
    return widget.revisionDopHeaderId;
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

  bool isSelectedDopDateValid() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrow = today.add(
      const Duration(days: 1),
    );

    final normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return normalizedSelectedDate == today ||
        normalizedSelectedDate == tomorrow;
  }

  bool hasUnfinishedEditing() {
    return editingDraftId != null;
  }

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

  @override
  void initState() {
    super.initState();

    if (widget.isDraftMode) {
      activeDraftHeaderId =
          widget.draftDopHeaderId;
    }
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

  Future<void> saveCurrentDraft() async {
    if (isSavingDraft || isSubmitting) {
      return;
    }

    if (isRevisionMode) {
      showMessage(
        'Fitur Simpan Draft tidak tersedia '
            'pada proses revisi.',
      );
      return;
    }

    if (selectedJobSiteId == null ||
        selectedJobSiteId!.trim().isEmpty) {
      showMessage(
        'Job Site wajib dipilih sebelum '
            'menyimpan draft.',
      );
      return;
    }

    if (!isSelectedDopDateValid()) {
      showMessage(
        'Tanggal DOP hanya dapat dibuat '
            'untuk hari ini atau besok.',
      );
      return;
    }

    if (activityDrafts.isEmpty) {
      showMessage(
        'Minimal satu aktivitas kendaraan '
            'diperlukan untuk menyimpan draft.',
      );
      return;
    }

    if (hasUnfinishedEditing()) {
      showMessage(
        'Selesaikan Update Aktivitas sebelum '
            'menyimpan draft.',
      );
      return;
    }

    setState(() {
      isSavingDraft = true;
    });

    try {
      final repository = ref.read(
        dopSubmissionRepositoryProvider,
      );

      final draftHeaderId =
      await repository.saveDraft(
        dopHeaderId: activeDraftHeaderId,
        jobSiteId: selectedJobSiteId!,
        dopDate: selectedDate,
        dayName: getDayName(selectedDate),
        activities: activityDrafts,
      );

      activeDraftHeaderId = draftHeaderId;

      ref.invalidate(dopListProvider);

      if (!mounted) {
        return;
      }

      showMessage(
        'Draft DOP berhasil disimpan.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        extractSubmissionError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingDraft = false;
        });
      }
    }
  }

  Future<void> submitDop() async {
    if (isSubmitting || isSavingDraft) {
      return;
    }

    if (selectedJobSiteId == null) {
      showMessage('Job Site wajib dipilih');
      return;
    }

    if (!isSelectedDopDateValid()) {
      showMessage(
        'Tanggal DOP hanya dapat dibuat untuk hari ini atau besok.',
      );
      return;
    }

    if (activityDrafts.isEmpty) {
      showMessage(
        'Minimal satu aktivitas kendaraan wajib ditambahkan.',
      );
      return;
    }

    if (hasUnfinishedEditing()) {
      showMessage(
        'Selesaikan Update Aktivitas sebelum Submit DOP.',
      );
      return;
    }

    final shouldSubmit = await showSubmitConfirmation();

    if (!shouldSubmit) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final repository = ref.read(
        dopSubmissionRepositoryProvider,
      );

      final result = await repository.submitDop(
        jobSiteId: selectedJobSiteId!,
        dopDate: selectedDate,
        dayName: getDayName(selectedDate),
        activities: activityDrafts,
      );

      ref.invalidate(dopListProvider);

      if (!mounted) {
        return;
      }

      showMessage(
        'DOP ${result.dopNumber} berhasil disubmit.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) {
        return;
      }

      context.go('/dop-list');
    } catch (error) {
      showMessage(
        extractSubmissionError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> handleMainSubmit() async {
    if (isDraftMode) {
      showMessage(
        'Submit Draft sedang disiapkan. '
            'Gunakan Perbarui Draft terlebih dahulu.',
      );
      return;
    }

    if (!isRevisionMode) {
      await submitDop();
      return;
    }

    await submitRevision();
  }

  Future<void> submitRevision() async {
    if (isSubmitting || isSavingDraft) {
      return;
    }

    if (!hasAppliedRevisionData ||
        revisionDopHeaderId == null) {
      showMessage(
        'Data revisi belum selesai dimuat.',
      );
      return;
    }

    if (selectedJobSiteId == null) {
      showMessage('Job Site wajib dipilih');
      return;
    }

    if (activityDrafts.isEmpty) {
      showMessage(
        'Minimal satu aktivitas kendaraan wajib tersedia.',
      );
      return;
    }

    if (hasUnfinishedEditing()) {
      showMessage(
        'Selesaikan Update Aktivitas '
            'sebelum Submit Ulang Revisi.',
      );
      return;
    }

    final shouldSubmit =
    await showRevisionSubmitConfirmation();

    if (!shouldSubmit) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final repository = ref.read(
        dopSubmissionRepositoryProvider,
      );

      final result =
      await repository.resubmitRevision(
        dopHeaderId: revisionDopHeaderId!,
        jobSiteId: selectedJobSiteId!,
        dopDate: selectedDate,
        dayName: getDayName(selectedDate),
        activities: activityDrafts,
      );

      ref.invalidate(dopListProvider);
      ref.invalidate(dopRevisionListProvider);
      ref.invalidate(dopApprovalListProvider);

      if (!mounted) {
        return;
      }

      showMessage(
        'Revisi DOP ${result.dopNumber} '
            'berhasil dikirim ulang.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) {
        return;
      }

      context.go('/dop-revisions');
    } catch (error) {
      showMessage(
        extractSubmissionError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<bool>
  showRevisionSubmitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Submit Ulang Revisi',
          ),
          content: Text(
            'Kirim ulang $activeRevisionDopNumber '
                'dengan ${activityDrafts.length} aktivitas?\n\n'
                'DOP akan kembali ke Approval Layer 3.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              icon: const Icon(
                Icons.send_outlined,
              ),
              label: const Text(
                'Submit Ulang',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> showSubmitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: buildSubmitConfirmationDialog,
    );

    return result ?? false;
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

  void applyRevisionData(
      DopRevisionData revisionData,
      ) {
    if (hasAppliedRevisionData) {
      return;
    }

    setState(() {
      selectedJobSiteId =
          revisionData.jobSiteId;

      selectedDate = DateTime(
        revisionData.dopDate.year,
        revisionData.dopDate.month,
        revisionData.dopDate.day,
      );

      activeRevisionDopNumber =
          revisionData.dopNumber;

      activeRevisionNumber =
          revisionData.revisionNumber;

      activityDrafts
        ..clear()
        ..addAll(
          revisionData.activities,
        );

      editingDraftId = null;
      hasAppliedRevisionData = true;
    });
  }

  void applyDraftData(
      DopRevisionData draftData,
      ) {
    if (hasAppliedDraftData) {
      return;
    }

    setState(() {
      activeDraftHeaderId =
          draftData.dopHeaderId;

      selectedJobSiteId =
          draftData.jobSiteId;

      selectedDate = DateTime(
        draftData.dopDate.year,
        draftData.dopDate.month,
        draftData.dopDate.day,
      );

      activityDrafts
        ..clear()
        ..addAll(draftData.activities);

      editingDraftId = null;
      hasAppliedDraftData = true;
    });
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
    selectedShift = 'Shift 1';

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

    if (selectedRouteId == null) {
      showMessage(
        'Rute wajib dipilih dari Master Rute',
      );
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
    final selectedRoute = findById(routes, selectedRouteId);
    final selectedJsa = findById(jsaProcedures, selectedJsaId);
    final selectedControlRoom = findById(
      controlRooms,
      selectedControlRoomId,
    );

    if (selectedUnit == null ||
        selectedDriver == null ||
        selectedRoute == null ||
        selectedJsa == null ||
        selectedControlRoom == null) {
      showMessage(
        'Data master aktivitas tidak valid',
      );
      return;
    }

    final routeName =
        selectedRoute['route_name']
            ?.toString()
            .trim() ?? '';

    final routeAreaType =
        selectedRoute['area_type']
            ?.toString()
            .trim() ?? '';

    if (routeName.isEmpty) {
      showMessage(
        'Nama Master Rute tidak valid',
      );
      return;
    }

    if (routeAreaType != 'site' &&
        routeAreaType != 'jalan_negara') {
      showMessage(
        'Area Tujuan pada Master Rute belum valid',
      );
      return;
    }

    final sidExpiredDate = parseExpiryDate(
      selectedDriver['sid_expired_date'] as String?,
    );

    if (sidExpiredDate != null &&
        isExpiredDate(sidExpiredDate)) {
      showMessage(
        'SID Driver "${selectedDriver['driver_name']}" '
            'telah expired pada '
            '${formatDate(sidExpiredDate)}.',
      );
      return;
    }

    final simperExpiredDate = parseExpiryDate(
      selectedDriver['simper_expired_date'] as String?,
    );

    if (simperExpiredDate != null &&
        isExpiredDate(simperExpiredDate)) {
      showMessage(
        'SIMPER Driver "${selectedDriver['driver_name']}" '
            'telah expired pada '
            '${formatDate(simperExpiredDate)}.',
      );
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
      areaType: routeAreaType,
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
      routeId: selectedRouteId!,
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

      selectedUnitId = normalizeSelectedId(
        draft.unitId,
      );

      selectedDriverId = normalizeSelectedId(
        draft.driverId,
      );

      selectedRouteId = normalizeSelectedId(
        draft.routeId,
      );

      selectedJsaId = normalizeSelectedId(
        draft.jsaId,
      );

      selectedControlRoomId = normalizeSelectedId(
        draft.controlRoomId,
      );

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

  void showRevisionDateInformation() {
    showMessage(
      'Tanggal DOP tidak dapat diubah '
          'pada proses revisi.',
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

  Widget buildSubmitConfirmationDialog(
      BuildContext dialogContext,
      ) {
    return AlertDialog(
      title: const Text('Submit DOP'),
      content: Text(
        'Submit DOP untuk ${activityDrafts.length} aktivitas kendaraan?\n\n'
            'Tanggal: ${getFormattedHeaderDate()}',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(false);
          },
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit DOP'),
        ),
      ],
    );
  }

  Widget buildDraftLoader() {
    final headerId = draftDopHeaderId;

    if (headerId == null) {
      return const SizedBox.shrink();
    }

    final draftAsync = ref.watch(
      dopDraftDataProvider(headerId),
    );

    return draftAsync.when(
      loading: () {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFECACA),
            ),
          ),
          child: Text(
            extractSubmissionError(error),
            style: const TextStyle(
              color: Color(0xFFB91C1C),
            ),
          ),
        );
      },
      data: (draftData) {
        if (!hasAppliedDraftData) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) {
            if (mounted) {
              applyDraftData(draftData);
            }
          });
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFCD34D),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.edit_note_outlined,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 9),
              Text(
                'Anda sedang melanjutkan Draft DOP.',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.all(20),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRevisionMode
                              ? 'Revisi DOP'
                              : isDraftMode
                              ? 'Lanjutkan Draft DOP'
                              : 'Request Form DOP',
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          isRevisionMode
                              ? activeRevisionDopNumber.isEmpty
                              ? 'Menyiapkan data revisi DOP...'
                              : '$activeRevisionDopNumber • '
                              'Revisi ${activeRevisionNumber + 1}'
                              : 'Input Daily Operation Plan '
                              'Transportasi',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed:
                    isSubmitting || isSavingDraft
                        ? null
                        : () {
                      if (isRevisionMode) {
                        context.go('/dop-revisions');
                        return;
                      }

                      context.go('/dop-list');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      foregroundColor: const Color(0xFF315D8A),
                      side: const BorderSide(
                        color: Color(0xFF94A3B8),
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
                      Icons.arrow_back,
                      size: 16,
                    ),
                    label: const Text('Kembali'),
                  ),

                  const SizedBox(width: 8),
                  if (!isRevisionMode) ...[
                    OutlinedButton.icon(
                      onPressed:
                      isSubmitting ||
                          isSavingDraft ||
                          activityDrafts.isEmpty
                          ? null
                          : saveCurrentDraft,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        foregroundColor:
                        const Color(0xFF315D8A),
                        backgroundColor: Colors.white,
                        disabledForegroundColor:
                        const Color(0xFF94A3B8),
                        disabledBackgroundColor:
                        const Color(0xFFF1F5F9),
                        side: const BorderSide(
                          color: Color(0xFF94A3B8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          height: 1,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),
                      icon: isSavingDraft
                          ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.save_outlined,
                        size: 16,
                      ),
                      label: Text(
                        isSavingDraft
                            ? 'Menyimpan...'
                            : activeDraftHeaderId == null
                            ? 'Simpan Draft'
                            : 'Perbarui Draft',
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed:
                    isSubmitting ||
                        isSavingDraft ||
                        activityDrafts.isEmpty ||
                        (isRevisionMode &&
                            !hasAppliedRevisionData)
                        ? null
                        : handleMainSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      foregroundColor: const Color(0xFF172033),
                      backgroundColor: const Color(0xFFFFB238),
                      disabledForegroundColor:
                      const Color(0xFF94A3B8),
                      disabledBackgroundColor:
                      const Color(0xFFE2E8F0),
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
                    icon: isSubmitting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                           strokeWidth: 2,
                         ),
                        )
                        : const Icon(
                      Icons.send,
                      size: 16,
                    ),
                    label: Text(
                      isSubmitting
                          ? isRevisionMode
                          ? 'Mengirim Revisi...'
                          : 'Submitting...'
                          : isRevisionMode
                          ? 'Submit Ulang Revisi '
                          '(${activityDrafts.length})'
                          : 'Submit DOP '
                          '(${activityDrafts.length})',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isDraftMode) ...[
                        buildDraftLoader(),
                        const SizedBox(height: 12),
                      ],
                      if (isRevisionMode &&
                          revisionDopHeaderId != null) ...[
                        DopRevisionFormLoader(
                          dopHeaderId:
                          revisionDopHeaderId!,
                          onRevisionLoaded:
                          applyRevisionData,
                        ),
                        const SizedBox(height: 12),
                      ],
                      DopHeaderForm(
                        formattedDate:
                          getFormattedHeaderDate(),
                        onDateTap: isRevisionMode
                            ? showRevisionDateInformation
                            : pickDate,
                        selectedJobSiteId:
                        selectedJobSiteId,
                        jobSites: jobSites,
                        onJobSiteChanged:
                        handleJobSiteChanged,
                      ),

                      const SizedBox(height: 12),

                      DopActivityTable(
                        drafts: activityDrafts,
                        editingDraftId: editingDraftId,
                        onEdit: editActivity,
                        onDuplicate: duplicateActivity,
                        onDelete: deleteActivity,
                      ),

                      const SizedBox(height: 12),

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
                        isSubmitting:
                        isSubmitting || isSavingDraft,
                        isEditing: editingDraftId != null,
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