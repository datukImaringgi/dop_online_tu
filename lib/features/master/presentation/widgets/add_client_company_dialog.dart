import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/active_companies_provider.dart';
import '../../data/client_company_repository.dart';
import '../../domain/client_company_result.dart';

class AddClientCompanyDialog
    extends ConsumerStatefulWidget {
  const AddClientCompanyDialog({
    super.key,
  });

  @override
  ConsumerState<AddClientCompanyDialog>
  createState() {
    return _AddClientCompanyDialogState();
  }
}

class _AddClientCompanyDialogState
    extends ConsumerState<
        AddClientCompanyDialog> {
  final formKey = GlobalKey<FormState>();

  final companyNameController =
  TextEditingController();

  final companyCodeController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final emailController =
  TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    companyNameController.dispose();
    companyCodeController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void closeDialog() {
    if (isSaving) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> registerCompany() async {
    if (isSaving) {
      return;
    }

    final isValid =
        formKey.currentState?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repository = ref.read(
        clientCompanyRepositoryProvider,
      );

      final result =
      await repository.registerCompany(
        companyName:
        companyNameController.text,
        companyCode:
        companyCodeController.text,
        address: addressController.text,
        phone: phoneController.text,
        email: emailController.text,
      );

      ref.invalidate(
        activeCompaniesProvider,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop<
          ClientCompanyResult>(
        result,
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
      final cleanedMessage =
      message.substring(
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
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
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
            Icons.add_business_outlined,
            color: Color(0xFF2563EB),
            size: 22,
          ),
          SizedBox(width: 10),
          Text(
            'Daftarkan Perusahaan Baru',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                buildInformationBanner(),
                const SizedBox(height: 14),
                buildCompanyNameField(),
                const SizedBox(height: 12),
                buildCompanyCodeField(),
                const SizedBox(height: 12),
                buildAddressField(),
                const SizedBox(height: 12),
                buildPhoneField(),
                const SizedBox(height: 12),
                buildEmailField(),
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
          isSaving ? null : registerCompany,
          style: FilledButton.styleFrom(
            backgroundColor:
            const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
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
                ? 'Mendaftarkan...'
                : 'Daftarkan Perusahaan',
          ),
        ),
      ],
    );
  }

  Widget buildInformationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF2563EB),
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Perusahaan baru akan langsung '
                  'didaftarkan karena tindakan ini '
                  'dilakukan oleh Layer 5.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompanyNameField() {
    return TextFormField(
      controller: companyNameController,
      enabled: !isSaving,
      textCapitalization:
      TextCapitalization.words,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Nama Perusahaan',
        hint: 'Contoh: PT Berau Coal',
        icon: Icons.business_outlined,
      ),
      validator: validateCompanyName,
    );
  }

  Widget buildCompanyCodeField() {
    return TextFormField(
      controller: companyCodeController,
      enabled: !isSaving,
      textCapitalization:
      TextCapitalization.characters,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Kode Perusahaan',
        hint: 'Contoh: BC',
        icon: Icons.tag_outlined,
      ),
      validator: validateCompanyCode,
    );
  }

  Widget buildAddressField() {
    return TextFormField(
      controller: addressController,
      enabled: !isSaving,
      minLines: 2,
      maxLines: 3,
      textCapitalization:
      TextCapitalization.sentences,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Alamat',
        hint: 'Opsional',
        icon: Icons.location_city_outlined,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      enabled: !isSaving,
      keyboardType: TextInputType.phone,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Nomor Telepon',
        hint: 'Opsional',
        icon: Icons.phone_outlined,
      ),
      validator: validatePhone,
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: emailController,
      enabled: !isSaving,
      keyboardType:
      TextInputType.emailAddress,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: buildInputDecoration(
        label: 'Email Perusahaan',
        hint: 'Opsional',
        icon: Icons.email_outlined,
      ),
      validator: validateEmail,
    );
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint:
      alignLabelWithHint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          bottom: alignLabelWithHint
              ? 35
              : 0,
        ),
        child: Icon(
          icon,
          size: 18,
        ),
      ),
      prefixIconConstraints:
      const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 12,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
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
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
          width: 1.4,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  String? validateCompanyName(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Nama perusahaan wajib diisi';
    }

    final companyName = value.trim();

    if (companyName.length < 3) {
      return 'Nama perusahaan minimal 3 karakter';
    }

    if (companyName.length > 200) {
      return 'Nama perusahaan maksimal 200 karakter';
    }

    return null;
  }

  String? validateCompanyCode(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Kode perusahaan wajib diisi';
    }

    final normalizedCode =
    value.trim().replaceAll(
      RegExp(r'[^A-Za-z0-9]'),
      '',
    );

    if (normalizedCode.length < 2) {
      return 'Kode perusahaan minimal 2 karakter';
    }

    if (normalizedCode.length > 20) {
      return 'Kode perusahaan maksimal 20 karakter';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final phone = value.trim();

    if (phone.length < 6) {
      return 'Nomor telepon terlalu pendek';
    }

    final phonePattern = RegExp(
      r'^[0-9+().\s-]+$',
    );

    if (!phonePattern.hasMatch(phone)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
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
}