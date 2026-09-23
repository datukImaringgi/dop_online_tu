class MasterUnitModel {
  final String id;
  final String companyId;
  final String companyName;
  final String? jobSiteId;
  final String jobSiteName;
  final String unitNumber;
  final String unitType;
  final String ownerCompany;
  final bool isActive;

  const MasterUnitModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.jobSiteId,
    required this.jobSiteName,
    required this.unitNumber,
    required this.unitType,
    required this.ownerCompany,
    required this.isActive,
  });

  factory MasterUnitModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final companyRelation =
    map['companies'] as Map<String, dynamic>?;

    final jobSiteRelation =
    map['job_sites'] as Map<String, dynamic>?;

    return MasterUnitModel(
      id: map['id'] as String,
      companyId:
      map['company_id'] as String,
      companyName:
      companyRelation?['company_name']
      as String? ??
          '-',
      jobSiteId:
      map['job_site_id'] as String?,
      jobSiteName:
      jobSiteRelation?['site_name']
      as String? ??
          '-',
      unitNumber:
      map['unit_number'] as String? ??
          '-',
      unitType:
      map['unit_type'] as String? ??
          '-',
      ownerCompany:
      map['owner_company'] as String? ??
          '-',
      isActive:
      map['is_active'] as bool? ??
          false,
    );
  }

  String get unitTypeLabel {
    final normalizedType =
    unitType.trim().toUpperCase();

    if (normalizedType == 'MICRO_BUS') {
      return 'Micro Bus';
    }

    if (normalizedType == 'MANHAUL') {
      return 'Manhaul';
    }

    if (normalizedType == 'BUS') {
      return 'BUS';
    }

    if (normalizedType == 'LV') {
      return 'LV';
    }

    return unitType;
  }

  String get statusLabel {
    if (isActive) {
      return 'Aktif';
    }

    return 'Nonaktif';
  }
}

class MasterUnitChangeResult {
  final String resultType;
  final String actionType;
  final String? requestId;
  final String? targetRecordId;
  final String message;

  const MasterUnitChangeResult({
    required this.resultType,
    required this.actionType,
    required this.requestId,
    required this.targetRecordId,
    required this.message,
  });

  factory MasterUnitChangeResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return MasterUnitChangeResult(
      resultType:
      map['result_type'] as String? ??
          'unknown',
      actionType:
      map['action_type'] as String? ??
          '-',
      requestId:
      map['request_id'] as String?,
      targetRecordId:
      map['target_record_id'] as String?,
      message:
      map['message'] as String? ??
          'Proses perubahan selesai.',
    );
  }

  bool get isPendingApproval {
    return resultType ==
        'pending_approval';
  }

  bool get isAppliedDirectly {
    return resultType == 'applied';
  }
}