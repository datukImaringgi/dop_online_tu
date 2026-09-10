import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/account_repository.dart';

class ChangePasswordDialog
    extends ConsumerStatefulWidget {
  const ChangePasswordDialog({
    super.key,
  });

  @override
  ConsumerState<ChangePasswordDialog>
  createState() {
    return _ChangePasswordDialogState();
  }
}

class _ChangePasswordDialogState
    extends ConsumerState<
        ChangePasswordDialog> {
  final formKey = GlobalKey<FormState>();

  final currentPasswordController =
  TextEditingController();

  final newPasswordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isSaving = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void closeDialog() {
    if (isSaving) {
      return;
    }

    Navigator.of(context).pop();
  }

  void toggleCurrentPassword() {
    setState(() {
      isCurrentPasswordVisible =
      !isCurrentPasswordVisible;
    });
  }

  void toggleNewPassword() {
    setState(() {
      isNewPasswordVisible =
      !isNewPasswordVisible;
    });
  }

  void toggleConfirmPassword() {
    setState(() {
      isConfirmPasswordVisible =
      !isConfirmPasswordVisible;
    });
  }

  String? validateCurrentPassword(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return 'Password saat ini wajib diisi';
    }

    return null;
  }

  String? validateNewPassword(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return 'Password baru wajib diisi';
    }

    if (value.length < 8) {
      return 'Password baru minimal 8 karakter';
    }

    if (value ==
        currentPasswordController.text) {
      return 'Password baru tidak boleh sama '
          'dengan password saat ini';
    }

    return null;
  }

  String? validateConfirmPassword(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (value != newPasswordController.text) {
      return 'Konfirmasi password tidak sama';
    }

    return null;
  }

  Future<void> savePassword() async {
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
        accountRepositoryProvider,
      );

      await repository.changePassword(
        currentPassword:
        currentPasswordController.text,
        newPassword:
        newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      final messenger =
      ScaffoldMessenger.of(context);

      Navigator.of(context).pop(true);

      messenger.showSnackBar(
        const SnackBar(
          backgroundColor:
          Color(0xFF059669),
          content: Text(
            'Password berhasil diperbarui.',
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFFDC2626),
        content: Text(message),
      ),
    );
  }

  String extractErrorMessage(
      Object error,
      ) {
    final message = error.toString();

    if (message.startsWith(
      'AuthException(message: ',
    )) {
      final cleaned = message.replaceFirst(
        'AuthException(message: ',
        '',
      );

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Row(
        children: [
          Icon(
            Icons.lock_reset_outlined,
            color: Color(0xFF2563EB),
            size: 21,
          ),
          SizedBox(width: 9),
          Text(
            'Ganti Password',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCurrentPasswordField(),
              const SizedBox(height: 12),
              buildNewPasswordField(),
              const SizedBox(height: 12),
              buildConfirmPasswordField(),
            ],
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
          isSaving ? null : savePassword,
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
            Icons.lock_reset_outlined,
            size: 17,
          ),
          label: Text(
            isSaving
                ? 'Memproses...'
                : 'Ganti Password',
          ),
        ),
      ],
    );
  }

  Widget buildCurrentPasswordField() {
    return TextFormField(
      controller:
      currentPasswordController,
      enabled: !isSaving,
      obscureText:
      !isCurrentPasswordVisible,
      decoration: buildDecoration(
        label: 'Password Saat Ini',
        visible:
        isCurrentPasswordVisible,
        onVisibilityPressed:
        toggleCurrentPassword,
      ),
      validator: validateCurrentPassword,
    );
  }

  Widget buildNewPasswordField() {
    return TextFormField(
      controller: newPasswordController,
      enabled: !isSaving,
      obscureText: !isNewPasswordVisible,
      decoration: buildDecoration(
        label: 'Password Baru',
        visible: isNewPasswordVisible,
        onVisibilityPressed:
        toggleNewPassword,
      ),
      validator: validateNewPassword,
    );
  }

  Widget buildConfirmPasswordField() {
    return TextFormField(
      controller:
      confirmPasswordController,
      enabled: !isSaving,
      obscureText:
      !isConfirmPasswordVisible,
      decoration: buildDecoration(
        label: 'Konfirmasi Password Baru',
        visible:
        isConfirmPasswordVisible,
        onVisibilityPressed:
        toggleConfirmPassword,
      ),
      validator: validateConfirmPassword,
    );
  }

  InputDecoration buildDecoration({
    required String label,
    required bool visible,
    required VoidCallback
    onVisibilityPressed,
  }) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: const Icon(
        Icons.lock_outline,
        size: 19,
      ),
      suffixIcon: IconButton(
        onPressed: onVisibilityPressed,
        tooltip: visible
            ? 'Sembunyikan password'
            : 'Tampilkan password',
        icon: Icon(
          visible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 19,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}