class ClientCompanyResult {
  final String companyId;
  final String companyName;
  final String companyCode;
  final bool isActive;
  final String message;

  const ClientCompanyResult({
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.isActive,
    required this.message,
  });

  factory ClientCompanyResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return ClientCompanyResult(
      companyId:
      map['company_id'] as String? ?? '',
      companyName:
      map['company_name'] as String? ?? '-',
      companyCode:
      map['company_code'] as String? ?? '-',
      isActive:
      map['is_active'] as bool? ?? false,
      message:
      map['message'] as String? ??
          'Perusahaan berhasil didaftarkan.',
    );
  }

  String get displayName {
    return '$companyName ($companyCode)';
  }
}