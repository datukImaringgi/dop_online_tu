import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/master_change_request_provider.dart';
import '../../data/operational_master_repository.dart';
import '../../domain/operational_master_config.dart';
import 'operational_master_dialog.dart';

class OperationalMasterSection
    extends ConsumerWidget {
  final OperationalMasterConfig config;
  final int actorHierarchyLayer;
  final String? fixedCompanyId;
  final String? fixedCompanyName;

  bool get hasJobSiteField {
    for (final field in config.fields) {
      if (field.type ==
          OperationalMasterFieldType.jobSite) {
        return true;
      }
    }

    return false;
  }

  const OperationalMasterSection({
    super.key,
    required this.config,
    required this.actorHierarchyLayer,
    required this.fixedCompanyId,
    required this.fixedCompanyName,
  });

  void openDialog({
    required BuildContext context,
    required Map<String, dynamic>? record,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return OperationalMasterDialog(
          config: config,
          record: record,
          actorHierarchyLayer:
          actorHierarchyLayer,
          fixedCompanyId: fixedCompanyId,
          fixedCompanyName: fixedCompanyName,
        );
      },
    );
  }

  void handleAdd(BuildContext context) {
    openDialog(
      context: context,
      record: null,
    );
  }

  void handleEdit({
    required BuildContext context,
    required Map<String, dynamic> record,
  }) {
    openDialog(
      context: context,
      record: record,
    );
  }

  Future<void> handleStatusChanged({
    required BuildContext context,
    required WidgetRef ref,
    required Map<String, dynamic> record,
    required bool nextStatus,
  }) async {
    final recordId =
    record['id'] as String?;

    final companyId =
    record['company_id'] as String?;

    if (recordId == null ||
        companyId == null) {
      showMessage(
        context,
        'Data Master tidak valid.',
        true,
      );
      return;
    }

    try {
      final repository = ref.read(
        operationalMasterRepositoryProvider,
      );

      final result =
      await repository.submitChange(
        masterType: config.masterType,
        actionType: nextStatus
            ? 'activate'
            : 'deactivate',
        targetRecordId: recordId,
        companyId: companyId,
      );

      ref.invalidate(
        operationalMasterDataProvider(
          config.tableName,
        ),
      );

      ref.invalidate(
        masterChangeRequestsProvider,
      );

      ref.invalidate(
        pendingMasterChangeCountProvider,
      );

      if (!context.mounted) {
        return;
      }

      showMessage(
        context,
        result.message,
        false,
        isPending:
        result.isPendingApproval,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      showMessage(
        context,
        extractErrorMessage(error),
        true,
      );
    }
  }

  String extractErrorMessage(Object error) {
    final message = error.toString();

    const prefix =
        'PostgrestException(message: ';

    if (message.startsWith(prefix)) {
      final cleaned =
      message.replaceFirst(prefix, '');

      final commaIndex =
      cleaned.indexOf(',');

      if (commaIndex > 0) {
        return cleaned
            .substring(0, commaIndex)
            .trim();
      }
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  void showMessage(
      BuildContext context,
      String message,
      bool isError, {
        bool isPending = false,
      }) {
    Color backgroundColor =
    const Color(0xFF059669);

    if (isPending) {
      backgroundColor =
      const Color(0xFFD97706);
    }

    if (isError) {
      backgroundColor =
      const Color(0xFFDC2626);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  void handleRefresh(WidgetRef ref) {
    ref.invalidate(
      operationalMasterDataProvider(
        config.tableName,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final recordsAsync = ref.watch(
      operationalMasterDataProvider(
        config.tableName,
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          buildHeader(
            context,
            ref,
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          Expanded(
            child: recordsAsync.when(
              loading: buildLoading,
              error: buildError,
              data: (
                  List<Map<String, dynamic>>
                  records,
                  ) {
                return buildContent(
                  context: context,
                  ref: ref,
                  records: records,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
              const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: Icon(
              config.icon,
              color:
              const Color(0xFF2563EB),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              config.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              handleRefresh(ref);
            },
            icon: const Icon(
              Icons.refresh,
              size: 16,
            ),
            label: const Text('Refresh'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              handleAdd(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
              const Color(0xFF2563EB),
            ),
            icon: const Icon(
              Icons.add,
              size: 16,
            ),
            label: Text(
              'Tambah ${config.singularLabel}',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError(
      Object error,
      StackTrace stackTrace,
      ) {
    return Center(
      child: Text(
        'Gagal membaca ${config.title}: '
            '${extractErrorMessage(error)}',
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required List<Map<String, dynamic>>
    records,
  }) {
    if (records.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data '
              '${config.singularLabel}.',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      );
    }

    return LayoutBuilder(
        builder: (
            BuildContext context,
            BoxConstraints constraints,
            ) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 38,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 48,
                  horizontalMargin: 12,
                  columnSpacing: 24,
                  headingRowColor:
                  WidgetStateProperty.all(
                    const Color(0xFFF8FAFC),
                  ),
                  columns: buildColumns(),
                  rows: buildRows(
                    context: context,
                    ref: ref,
                    records: records,
                  ),
                ),
              ),
            ),
          );
        },
    );
  }

  List<DataColumn> buildColumns() {
    final columns = <DataColumn>[
      DataColumn(
        label: Text(
          config.masterType == 'route'
              ? 'Route'
              : config.masterType == 'jsa_procedure'
              ? 'Deskripsi Prosedur'
              : config.masterType == 'driver'
              ? 'Nama Driver'
              : config.masterType == 'control_room'
              ? 'RIC Person'
              : config.masterType == 'job_site'
              ? 'Job Site'
              : 'Nama Data',
        ),
      ),
    ];

    if (config.masterType == 'job_site') {
      columns.add(
        const DataColumn(
          label: Text('Kode'),
        ),
      );
    }

    if (config.masterType == 'route') {
      columns.add(
        const DataColumn(
          label: Text('Area Tujuan'),
        ),
      );
    }

    columns.add(
      const DataColumn(
        label: Text('Perusahaan'),
      ),
    );

    if (hasJobSiteField) {
      columns.add(
        const DataColumn(
          label: Text('Job Site'),
        ),
      );
    }

    if (config.masterType == 'jsa_procedure') {
      columns.insert(
        0,
        const DataColumn(
          label: Text('Kode Prosedur'),
        ),
      );
    }

    if (config.masterType == 'driver') {
      columns.add(
        const DataColumn(
          label: Text('Masa Berlaku SID'),
        ),
      );

      columns.add(
        const DataColumn(
          label: Text('Masa Berlaku SIMPER'),
        ),
      );
    }

    columns.add(
      const DataColumn(
        label: Text('Status'),
      ),
    );

    columns.add(
      const DataColumn(
        label: Text('Action'),
      ),
    );

    return columns;
  }

  List<DataRow> buildRows({
    required BuildContext context,
    required WidgetRef ref,
    required List<Map<String, dynamic>>
    records,
  }) {
    final rows = <DataRow>[];

    for (final record in records) {
      final isActive =
          record['is_active'] as bool? ??
              false;

      rows.add(
        DataRow(
          cells: [
            if (config.masterType == 'jsa_procedure')
              DataCell(
                Text(
                  record['procedure_code']
                      ?.toString()
                      .trim() ??
                      '-',
                ),
              ),
            DataCell(
              Text(
                config.displayName(record),
              ),
            ),
            if (config.masterType == 'job_site')
              DataCell(
                Text(
                  record['site_code']
                      ?.toString()
                      .trim() ??
                      '-',
                ),
              ),
            if (config.masterType == 'route')
              DataCell(
                Text(
                  formatAreaType(
                    record['area_type'],
                  ),
                ),
              ),
            DataCell(
              Text(
                readRelationValue(
                  record,
                  'companies',
                  'company_name',
                ),
              ),
            ),
            if (hasJobSiteField)
              DataCell(
                Text(
                  readRelationValue(
                    record,
                    'job_sites',
                    'site_name',
                  ),
                ),
              ),

            if (config.masterType == 'driver')
              DataCell(
                Text(
                  formatDateValue(
                    record['sid_expired_date'],
                  ),
                ),
              ),

            if (config.masterType == 'driver')
              DataCell(
                Text(
                  formatDateValue(
                    record['simper_expired_date'],
                  ),
                ),
              ),

            DataCell(
              Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Switch(
                    value: isActive,
                    onChanged: (bool value) {
                      handleStatusChanged(
                        context: context,
                        ref: ref,
                        record: record,
                        nextStatus: value,
                      );
                    },
                  ),
                  Text(
                    isActive
                        ? 'Aktif'
                        : 'Nonaktif',
                  ),
                ],
              ),
            ),
            DataCell(
              IconButton(
                onPressed: () {
                  handleEdit(
                    context: context,
                    record: record,
                  );
                },
                tooltip:
                'Edit ${config.singularLabel}',
                icon: const Icon(
                  Icons.edit_outlined,
                  color:
                  Color(0xFF2563EB),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  String formatAreaType(dynamic value) {
    final areaType =
        value?.toString().trim() ?? '';

    if (areaType == 'site') {
      return 'Area Site';
    }

    if (areaType == 'jalan_negara') {
      return 'Area Jalan Negara';
    }

    return '-';
  }

  String formatDateValue(dynamic value) {
    if (value == null) {
      return '-';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '-';
    }

    final parsedDate =
    DateTime.tryParse(text);

    if (parsedDate == null) {
      return text;
    }

    final day = parsedDate.day
        .toString()
        .padLeft(2, '0');

    final month = parsedDate.month
        .toString()
        .padLeft(2, '0');

    final year = parsedDate.year
        .toString()
        .padLeft(4, '0');

    return '$day-$month-$year';
  }

  String readRelationValue(
      Map<String, dynamic> record,
      String relationKey,
      String valueKey,
      ) {
    final relation =
    record[relationKey];

    if (relation is Map) {
      return relation[valueKey]
          ?.toString() ??
          '-';
    }

    return '-';
  }
}