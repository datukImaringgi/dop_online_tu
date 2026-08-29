class DopApprovalListItem {
  final String dopHeaderId;
  final String dopNumber;

  final String companyId;
  final String companyName;
  final String companyCode;

  final String? jobSiteId;
  final String jobSite;

  final String dopDate;
  final String dayName;
  final String headerStatus;

  final String createdBy;
  final String createdByName;
  final String createdBySid;

  final String submittedAt;
  final int totalActivities;

  final String? approvalId;
  final int? approvalLevel;
  final String approvalRole;
  final String approvalStatus;
  final String? approverId;

  final int waitingSeconds;

  const DopApprovalListItem({
    required this.dopHeaderId,
    required this.dopNumber,
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.jobSiteId,
    required this.jobSite,
    required this.dopDate,
    required this.dayName,
    required this.headerStatus,
    required this.createdBy,
    required this.createdByName,
    required this.createdBySid,
    required this.submittedAt,
    required this.totalActivities,
    required this.approvalId,
    required this.approvalLevel,
    required this.approvalRole,
    required this.approvalStatus,
    required this.approverId,
    required this.waitingSeconds,
  });

  factory DopApprovalListItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return DopApprovalListItem(
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
      map['job_site_id'] as String?,
      jobSite:
      map['job_site'] as String? ?? '-',
      dopDate:
      map['dop_date'] as String? ?? '-',
      dayName:
      map['day_name'] as String? ?? '-',
      headerStatus:
      map['status'] as String? ?? '-',
      createdBy:
      map['created_by'] as String,
      createdByName:
      map['created_by_name'] as String? ?? '-',
      createdBySid:
      map['created_by_sid'] as String? ?? '-',
      submittedAt:
      map['submitted_at'] as String? ?? '-',
      totalActivities:
      map['total_activities'] as int? ?? 0,
      approvalId:
      map['approval_id'] as String?,
      approvalLevel:
      map['approval_level'] as int?,
      approvalRole:
      map['approver_role'] as String? ?? '-',
      approvalStatus:
      map['approval_status'] as String? ?? '-',
      approverId:
      map['approver_id'] as String?,
      waitingSeconds:
      readInteger(
        map['waiting_seconds'],
      ),
    );
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

  String get statusLabel {
    if (headerStatus == 'pending_layer_3') {
      return 'Approval Layer 3';
    }

    if (headerStatus == 'pending_layer_4') {
      return 'Approval Layer 4';
    }

    if (headerStatus == 'revision_required') {
      return 'Perlu Revisi';
    }

    if (headerStatus == 'approved') {
      return 'Disetujui';
    }

    if (headerStatus == 'rejected') {
      return 'Ditolak';
    }

    if (headerStatus == 'cancelled') {
      return 'Dibatalkan';
    }

    return headerStatus;
  }

  String get waitingTimeLabel {
    if (waitingSeconds <= 0) {
      return '-';
    }

    final totalMinutes =
        waitingSeconds ~/ 60;

    if (totalMinutes < 60) {
      return '$totalMinutes menit';
    }

    final totalHours =
        totalMinutes ~/ 60;

    final remainingMinutes =
        totalMinutes % 60;

    if (totalHours < 24) {
      if (remainingMinutes == 0) {
        return '$totalHours jam';
      }

      return '$totalHours jam '
          '$remainingMinutes menit';
    }

    final totalDays =
        totalHours ~/ 24;

    final remainingHours =
        totalHours % 24;

    if (remainingHours == 0) {
      return '$totalDays hari';
    }

    return '$totalDays hari '
        '$remainingHours jam';
  }
}