import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../domain/company_layer_4_group_model.dart';

final companyLayer4GroupsProvider =
FutureProvider<
    List<CompanyLayer4GroupModel>>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final response = await supabase
        .from('company_layer_4_groups')
        .select(
      'id, '
          'company_1_id, '
          'company_2_id, '
          'is_active, '
          'created_by, '
          'created_at, '
          'updated_at, '
          'company_1:companies!company_layer_4_groups_company_1_id_fkey'
          '(company_name), '
          'company_2:companies!company_layer_4_groups_company_2_id_fkey'
          '(company_name), '
          'creator:profiles!company_layer_4_groups_created_by_fkey'
          '(full_name)',
    )
        .order(
      'created_at',
      ascending: false,
    );

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    return records
        .map(
      CompanyLayer4GroupModel.fromMap,
    )
        .toList();
  },
);

final layer4GroupCompanyOptionsProvider =
FutureProvider<
    List<Layer4GroupCompanyOption>>(
      (ref) async {
    final supabase = ref.watch(
      supabaseProvider,
    );

    final response = await supabase
        .from('companies')
        .select(
      'id, company_name',
    )
        .eq(
      'is_active',
      true,
    )
        .order(
      'company_name',
      ascending: true,
    );

    final records =
    List<Map<String, dynamic>>.from(
      response,
    );

    return records
        .map(
      Layer4GroupCompanyOption.fromMap,
    )
        .toList();
  },
);

final companyLayer4GroupRepositoryProvider =
Provider<CompanyLayer4GroupRepository>(
      (ref) {
    return CompanyLayer4GroupRepository(
      ref.watch(supabaseProvider),
    );
  },
);

class CompanyLayer4GroupRepository {
  final SupabaseClient supabase;

  const CompanyLayer4GroupRepository(
      this.supabase,
      );

  Future<void> createGroup({
    required String firstCompanyId,
    required String secondCompanyId,
  }) async {
    final firstId = firstCompanyId.trim();
    final secondId = secondCompanyId.trim();

    if (firstId.isEmpty || secondId.isEmpty) {
      throw Exception(
        'Dua perusahaan wajib dipilih.',
      );
    }

    if (firstId == secondId) {
      throw Exception(
        'Perusahaan 1 dan Perusahaan 2 '
            'tidak boleh sama.',
      );
    }

    final orderedIds = <String>[
      firstId,
      secondId,
    ]..sort();

    final currentUserId =
        supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      throw Exception(
        'User belum login.',
      );
    }

    await supabase
        .from('company_layer_4_groups')
        .insert({
      'company_1_id': orderedIds[0],
      'company_2_id': orderedIds[1],
      'is_active': true,
      'created_by': currentUserId,
    });
  }

  Future<void> updateStatus({
    required String groupId,
    required bool isActive,
  }) async {
    final cleanedGroupId = groupId.trim();

    if (cleanedGroupId.isEmpty) {
      throw Exception(
        'Gabungan Layer 4 tidak valid.',
      );
    }

    await supabase
        .from('company_layer_4_groups')
        .update({
      'is_active': isActive,
      'updated_at':
      DateTime.now().toUtc().toIso8601String(),
    }).eq(
      'id',
      cleanedGroupId,
    );
  }
}