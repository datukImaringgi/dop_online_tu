import 'dop_activity_draft.dart';

class DopRevisionData {
  final String dopHeaderId;
  final String dopNumber;
  final String companyId;
  final String jobSiteId;
  final DateTime dopDate;
  final String dayName;
  final int revisionNumber;
  final String revisionNote;
  final List<DopActivityDraft> activities;

  const DopRevisionData({
    required this.dopHeaderId,
    required this.dopNumber,
    required this.companyId,
    required this.jobSiteId,
    required this.dopDate,
    required this.dayName,
    required this.revisionNumber,
    required this.revisionNote,
    required this.activities,
  });
}

class DopRevisionDetailRecord {
  final String detailId;
  final String workPlan;
  final String areaType;
  final String shift;

  final String? unitId;
  final String unitType;
  final String unitNumber;
  final String transportCompany;

  final String? driverId;
  final String driverName;
  final String? sid;
  final String? sidExpiredDate;
  final String? simperExpiredDate;

  final String startTime;
  final String endTime;

  final String? routeId;
  final String routeName;
  final String observer;

  final String? jsaId;
  final String jsaProcedure;

  final String? controlRoomId;
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

  const DopRevisionDetailRecord({
    required this.detailId,
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

  factory DopRevisionDetailRecord.fromMap(
      Map<String, dynamic> map,
      ) {
    return DopRevisionDetailRecord(
      detailId: map['id'] as String,
      workPlan:
      map['work_plan'] as String? ?? '',
      areaType:
      map['area_type'] as String? ?? 'site',
      shift:
      map['shift'] as String? ?? 'Day Shift',
      unitId:
      map['unit_id'] as String?,
      unitType:
      map['unit_type'] as String? ?? '-',
      unitNumber:
      map['unit_number'] as String? ?? '-',
      transportCompany:
      map['transport_company'] as String? ?? '-',
      driverId:
      map['driver_id'] as String?,
      driverName:
      map['driver_name'] as String? ?? '-',
      sid:
      map['sid'] as String?,
      sidExpiredDate:
      readDateText(
        map['sid_expired_date'],
      ),
      simperExpiredDate:
      readDateText(
        map['simper_expired_date'],
      ),
      startTime:
      readTimeText(map['start_time']),
      endTime:
      readTimeText(map['end_time']),
      routeId:
      map['route_id'] as String?,
      routeName:
      map['route'] as String? ?? '',
      observer:
      map['observer'] as String? ?? '',
      jsaId:
      map['jsa_id'] as String?,
      jsaProcedure:
      map['jsa_procedure'] as String? ?? '',
      controlRoomId:
      map['control_room_id'] as String?,
      controlRoomName:
      map['control_room'] as String? ?? '',
      layer1UserId:
      map['layer_1_user_id'] as String?,
      layer2UserId:
      map['layer_2_user_id'] as String?,
      layer3UserId:
      map['layer_3_user_id'] as String?,
      layer4UserId:
      map['layer_4_user_id'] as String?,
      layer1:
      map['layer_1'] as String?,
      layer2:
      map['layer_2'] as String?,
      layer3:
      map['layer_3'] as String?,
      layer4:
      map['layer_4'] as String?,
      notes:
      map['notes'] as String? ?? '',
    );
  }

  DopActivityDraft toDraft() {
    return DopActivityDraft(
      localId: detailId,
      workPlan: workPlan,
      areaType: areaType,
      shift: shift,
      unitId: unitId ?? '',
      unitType: unitType,
      unitNumber: unitNumber,
      transportCompany: transportCompany,
      driverId: driverId ?? '',
      driverName: driverName,
      sid: sid,
      sidExpiredDate: sidExpiredDate,
      simperExpiredDate: simperExpiredDate,
      startTime: startTime,
      endTime: endTime,
      routeId: routeId,
      routeName: routeName,
      observer: observer,
      jsaId: jsaId ?? '',
      jsaProcedure: jsaProcedure,
      controlRoomId: controlRoomId ?? '',
      controlRoomName: controlRoomName,
      layer1UserId: layer1UserId,
      layer2UserId: layer2UserId,
      layer3UserId: layer3UserId,
      layer4UserId: layer4UserId,
      layer1: layer1,
      layer2: layer2,
      layer3: layer3,
      layer4: layer4,
      notes: notes,
    );
  }

  static String? readDateText(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static String readTimeText(dynamic value) {
    if (value == null) {
      return '00:00';
    }

    final text = value.toString();

    if (text.length >= 5) {
      return text.substring(0, 5);
    }

    return text;
  }
}