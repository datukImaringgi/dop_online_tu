class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? sid;
  final String? notificationEmail;
  final bool isEmailNotificationEnabled;
  final String globalRole;
  final bool isActive;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.sid,
    required this.notificationEmail,
    required this.isEmailNotificationEnabled,
    required this.globalRole,
    required this.isActive,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      sid: map['sid'] as String?,
      notificationEmail: map['notification_email'] as String?,
      isEmailNotificationEnabled:
      map['is_email_notification_enabled'] as bool? ?? false,
      globalRole: map['global_role'] as String,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}