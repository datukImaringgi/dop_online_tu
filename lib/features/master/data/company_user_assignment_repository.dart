import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';

class CompanyUserAssignmentRepository {
  final SupabaseClient supabase;

  const CompanyUserAssignmentRepository({required this.supabase});

  Future<void> updateAssignment({
    required String companyUserId,
    required int hierarchyLayer,
    required String position,
    required String department,
    required String? jobSiteId,
    required bool isActive,
  }) async {
    final cleanedPosition = position.trim();
    final cleanedDepartment = department.trim();

    if (companyUserId.trim().isEmpty) {
      throw Exception('Assignment user tidak valid.');
    }

    if (hierarchyLayer < 1 || hierarchyLayer > 4) {
      throw Exception(
        'Hierarchy hanya dapat menggunakan Layer 1 sampai Layer 4.',
      );
    }

    if (cleanedPosition.isEmpty) {
      throw Exception('Position wajib diisi.');
    }

    if (cleanedDepartment.isEmpty) {
      throw Exception('Department wajib diisi.');
    }

    await supabase.rpc(
      'update_user_assignment',
      params: {
        'p_company_user_id': companyUserId,
        'p_hierarchy_layer': hierarchyLayer,
        'p_position': cleanedPosition,
        'p_department': cleanedDepartment,
        'p_job_site_id': jobSiteId,
        'p_is_active': isActive,
      },
    );
  }
}

CompanyUserAssignmentRepository buildCompanyUserAssignmentRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);

  return CompanyUserAssignmentRepository(supabase: supabase);
}

final companyUserAssignmentRepositoryProvider =
    Provider<CompanyUserAssignmentRepository>(
      buildCompanyUserAssignmentRepository,
    );
