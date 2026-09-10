import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/supabase_provider.dart';
import '../providers/user_session_provider.dart';
import '../../features/approval/data/dop_approval_provider.dart';
import '../../features/dop/data/dop_revision_list_provider.dart';
import '../../features/master/data/master_change_request_provider.dart';
import '../widgets/profile_dialog.dart';

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

    if (location.startsWith('/dop-list') ||
        location.startsWith('/dop-request')) {
      return 1;
    }

    if (location.startsWith('/dop-revisions')) {
      return 2;
    }

    if (location.startsWith('/approval')) {
      return 3;
    }

    if (location.startsWith('/master-approval')) {
      return 5;
    }

    if (location.startsWith('/master')) {
      return 4;
    }

    return 0;
  }

  void onMenuSelected(
      BuildContext context,
      int index,
      ) {
    if (index == 0) {
      context.go('/dashboard');
      return;
    }

    if (index == 1) {
      context.go('/dop-list');
      return;
    }

    if (index == 2) {
      context.go('/dop-revisions');
      return;
    }

    if (index == 3) {
      context.go('/approval');
      return;
    }

    if (index == 4) {
      context.go('/master');
      return;
    }

    if (index == 5) {
      context.go('/master-approval');
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
        dopRevisionListProvider,
      );

      ref.invalidate(
        dopRevisionCountProvider,
      );

      ref.invalidate(
        pendingApprovalCountProvider,
      );

      ref.invalidate(
        masterChangeRequestsProvider,
      );

      ref.invalidate(
        pendingMasterChangeCountProvider,
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
    final hierarchyAsync = ref.watch(
      currentHierarchyLayerProvider,
    );

    final hierarchyLayer =
        hierarchyAsync.asData?.value;

    final canAccessDopRevision =
        hierarchyLayer != null &&
            hierarchyLayer >= 1 &&
            hierarchyLayer <= 4;

    final canAccessDopApproval =
        hierarchyLayer == 3 ||
            hierarchyLayer == 4;

    final canAccessMasterData =
        hierarchyLayer != null &&
            hierarchyLayer >= 3;

    final canAccessMasterRequest =
        hierarchyLayer == 3 ||
            hierarchyLayer == 4 ||
            hierarchyLayer == 5;

    final canReviewMasterRequest =
        hierarchyLayer == 5;

    final pendingApprovalCountAsync = ref.watch(
      pendingApprovalCountProvider,
    );

    final pendingApprovalCount =
        pendingApprovalCountAsync.asData?.value ?? 0;

    final pendingApprovalBadge =
    pendingApprovalCount > 0
        ? pendingApprovalCount.toString()
        : null;

    final pendingMasterCountAsync = ref.watch(
      pendingMasterChangeCountProvider,
    );

    final pendingMasterCount =
        pendingMasterCountAsync.asData?.value ??
            0;

    final pendingMasterBadge =
    pendingMasterCount > 0
        ? pendingMasterCount.toString()
        : null;

    String? revisionBadge;

    if (canAccessDopRevision) {
      final revisionCountAsync = ref.watch(
        dopRevisionCountProvider,
      );

      final revisionCount =
          revisionCountAsync.asData?.value ?? 0;

      if (revisionCount > 0) {
        revisionBadge =
            revisionCount.toString();
      }
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 224,
            color: const Color(0xFF062B4F),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: Image.network(
                            'https://edtuzimhejrluwljkihb.supabase.co/storage/v1/object/public/public-assets/logos/berau_coal_logo.jpg',
                            fit: BoxFit.contain,
                          )
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 7,
                          ),
                          color: const Color(0xFFCBD5E1),
                        ),
                        Expanded(
                          flex: 10,
                          child: Image.network(
                            'https://edtuzimhejrluwljkihb.supabase.co/storage/v1/object/public/public-assets/logos/trakindo_cat_logo.png',
                            fit: BoxFit.contain,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
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
                            fontSize: 12.5,
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        if (canAccessDopRevision)
                          _SidebarMenuItem(
                            icon: Icons.edit_note_outlined,
                            label: 'Revisi DOP',
                            isSelected: selectedIndex == 2,
                            badgeText: revisionBadge,
                            onTap: () {
                              onMenuSelected(context, 2);
                            },
                          ),
                        if (canAccessDopApproval)
                          _SidebarMenuItem(
                            icon: Icons.fact_check_outlined,
                            label: 'Approval DOP',
                            isSelected: selectedIndex == 3,
                            badgeText: pendingApprovalBadge,
                            onTap: () {
                              onMenuSelected(context, 3);
                            },
                          ),
                        if (canAccessMasterData)
                          _SidebarMenuItem(
                            icon: Icons.storage_outlined,
                            label: 'Master Data',
                            isSelected: selectedIndex == 4,
                            onTap: () {
                              onMenuSelected(context, 4);
                            },
                          ),

                        if (canAccessMasterRequest)
                          _SidebarMenuItem(
                            icon: canReviewMasterRequest
                                ? Icons.approval_outlined
                                : Icons.history_outlined,
                            label: canReviewMasterRequest
                                ? 'Approval Master'
                                : 'Master Request',
                            isSelected: selectedIndex == 5,
                            badgeText: pendingMasterBadge,
                            onTap: () {
                              onMenuSelected(context, 5);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3A68),
                      borderRadius: BorderRadius.circular(10),
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
                        return companyAccessAsync.when(
                          loading: () {
                            return _UserCardContent(
                              fullName:
                              profile?.fullName ?? '-',
                              sid:
                              profile?.sid ?? '-',
                              hierarchyLayer: null,
                              position: 'Loading...',
                              notificationEmail:
                              profile?.notificationEmail ?? '-',
                            );
                          },
                          error: (error, stackTrace) {
                            return _UserCardContent(
                              fullName:
                              profile?.fullName ?? '-',
                              sid:
                              profile?.sid ?? '-',
                              hierarchyLayer: null,
                              position: '-',
                              notificationEmail:
                              profile?.notificationEmail ?? '-',
                            );
                          },
                          data: (companyAccess) {
                            if (profile == null) {
                              return const Text(
                                'Profil tidak tersedia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                ),
                              );
                            }

                            return Tooltip(
                              message: 'Buka Profil Saya',
                              child: InkWell(
                                onTap: () {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (
                                        BuildContext dialogContext,
                                        ) {
                                      return ProfileDialog(
                                        profile: profile,
                                        companyAccess: companyAccess,
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: _UserCardContent(
                                    fullName: profile.fullName,
                                    sid: profile.sid ?? '-',
                                    hierarchyLayer:
                                    companyAccess?.hierarchyLayer,
                                    position:
                                    companyAccess?.position ?? '-',
                                    notificationEmail:
                                    profile.notificationEmail ?? '-',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: () {
                      logout(context, ref);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
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
  final String fullName;
  final String sid;
  final int? hierarchyLayer;
  final String position;
  final String notificationEmail;

  const _UserCardContent({
    required this.fullName,
    required this.sid,
    required this.hierarchyLayer,
    required this.position,
    required this.notificationEmail,
  });

  String get identityText {
    return '$fullName - $sid';
  }

  String get accessText {
    final layerText = hierarchyLayer == null
        ? 'Layer -'
        : 'Layer $hierarchyLayer';

    return '$layerText - $position';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFE8EEF5),
          child: Icon(
            Icons.person,
            color: Color(0xFF062B4F),
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: identityText,
                child: Text(
                  identityText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Tooltip(
                message: accessText,
                child: Text(
                  accessText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 10.5,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Tooltip(
                message: notificationEmail,
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF93C5FD),
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        notificationEmail,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 9.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0D6EFD)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFCBD5E1),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFE2E8F0),
                    fontSize: 12.5,
                    height: 1.1,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B4E),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeText!,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w700,
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