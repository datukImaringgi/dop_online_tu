import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../domain/client_company_result.dart';

final clientCompanyRepositoryProvider =
Provider<ClientCompanyRepository>(
  createClientCompanyRepository,
);

ClientCompanyRepository
createClientCompanyRepository(
    Ref ref,
    ) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return ClientCompanyRepository(
    supabase: supabase,
  );
}

class ClientCompanyRepository {
  final SupabaseClient supabase;

  const ClientCompanyRepository({
    required this.supabase,
  });

  Future<ClientCompanyResult> registerCompany({
    required String companyName,
    required String companyCode,
    String? address,
    String? phone,
    String? email,
  }) async {
    final response = await supabase.rpc(
      'register_client_company',
      params: {
        'p_company_name':
        companyName.trim(),
        'p_company_code':
        companyCode.trim(),
        'p_address': normalizeOptional(
          address,
        ),
        'p_phone': normalizeOptional(
          phone,
        ),
        'p_email': normalizeOptional(
          email,
        ),
      },
    );

    return parseCompanyResult(
      response,
    );
  }

  String? normalizeOptional(String? value,) {
    if (value == null) {
      return null;
    }

    final normalizedValue =
    value.trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  ClientCompanyResult parseCompanyResult(dynamic response,) {
    if (response
    is Map<String, dynamic>) {
      return ClientCompanyResult.fromMap(
        response,
      );
    }

    if (response is Map) {
      final normalizedResponse =
      <String, dynamic>{};

      for (final entry
      in response.entries) {
        normalizedResponse[
        entry.key.toString()
        ] = entry.value;
      }

      return ClientCompanyResult.fromMap(
        normalizedResponse,
      );
    }

    throw Exception(
      'Respons registrasi perusahaan '
          'tidak valid.',
    );
  }
}