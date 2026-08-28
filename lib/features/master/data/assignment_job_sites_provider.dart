import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supabase_provider.dart';

class AssignmentJobSiteOption {
  final String id;
  final String companyId;
  final String siteName;
  final String siteCode;

  const AssignmentJobSiteOption({
    required this.id,
    required this.companyId,
    required this.siteName,
    required this.siteCode,
  });

  factory AssignmentJobSiteOption.fromMap(
      Map<String, dynamic> map,
      ) {
    return AssignmentJobSiteOption(
      id: map['id'] as String,
      companyId: map['company_id'] as String,
      siteName: map['site_name'] as String? ?? '-',
      siteCode: map['site_code'] as String? ?? '-',
    );
  }

  String get displayName {
    if (siteCode == '-') {
      return siteName;
    }

    return '$siteName ($siteCode)';
  }
}

Future<List<AssignmentJobSiteOption>>
loadAssignmentJobSites(
    Ref ref,
    String companyId,
    ) async {
  if (companyId.trim().isEmpty) {
    return <AssignmentJobSiteOption>[];
  }

  final supabase = ref.watch(
    supabaseProvider,
  );

  final response = await supabase
      .from('job_sites')
      .select(
    'id, company_id, site_name, site_code',
  )
      .eq(
    'company_id',
    companyId,
  )
      .eq(
    'is_active',
    true,
  )
      .order(
    'site_name',
    ascending: true,
  );

  final rawItems = response as List<dynamic>;
  final options = <AssignmentJobSiteOption>[];

  for (final rawItem in rawItems) {
    options.add(
      AssignmentJobSiteOption.fromMap(
        rawItem as Map<String, dynamic>,
      ),
    );
  }

  return options;
}

final assignmentJobSitesProvider = FutureProvider.family<
    List<AssignmentJobSiteOption>,
    String>(
  loadAssignmentJobSites,
);