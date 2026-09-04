import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/active_companies_provider.dart';
import '../../data/assignment_job_sites_provider.dart';
import '../../data/master_change_request_provider.dart';
import '../../data/operational_master_repository.dart';
import '../../domain/operational_master_config.dart';

class OperationalMasterDialog
    extends ConsumerStatefulWidget {
  final OperationalMasterConfig config;
  final Map<String, dynamic>? record;
  final int actorHierarchyLayer;
  final String? fixedCompanyId;
  final String? fixedCompanyName;

  const OperationalMasterDialog({
    super.key,
    required this.config,
    required this.record,
    required this.actorHierarchyLayer,
    required this.fixedCompanyId,
    required this.fixedCompanyName,
  });

  bool get isEditing {
    return record != null;
  }

  bool get isLayerFive {
    return actorHierarchyLayer == 5;
  }

  @override
  ConsumerState<OperationalMasterDialog>
  createState() {
    return _OperationalMasterDialogState();
  }
}

class _OperationalMasterDialogState
    extends ConsumerState<
        OperationalMasterDialog> {
  final formKey = GlobalKey<FormState>();

  final controllers = <String, TextEditingController>{};

  final vendorController = TextEditingController();

  final vendorFocusNode = FocusNode();

  List<String> visibleVendorOptions = <String>[];

  String? selectedCompanyId;
  String? selectedJobSiteId;

  bool isActive = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final recordCompanyId =
    widget.record?['company_id'];

    if (widget.isLayerFive) {
      selectedCompanyId =
      recordCompanyId is String
          ? recordCompanyId
          : null;
    } else {
      selectedCompanyId =
          widget.fixedCompanyId;
    }

    final recordJobSiteId =
    widget.record?['job_site_id'];

    selectedJobSiteId =
    recordJobSiteId is String
        ? recordJobSiteId
        : null;

    final recordIsActive = widget.record?['is_active'];

    isActive = recordIsActive is bool
        ? recordIsActive
        : true;

    final recordVendorCompany =
    widget.record?['vendor_company'];

    if (recordVendorCompany is String) {
      vendorController.text =
          recordVendorCompany.trim();
    }

    for (final field
    in widget.config.fields) {
      if (field.type ==
          OperationalMasterFieldType.jobSite) {
        continue;
      }

      final value =
      widget.record?[field.key];

      controllers[field.key] =
          TextEditingController(
            text: formatInitialValue(value),
          );
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    vendorController.dispose();
    vendorFocusNode.dispose();

    super.dispose();
  }

  String formatInitialValue(dynamic value) {
    if (value == null) {
      return '';
    }

    final text = value.toString();

    if (text.length >= 10 &&
        RegExp(
          r'^\d{4}-\d{2}-\d{2}',
        ).hasMatch(text)) {
      return text.substring(0, 10);
    }

    return text;
  }

  void handleCompanyChanged(String? value) {
    setState(() {
      selectedCompanyId = value;
      selectedJobSiteId = null;
    });
  }

  void handleJobSiteChanged(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        selectedJobSiteId = null;
        return;
      }

      selectedJobSiteId = value;
    });
  }

  void handleActiveChanged(bool value) {
    setState(() {
      isActive = value;
    });
  }

  Future<void> selectDate(
      OperationalMasterFieldConfig field,
      ) async {
    final controller =
    controllers[field.key];

    if (controller == null) {
      return;
    }

    final existingDate =
    DateTime.tryParse(controller.text);

    final result = await showDatePicker(
      context: context,
      initialDate:
      existingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: field.label,
    );

    if (result == null) {
      return;
    }

    final year =
    result.year.toString().padLeft(4, '0');

    final month =
    result.month.toString().padLeft(2, '0');

    final day =
    result.day.toString().padLeft(2, '0');

    setState(() {
      controller.text =
      '$year-$month-$day';
    });
  }

  Map<String, dynamic> buildRequestedData() {
    final result = <String, dynamic>{
      'company_id': selectedCompanyId,
      'is_active': isActive,
    };

    for (final field in widget.config.fields) {
      if (field.type ==
          OperationalMasterFieldType.jobSite) {
        result[field.key] =
            selectedJobSiteId;
        continue;
      }

      final controller =
      controllers[field.key];

      if (controller == null) {
        continue;
      }

      final value = controller.text.trim();

      result[field.key] =
      value.isEmpty ? null : value;
    }

    if (widget.config.masterType ==
        'route') {
      final origin =
          result['origin']
              ?.toString()
              .trim() ??
              '';

      final destination =
          result['destination']
              ?.toString()
              .trim() ??
              '';

      result['origin'] = origin;
      result['destination'] =
          destination;
      result['route_name'] =
      '$origin - $destination';
    }

    if (widget.config.masterType ==
        'driver') {
      final vendorName =
      vendorController.text.trim();

      result['vendor_company'] =
      vendorName.isEmpty
          ? null
          : vendorName;

      result['employee_number'] = null;
    }

    return result;
  }

  String? validateRouteData() {
    if (widget.config.masterType !=
        'route') {
      return null;
    }

    final originController =
    controllers['origin'];

    final destinationController =
    controllers['destination'];

    final origin =
        originController?.text.trim() ??
            '';

    final destination =
        destinationController
            ?.text
            .trim() ??
            '';

    if (origin.isEmpty ||
        destination.isEmpty) {
      return 'Asal dan Tujuan wajib diisi.';
    }

    if (origin.toLowerCase() ==
        destination.toLowerCase()) {
      return 'Asal dan Tujuan tidak boleh sama.';
    }

    return null;
  }

  Future<void> save() async {
    if (isSaving) {
      return;
    }

    final isValid =
        formKey.currentState?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    final routeValidationMessage =
    validateRouteData();

    if (routeValidationMessage != null) {
      showMessage(
        routeValidationMessage,
        true,
      );
      return;
    }

    final companyId = selectedCompanyId;

    if (companyId == null ||
        companyId.isEmpty) {
      showMessage(
        'Perusahaan wajib dipilih.',
        true,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repository = ref.read(
        operationalMasterRepositoryProvider,
      );

      final result =
      await repository.submitChange(
        masterType:
        widget.config.masterType,
        actionType:
        widget.isEditing
            ? 'update'
            : 'create',
        targetRecordId:
        widget.record?['id'] as String?,
        companyId: companyId,
        requestedData:
        buildRequestedData(),
      );

      ref.invalidate(
        operationalMasterDataProvider(
          widget.config.tableName,
        ),
      );

      if (widget.config.masterType ==
          'driver') {
        ref.invalidate(
          driverVendorOptionsProvider(
            DriverVendorQuery(
              companyId: companyId,
            ),
          ),
        );
      }

      ref.invalidate(
        masterChangeRequestsProvider,
      );

      ref.invalidate(
        pendingMasterChangeCountProvider,
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          result.isPendingApproval
              ? const Color(0xFFD97706)
              : const Color(0xFF059669),
          content: Text(result.message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        extractErrorMessage(error),
        true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String extractErrorMessage(Object error) {
    final message = error.toString();

    const prefix =
        'PostgrestException(message: ';

    if (message.startsWith(prefix)) {
      final cleaned =
      message.replaceFirst(prefix, '');

      final commaIndex =
      cleaned.indexOf(',');

      if (commaIndex > 0) {
        return cleaned
            .substring(0, commaIndex)
            .trim();
      }
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  void showMessage(
      String message,
      bool isError,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(
      activeCompaniesProvider,
    );

    AsyncValue<
        List<AssignmentJobSiteOption>>?
    jobSitesAsync;

    if (selectedCompanyId != null &&
        selectedCompanyId!.isNotEmpty &&
        widget.config.masterType !=
            'job_site') {
      jobSitesAsync = ref.watch(
        assignmentJobSitesProvider(
          selectedCompanyId!,
        ),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          Icon(
            widget.config.icon,
            color: const Color(0xFF2563EB),
            size: 21,
          ),
          const SizedBox(width: 9),
          Text(
            widget.isEditing
                ? 'Edit ${widget.config.singularLabel}'
                : 'Tambah ${widget.config.singularLabel}',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                buildCompanyField(
                  companiesAsync,
                ),
                const SizedBox(height: 12),
                for (final field
                in widget.config.fields) ...[
                  buildField(
                    field,
                    jobSitesAsync,
                  ),
                  const SizedBox(height: 12),
                ],

                if (widget.config.masterType ==
                    'driver') ...[
                  buildVendorField(),
                  const SizedBox(height: 12),
                ],

                buildActiveSwitch(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : closeDialog,
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed:
          isSaving ? null : save,
          icon: isSaving
              ? const SizedBox(
            width: 15,
            height: 15,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 17,
          ),
          label: Text(
            isSaving
                ? 'Memproses...'
                : widget.isLayerFive
                ? 'Simpan'
                : 'Ajukan Perubahan',
          ),
        ),
      ],
    );
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  Widget buildCompanyField(
      AsyncValue<List<ActiveCompanyOption>>
      companiesAsync,
      ) {
    if (!widget.isLayerFive) {
      return buildFixedCompany();
    }

    if (widget.isEditing) {
      return companiesAsync.when(
        loading: buildLoadingField,
        error: buildCompanyError,
        data: buildLockedCompanyDropdown,
      );
    }

    return companiesAsync.when(
      loading: buildLoadingField,
      error: buildCompanyError,
      data: buildCompanyDropdown,
    );
  }

  Widget buildCompanyError(
      Object error,
      StackTrace stackTrace,
      ) {
    return Text(
      'Gagal membaca perusahaan: $error',
      style: const TextStyle(
        color: Color(0xFFDC2626),
      ),
    );
  }

  Widget buildCompanyDropdown(
      List<ActiveCompanyOption> companies,
      ) {
    return DropdownButtonFormField<String>(
      value: selectedCompanyId,
      isExpanded: true,
      decoration: inputDecoration(
        'Perusahaan',
      ),
      items: buildCompanyItems(companies),
      onChanged: handleCompanyChanged,
      validator: validateCompany,
    );
  }

  Widget buildLockedCompanyDropdown(
      List<ActiveCompanyOption> companies,
      ) {
    String companyName = '-';

    for (final company in companies) {
      if (company.id ==
          selectedCompanyId) {
        companyName =
            company.displayName;
        break;
      }
    }

    return buildLockedField(
      'Perusahaan',
      companyName,
    );
  }

  List<DropdownMenuItem<String>>
  buildCompanyItems(
      List<ActiveCompanyOption> companies,
      ) {
    final items =
    <DropdownMenuItem<String>>[];

    for (final company in companies) {
      items.add(
        DropdownMenuItem<String>(
          value: company.id,
          child: Text(
            company.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  Widget buildFixedCompany() {
    return buildLockedField(
      'Perusahaan',
      widget.fixedCompanyName ?? '-',
    );
  }

  Widget buildLockedField(
      String label,
      String value,
      ) {
    return InputDecorator(
      decoration:
      inputDecoration(label),
      child: Row(
        children: [
          Expanded(
            child: Text(value),
          ),
          const Icon(
            Icons.lock_outline,
            size: 16,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget buildField(
      OperationalMasterFieldConfig field,
      AsyncValue<
          List<AssignmentJobSiteOption>>?
      jobSitesAsync,
      ) {
    if (field.type ==
        OperationalMasterFieldType.jobSite) {
      return buildJobSiteField(
        field,
        jobSitesAsync,
      );
    }

    final controller =
    controllers[field.key]!;

    if (field.type ==
        OperationalMasterFieldType.date) {
      return TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () {
          selectDate(field);
        },
        decoration: inputDecoration(
          field.label,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      minLines: field.type ==
          OperationalMasterFieldType
              .multiline
          ? 2
          : 1,
      maxLines: field.type ==
          OperationalMasterFieldType
              .multiline
          ? 4
          : 1,
      decoration:
      inputDecoration(field.label),
      validator: field.isRequired
          ? validateRequired
          : null,
    );
  }

  Widget buildJobSiteField(
      OperationalMasterFieldConfig field,
      AsyncValue<
          List<AssignmentJobSiteOption>>?
      jobSitesAsync,
      ) {
    if (jobSitesAsync == null) {
      return DropdownButtonFormField<String>(
        items: const [],
        onChanged: null,
        decoration: inputDecoration(
          field.label,
          hint:
          'Pilih perusahaan terlebih dahulu',
        ),
      );
    }

    return jobSitesAsync.when(
      loading: buildLoadingField,
      error: buildJobSiteError,
      data: buildJobSiteDropdown,
    );
  }

  Widget buildJobSiteError(
      Object error,
      StackTrace stackTrace,
      ) {
    return Text(
      'Gagal membaca Job Site: $error',
      style: const TextStyle(
        color: Color(0xFFDC2626),
      ),
    );
  }

  Widget buildJobSiteDropdown(
      List<AssignmentJobSiteOption> jobSites,
      ) {
    final items =
    <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: '',
        child: Text(
          'Tanpa Job Site khusus',
        ),
      ),
    ];

    for (final jobSite in jobSites) {
      items.add(
        DropdownMenuItem<String>(
          value: jobSite.id,
          child: Text(
            jobSite.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedJobSiteId ?? '',
      isExpanded: true,
      decoration:
      inputDecoration('Job Site'),
      items: items,
      onChanged: handleJobSiteChanged,
    );
  }

  Widget buildVendorField() {
    final vendorsAsync = ref.watch(
      driverVendorOptionsProvider(
        DriverVendorQuery(
          companyId: selectedCompanyId,
        ),
      ),
    );

    return vendorsAsync.when(
      loading: buildLoadingField,
      error: buildVendorError,
      data: buildVendorAutocomplete,
    );
  }

  Widget buildVendorError(
      Object error,
      StackTrace stackTrace,
      ) {
    return TextFormField(
      controller: vendorController,
      decoration: inputDecoration(
        'Perusahaan Driver',
        hint:
        'Ketik nama perusahaan vendor',
      ),
    );
  }

  Widget buildVendorAutocomplete(
      List<String> vendorOptions,
      ) {
    return RawAutocomplete<String>(
      textEditingController:
      vendorController,
      focusNode: vendorFocusNode,
      displayStringForOption:
      displayVendorOption,
      optionsBuilder: (
          TextEditingValue inputValue,
          ) {
        return filterVendorOptions(
          inputValue,
          vendorOptions,
        );
      },
      onSelected: handleVendorSelected,
      fieldViewBuilder: buildVendorTextField,
      optionsViewBuilder:
      buildVendorOptionsView,
    );
  }

  String displayVendorOption(
      String vendor,
      ) {
    return vendor;
  }

  Iterable<String> filterVendorOptions(
      TextEditingValue inputValue,
      List<String> vendorOptions,
      ) {
    final query =
    inputValue.text.trim().toLowerCase();

    if (query.isEmpty) {
      visibleVendorOptions =
          vendorOptions.take(20).toList();

      return visibleVendorOptions;
    }

    final filtered = <String>[];

    for (final vendor in vendorOptions) {
      if (vendor
          .toLowerCase()
          .contains(query)) {
        filtered.add(vendor);
      }

      if (filtered.length >= 20) {
        break;
      }
    }

    visibleVendorOptions = filtered;

    return filtered;
  }

  void handleVendorSelected(
      String vendor,
      ) {
    vendorController.value =
        TextEditingValue(
          text: vendor,
          selection:
          TextSelection.collapsed(
            offset: vendor.length,
          ),
        );
  }

  Widget buildVendorTextField(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
      ) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization:
      TextCapitalization.words,
      decoration: inputDecoration(
        'Perusahaan Driver',
        hint:
        'Pilih vendor atau ketik vendor baru',
        suffixIcon: const Icon(
          Icons.business_outlined,
          size: 18,
        ),
      ),
    );
  }

  Widget buildVendorOptionsView(
      BuildContext context,
      AutocompleteOnSelected<String>
      onSelected,
      Iterable<String> options,
      ) {
    final optionList = options.toList();

    if (optionList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius:
        BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            minWidth: 300,
            maxWidth: 500,
            maxHeight: 220,
          ),
          child: ListView.builder(
            padding:
            const EdgeInsets.symmetric(
              vertical: 4,
            ),
            shrinkWrap: true,
            itemCount: optionList.length,
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              final vendor =
              optionList[index];

              return ListTile(
                dense: true,
                leading: const Icon(
                  Icons.business_outlined,
                  size: 17,
                ),
                title: Text(
                  vendor,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  onSelected(vendor);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildActiveSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
        ),
      ),
      child: SwitchListTile(
        value: isActive,
        onChanged:
        isSaving ? null : handleActiveChanged,
        dense: true,
        title: const Text(
          'Status Aktif',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildLoadingField() {
    return const SizedBox(
      height: 46,
      child: Center(
        child: LinearProgressIndicator(),
      ),
    );
  }

  String? validateCompany(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Perusahaan wajib dipilih';
    }

    return null;
  }

  String? validateRequired(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }

    return null;
  }

  InputDecoration inputDecoration(
      String label, {
        String? hint,
        Widget? suffixIcon,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
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
          color: Color(0xFF2563EB),
          width: 1.3,
        ),
      ),
    );
  }
}