import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/supabase_provider.dart';
import '../providers/user_session_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  int getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) {
      return 0;
    }

    if (location.startsWith('/dop-list') || location.startsWith('/dop-request')) {
      return 1;
    }

    if (location.startsWith('/approval')) {
      return 2;
    }

    if (location.startsWith('/master')) {
      return 3;
    }

    return 0;
  }

  void onMenuSelected(BuildContext context, int index) {
    if (index == 0) {
      context.go('/dashboard');
    } else if (index == 1) {
      context.go('/dop-list');
    } else if (index == 2) {
      context.go('/approval');
    } else if (index == 3) {
      context.go('/master');
    }
  }

  Future<void> logout(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final supabase = ref.read(
      supabaseProvider,
    );

    try {
      await supabase.auth.signOut();

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

      if (!context.mounted) {
        return;
      }

      context.go('/login');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal logout: $error',
          ),
          backgroundColor:
          const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = getSelectedIndex(location);

    final profileAsync = ref.watch(currentProfileProvider);
    final companyAccessAsync = ref.watch(currentCompanyAccessProvider);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF062B4F),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        alignment: Alignment.center,
                        color: const Color(0xFFFFC928),
                        child: const Text(
                          'Trakindo',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        alignment: Alignment.center,
                        color: Colors.black,
                        child: const Text(
                          'CAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: companyAccessAsync.when(
                      loading: (){
                        return const Text(
                          'loading company...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                      error: (error, stackTrace){
                        return const Text(
                          'DOP Online',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                      data: (companyAccess){
                        return Text(
                          companyAccess?.companyName ?? 'DOP Online',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        _SidebarMenuItem(
                          icon: Icons.dashboard_outlined,
                          label: 'Dashboard',
                          isSelected: selectedIndex == 0,
                          onTap: () {
                            onMenuSelected(context, 0);
                          },
                        ),
                        _SidebarMenuItem(
                          icon: Icons.table_chart_outlined,
                          label: 'DOP List',
                          isSelected: selectedIndex == 1,
                          onTap: () {
                            onMenuSelected(context, 1);
                          },
                        ),
                        _SidebarMenuItem(
                          icon: Icons.fact_check_outlined,
                          label: 'Approval',
                          isSelected: selectedIndex == 2,
                          badgeText: '6',
                          onTap: () {
                            onMenuSelected(context, 2);
                          },
                        ),
                        _SidebarMenuItem(
                          icon: Icons.storage_outlined,
                          label: 'Master Data',
                          isSelected: selectedIndex == 3,
                          onTap: () {
                            onMenuSelected(context, 3);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3A68),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: profileAsync.when(
                      loading: () {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) {
                        return const Text(
                          'User',
                          style: TextStyle(color: Colors.white),
                        );
                      },
                      data: (profile) {
                        return  companyAccessAsync.when(
                          loading: () {
                            return _UserCardContent(
                              fullname: profile?.fullName ?? '-',
                              position: 'Loading...',
                            );
                          },
                          error: (error, stackTrace) {
                            return _UserCardContent(
                              fullname: profile?.fullName ?? '-',
                              position: '-',
                            );
                          },
                          data: (companyAccess) {
                            return _UserCardContent(
                              fullname: profile?.fullName ?? '-',
                              position: companyAccess?.position ?? '-',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: InkWell(
                    onTap: () {
                      logout(context, ref);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFFF7F9FC),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCardContent extends StatelessWidget {
  final String fullname;
  final String position;

  const _UserCardContent ({
    required this.fullname,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFE8EEF5),
          child: Icon(
            Icons.person,
            color: Color(0xFF062B4F),
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badgeText;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0D6EFD)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B4E),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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