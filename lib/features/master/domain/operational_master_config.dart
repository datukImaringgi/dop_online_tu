import 'package:flutter/material.dart';

class OperationalMasterFieldConfig {
  final String key;
  final String label;
  final bool isRequired;
  final OperationalMasterFieldType type;

  const OperationalMasterFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.isRequired = false,
  });
}

enum OperationalMasterFieldType {
  text,
  multiline,
  date,
  jobSite,
}

class OperationalMasterConfig {
  final String masterType;
  final String tableName;
  final String title;
  final String singularLabel;
  final IconData icon;
  final String primaryKey;
  final List<OperationalMasterFieldConfig>
  fields;

  const OperationalMasterConfig({
    required this.masterType,
    required this.tableName,
    required this.title,
    required this.singularLabel,
    required this.icon,
    required this.primaryKey,
    required this.fields,
  });

  String displayName(
      Map<String, dynamic> record,
      ) {
    final value =
    record[primaryKey]?.toString().trim();

    if (value == null || value.isEmpty) {
      return '-';
    }

    return value;
  }

  static const driver = OperationalMasterConfig(
    masterType: 'driver',
    tableName: 'drivers',
    title: 'Master Driver',
    singularLabel: 'Driver',
    icon: Icons.person_pin_outlined,
    primaryKey: 'driver_name',
    fields: [
      OperationalMasterFieldConfig(
        key: 'job_site_id',
        label: 'Job Site',
        type:
        OperationalMasterFieldType.jobSite,
      ),
      OperationalMasterFieldConfig(
        key: 'driver_name',
        label: 'Nama Driver',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'sid',
        label: 'SID',
        type:
        OperationalMasterFieldType.text,
      ),
      OperationalMasterFieldConfig(
        key: 'sid_expired_date',
        label: 'Masa Berlaku SID',
        type:
        OperationalMasterFieldType.date,
      ),
      OperationalMasterFieldConfig(
        key: 'simper_expired_date',
        label: 'Masa Berlaku SIMPER',
        type:
        OperationalMasterFieldType.date,
      ),
    ],
  );

  static const route =
  OperationalMasterConfig(
    masterType: 'route',
    tableName: 'routes',
    title: 'Master Rute',
    singularLabel: 'Rute',
    icon: Icons.route_outlined,
    primaryKey: 'route_name',
    fields: [
      OperationalMasterFieldConfig(
        key: 'job_site_id',
        label: 'Job Site',
        type:
        OperationalMasterFieldType.jobSite,
      ),
      OperationalMasterFieldConfig(
        key: 'origin',
        label: 'Asal',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'destination',
        label: 'Tujuan',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
    ],
  );

  static const jobSite =
  OperationalMasterConfig(
    masterType: 'job_site',
    tableName: 'job_sites',
    title: 'Master Job Site',
    singularLabel: 'Job Site',
    icon: Icons.location_on_outlined,
    primaryKey: 'site_name',
    fields: [
      OperationalMasterFieldConfig(
        key: 'site_name',
        label: 'Nama Job Site',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'site_code',
        label: 'Kode Job Site',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'location',
        label: 'Lokasi',
        type:
        OperationalMasterFieldType.text,
      ),
    ],
  );

  static const jsa =
  OperationalMasterConfig(
    masterType: 'jsa_procedure',
    tableName: 'jsa_procedures',
    title: 'Master JSA',
    singularLabel: 'JSA',
    icon: Icons.fact_check_outlined,
    primaryKey: 'procedure_name',
    fields: [
      OperationalMasterFieldConfig(
        key: 'procedure_code',
        label: 'Kode Prosedur',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'procedure_name',
        label: 'Nama Prosedur',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
      OperationalMasterFieldConfig(
        key: 'description',
        label: 'Deskripsi',
        type:
        OperationalMasterFieldType.multiline,
      ),
    ],
  );

  static const ric = OperationalMasterConfig(
    masterType: 'control_room',
    tableName: 'control_rooms',
    title: 'Master RIC',
    singularLabel: 'RIC',
    icon: Icons.support_agent_outlined,
    primaryKey: 'control_room_name',
    fields: [
      OperationalMasterFieldConfig(
        key: 'job_site_id',
        label: 'Job Site',
        type:
        OperationalMasterFieldType.jobSite,
      ),
      OperationalMasterFieldConfig(
        key: 'control_room_name',
        label: 'RIC Person Name',
        type:
        OperationalMasterFieldType.text,
        isRequired: true,
      ),
    ],
  );

  static const all =
  <OperationalMasterConfig>[
    jobSite,
    driver,
    route,
    jsa,
    ric,
  ];
}