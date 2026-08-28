import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';

class ActiveCompanyOption {
  final String id;
  final String companyName;
  final String companyCode;

  const ActiveCompanyOption({
    required this.id,
    required this.companyName,
    required this.companyCode,
  });

  factory ActiveCompanyOption.fromMap(
      Map<String, dynamic> map,
      ) {
    return ActiveCompanyOption(
      id: map['id'] as String,
      companyName:
      map['company_name'] as String? ?? '-',
      companyCode:
      map['company_code'] as String? ?? '-',
    );
  }

  String get displayName {
    if (companyCode == '-') {
      return companyName;
    }

    return '$companyName ($companyCode)';
  }
}

Future<List<ActiveCompanyOption>>
loadActiveCompanies(
    Ref ref,
    ) async {
  final supabase = ref.watch(
    supabaseProvider,
  );

  final response = await supabase
      .from('companies')
      .select(
    'id, company_name, company_code',
  )
      .eq(
    'is_active',
    true,
  )
      .order(
    'company_name',
    ascending: true,
  );

  final rawItems = response as List<dynamic>;
  final companies = <ActiveCompanyOption>[];

  for (final rawItem in rawItems) {
    companies.add(
      ActiveCompanyOption.fromMap(
        rawItem as Map<String, dynamic>,
      ),
    );
  }

  return companies;
}

final activeCompaniesProvider =
FutureProvider<List<ActiveCompanyOption>>(
  loadActiveCompanies,
);