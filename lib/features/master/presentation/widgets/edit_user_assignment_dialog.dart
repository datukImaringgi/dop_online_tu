import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/assignment_job_sites_provider.dart';
import '../../data/company_user_assignment_repository.dart';
import '../../data/company_user_hierarchy_provider.dart';
import '../../domain/company_user_hierarchy_model.dart';

class EditUserAssignmentDialog
    extends ConsumerStatefulWidget {
  final CompanyUserHierarchyModel user;

  const EditUserAssignmentDialog({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditUserAssignmentDialog>
  createState() {
    return _EditUserAssignmentDialogState();
  }
}

class _EditUserAssignmentDialogState
    extends ConsumerState<EditUserAssignmentDialog> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController positionController;
  late TextEditingController departmentController;

  int? selectedHierarchyLayer;
  String? selectedJobSiteId;

  bool isActive = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    selectedHierarchyLayer =
        widget.user.hierarchyLayer;

    selectedJobSiteId =
        widget.user.jobSiteId;

    positionController = TextEditingController(
      text: normalizeInitialText(
        widget.user.position,
      ),
    );

    departmentController = TextEditingController(
      text: normalizeInitialText(
        widget.user.department,
      ),
    );

    isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    positionController.dispose();
    departmentController.dispose();

    super.dispose();
  }

  String normalizeInitialText(String value) {
    if (value == '-') {
      return '';
    }

    return value;
  }

  void handleHierarchyChanged(int? value) {
    setState(() {
      selectedHierarchyLayer = value;
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

  void closeDialog() {
    if (isSaving) {
      return;
    }

    Navigator.of(context).pop();
  }

  String? validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }

    return null;
  }

  Future<void> handleSave() async {
    if (isSaving) {
      return;
    }

    final isValid =
        formKey.currentState?.validate() ?? false;

    if (!isValid) {
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
        companyUserAssignmentRepositoryProvider,
      );

      await repository.updateAssignment(
        companyUserId:
        widget.user.companyUserId,
        hierarchyLayer:
        selectedHierarchyLayer!,
        position:
        positionController.text,
        department:
        departmentController.text,
        jobSiteId:
        selectedJobSiteId,
        isActive:
        isActive,
      );

      ref.invalidate(
        companyUserHierarchyProvider,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assignment ${widget.user.fullName} '
                'berhasil diperbarui.',
          ),
          backgroundColor:
          const Color(0xFF059669),
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
        content: Text(message),
        backgroundColor:
        const Color(0xFFDC2626),
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
    final jobSitesAsync = ref.watch(
      assignmentJobSitesProvider(
        widget.user.companyId,
      ),
    );

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
            Icons.manage_accounts_outlined,
            color: Color(0xFF0D6EFD),
            size: 23,
          ),
          SizedBox(width: 10),
          Text(
            'Edit User Assignment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                buildUserSummary(),
                const SizedBox(height: 18),
                buildHierarchyField(),
                const SizedBox(height: 14),
                buildPositionField(),
                const SizedBox(height: 14),
                buildDepartmentField(),
                const SizedBox(height: 14),
                buildJobSiteField(
                  jobSitesAsync,
                ),
                const SizedBox(height: 10),
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
          onPressed: isSaving
              ? null
              : handleSave,
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
            Icons.save_outlined,
            size: 18,
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

  Widget buildUserSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          DialogInfoRow(
            label: 'Nama',
            value: widget.user.fullName,
          ),
          DialogInfoRow(
            label: 'SID',
            value: widget.user.sid,
          ),
          DialogInfoRow(
            label: 'Perusahaan',
            value: widget.user.companyName,
          ),
          DialogInfoRow(
            label: 'Job Site',
            value: widget.user.jobSite,
          ),
        ],
      ),
    );
  }

  Widget buildHierarchyField() {
    return DropdownButtonFormField<int>(
      value: selectedHierarchyLayer,
      isExpanded: true,
      decoration: buildInputDecoration(
        label: 'Hierarchy Layer',
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

  String? validateHierarchy(int? value) {
    if (value == null) {
      return 'Hierarchy wajib dipilih';
    }

    if (value < 1 || value > 4) {
      return 'Hierarchy tidak valid';
    }

    return null;
  }

  Widget buildPositionField() {
    return TextFormField(
      controller: positionController,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Position',
        hint: 'Contoh: Supervisor',
      ),
      validator: validateRequiredText,
    );
  }

  Widget buildDepartmentField() {
    return TextFormField(
      controller: departmentController,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Department',
        hint: 'Contoh: Operation',
      ),
      validator: validateRequiredText,
    );
  }

  Widget buildJobSiteField(
      AsyncValue<List<AssignmentJobSiteOption>>
      jobSitesAsync,
      ) {
    return jobSitesAsync.when(
      loading: buildJobSiteLoading,
      error: buildJobSiteError,
      data: buildJobSiteDropdown,
    );
  }

  Widget buildJobSiteLoading() {
    return const SizedBox(
      height: 46,
      child: Center(
        child: LinearProgressIndicator(),
      ),
    );
  }

  Widget buildJobSiteError(
      Object error,
      StackTrace stackTrace,
      ) {
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
        'Gagal membaca Job Site: $error',
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 12,
        ),
      ),
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
        availableIds.contains(selectedJobSiteId)) {
      validSelectedValue = selectedJobSiteId;
    }

    return DropdownButtonFormField<String>(
      value: validSelectedValue,
      isExpanded: true,
      decoration: buildInputDecoration(
        label: 'Job Site',
        hint: 'Pilih Job Site',
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

  Widget buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: SwitchListTile(
        value: isActive,
        onChanged: handleActiveChanged,
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
              ? 'User aktif dan dapat menggunakan aksesnya.'
              : 'Assignment user dinonaktifkan.',
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
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const DialogInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
