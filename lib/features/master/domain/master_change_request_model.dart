class MasterChangeRequestModel {
  final String id;
  final String companyId;
  final String companyName;
  final String masterType;
  final String actionType;
  final String? targetRecordId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? requestedData;
  final String status;
  final String requestedBy;
  final String requestedByName;
  final DateTime requestedAt;
  final String? reviewedBy;
  final String reviewedByName;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final Map<String, String> jobSiteNames;

  const MasterChangeRequestModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.masterType,
    required this.actionType,
    required this.targetRecordId,
    required this.oldData,
    required this.requestedData,
    required this.status,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedAt,
    required this.reviewedBy,
    required this.reviewedByName,
    required this.reviewedAt,
    required this.reviewNote,
    required this.jobSiteNames,
  });

  factory MasterChangeRequestModel.fromMap(
      Map<String, dynamic> map, {
        required Map<String, String> profileNames,
        required Map<String, String> jobSiteNames,
      }) {
    final requestedBy =
        map['requested_by'] as String? ?? '';

    final reviewedBy =
    map['reviewed_by'] as String?;

    final companyRelation =
    map['companies'] as Map<String, dynamic>?;

    return MasterChangeRequestModel(
      id: map['id'] as String,
      companyId:
      map['company_id'] as String,
      companyName:
      companyRelation?['company_name']
      as String? ??
          '-',
      masterType:
      map['master_type'] as String? ??
          '-',
      actionType:
      map['action_type'] as String? ??
          '-',
      targetRecordId:
      map['target_record_id'] as String?,
      oldData: readJsonMap(
        map['old_data'],
      ),
      requestedData: readJsonMap(
        map['requested_data'],
      ),
      status:
      map['status'] as String? ??
          '-',
      requestedBy: requestedBy,
      requestedByName:
      profileNames[requestedBy] ??
          requestedBy,
      requestedAt: readDateTime(
        map['requested_at'],
      ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),
      reviewedBy: reviewedBy,
      reviewedByName: reviewedBy == null
          ? '-'
          : profileNames[reviewedBy] ??
          reviewedBy,
      reviewedAt: readDateTime(
        map['reviewed_at'],
      ),
      reviewNote:
      map['review_note'] as String?,
      jobSiteNames: jobSiteNames,
    );
  }

  static Map<String, dynamic>? readJsonMap(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      final result = <String, dynamic>{};

      for (final entry in value.entries) {
        result[entry.key.toString()] =
            entry.value;
      }

      return result;
    }

    return null;
  }

  static DateTime? readDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String get masterTypeLabel {
    if (masterType == 'unit') {
      return 'Master Unit';
    }

    if (masterType == 'user_assignment') {
      return 'User & Hierarchy';
    }

    if (masterType == 'driver') {
      return 'Master Driver';
    }

    if (masterType == 'route') {
      return 'Master Rute';
    }

    if (masterType == 'job_site') {
      return 'Master Job Site';
    }

    if (masterType == 'jsa_procedure') {
      return 'Master JSA';
    }

    if (masterType == 'control_room') {
      return 'Master RIC';
    }

    return masterType;
  }

  String get actionTypeLabel {
    if (actionType == 'create') {
      return 'Penambahan';
    }

    if (actionType == 'update') {
      return 'Perubahan';
    }

    if (actionType == 'activate') {
      return 'Aktivasi';
    }

    if (actionType == 'deactivate') {
      return 'Penonaktifan';
    }

    return actionType;
  }

  String get statusLabel {
    if (status == 'pending') {
      return 'Menunggu Approval';
    }

    if (status == 'approved') {
      return 'Disetujui';
    }

    if (status == 'rejected') {
      return 'Ditolak';
    }

    if (status == 'cancelled') {
      return 'Dibatalkan';
    }

    return status;
  }

  bool get isPending {
    return status == 'pending';
  }

  String get targetDisplayName {
    final requested = requestedData;
    final old = oldData;

    if (masterType == 'unit') {
      final requestedUnitNumber =
      requested?['unit_number'];

      if (requestedUnitNumber != null) {
        return requestedUnitNumber
            .toString();
      }

      final oldUnitNumber =
      old?['unit_number'];

      if (oldUnitNumber != null) {
        return oldUnitNumber.toString();
      }
    }

    return targetRecordId ?? '-';
  }
  Map<String, dynamic>? get displayOldData {
    return buildDisplayData(
      oldData,
    );
  }

  Map<String, dynamic>? get displayRequestedData {
    return buildDisplayData(
      requestedData,
    );
  }

  Map<String, dynamic>? buildDisplayData(
      Map<String, dynamic>? source,
      ) {
    if (source == null) {
      return null;
    }

    final result = <String, dynamic>{};

    for (final entry in source.entries) {
      if (entry.key == 'company_id') {
        continue;
      }

      if (entry.key == 'job_site_id') {
        final jobSiteId =
            entry.value?.toString() ?? '';

        result['job_site'] =
            jobSiteNames[jobSiteId] ??
                'Job Site tidak ditemukan';

        continue;
      }

      result[entry.key] = entry.value;
    }

    return result;
  }
}

class MasterChangeReviewResult {
  final String resultType;
  final String requestId;
  final String? targetRecordId;
  final String message;

  const MasterChangeReviewResult({
    required this.resultType,
    required this.requestId,
    required this.targetRecordId,
    required this.message,
  });

  factory MasterChangeReviewResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return MasterChangeReviewResult(
      resultType:
      map['result_type'] as String? ??
          map['resultType'] as String? ??
          'unknown',
      requestId:
      map['request_id'] as String? ??
          map['requestId'] as String? ??
          '',
      targetRecordId:
      map['target_record_id']
      as String? ??
          map['targetRecordId']
          as String?,
      message:
      map['message'] as String? ??
          'Request berhasil diproses.',
    );
  }
}