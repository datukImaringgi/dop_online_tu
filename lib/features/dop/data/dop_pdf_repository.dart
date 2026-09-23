import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/dop_list_item_model.dart';

final dopPdfRepositoryProvider =
Provider<DopPdfRepository>((ref) {
  return const DopPdfRepository();
});

class DopPdfRepository {
  const DopPdfRepository();

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

    final logo = await imageFromAssetBundle(
      'assets/images/berau_coal_logo.jpg',
    );

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
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(
              top: 10,
            ),
            child: pw.Text(
              'Halaman ${context.pageNumber} '
                  'dari ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey700,
              ),
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
      pw.ImageProvider logo,
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
          pw.Row(
            children: [
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
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DOP ONLINE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 17,
                      fontWeight:
                      pw.FontWeight.bold,
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
            ],
          ),
          pw.Text(
            item.dopNumber,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
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
              ['Status', _formatStatusWithApprovalTime(item),],
              ['Dibuat Oleh', item.createdByName],
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
        'JSA',
        'Risiko',
        'Bahaya',
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
            activities[index].jsaProcedure,
            'High',
            'Unit ditabrak, tertabrak '
                '& terbalik',
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
                _buildLayerValueCell(
                  _normalizeText(
                    item.createdByName,
                  ),
                ),
                _buildLayerValueCell(
                  _normalizeText(
                    item.approvedByName,
                  ),
                ),
                _buildLayerValueCell(
                  _normalizeText(
                    item.knownByName,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatStatusWithApprovalTime(
      DopListItemModel item,
      ) {
    final statusText =
    _formatStatus(item.status);

    if (item.status != 'approved' ||
        item.approvedAt == null) {
      return statusText;
    }

    return '$statusText - '
        '${_formatDateTime(item.approvedAt!)}';
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