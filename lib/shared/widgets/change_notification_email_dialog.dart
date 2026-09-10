import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_session_provider.dart';
import '../repositories/account_repository.dart';

class ChangeNotificationEmailDialog
    extends ConsumerStatefulWidget {
  final String currentEmail;

  const ChangeNotificationEmailDialog({
    super.key,
    required this.currentEmail,
  });

  @override
  ConsumerState<ChangeNotificationEmailDialog>
  createState() {
    return _ChangeNotificationEmailDialogState();
  }
}

class _ChangeNotificationEmailDialogState
    extends ConsumerState<
        ChangeNotificationEmailDialog> {
  final formKey = GlobalKey<FormState>();
  final emailController =
  TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.currentEmail != '-') {
      emailController.text =
          widget.currentEmail.trim();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email =
        value?.trim().toLowerCase() ?? '';

    if (email.isEmpty) {
      return 'Email notifikasi wajib diisi';
    }

    final pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  Future<void> saveEmail() async {
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

      await repository.updateNotificationEmail(
        notificationEmail:
        emailController.text,
      );

      ref.invalidate(
        currentProfileProvider,
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
            'Email notifikasi berhasil diperbarui.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
          const Color(0xFFDC2626),
          content: Text(
            extractErrorMessage(error),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String extractErrorMessage(
      Object error,
      ) {
    final message = error.toString();

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
      title: const Text(
        'Ubah Email Notifikasi',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            enabled: !isSaving,
            keyboardType:
            TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Notifikasi',
              hintText:
              'nama@perusahaan.com',
              prefixIcon: const Icon(
                Icons.email_outlined,
                size: 19,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
            validator: validateEmail,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed:
          isSaving ? null : saveEmail,
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
                ? 'Menyimpan...'
                : 'Simpan',
          ),
        ),
      ],
    );
  }
}