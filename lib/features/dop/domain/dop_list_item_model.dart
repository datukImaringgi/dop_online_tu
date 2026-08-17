class DopListItemModel {
  final String detailId;
  final String dopHeaderId;
  final String companyId;
  final String companyName;
  final String companyCode;

  final String dayName;
  final String dopDate;
  final String jobSite;

  final String workPlan;
  final String unitType;
  final String unitNumber;
  final String startTime;
  final String endTime;

  final String driverName;
  final String sid;
  final String sidExpiredDate;
  final String simperExpiredDate;

  final String route;
  final String observer;
  final bool isCritical;
  final String riskLevel;
  final String jsaProcedure;
  final String shift;

  final String layer1;
  final String layer2;
  final String layer3;
  final String layer4;

  final String controlRoom;
  final String areaType;
  final String transportCompany;

  final String status;
  final String createdByName;
  final String approvedByName;
  final String knownByName;

  DopListItemModel({
    required this.detailId,
    required this.dopHeaderId,
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.dayName,
    required this.dopDate,
    required this.jobSite,
    required this.workPlan,
    required this.unitType,
    required this.unitNumber,
    required this.startTime,
    required this.endTime,
    required this.driverName,
    required this.sid,
    required this.sidExpiredDate,
    required this.simperExpiredDate,
    required this.route,
    required this.observer,
    required this.isCritical,
    required this.riskLevel,
    required this.jsaProcedure,
    required this.shift,
    required this.layer1,
    required this.layer2,
    required this.layer3,
    required this.layer4,
    required this.controlRoom,
    required this.areaType,
    required this.transportCompany,
    required this.status,
    required this.createdByName,
    required this.approvedByName,
    required this.knownByName,
  });

  factory DopListItemModel.fromMap(Map<String, dynamic> map) {
    return DopListItemModel(
      detailId: map['detail_id'] as String,
      dopHeaderId: map['dop_header_id'] as String,
      companyId: map['company_id'] as String,
      companyName: map['company_name'] as String? ?? '-',
      companyCode: map['company_code'] as String? ?? '-',
      dayName: map['day_name'] as String? ?? '-',
      dopDate: map['dop_date'] as String? ?? '-',
      jobSite: map['job_site'] as String? ?? '-',
      workPlan: map['work_plan'] as String? ?? '-',
      unitType: map['unit_type'] as String? ?? '-',
      unitNumber: map['unit_number'] as String? ?? '-',
      startTime: map['start_time'] as String? ?? '-',
      endTime: map['end_time'] as String? ?? '-',
      driverName: map['driver_name'] as String? ?? '-',
      sid: map['sid'] as String? ?? '-',
      sidExpiredDate: map['sid_expired_date'] as String? ?? '-',
      simperExpiredDate: map['simper_expired_date'] as String? ?? '-',
      route: map['route'] as String? ?? '-',
      observer: map['observer'] as String? ?? '-',
      isCritical: map['is_critical'] as bool? ?? true,
      riskLevel: map['risk_level'] as String? ?? 'High',
      jsaProcedure: map['jsa_procedure'] as String? ?? '-',
      shift: map['shift'] as String? ?? '-',
      layer1: map['layer_1'] as String? ?? '-',
      layer2: map['layer_2'] as String? ?? '-',
      layer3: map['layer_3'] as String? ?? '-',
      layer4: map['layer_4'] as String? ?? '-',
      controlRoom: map['control_room'] as String? ?? '-',
      areaType: map['area_type'] as String? ?? '-',
      transportCompany: map['transport_company'] as String? ?? '-',
      status: map['status'] as String? ?? '-',
      createdByName: map['created_by_name'] as String? ?? '-',
      approvedByName: map['approved_by_name'] as String? ?? '-',
      knownByName: map['known_by_name'] as String? ?? '-',
    );
  }
}