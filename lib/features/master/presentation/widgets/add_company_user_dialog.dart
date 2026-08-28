import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/active_companies_provider.dart';
import '../../data/assignment_job_sites_provider.dart';
import '../../data/company_user_hierarchy_provider.dart';
import '../../data/company_user_registration_repository.dart';

class AddCompanyUserDialog
    extends ConsumerStatefulWidget {
  final int actorHierarchyLayer;
  final String? fixedCompanyId;
  final String? fixedCompanyName;

  const AddCompanyUserDialog({
    super.key,
    required this.actorHierarchyLayer,
    required this.fixedCompanyId,
    required this.fixedCompanyName,
  });

  bool get isPlatformSuperAdmin {
    return actorHierarchyLayer == 5;
  }

  @override
  ConsumerState<AddCompanyUserDialog>
  createState() {
    return _AddCompanyUserDialogState();
  }
}

class _AddCompanyUserDialogState
    extends ConsumerState<AddCompanyUserDialog> {
  final formKey = GlobalKey<FormState>();

  final fullNameController =
  TextEditingController();

  final sidController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final notificationEmailController =
  TextEditingController();

  final positionController =
  TextEditingController();

  final departmentController =
  TextEditingController();

  String? selectedCompanyId;
  String? selectedJobSiteId;
  int? selectedHierarchyLayer;

  bool isPasswordVisible = false;
  bool isActive = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    selectedCompanyId =
        widget.fixedCompanyId;

    selectedHierarchyLayer = 1;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    sidController.dispose();
    passwordController.dispose();
    notificationEmailController.dispose();
    positionController.dispose();
    departmentController.dispose();

    super.dispose();
  }

  void closeDialog() {
    if (isSaving) {
      return;
    }

    Navigator.of(context).pop();
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

  void handleHierarchyChanged(int? value) {
    setState(() {
      selectedHierarchyLayer = value;
    });
  }

  void handleActiveChanged(bool value) {
    setState(() {
      isActive = value;
    });
  }

  void handlePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> handleRegisterUser() async {
    if (isSaving) {
      return;
    }

    final isValid =
        formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (selectedCompanyId == null ||
        selectedCompanyId!.isEmpty) {
      showErrorMessage(
        'Perusahaan wajib dipilih.',
      );
      return;
    }

    if (selectedHierarchyLayer == null) {
      showErrorMessage(
        'Hierarchy wajib dipilih.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repository = ref.read(
        companyUserRegistrationRepositoryProvider,
      );

      final result = await repository.registerUser(
        fullName: fullNameController.text,
        sid: sidController.text,
        password: passwordController.text,
        notificationEmail:
        notificationEmailController.text,
        companyId: selectedCompanyId!,
        hierarchyLayer:
        selectedHierarchyLayer!,
        position: positionController.text,
        department: departmentController.text,
        jobSiteId: selectedJobSiteId,
        isActive: isActive,
      );

      ref.invalidate(
        companyUserHierarchyProvider,
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
          const Color(0xFF059669),
          duration: const Duration(
            seconds: 6,
          ),
          content: Text(
            'User ${result.sid} berhasil didaftarkan. '
                'Email login: ${result.authEmail}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFFDC2626),
        content: Text(message),
      ),
    );
  }

  String extractErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    final messageStart =
    message.indexOf('message: ');

    if (messageStart >= 0) {
      final cleanedMessage = message.substring(
        messageStart + 9,
      );

      final commaIndex =
      cleanedMessage.indexOf(',');

      if (commaIndex > 0) {
        return cleanedMessage
            .substring(0, commaIndex)
            .trim();
      }

      return cleanedMessage.trim();
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(
      activeCompaniesProvider,
    );

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

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        12,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      title: const Row(
        children: [
          Icon(
            Icons.person_add_alt_1_outlined,
            color: Color(0xFF0D6EFD),
            size: 23,
          ),
          SizedBox(width: 10),
          Text(
            'Tambah User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: buildFormContent(
              companiesAsync,
              jobSitesAsync,
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
          onPressed: isSaving
              ? null
              : handleRegisterUser,
          icon: isSaving
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.person_add_alt_1_outlined,
            size: 18,
          ),
          label: Text(
            isSaving
                ? 'Mendaftarkan...'
                : 'Daftarkan User',
          ),
        ),
      ],
    );
  }

  Widget buildFormContent(
      AsyncValue<List<ActiveCompanyOption>>
      companiesAsync,
      AsyncValue<List<AssignmentJobSiteOption>>?
      jobSitesAsync,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (widget.isPlatformSuperAdmin)
          buildCompanyField(companiesAsync)
        else
          buildFixedCompanyInformation(),
        const SizedBox(height: 16),
        buildFullNameField(),
        const SizedBox(height: 12),
        buildSidField(),
        const SizedBox(height: 12),
        buildPasswordField(),
        const SizedBox(height: 12),
        buildNotificationEmailField(),
        const SizedBox(height: 12),
        buildHierarchyField(),
        const SizedBox(height: 12),
        buildPositionField(),
        const SizedBox(height: 12),
        buildDepartmentField(),
        const SizedBox(height: 12),
        buildJobSiteField(jobSitesAsync),
        const SizedBox(height: 10),
        buildActiveSwitch(),
      ],
    );
  }

  Widget buildCompanyField(
      AsyncValue<List<ActiveCompanyOption>>
      companiesAsync,
      ) {
    return companiesAsync.when(
      loading: buildFieldLoading,
      error: (
          Object error,
          StackTrace stackTrace,
          ) {
        return buildFieldError(
          'Gagal membaca perusahaan: $error',
        );
      },
      data: buildCompanyDropdown,
    );
  }

  Widget buildCompanyDropdown(
      List<ActiveCompanyOption> companies,
      ) {
    return DropdownButtonFormField<String>(
      value: selectedCompanyId,
      isExpanded: true,
      decoration: buildInputDecoration(
        label: 'Perusahaan',
        hint: 'Pilih perusahaan',
        icon: Icons.business_outlined,
      ),
      items: buildCompanyItems(companies),
      validator: validateCompany,
      onChanged: handleCompanyChanged,
    );
  }

  List<DropdownMenuItem<String>>
  buildCompanyItems(
      List<ActiveCompanyOption> companies,
      ) {
    final items = <DropdownMenuItem<String>>[];

    for (final company in companies) {
      items.add(
        DropdownMenuItem<String>(
          value: company.id,
          child: Text(
            company.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  Widget buildFixedCompanyInformation() {
    final companyName =
        widget.fixedCompanyName ??
            'Company tidak ditemukan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business_outlined,
            color: Color(0xFF0D6EFD),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perusahaan',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  companyName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline,
            color: Color(0xFF94A3B8),
            size: 17,
          ),
        ],
      ),
    );
  }

  Widget buildJobSiteField(
      AsyncValue<List<AssignmentJobSiteOption>>?
      jobSitesAsync,
      ) {
    if (selectedCompanyId == null ||
        selectedCompanyId!.isEmpty) {
      return DropdownButtonFormField<String>(
        items: const [],
        onChanged: null,
        decoration: buildInputDecoration(
          label: 'Job Site',
          hint: 'Pilih perusahaan terlebih dahulu',
          icon: Icons.location_on_outlined,
        ),
      );
    }

    if (jobSitesAsync == null) {
      return buildFieldLoading();
    }

    return jobSitesAsync.when(
      loading: buildFieldLoading,
      error: (
          Object error,
          StackTrace stackTrace,
          ) {
        return buildFieldError(
          'Gagal membaca Job Site: $error',
        );
      },
      data: buildJobSiteDropdown,
    );
  }

  Widget buildJobSiteDropdown(
      List<AssignmentJobSiteOption> jobSites,
      ) {
    final availableIds = <String>{};

    for (final jobSite in jobSites) {
      availableIds.add(jobSite.id);
    }

    String? validSelectedValue;

    if (selectedJobSiteId != null &&
        availableIds.contains(
          selectedJobSiteId,
        )) {
      validSelectedValue =
          selectedJobSiteId;
    }

    return DropdownButtonFormField<String>(
      value: validSelectedValue,
      isExpanded: true,
      decoration: buildInputDecoration(
        label: 'Job Site',
        hint: 'Pilih Job Site',
        icon: Icons.location_on_outlined,
      ),
      items: buildJobSiteItems(jobSites),
      onChanged: handleJobSiteChanged,
    );
  }

  List<DropdownMenuItem<String>>
  buildJobSiteItems(
      List<AssignmentJobSiteOption> jobSites,
      ) {
    final items = <DropdownMenuItem<String>>[
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  Widget buildFieldLoading() {
    return const SizedBox(
      height: 46,
      child: Center(
        child: LinearProgressIndicator(),
      ),
    );
  }

  Widget buildFieldError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 12,
        ),
      ),
    );
  }

  String? validateCompany(String? value) {
    if (!widget.isPlatformSuperAdmin) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Perusahaan wajib dipilih';
    }

    return null;
  }

  Widget buildFullNameField() {
    return TextFormField(
      controller: fullNameController,
      textCapitalization:
      TextCapitalization.words,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Nama Lengkap',
        hint: 'Masukkan nama lengkap',
        icon: Icons.person_outline,
      ),
      validator: validateRequiredText,
    );
  }

  Widget buildSidField() {
    return TextFormField(
      controller: sidController,
      textCapitalization:
      TextCapitalization.characters,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'SID',
        hint: 'Contoh: TESTL1',
        icon: Icons.badge_outlined,
      ),
      validator: validateSid,
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Password Sementara',
        hint: 'Minimal 8 karakter',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          onPressed: handlePasswordVisibility,
          tooltip: isPasswordVisible
              ? 'Sembunyikan password'
              : 'Tampilkan password',
          visualDensity: VisualDensity.compact,
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 19,
          ),
        ),
      ),
      validator: validatePassword,
    );
  }

  Widget buildNotificationEmailField() {
    return TextFormField(
      controller:
      notificationEmailController,
      keyboardType:
      TextInputType.emailAddress,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Email Notifikasi',
        hint: 'nama@perusahaan.com',
        icon: Icons.email_outlined,
      ),
      validator: validateEmail,
    );
  }

  Widget buildHierarchyField() {
    return DropdownButtonFormField<int>(
      value: selectedHierarchyLayer,
      isExpanded: true,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Hierarchy Layer',
        icon: Icons.account_tree_outlined,
      ),
      items: const [
        DropdownMenuItem<int>(
          value: 1,
          child: Text('Layer 1'),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text('Layer 2'),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Text('Layer 3'),
        ),
        DropdownMenuItem<int>(
          value: 4,
          child: Text('Layer 4'),
        ),
      ],
      validator: validateHierarchy,
      onChanged: handleHierarchyChanged,
    );
  }

  Widget buildPositionField() {
    return TextFormField(
      controller: positionController,
      textCapitalization:
      TextCapitalization.words,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Position',
        hint: 'Contoh: Supervisor',
        icon: Icons.work_outline,
      ),
      validator: validateRequiredText,
    );
  }

  Widget buildDepartmentField() {
    return TextFormField(
      controller: departmentController,
      textCapitalization:
      TextCapitalization.words,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Department',
        hint: 'Contoh: Operation',
        icon: Icons.apartment_outlined,
      ),
      validator: validateRequiredText,
    );
  }

  Widget buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: SwitchListTile(
        value: isActive,
        onChanged: isSaving
            ? null
            : handleActiveChanged,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: const Text(
          'Status User',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isActive
              ? 'User aktif setelah didaftarkan.'
              : 'User dibuat dalam kondisi nonaktif.',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      prefixIcon: Icon(
        icon,
        size: 19,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
          width: 1.4,
        ),
      ),
    );
  }

  String? validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }

    return null;
  }

  String? validateSid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SID wajib diisi';
    }

    final sid = value.trim();

    if (sid.length < 3) {
      return 'SID minimal 3 karakter';
    }

    final sidPattern = RegExp(
      r'^[A-Za-z0-9._-]+$',
    );

    if (!sidPattern.hasMatch(sid)) {
      return 'SID hanya boleh berisi huruf, angka, titik, _ atau -';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password sementara wajib diisi';
    }

    if (value.length < 4) {
      return 'Password minimal 4 karakter';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final email = value.trim();

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? validateHierarchy(int? value) {
    if (value == null) {
      return 'Hierarchy wajib dipilih';
    }

    if (value < 1 || value > 4) {
      return 'Hierarchy tidak valid';
    }

    return null;
  }
}