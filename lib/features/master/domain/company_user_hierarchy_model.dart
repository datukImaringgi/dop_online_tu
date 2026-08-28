class CompanyUserHierarchyModel {
  final String companyUserId;
  final String userId;
  final String companyId;

  final String companyName;
  final String companyCode;

  final String fullName;
  final String sid;
  final String notificationEmail;

  final String role;
  final int? hierarchyLayer;

  final String position;
  final String department;

  final String? jobSiteId;
  final String jobSite;

  final bool isActive;

  const CompanyUserHierarchyModel({
    required this.companyUserId,
    required this.userId,
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.fullName,
    required this.sid,
    required this.notificationEmail,
    required this.role,
    required this.hierarchyLayer,
    required this.position,
    required this.department,
    required this.jobSiteId,
    required this.jobSite,
    required this.isActive,
  });

  factory CompanyUserHierarchyModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return CompanyUserHierarchyModel(
      companyUserId:
      map['company_user_id'] as String,
      userId:
      map['user_id'] as String,
      companyId:
      map['company_id'] as String,
      companyName:
      map['company_name'] as String? ?? '-',
      companyCode:
      map['company_code'] as String? ?? '-',
      fullName:
      map['full_name'] as String? ?? '-',
      sid:
      map['sid'] as String? ?? '-',
      notificationEmail:
      map['notification_email'] as String? ?? '-',
      role:
      map['role'] as String? ?? '-',
      hierarchyLayer:
      map['hierarchy_layer'] as int?,
      position:
      map['position'] as String? ?? '-',
      department:
      map['department'] as String? ?? '-',
      jobSiteId:
      map['job_site_id'] as String?,
      jobSite:
      map['job_site'] as String? ?? '-',
      isActive:
      map['is_active'] as bool? ?? false,
    );
  }

  String get hierarchyLabel {
    if (hierarchyLayer == null) {
      return 'Belum Diatur';
    }

    return 'Layer $hierarchyLayer';
  }

  String get statusLabel {
    if (isActive) {
      return 'Aktif';
    }

    return 'Nonaktif';
  }
}