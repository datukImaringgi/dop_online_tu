import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';

class CompanyUserRegistrationResult {
  final String resultType;
  final String? requestId;
  final String? userId;
  final String? authEmail;
  final String sid;
  final String companyId;
  final int hierarchyLayer;
  final String message;

  const CompanyUserRegistrationResult({
    required this.resultType,
    required this.requestId,
    required this.userId,
    required this.authEmail,
    required this.sid,
    required this.companyId,
    required this.hierarchyLayer,
    required this.message,
  });

  factory CompanyUserRegistrationResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return CompanyUserRegistrationResult(
      resultType:
      map['resultType'] as String? ??
          'applied',
      requestId:
      map['requestId'] as String?,
      userId:
      map['userId'] as String?,
      authEmail:
      map['authEmail'] as String?,
      sid:
      map['sid'] as String? ?? '-',
      companyId:
      map['companyId'] as String? ?? '',
      hierarchyLayer:
      map['hierarchyLayer'] as int? ?? 0,
      message:
      map['message'] as String? ??
          'Proses registrasi user selesai.',
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

class CompanyUserRegistrationRepository {
  final SupabaseClient supabase;

  const CompanyUserRegistrationRepository({
    required this.supabase,
  });

  Future<CompanyUserRegistrationResult>
  registerUser({
    required String fullName,
    required String sid,
    required String password,
    required String? notificationEmail,
    required String companyId,
    required int hierarchyLayer,
    required String position,
    required String department,
    required String? jobSiteId,
    required bool isActive,
  }) async {
    final cleanedFullName =
    fullName.trim();

    final cleanedSid =
    sid.trim().toUpperCase();

    final cleanedEmail =
    notificationEmail?.trim();

    final cleanedPosition =
    position.trim();

    final cleanedDepartment =
    department.trim();

    if (cleanedFullName.isEmpty) {
      throw Exception(
        'Nama lengkap wajib diisi.',
      );
    }

    if (cleanedSid.isEmpty) {
      throw Exception(
        'SID wajib diisi.',
      );
    }

    if (password.length < 6) {
      throw Exception(
        'Password minimal 6 karakter.',
      );
    }

    if (companyId.trim().isEmpty) {
      throw Exception(
        'Perusahaan wajib dipilih.',
      );
    }

    if (hierarchyLayer < 1 ||
        hierarchyLayer > 4) {
      throw Exception(
        'Hierarchy hanya dapat menggunakan '
            'Layer 1 sampai Layer 4.',
      );
    }

    if (cleanedPosition.isEmpty) {
      throw Exception(
        'Position wajib diisi.',
      );
    }

    if (cleanedDepartment.isEmpty) {
      throw Exception(
        'Department wajib diisi.',
      );
    }

    final response =
    await supabase.functions.invoke(
      'register-company-user',
      body: {
        'fullName': cleanedFullName,
        'sid': cleanedSid,
        'password': password,
        'notificationEmail':
        cleanedEmail == null ||
            cleanedEmail.isEmpty
            ? null
            : cleanedEmail,
        'companyId': companyId,
        'hierarchyLayer':
        hierarchyLayer,
        'position': cleanedPosition,
        'department':
        cleanedDepartment,
        'jobSiteId': jobSiteId,
        'isActive': isActive,
      },
    );

    final responseData =
    extractResponseData(
      response.data,
    );

    final success =
        responseData['success'] as bool? ??
            false;

    if (!success) {
      final message =
          responseData['message']
          as String? ??
              'Registrasi user gagal.';

      throw Exception(message);
    }

    return CompanyUserRegistrationResult
        .fromMap(responseData);
  }

  Map<String, dynamic> extractResponseData(
      dynamic data,
      ) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(
        data,
      );
    }

    throw Exception(
      'Format response registrasi '
          'tidak dikenali.',
    );
  }
}

CompanyUserRegistrationRepository
buildCompanyUserRegistrationRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return CompanyUserRegistrationRepository(
    supabase: supabase,
  );
}

final companyUserRegistrationRepositoryProvider =
Provider<
    CompanyUserRegistrationRepository>(
  buildCompanyUserRegistrationRepository,
);