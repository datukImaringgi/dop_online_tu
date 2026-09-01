import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/active_companies_provider.dart';
import '../../data/assignment_job_sites_provider.dart';
import '../../data/master_unit_provider.dart';
import '../../domain/master_unit_model.dart';

class MasterUnitDialog
    extends ConsumerStatefulWidget {
  final MasterUnitModel? unit;
  final int actorHierarchyLayer;
  final String? fixedCompanyId;
  final String? fixedCompanyName;

  const MasterUnitDialog({
    super.key,
    required this.unit,
    required this.actorHierarchyLayer,
    required this.fixedCompanyId,
    required this.fixedCompanyName,
  });

  bool get isEditMode {
    return unit != null;
  }

  bool get isPlatformSuperAdmin {
    return actorHierarchyLayer == 5;
  }

  @override
  ConsumerState<MasterUnitDialog> createState() {
    return _MasterUnitDialogState();
  }
}

class _MasterUnitDialogState
    extends ConsumerState<MasterUnitDialog> {
  final formKey = GlobalKey<FormState>();

  final unitNumberController =
  TextEditingController();

  final ownerCompanyController =
  TextEditingController();

  String? selectedCompanyId;
  String? selectedJobSiteId;
  String selectedUnitType = 'LV';

  bool isActive = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final unit = widget.unit;

    if (unit != null) {
      selectedCompanyId = unit.companyId;
      selectedJobSiteId = unit.jobSiteId;
      selectedUnitType = unit.unitType;
      unitNumberController.text =
          unit.unitNumber;
      ownerCompanyController.text =
          unit.ownerCompany;
      isActive = unit.isActive;
      return;
    }

    selectedCompanyId =
        widget.fixedCompanyId;
  }

  @override
  void dispose() {
    unitNumberController.dispose();
    ownerCompanyController.dispose();
    super.dispose();
  }

  void handleCompanyChanged(String? value) {
    setState(() {
      selectedCompanyId = value;
      selectedJobSiteId = null;
    });
  }

  void handleJobSiteChanged(String? value) {
    setState(() {
      selectedJobSiteId = value;
    });
  }

  void handleUnitTypeChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      selectedUnitType = value;
    });
  }

  void handleActiveChanged(bool value) {
    setState(() {
      isActive = value;
    });
  }

  void closeDialog() {
    if (isSaving) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> saveUnit() async {
    if (isSaving) {
      return;
    }

    final isValid =
        formKey.currentState?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    if (selectedCompanyId == null ||
        selectedCompanyId!.isEmpty) {
      showError('Perusahaan wajib dipilih.');
      return;
    }

    if (selectedJobSiteId == null ||
        selectedJobSiteId!.isEmpty) {
      showError('Job Site wajib dipilih.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repository = ref.read(
        masterUnitRepositoryProvider,
      );

      MasterUnitChangeResult result;

      if (widget.isEditMode) {
        result = await repository.updateUnit(
          unitId: widget.unit!.id,
          jobSiteId: selectedJobSiteId!,
          unitNumber:
          unitNumberController.text,
          unitType: selectedUnitType,
          ownerCompany:
          ownerCompanyController.text,
          isActive: isActive,
        );
      } else {
        result = await repository.createUnit(
          companyId: selectedCompanyId!,
          jobSiteId: selectedJobSiteId!,
          unitNumber:
          unitNumberController.text,
          unitType: selectedUnitType,
          ownerCompany:
          ownerCompanyController.text,
          isActive: isActive,
        );
      }

      ref.invalidate(masterUnitsProvider);

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      final message = result.message;

      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(
          backgroundColor:
          result.isPendingApproval
              ? const Color(0xFFD97706)
              : const Color(0xFF059669),
          content: Text(message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showError(
        'Gagal menyimpan unit: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFFDC2626),
        content: Text(message),
      ),
    );
  }

  String? validateRequired(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }

    return null;
  }

  String? validateJobSite(String? value) {
    if (value == null || value.isEmpty) {
      return 'Job Site wajib dipilih';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<AssignmentJobSiteOption>>?
    jobSitesAsync;

    if (selectedCompanyId != null &&
        selectedCompanyId!.isNotEmpty) {
      jobSitesAsync = ref.watch(
        assignmentJobSitesProvider(
          selectedCompanyId!,
        ),
      );
    }

    final companiesAsync = ref.watch(
      activeCompaniesProvider,
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        10,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        18,
        4,
        18,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        14,
      ),
      title: Row(
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isEditMode
                ? 'Edit Unit'
                : 'Tambah Unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildCompanyField(
                  companiesAsync,
                ),
                const SizedBox(height: 10),
                buildJobSiteField(
                  jobSitesAsync,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller:
                  unitNumberController,
                  textCapitalization:
                  TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 12.5,
                  ),
                  decoration: buildDecoration(
                    label: 'Nomor Unit',
                    icon:
                    Icons.confirmation_number_outlined,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedUnitType,
                  isExpanded: true,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                  ),
                  decoration: buildDecoration(
                    label: 'Kategori Kendaraan',
                    icon:
                    Icons.category_outlined,
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'BUS',
                      child: Text('Massal'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'LV',
                      child: Text('Non-Massal'),
                    ),
                  ],
                  onChanged:
                  handleUnitTypeChanged,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller:
                  ownerCompanyController,
                  textCapitalization:
                  TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 12.5,
                  ),
                  decoration: buildDecoration(
                    label: 'Perusahaan Pemilik',
                    icon:
                    Icons.business_outlined,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: isActive,
                  onChanged: isSaving
                      ? null
                      : handleActiveChanged,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Status Unit',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isActive
                        ? 'Unit aktif'
                        : 'Unit nonaktif',
                    style: const TextStyle(
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
          isSaving ? null : closeDialog,
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed:
          isSaving ? null : saveUnit,
          icon: isSaving
              ? const SizedBox(
            width: 14,
            height: 14,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 16,
          ),
          label: Text(
            isSaving
                ? 'Menyimpan...'
                : 'Simpan',
          ),
        ),
      ],
    );
  }

  Widget buildCompanyField(
      AsyncValue<List<ActiveCompanyOption>>
      companiesAsync,
      ) {
    if (widget.isEditMode ||
        !widget.isPlatformSuperAdmin) {
      final companyName = widget.isEditMode
          ? widget.unit!.companyName
          : widget.fixedCompanyName ?? '-';

      return InputDecorator(
        decoration: buildDecoration(
          label: 'Perusahaan',
          icon: Icons.business_outlined,
        ),
        child: Text(
          companyName,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        fontSize: 11,
      ),
    );
  }

  Widget buildCompanyDropdown(
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

    return DropdownButtonFormField<String>(
      value: selectedCompanyId,
      isExpanded: true,
      decoration: buildDecoration(
        label: 'Perusahaan',
        icon: Icons.business_outlined,
      ),
      items: items,
      onChanged: handleCompanyChanged,
      validator: validateRequired,
    );
  }

  Widget buildJobSiteField(
      AsyncValue<List<AssignmentJobSiteOption>>?
      jobSitesAsync,
      ) {
    if (jobSitesAsync == null) {
      return DropdownButtonFormField<String>(
        items: const [],
        onChanged: null,
        decoration: buildDecoration(
          label: 'Job Site',
          icon: Icons.location_on_outlined,
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
        fontSize: 11,
      ),
    );
  }

  Widget buildJobSiteDropdown(
      List<AssignmentJobSiteOption> jobSites,
      ) {
    final items =
    <DropdownMenuItem<String>>[];

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
      value: selectedJobSiteId,
      isExpanded: true,
      decoration: buildDecoration(
        label: 'Job Site',
        icon: Icons.location_on_outlined,
      ),
      items: items,
      validator: validateJobSite,
      onChanged: handleJobSiteChanged,
    );
  }

  Widget buildLoadingField() {
    return const SizedBox(
      height: 40,
      child: Center(
        child: LinearProgressIndicator(),
      ),
    );
  }

  InputDecoration buildDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: Icon(
        icon,
        size: 17,
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
      ),
    );
  }
}
