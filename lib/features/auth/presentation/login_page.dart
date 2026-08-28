import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final sidController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    sidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String buildInternalEmail(String sid) {
    final normalizedSid = sid.trim().toLowerCase();
    return '$normalizedSid@dop.local';
  }

  Future<void> login() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final sid = sidController.text.trim();
      final password = passwordController.text;

      if (sid.isEmpty) {
        throw Exception('SID wajib diisi');
      }

      if (password.isEmpty) {
        throw Exception('Password wajib diisi');
      }

      final internalEmail = buildInternalEmail(sid);
      final supabase = ref.read(supabaseProvider);

      await supabase.auth.signInWithPassword(
        email: internalEmail,
        password: password,
      );

      ref.invalidate(
        currentProfileProvider,
      );

      ref.invalidate(
        userCompaniesProvider,
      );

      ref.invalidate(
        currentCompanyAccessProvider,
      );

      ref.invalidate(
        currentHierarchyLayerProvider,
      );

      if (!mounted) {
        return;
      }

      context.go('/dashboard');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
        'Login gagal. Periksa SID dan password.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DOP Online',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Login menggunakan SID dan password'),
                  const SizedBox(height: 24),
                  TextField(
                    controller: sidController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'SID',
                      hintText: 'Contoh: HI12O',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      login();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      login();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : login,
                      child: isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                        ),
                      )
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}