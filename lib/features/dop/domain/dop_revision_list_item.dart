class DopRevisionListItem {
  final String dopHeaderId;
  final String dopNumber;

  final String companyId;
  final String companyName;
  final String companyCode;

  final String jobSiteId;
  final String jobSite;

  final String dopDate;
  final String dayName;
  final String status;
  final int revisionNumber;

  final String createdBy;
  final String createdByName;
  final String createdBySid;

  final int totalActivities;

  final int? returnedByLayer;
  final String? returnedBy;
  final String returnedByName;
  final String revisionNote;
  final String rejectedAt;

  final String createdAt;
  final String updatedAt;

  const DopRevisionListItem({
    required this.dopHeaderId,
    required this.dopNumber,
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.jobSiteId,
    required this.jobSite,
    required this.dopDate,
    required this.dayName,
    required this.status,
    required this.revisionNumber,
    required this.createdBy,
    required this.createdByName,
    required this.createdBySid,
    required this.totalActivities,
    required this.returnedByLayer,
    required this.returnedBy,
    required this.returnedByName,
    required this.revisionNote,
    required this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DopRevisionListItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return DopRevisionListItem(
      dopHeaderId:
      map['dop_header_id'] as String,
      dopNumber:
      map['dop_number'] as String? ?? '-',
      companyId:
      map['company_id'] as String,
      companyName:
      map['company_name'] as String? ?? '-',
      companyCode:
      map['company_code'] as String? ?? '-',
      jobSiteId:
      map['job_site_id'] as String? ?? '',
      jobSite:
      map['job_site'] as String? ?? '-',
      dopDate:
      map['dop_date']?.toString() ?? '-',
      dayName:
      map['day_name'] as String? ?? '-',
      status:
      map['status'] as String? ?? '-',
      revisionNumber:
      readInteger(
        map['revision_number'],
      ),
      createdBy:
      map['created_by'] as String? ?? '',
      createdByName:
      map['created_by_name'] as String? ?? '-',
      createdBySid:
      map['created_by_sid'] as String? ?? '-',
      totalActivities:
      readInteger(
        map['total_activities'],
      ),
      returnedByLayer:
      readNullableInteger(
        map['returned_by_layer'],
      ),
      returnedBy:
      map['returned_by'] as String?,
      returnedByName:
      map['returned_by_name'] as String? ?? '-',
      revisionNote:
      readDisplayText(
        map['revision_note'],
      ),
      rejectedAt:
      readDisplayText(
        map['rejected_at'],
      ),
      createdAt:
      readDisplayText(
        map['created_at'],
      ),
      updatedAt:
      readDisplayText(
        map['updated_at'],
      ),
    );
  }

  bool canEdit(String? currentUserId) {
    if (currentUserId == null ||
        currentUserId.isEmpty) {
      return false;
    }

    return status == 'revision_required' &&
        createdBy == currentUserId;
  }

  String get returnedByLayerLabel {
    if (returnedByLayer == null) {
      return '-';
    }

    return 'Layer $returnedByLayer';
  }

  String get revisionLabel {
    if (revisionNumber <= 0) {
      return 'Revisi Pertama';
    }

    return 'Revisi ${revisionNumber + 1}';
  }

  String get statusLabel {
    if (status == 'revision_required') {
      return 'Perlu Revisi';
    }

    return status;
  }

  static int readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int? readNullableInteger(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static String readDisplayText(
      dynamic value,
      ) {
    if (value == null) {
      return '-';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '-';
    }

    return text;
  }
}