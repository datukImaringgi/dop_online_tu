class CompanyUserModel {
  final String id;
  final String companyId;
  final String userId;
  final String role;
  final int? hierarchyLayer;
  final String? position;
  final String? department;
  final String? jobSiteId;
  final String? jobSiteName;
  final bool isActive;
  final String? companyName;
  final String? companyCode;

  CompanyUserModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.role,
    required this.hierarchyLayer,
    required this.position,
    required this.department,
    required this.jobSiteId,
    required this.jobSiteName,
    required this.isActive,
    required this.companyName,
    required this.companyCode,
  });

  factory CompanyUserModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final company =
    map['companies']
    as Map<String, dynamic>?;

    final jobSite =
    map['job_sites']
    as Map<String, dynamic>?;

    return CompanyUserModel(
      id: map['id'] as String,
      companyId:
      map['company_id'] as String,
      userId:
      map['user_id'] as String,
      role:
      map['role'] as String,
      hierarchyLayer:
      map['hierarchy_layer'] as int?,
      position:
      map['position'] as String?,
      department:
      map['department'] as String?,
      jobSiteId:
      map['job_site_id'] as String?,
      jobSiteName:
      jobSite?['site_name'] as String?,
      isActive:
      map['is_active'] as bool? ?? true,
      companyName:
      company?['company_name'] as String?,
      companyCode:
      company?['company_code'] as String?,
    );
  }
}