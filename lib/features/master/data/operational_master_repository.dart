import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';

class OperationalMasterResult {
  final String resultType;
  final String masterType;
  final String actionType;
  final String? requestId;
  final String? targetRecordId;
  final String message;

  const OperationalMasterResult({
    required this.resultType,
    required this.masterType,
    required this.actionType,
    required this.requestId,
    required this.targetRecordId,
    required this.message,
  });

  factory OperationalMasterResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return OperationalMasterResult(
      resultType:
      map['result_type'] as String? ??
          'unknown',
      masterType:
      map['master_type'] as String? ??
          '',
      actionType:
      map['action_type'] as String? ??
          '',
      requestId:
      map['request_id'] as String?,
      targetRecordId:
      map['target_record_id']
      as String?,
      message:
      map['message'] as String? ??
          'Perubahan Master Data berhasil diproses.',
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

class OperationalMasterRepository {
  final SupabaseClient supabase;

  const OperationalMasterRepository({
    required this.supabase,
  });

  Future<List<Map<String, dynamic>>>
  loadMasterData({
    required String tableName,
  }) async {
    validateTableName(tableName);

    final masterResponse = await supabase
        .from(tableName)
        .select()
        .order(
      'created_at',
      ascending: false,
    );

    final companyResponse = await supabase
        .from('companies')
        .select(
      'id, company_name',
    );

    final jobSiteResponse = await supabase
        .from('job_sites')
        .select(
      'id, site_name',
    );

    final companyNames = <String, String>{};

    for (final rawCompany
    in companyResponse) {
      final company =
      Map<String, dynamic>.from(
        rawCompany,
      );

      final companyId =
      company['id'] as String?;

      final companyName =
      company['company_name']
      as String?;

      if (companyId == null) {
        continue;
      }

      companyNames[companyId] =
          companyName ?? '-';
    }

    final jobSiteNames = <String, String>{};

    for (final rawJobSite
    in jobSiteResponse) {
      final jobSite =
      Map<String, dynamic>.from(
        rawJobSite,
      );

      final jobSiteId =
      jobSite['id'] as String?;

      final siteName =
      jobSite['site_name']
      as String?;

      if (jobSiteId == null) {
        continue;
      }

      jobSiteNames[jobSiteId] =
          siteName ?? '-';
    }

    final records =
    <Map<String, dynamic>>[];

    for (final rawRecord
    in masterResponse) {
      final record =
      Map<String, dynamic>.from(
        rawRecord,
      );

      final companyId =
      record['company_id']
      as String?;

      final jobSiteId =
      record['job_site_id']
      as String?;

      record['companies'] =
      <String, dynamic>{
        'company_name':
        companyNames[companyId] ?? '-',
      };

      record['job_sites'] =
      <String, dynamic>{
        'site_name':
        jobSiteNames[jobSiteId] ?? '-',
      };

      records.add(record);
    }

    return records;
  }

  Future<List<String>> loadDriverVendors({
    required String? companyId,
  }) async {
    var query = supabase
        .from('drivers')
        .select('vendor_company')
        .not(
      'vendor_company',
      'is',
      null,
    );

    if (companyId != null &&
        companyId.trim().isNotEmpty) {
      query = query.eq(
        'company_id',
        companyId.trim(),
      );
    }

    final response = await query.order(
      'vendor_company',
      ascending: true,
    );

    final vendorNames = <String>{};

    for (final rawRecord in response) {
      final record =
      Map<String, dynamic>.from(
        rawRecord,
      );

      final rawVendor =
      record['vendor_company'];

      if (rawVendor is! String) {
        continue;
      }

      final vendorName =
      rawVendor.trim();

      if (vendorName.isEmpty) {
        continue;
      }

      vendorNames.add(vendorName);
    }

    final result = vendorNames.toList();

    result.sort(
      compareVendorNames,
    );

    return result;
  }

  int compareVendorNames(
      String first,
      String second,
      ) {
    return first
        .toLowerCase()
        .compareTo(
      second.toLowerCase(),
    );
  }

  Future<List<String>> loadBusStopNames({
    required String? companyId,
    required String? jobSiteId,
  }) async {
    final normalizedCompanyId =
    normalizeOptional(companyId);

    if (normalizedCompanyId == null) {
      return <String>[];
    }

    var query = supabase
        .from('bus_stops')
        .select(
      'stop_name, job_site_id',
    )
        .eq(
      'company_id',
      normalizedCompanyId,
    )
        .eq(
      'is_active',
      true,
    );

    final response = await query.order(
      'stop_name',
      ascending: true,
    );

    final normalizedJobSiteId =
    normalizeOptional(jobSiteId);

    final stopNames = <String>{};

    for (final rawRecord in response) {
      final record =
      Map<String, dynamic>.from(
        rawRecord,
      );

      final recordJobSiteId =
      record['job_site_id'] as String?;

      final belongsToSelectedSite =
          normalizedJobSiteId == null ||
              recordJobSiteId == null ||
              recordJobSiteId ==
                  normalizedJobSiteId;

      if (!belongsToSelectedSite) {
        continue;
      }

      final rawStopName =
      record['stop_name'];

      if (rawStopName is! String) {
        continue;
      }

      final stopName =
      rawStopName.trim();

      if (stopName.isEmpty) {
        continue;
      }

      stopNames.add(stopName);
    }

    final result = stopNames.toList();

    result.sort(
          (String first, String second) {
        return first
            .toLowerCase()
            .compareTo(
          second.toLowerCase(),
        );
      },
    );

    return result;
  }

  Future<OperationalMasterResult> submitChange({
    required String masterType,
    required String actionType,
    required String companyId,
    String? targetRecordId,
    Map<String, dynamic>? requestedData,
  }) async {
    validateMasterType(masterType);
    validateActionType(actionType);

    if (companyId.trim().isEmpty) {
      throw Exception(
        'Perusahaan wajib tersedia.',
      );
    }

    final response = await supabase.rpc(
      'submit_master_data_change',
      params: {
        'p_master_type': masterType,
        'p_action_type': actionType,
        'p_target_record_id':
        normalizeOptional(
          targetRecordId,
        ),
        'p_company_id': companyId,
        'p_requested_data':
        requestedData,
      },
    );

    return OperationalMasterResult.fromMap(
      normalizeResponse(response),
    );
  }

  void validateMasterType(
      String masterType,
      ) {
    const allowedTypes = <String>{
      'unit',
      'driver',
      'bus_stop',
      'route',
      'job_site',
      'jsa_procedure',
      'control_room',
    };

    if (!allowedTypes.contains(masterType)) {
      throw Exception(
        'Jenis Master Data tidak valid.',
      );
    }
  }

  void validateActionType(
      String actionType,
      ) {
    const allowedActions = <String>{
      'create',
      'update',
      'activate',
      'deactivate',
    };

    if (!allowedActions.contains(actionType)) {
      throw Exception(
        'Jenis perubahan tidak valid.',
      );
    }
  }

  void validateTableName(
      String tableName,
      ) {
    const allowedTables = <String>{
      'units',
      'drivers',
      'bus_stops',
      'routes',
      'job_sites',
      'jsa_procedures',
      'control_rooms',
    };

    if (!allowedTables.contains(tableName)) {
      throw Exception(
        'Tabel Master Data tidak valid.',
      );
    }
  }

  String? normalizeOptional(
      String? value,
      ) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  Map<String, dynamic> normalizeResponse(
      dynamic response,
      ) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(
        response,
      );
    }

    throw Exception(
      'Respons perubahan Master Data '
          'tidak valid.',
    );
  }
}

OperationalMasterRepository
buildOperationalMasterRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return OperationalMasterRepository(
    supabase: supabase,
  );
}

final operationalMasterRepositoryProvider =
Provider<OperationalMasterRepository>(
  buildOperationalMasterRepository,
);

final operationalMasterDataProvider =
FutureProvider.family<
    List<Map<String, dynamic>>,
    String>(
  loadOperationalMasterData,
);

class DriverVendorQuery {
  final String? companyId;

  const DriverVendorQuery({
    required this.companyId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DriverVendorQuery &&
        other.companyId == companyId;
  }

  @override
  int get hashCode {
    return companyId.hashCode;
  }
}

class BusStopQuery {
  final String? companyId;
  final String? jobSiteId;

  const BusStopQuery({
    required this.companyId,
    required this.jobSiteId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BusStopQuery &&
        other.companyId == companyId &&
        other.jobSiteId == jobSiteId;
  }

  @override
  int get hashCode {
    return Object.hash(
      companyId,
      jobSiteId,
    );
  }
}

final busStopOptionsProvider =
FutureProvider.family<
    List<String>,
    BusStopQuery>(
  loadBusStopOptions,
);

Future<List<String>> loadBusStopOptions(
    Ref ref,
    BusStopQuery query,
    ) async {
  final repository = ref.watch(
    operationalMasterRepositoryProvider,
  );

  return repository.loadBusStopNames(
    companyId: query.companyId,
    jobSiteId: query.jobSiteId,
  );
}

final driverVendorOptionsProvider =
FutureProvider.family<
    List<String>,
    DriverVendorQuery>(
  loadDriverVendorOptions,
);

Future<List<String>>
loadDriverVendorOptions(
    Ref ref,
    DriverVendorQuery query,
    ) async {
  final repository = ref.watch(
    operationalMasterRepositoryProvider,
  );

  return repository.loadDriverVendors(
    companyId: query.companyId,
  );
}

Future<List<Map<String, dynamic>>>
loadOperationalMasterData(
    Ref ref,
    String tableName,
    ) async {
  final repository = ref.watch(
    operationalMasterRepositoryProvider,
  );

  final hierarchyLayer = await ref.watch(
    currentHierarchyLayerProvider.future,
  );

  final companyAccess = await ref.watch(
    currentCompanyAccessProvider.future,
  );

  final records =
  await repository.loadMasterData(
    tableName: tableName,
  );

  if (hierarchyLayer == 5) {
    return records;
  }

  if (companyAccess == null) {
    return <Map<String, dynamic>>[];
  }

  final filteredRecords =
  <Map<String, dynamic>>[];

  for (final record in records) {
    if (record['company_id'] ==
        companyAccess.companyId) {
      filteredRecords.add(record);
    }
  }

  return filteredRecords;
}