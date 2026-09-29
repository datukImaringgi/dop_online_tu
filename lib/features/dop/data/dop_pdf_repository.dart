import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../domain/dop_list_item_model.dart';
import '../../../shared/providers/supabase_provider.dart';

final dopPdfRepositoryProvider =
Provider<DopPdfRepository>((ref) {
  final supabase = ref.watch(
    supabaseProvider,
  );

  return DopPdfRepository(
    supabase: supabase,
  );
});

class DopPdfRepository {
  final SupabaseClient supabase;

  const DopPdfRepository({
    required this.supabase,
  });

  Future<DopPdfApprovalMetadata>
  loadApprovalMetadata({
    required String dopHeaderId,
  }) async {
    final headerResponse = await supabase
        .from('dop_headers')
        .select(
      'company_id, '
          'created_by, '
          'submitted_at, '
          'created_at',
    )
        .eq('id', dopHeaderId)
        .maybeSingle();

    if (headerResponse == null) {
      throw Exception(
        'Header DOP tidak ditemukan.',
      );
    }

    final header =
    Map<String, dynamic>.from(
      headerResponse,
    );

    final companyId =
    header['company_id']?.toString();

    final createdBy =
    header['created_by']?.toString();

    final createdAt = _readDateTime(
      header['submitted_at'] ??
          header['created_at'],
    );

    final approvalResponse = await supabase
        .from('dop_approvals')
        .select(
      'approval_level, '
          'approver_id, '
          'status, '
          'approved_at',
    )
        .eq(
      'dop_header_id',
      dopHeaderId,
    )
        .inFilter(
      'approval_level',
      [3, 4],
    );

    final approvals =
    List<Map<String, dynamic>>.from(
      approvalResponse,
    );

    String? layer3UserId;
    String? layer4UserId;
    DateTime? layer3ApprovedAt;
    DateTime? layer4ApprovedAt;

    for (final approval in approvals) {
      final level = approval[
      'approval_level'];

      final status =
      approval['status']?.toString();

      if (status != 'approved') {
        continue;
      }

      final approverId =
      approval['approver_id']
          ?.toString();

      final approvedAt = _readDateTime(
        approval['approved_at'],
      );

      if (level == 3) {
        layer3UserId = approverId;
        layer3ApprovedAt = approvedAt;
      }

      if (level == 4) {
        layer4UserId = approverId;
        layer4ApprovedAt = approvedAt;
      }
    }

    final userIds = <String>{
      if (createdBy != null &&
          createdBy.isNotEmpty)
        createdBy,
      if (layer3UserId != null &&
          layer3UserId.isNotEmpty)
        layer3UserId,
      if (layer4UserId != null &&
          layer4UserId.isNotEmpty)
        layer4UserId,
    };

    final profileNames =
    <String, String>{};

    final positions =
    <String, String>{};

    if (userIds.isNotEmpty) {
      final profileResponse = await supabase
          .from('profiles')
          .select('id, full_name')
          .inFilter(
        'id',
        userIds.toList(),
      );

      final profiles =
      List<Map<String, dynamic>>.from(
        profileResponse,
      );

      for (final profile in profiles) {
        final userId =
        profile['id']?.toString();

        if (userId == null) {
          continue;
        }

        profileNames[userId] =
            profile['full_name']
                ?.toString()
                .trim() ??
                '-';
      }

      var positionQuery = supabase
          .from('company_users')
          .select(
        'user_id, position',
      )
          .inFilter(
        'user_id',
        userIds.toList(),
      )
          .eq('is_active', true);

      if (companyId != null &&
          companyId.isNotEmpty) {
        positionQuery = positionQuery.eq(
          'company_id',
          companyId,
        );
      }

      final positionResponse =
      await positionQuery;

      final positionRecords =
      List<Map<String, dynamic>>.from(
        positionResponse,
      );

      for (final record
      in positionRecords) {
        final userId =
        record['user_id']?.toString();

        if (userId == null) {
          continue;
        }

        positions[userId] =
            record['position']
                ?.toString()
                .trim() ??
                '-';
      }
    }

    return DopPdfApprovalMetadata(
      creatorPosition:
      positions[createdBy] ?? '-',
      createdAt: createdAt,
      layer3Name:
      profileNames[layer3UserId] ?? '-',
      layer3Position:
      positions[layer3UserId] ?? '-',
      layer3ApprovedAt:
      layer3ApprovedAt,
      layer4Name:
      profileNames[layer4UserId] ?? '-',
      layer4Position:
      positions[layer4UserId] ?? '-',
      layer4ApprovedAt:
      layer4ApprovedAt,
    );
  }

  DateTime? _readDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  Future<pw.ImageProvider?> _loadPdfLogo() async {
    try {
      return await networkImage(
        'https://edtuzimhejrluwljkihb.supabase.co/'
            'storage/v1/object/public/public-assets/'
            'logos/berau_coal_logo.jpg',
      );
    } catch (error) {
      debugPrint(
        'Logo PDF gagal dimuat: $error',
      );

      return null;
    }
  }

  Future<void> downloadDopPdf({
    required DopListItemModel headerItem,
    required List<DopListItemModel> activities,
  }) async {
    if (headerItem.status == 'draft') {
      throw Exception(
        'Draft belum dapat diunduh sebagai PDF DOP resmi.',
      );
    }

    if (activities.isEmpty) {
      throw Exception(
        'Aktivitas DOP tidak ditemukan.',
      );
    }

    final approvalMetadata =
    await loadApprovalMetadata(
      dopHeaderId:
      headerItem.dopHeaderId,
    );

    final printedAt = DateTime.now();

    final logo = await _loadPdfLogo();

    final document = pw.Document(
      title: headerItem.dopNumber,
      author: 'DOP Online',
      creator: 'DOP Online',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (context) {
          return _buildHeader(
            headerItem,
            logo,
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 10,
            ),
            child: pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'PDF printed at: '
                      '${_formatDateTime(printedAt)}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} '
                      'dari ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) {
          return [
            _buildInformation(
              headerItem,
              activities.length,
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              'Daftar Aktivitas Kendaraan',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 7),
            _buildActivityTable(activities),
            pw.SizedBox(height: 14),
            _buildLayerInformation(
              headerItem,
            ),
            pw.SizedBox(height: 10),
            _buildApprovalInformation(
              headerItem,
              approvalMetadata,
            ),
          ];
        },
      ),
    );

    final bytes = await document.save();

    final safeNumber = headerItem.dopNumber
        .replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'DOP-$safeNumber.pdf',
    );
  }

  pw.Widget _buildHeader(
      DopListItemModel item,
      pw.ImageProvider? logo,
      ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        bottom: 14,
      ),
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius:
        pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DOP ONLINE',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Daily Operation Plan Transportasi',
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          if (logo != null)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 5,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius:
                pw.BorderRadius.circular(5),
              ),
              child: pw.ConstrainedBox(
                constraints: const pw.BoxConstraints(
                  maxWidth: 90,
                  maxHeight: 38,
                ),
                child: pw.Image(
                  logo,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildInformation(
      DopListItemModel item,
      int activityCount,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _informationColumn([
              ['Perusahaan', item.companyName],
              ['Job Site', item.jobSite],
              ['Tanggal', '${item.dayName}, '
                  '${item.dopDate}'],
            ]),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: _informationColumn([
              ['Nomor DOP', item.dopNumber,],
              ['Status', _formatStatus(item.status),],
              [
                'Jumlah Aktivitas',
                activityCount.toString(),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  pw.Widget _informationColumn(
      List<List<String>> rows,
      ) {
    return pw.Column(
      children: rows.map((row) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(
            bottom: 5,
          ),
          child: pw.Row(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 90,
                child: pw.Text(
                  row[0],
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  row[1],
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildActivityTable(
      List<DopListItemModel> activities,
      ) {
    return pw.TableHelper.fromTextArray(
      headers: const [
        'No',
        'Pekerjaan',
        'Unit',
        'Tipe Unit',
        'Driver',
        'Expired SID',
        'Expired SIMPER',
        'Waktu',
        'Rute',
        'Observer',
        'Area',
        'Shift',
        'RIC',
        'Bahaya',
        'Risiko',
        'JSA',
      ],
      data: [
        for (
        var index = 0;
        index < activities.length;
        index++
        )
          [
            '${index + 1}',
            activities[index].workPlan,
            activities[index].unitNumber,
            _formatUnitType(
              activities[index].unitType,
            ),
            activities[index].driverName,
            _formatDateText(
              activities[index]
                  .sidExpiredDate,
            ),
            _formatDateText(
              activities[index]
                  .simperExpiredDate,
            ),
            '${_formatTime(
              activities[index].startTime,
            )} - ${_formatTime(
              activities[index].endTime,
            )}',
            activities[index].route,
            activities[index].observer,
            _formatArea(
              activities[index].areaType,
            ),
            activities[index].shift,
            activities[index].controlRoom,
            'Unit ditabrak, tertabrak '
                '& terbalik',
            'High',
            activities[index].jsaProcedure,
          ],
      ],
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 5.5,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration:
      const pw.BoxDecoration(
        color: PdfColors.blueGrey800,
      ),
      cellStyle: const pw.TextStyle(
        fontSize: 5.1,
        lineSpacing: 1.15,
      ),
      cellPadding:
      const pw.EdgeInsets.symmetric(
        horizontal: 2.5,
        vertical: 4,
      ),
      cellAlignment:
      pw.Alignment.centerLeft,
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(19),
        1: const pw.FlexColumnWidth(2.2),
        2: const pw.FlexColumnWidth(0.75),
        3: const pw.FlexColumnWidth(0.8),
        4: const pw.FlexColumnWidth(1.05),
        5: const pw.FlexColumnWidth(0.85),
        6: const pw.FlexColumnWidth(0.85),
        7: const pw.FlexColumnWidth(0.85),
        8: const pw.FlexColumnWidth(1.05),
        9: const pw.FlexColumnWidth(1.05),
        10: const pw.FlexColumnWidth(0.9),
        11: const pw.FlexColumnWidth(0.7),
        12: const pw.FlexColumnWidth(0.95),
        13: const pw.FlexColumnWidth(1.7),
        14: const pw.FlexColumnWidth(0.6),
        15: const pw.FlexColumnWidth(1.7),
      },
    );
  }

  pw.Widget _buildLayerInformation(
      DopListItemModel item,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Hierarchy Personel DOP',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(),
            1: pw.FlexColumnWidth(),
            2: pw.FlexColumnWidth(),
            3: pw.FlexColumnWidth(),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              children: [
                _buildLayerHeaderCell(
                  'Layer 1',
                ),
                _buildLayerHeaderCell(
                  'Layer 2',
                ),
                _buildLayerHeaderCell(
                  'Layer 3',
                ),
                _buildLayerHeaderCell(
                  'Layer 4',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildLayerValueCell(
                  item.layer1,
                ),
                _buildLayerValueCell(
                  item.layer2,
                ),
                _buildLayerValueCell(
                  item.layer3,
                ),
                _buildLayerValueCell(
                  item.layer4,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLayerHeaderCell(
      String value,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        value,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildLayerValueCell(
      String value,
      ) {
    final normalizedValue =
    value.trim().isEmpty
        ? '-'
        : value.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        normalizedValue,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.blueGrey900,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildApprovalInformation(
      DopListItemModel item,
      DopPdfApprovalMetadata metadata,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Approval DOP',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(),
            1: pw.FlexColumnWidth(),
            2: pw.FlexColumnWidth(),
          },
          children: [
            pw.TableRow(
              decoration:
              const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              children: [
                _buildLayerHeaderCell(
                  'Dibuat Oleh',
                ),
                _buildLayerHeaderCell(
                  'Disetujui Oleh',
                ),
                _buildLayerHeaderCell(
                  'Diketahui Oleh',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildApprovalValueCell(
                  name: item.createdByName,
                  position:
                  metadata.creatorPosition,
                  dateTime:
                  metadata.createdAt,
                ),
                _buildApprovalValueCell(
                  name: metadata.layer3Name,
                  position:
                  metadata.layer3Position,
                  dateTime:
                  metadata.layer3ApprovedAt,
                ),
                _buildApprovalValueCell(
                  name: metadata.layer4Name,
                  position:
                  metadata.layer4Position,
                  dateTime:
                  metadata.layer4ApprovedAt,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildApprovalValueCell({
    required String name,
    required String position,
    required DateTime? dateTime,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _normalizeText(name),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.blueGrey900,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _normalizeText(position),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 7.5,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            dateTime == null
                ? '-'
                : _formatDateTime(dateTime),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final localValue = value.toLocal();

    final day = localValue.day
        .toString()
        .padLeft(2, '0');

    final month = localValue.month
        .toString()
        .padLeft(2, '0');

    final year = localValue.year
        .toString()
        .padLeft(4, '0');

    final hour = localValue.hour
        .toString()
        .padLeft(2, '0');

    final minute = localValue.minute
        .toString()
        .padLeft(2, '0');

    return '$day-$month-$year '
        '$hour:$minute';
  }

  String _formatStatus(String status) {
    if (status == 'pending_layer_3') {
      return 'Menunggu Approval Layer 3';
    }
    if (status == 'pending_layer_4') {
      return 'Menunggu Approval Layer 4';
    }
    if (status == 'revision_required') {
      return 'Perlu Revisi';
    }
    if (status == 'approved') {
      return 'Approved';
    }
    if (status == 'rejected') {
      return 'Rejected';
    }
    return status;
  }

  String _formatUnitType(String value) {
    final normalized =
    value.trim().toUpperCase();

    if (normalized == 'MICRO_BUS') {
      return 'Micro Bus';
    }

    if (normalized == 'MANHAUL') {
      return 'Manhaul';
    }

    if (normalized == 'BUS') {
      return 'BUS';
    }

    if (normalized == 'LV') {
      return 'LV';
    }

    if (normalized.isEmpty ||
        normalized == '-') {
      return '-';
    }

    return value.trim();
  }

  String _formatArea(String value) {
    if (value == 'jalan_negara') {
      return 'Jalan Negara';
    }
    if (value == 'site') {
      return 'Area Site';
    }
    return value;
  }

  String _formatDateText(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty ||
        normalized == '-') {
      return '-';
    }

    if (normalized.length >= 10) {
      return normalized.substring(0, 10);
    }

    return normalized;
  }

  String _normalizeText(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty ||
        normalized == '-') {
      return '-';
    }

    return normalized;
  }

  String _formatTime(String value) {
    if (value.length >= 5) {
      return value.substring(0, 5);
    }
    return value;
  }
}

class DopPdfApprovalMetadata {
  final String creatorPosition;
  final DateTime? createdAt;

  final String layer3Name;
  final String layer3Position;
  final DateTime? layer3ApprovedAt;

  final String layer4Name;
  final String layer4Position;
  final DateTime? layer4ApprovedAt;

  const DopPdfApprovalMetadata({
    required this.creatorPosition,
    required this.createdAt,
    required this.layer3Name,
    required this.layer3Position,
    required this.layer3ApprovedAt,
    required this.layer4Name,
    required this.layer4Position,
    required this.layer4ApprovedAt,
  });
}