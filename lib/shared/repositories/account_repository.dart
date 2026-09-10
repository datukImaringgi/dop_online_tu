import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_provider.dart';

class AccountRepository {
  final SupabaseClient supabase;

  const AccountRepository({
    required this.supabase,
  });

  Future<void> updateNotificationEmail({
    required String notificationEmail,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Session user tidak ditemukan.',
      );
    }

    final normalizedEmail =
    notificationEmail.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'Email notifikasi wajib diisi.',
      );
    }

    await supabase
        .from('profiles')
        .update({
      'notification_email': normalizedEmail,
    })
        .eq('id', user.id);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Session user tidak ditemukan.',
      );
    }

    final email = user.email;

    if (email == null || email.trim().isEmpty) {
      throw Exception(
        'Email login user tidak ditemukan.',
      );
    }

    if (currentPassword.isEmpty) {
      throw Exception(
        'Password saat ini wajib diisi.',
      );
    }

    if (newPassword.length < 8) {
      throw Exception(
        'Password baru minimal 8 karakter.',
      );
    }

    if (currentPassword == newPassword) {
      throw Exception(
        'Password baru tidak boleh sama '
            'dengan password saat ini.',
      );
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw Exception(
        'Password saat ini tidak sesuai.',
      );
    }

    await supabase.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
  }
}

AccountRepository buildAccountRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return AccountRepository(
    supabase: supabase,
  );
}

final accountRepositoryProvider =
Provider<AccountRepository>(
  buildAccountRepository,
);