class CompanyLayer4GroupModel {
  final String id;

  final String company1Id;
  final String company1Name;

  final String company2Id;
  final String company2Name;

  final bool isActive;

  final String createdBy;
  final String createdByName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyLayer4GroupModel({
    required this.id,
    required this.company1Id,
    required this.company1Name,
    required this.company2Id,
    required this.company2Name,
    required this.isActive,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyLayer4GroupModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return CompanyLayer4GroupModel(
      id: map['id']?.toString() ?? '',
      company1Id:
      map['company_1_id']?.toString() ??
          '',
      company1Name: _readRelationValue(
        map['company_1'],
        'company_name',
      ),
      company2Id:
      map['company_2_id']?.toString() ??
          '',
      company2Name: _readRelationValue(
        map['company_2'],
        'company_name',
      ),
      isActive:
      map['is_active'] as bool? ?? false,
      createdBy:
      map['created_by']?.toString() ?? '',
      createdByName: _readRelationValue(
        map['creator'],
        'full_name',
      ),
      createdAt: DateTime.tryParse(
        map['created_at']?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        map['updated_at']?.toString() ?? '',
      ),
    );
  }

  String get statusLabel {
    return isActive ? 'Aktif' : 'Nonaktif';
  }

  String get groupLabel {
    return '$company1Name ↔ $company2Name';
  }

  static String _readRelationValue(
      dynamic relation,
      String key,
      ) {
    if (relation is Map) {
      final value =
      relation[key]?.toString().trim();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '-';
  }
}

class Layer4GroupCompanyOption {
  final String id;
  final String companyName;

  const Layer4GroupCompanyOption({
    required this.id,
    required this.companyName,
  });

  factory Layer4GroupCompanyOption.fromMap(
      Map<String, dynamic> map,
      ) {
    return Layer4GroupCompanyOption(
      id: map['id']?.toString() ?? '',
      companyName:
      map['company_name']?.toString() ??
          '-',
    );
  }
}