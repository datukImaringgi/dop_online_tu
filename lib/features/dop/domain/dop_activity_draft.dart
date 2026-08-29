class DopActivityDraft {
  final String localId;

  final String workPlan;
  final String areaType;
  final String shift;

  final String unitId;
  final String unitType;
  final String unitNumber;
  final String transportCompany;

  final String driverId;
  final String driverName;
  final String? sid;
  final String? sidExpiredDate;
  final String? simperExpiredDate;

  final String startTime;
  final String endTime;

  final String? routeId;
  final String routeName;

  final String observer;

  final String jsaId;
  final String jsaProcedure;

  final String controlRoomId;
  final String controlRoomName;

  final String? layer1UserId;
  final String? layer2UserId;
  final String? layer3UserId;
  final String? layer4UserId;

  final String? layer1;
  final String? layer2;
  final String? layer3;
  final String? layer4;

  final String notes;

  const DopActivityDraft({
    required this.localId,
    required this.workPlan,
    required this.areaType,
    required this.shift,
    required this.unitId,
    required this.unitType,
    required this.unitNumber,
    required this.transportCompany,
    required this.driverId,
    required this.driverName,
    required this.sid,
    required this.sidExpiredDate,
    required this.simperExpiredDate,
    required this.startTime,
    required this.endTime,
    required this.routeId,
    required this.routeName,
    required this.observer,
    required this.jsaId,
    required this.jsaProcedure,
    required this.controlRoomId,
    required this.controlRoomName,
    required this.layer1UserId,
    required this.layer2UserId,
    required this.layer3UserId,
    required this.layer4UserId,
    required this.layer1,
    required this.layer2,
    required this.layer3,
    required this.layer4,
    required this.notes,
  });

  String get areaDisplayName {
    if (areaType == 'jalan_negara') {
      return 'Area Jalan Negara';
    }

    if (areaType == 'site') {
      return 'Area Site';
    }

    return areaType;
  }

  String get duplicateKey {
    final normalizedRoute = routeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    return [
      unitId,
      startTime,
      endTime,
      normalizedRoute,
    ].join('|');
  }

  Map<String, dynamic> toDetailPayload({
    required String companyId,
    required String dopHeaderId,
  }) {
    return {
      'company_id': companyId,
      'dop_header_id': dopHeaderId,
      'work_plan': workPlan,
      'unit_type': unitType,
      'unit_number': unitNumber,
      'start_time': startTime,
      'end_time': endTime,
      'driver_name': driverName,
      'sid': sid,
      'sid_expired_date': sidExpiredDate,
      'simper_expired_date': simperExpiredDate,
      'route': routeName,
      'observer': observer,
      'is_critical': true,
      'risk_level': 'High',
      'jsa_procedure': jsaProcedure,
      'shift': shift,
      'layer_1': layer1,
      'layer_2': layer2,
      'layer_3': layer3,
      'layer_4': layer4,
      'control_room': controlRoomName,
      'area_type': areaType,
      'transport_company': transportCompany,
      'notes': notes,
      'is_active': true,
    };
  }

  Map<String, dynamic> toSubmissionPayload() {
    return {
      'work_plan': workPlan,
      'unit_id': unitId,
      'unit_type': unitType,
      'unit_number': unitNumber,
      'start_time': startTime,
      'end_time': endTime,
      'driver_id': driverId,
      'driver_name': driverName,
      'sid': sid,
      'sid_expired_date': sidExpiredDate,
      'simper_expired_date': simperExpiredDate,
      'route_id': routeId,
      'route': routeName,
      'observer': observer,
      'is_critical': true,
      'risk_level': 'High',
      'jsa_id': jsaId,
      'jsa_procedure': jsaProcedure,
      'shift': shift,
      'layer_1_user_id': layer1UserId,
      'layer_2_user_id': layer2UserId,
      'layer_3_user_id': layer3UserId,
      'layer_4_user_id': layer4UserId,
      'layer_1': layer1,
      'layer_2': layer2,
      'layer_3': layer3,
      'layer_4': layer4,
      'control_room_id': controlRoomId,
      'control_room': controlRoomName,
      'area_type': areaType,
      'transport_company': transportCompany,
      'notes': notes,
      'is_active': true,
    };
  }
}