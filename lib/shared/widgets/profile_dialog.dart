import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_session_provider.dart';
import '../models/company_user_model.dart';
import '../models/profile_model.dart';
import 'change_notification_email_dialog.dart';
import 'change_password_dialog.dart';

class ProfileDialog extends ConsumerWidget {
  final ProfileModel profile;
  final CompanyUserModel? companyAccess;

  const ProfileDialog({
    super.key,
    required this.profile,
    required this.companyAccess,
  });

  String displayValue(String? value) {
    final normalizedValue = value?.trim() ?? '';

    if (normalizedValue.isEmpty) {
      return '-';
    }

    return normalizedValue;
  }

  String get hierarchyText {
    final hierarchyLayer =
        companyAccess?.hierarchyLayer;

    if (hierarchyLayer == null) {
      return '-';
    }

    return 'Layer $hierarchyLayer';
  }

  String buildAccountStatus(
      ProfileModel currentProfile,
      ) {
    final assignmentIsActive =
        companyAccess?.isActive ?? false;

    if (currentProfile.isActive &&
        assignmentIsActive) {
      return 'Aktif';
    }

    return 'Nonaktif';
  }

  Future<void> openEmailDialog(
      BuildContext context,
      ProfileModel currentProfile,
      ) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return ChangeNotificationEmailDialog(
          currentEmail:
          currentProfile.notificationEmail ??
              '',
        );
      },
    );
  }

  Future<void> openPasswordDialog(
      BuildContext context,
      ) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return const ChangePasswordDialog();
      },
    );
  }

  void closeDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final latestProfileAsync = ref.watch(
      currentProfileProvider,
    );

    final latestProfile =
        latestProfileAsync.asData?.value ??
            profile;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Row(
        children: [
          Icon(
            Icons.account_circle_outlined,
            color: Color(0xFF2563EB),
            size: 22,
          ),
          SizedBox(width: 9),
          Text(
            'Profil Saya',
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildProfileInformation(
                latestProfile,
              ),
              const SizedBox(height: 14),
              buildPersonalSettings(
                context,
                latestProfile,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            closeDialog(context);
          },
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget buildProfileInformation(
      ProfileModel currentProfile,
      ) {
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
          ProfileInformationRow(
            label: 'Nama Lengkap',
            value: displayValue(
              currentProfile.fullName,
            ),
          ),
          ProfileInformationRow(
            label: 'SID',
            value: displayValue(currentProfile.sid),
          ),
          ProfileInformationRow(
            label: 'Perusahaan',
            value: displayValue(
              companyAccess?.companyName,
            ),
          ),
          ProfileInformationRow(
            label: 'Hierarchy',
            value: hierarchyText,
          ),
          ProfileInformationRow(
            label: 'Position',
            value: displayValue(
              companyAccess?.position,
            ),
          ),
          ProfileInformationRow(
            label: 'Department',
            value: displayValue(
              companyAccess?.department,
            ),
          ),
          ProfileInformationRow(
            label: 'Status',
            value: buildAccountStatus(
              currentProfile,
            ),
            showBottomSpacing: false,
          ),
        ],
      ),
    );
  }

  Widget buildPersonalSettings(
      BuildContext context,
      ProfileModel currentProfile,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan Pribadi',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.email_outlined,
              color: Color(0xFF2563EB),
            ),
            title: const Text(
              'Email Notifikasi',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              displayValue(
                currentProfile.notificationEmail,
              ),
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                openEmailDialog(
                  context,
                  currentProfile,
                );
              },
              child: const Text('Ubah'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.lock_reset_outlined,
              color: Color(0xFF2563EB),
            ),
            title: const Text(
              'Password',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Perbarui password akun Anda',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                openPasswordDialog(context);
              },
              child: const Text(
                'Ganti Password',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInformationRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool showBottomSpacing;

  const ProfileInformationRow({
    super.key,
    required this.label,
    required this.value,
    this.showBottomSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing ? 9 : 0,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}