import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'dart:async';
import 'dart:html' as html;

import '../domain/dop_activity_draft.dart';
import '../domain/dop_excel_import_result.dart';

class DopExcelImportRepository {
  static const String activitySheetName =
      'Aktivitas';

  static const String instructionSheetName =
      'Petunjuk';

  static const List<String> requiredHeaders = [
    'rencana_pekerjaan',
    'shift',
    'nama_rute',
    'waktu_mulai',
    'waktu_akhir',
    'nomor_unit',
    'sid_driver',
    'observer',
    'kode_jsa',
    'ric',
    'layer_1',
    'layer_2',
    'layer_3',
    'layer_4',
  ];

  Future<void> downloadTemplate() async {
    final excel = Excel.createExcel();

    excel.rename(
      excel.getDefaultSheet() ?? 'Sheet1',
      activitySheetName,
    );

    final activitySheet =
    excel[activitySheetName];

    final instructionSheet =
    excel[instructionSheetName];

    _buildActivitySheet(
      activitySheet,
    );

    _buildInstructionSheet(
      instructionSheet,
    );

    excel.setDefaultSheet(
      activitySheetName,
    );

    final result = excel.save(
      fileName:
      'Template_Import_Aktivitas_DOP.xlsx',
    );

    if (result == null) {
      throw Exception(
        'Template Excel gagal dibuat.',
      );
    }
  }

  Future<DopExcelParsedFile?>
  pickAndReadTemplate() async {
    final completer =
    Completer<DopExcelParsedFile?>();

    final input =
    html.FileUploadInputElement()
      ..accept = '.xlsx'
      ..multiple = false;

    input.onChange.first.then((_) {
      final files = input.files;

      if (files == null ||
          files.isEmpty) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }

        return;
      }

      final selectedFile = files.first;

      final normalizedFileName =
      selectedFile.name
          .trim()
          .toLowerCase();

      if (!normalizedFileName.endsWith(
        '.xlsx',
      )) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(
              'File wajib menggunakan '
                  'format XLSX.',
            ),
          );
        }

        return;
      }

      final reader =
      html.FileReader();

      reader.onError.first.then((_) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(
              'File Excel tidak dapat dibaca.',
            ),
          );
        }
      });

      reader.onLoadEnd.first.then((_) {
        try {
          final result = reader.result;

          if (result is! List<int>) {
            throw Exception(
              'Isi file Excel tidak valid.',
            );
          }

          final bytes =
          Uint8List.fromList(result);

          if (bytes.isEmpty) {
            throw Exception(
              'File Excel kosong.',
            );
          }

          final parsedFile =
          readTemplateBytes(
            fileName: selectedFile.name,
            bytes: bytes,
          );

          if (!completer.isCompleted) {
            completer.complete(
              parsedFile,
            );
          }
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
      });

      reader.readAsArrayBuffer(
        selectedFile,
      );
    });

    input.click();

    return completer.future;
  }

  DopExcelParsedFile readTemplateBytes({
    required String fileName,
    required Uint8List bytes,
  }) {
    Excel workbook;

    try {
      workbook = Excel.decodeBytes(bytes);
    } catch (_) {
      throw Exception(
        'File XLSX rusak atau tidak dapat dibuka.',
      );
    }

    if (!workbook.tables.containsKey(
      activitySheetName,
    )) {
      throw Exception(
        'Sheet "$activitySheetName" '
            'tidak ditemukan.',
      );
    }

    final sheet =
    workbook.tables[activitySheetName];

    if (sheet == null || sheet.rows.isEmpty) {
      throw Exception(
        'Sheet "$activitySheetName" kosong.',
      );
    }

    final actualHeaders =
    _readHeaderRow(sheet);

    _validateHeaders(actualHeaders);

    final rows = <DopExcelRawRow>[];

    for (
    var rowIndex = 1;
    rowIndex < sheet.rows.length;
    rowIndex++
    ) {
      final excelRow =
      sheet.rows[rowIndex];

      final values = <String, String>{};

      for (
      var columnIndex = 0;
      columnIndex <
          requiredHeaders.length;
      columnIndex++
      ) {
        final header =
        requiredHeaders[columnIndex];

        Data? cell;

        if (columnIndex <
            excelRow.length) {
          cell = excelRow[columnIndex];
        }

        values[header] =
            _readCellText(cell);
      }

      final rawRow = DopExcelRawRow(
        rowNumber: rowIndex + 1,
        values: values,
      );

      if (rawRow.isEmpty) {
        continue;
      }

      rows.add(rawRow);
    }

    if (rows.isEmpty) {
      throw Exception(
        'Template belum berisi aktivitas.',
      );
    }

    return DopExcelParsedFile(
      fileName: fileName,
      rows: rows,
    );
  }

  DopExcelImportResult validateAndConvert({
    required DopExcelParsedFile parsedFile,
    required String jobSiteId,
    required List<Map<String, dynamic>> units,
    required List<Map<String, dynamic>> drivers,
    required List<Map<String, dynamic>> routes,
    required List<Map<String, dynamic>> jsaProcedures,
    required List<Map<String, dynamic>> controlRooms,
    required List<Map<String, dynamic>> employees,
    required List<DopActivityDraft> existingActivities,
  }) {
    final validActivities =
    <DopActivityDraft>[];

    final errors =
    <DopExcelImportError>[];

    DopExcelImportedLayers? importedLayers;

    final duplicateKeys = <String>{
      for (final activity in existingActivities)
        activity.duplicateKey,
    };

    for (final rawRow in parsedFile.rows) {
      final rowErrors =
      <DopExcelImportError>[];

      void addError(
          String field,
          String message,
          ) {
        rowErrors.add(
          DopExcelImportError(
            rowNumber: rawRow.rowNumber,
            fieldName: field,
            message: message,
          ),
        );
      }

      for (final header in requiredHeaders) {
        if (rawRow.read(header).isEmpty) {
          addError(
            header,
            'Wajib diisi.',
          );
        }
      }

      final shift = _normalizeShift(
        rawRow.read('shift'),
      );

      if (shift == null) {
        addError(
          'shift',
          'Gunakan Shift 1 atau Shift 2.',
        );
      }

      final startTime = _normalizeTime(
        rawRow.read('waktu_mulai'),
      );

      final endTime = _normalizeTime(
        rawRow.read('waktu_akhir'),
      );

      if (startTime == null) {
        addError(
          'waktu_mulai',
          'Gunakan format 24 jam HH:mm.',
        );
      }

      if (endTime == null) {
        addError(
          'waktu_akhir',
          'Gunakan format 24 jam HH:mm.',
        );
      }

      if (startTime != null &&
          endTime != null &&
          startTime == endTime) {
        addError(
          'waktu_akhir',
          'Waktu mulai dan akhir '
              'tidak boleh sama.',
        );
      }

      final unit = _findMaster(
        items: units,
        field: 'unit_number',
        value: rawRow.read('nomor_unit'),
        jobSiteId: jobSiteId,
      );

      if (unit == null) {
        addError(
          'nomor_unit',
          'Unit tidak ditemukan atau '
              'tidak sesuai Job Site.',
        );
      }

      final driver = _findMaster(
        items: drivers,
        field: 'sid',
        value: rawRow.read('sid_driver'),
        jobSiteId: jobSiteId,
      );

      if (driver == null) {
        addError(
          'sid_driver',
          'Driver tidak ditemukan atau '
              'tidak sesuai Job Site.',
        );
      }

      final route = _findMaster(
        items: routes,
        field: 'route_name',
        value: rawRow.read('nama_rute'),
        jobSiteId: jobSiteId,
      );

      if (route == null) {
        addError(
          'nama_rute',
          'Rute tidak ditemukan atau '
              'tidak sesuai Job Site.',
        );
      }

      final jsa = _findMaster(
        items: jsaProcedures,
        field: 'procedure_code',
        value: rawRow.read('kode_jsa'),
        jobSiteId: jobSiteId,
      );

      if (jsa == null) {
        addError(
          'kode_jsa',
          'Kode JSA tidak ditemukan.',
        );
      }

      final controlRoom = _findMaster(
        items: controlRooms,
        field: 'control_room_name',
        value: rawRow.read('ric'),
        jobSiteId: jobSiteId,
      );

      if (controlRoom == null) {
        addError(
          'ric',
          'RIC tidak ditemukan atau '
              'tidak sesuai Job Site.',
        );
      }

      final rowLayers = _readLayers(
        rawRow: rawRow,
        employees: employees,
        errors: rowErrors,
      );

      if (rowLayers != null) {
        if (importedLayers == null) {
          importedLayers = rowLayers;
        } else if (!importedLayers
            .hasSameSelection(rowLayers)) {
          addError(
            'layer_1 - layer_4',
            'Layer harus sama untuk seluruh '
                'aktivitas dalam satu file.',
          );
        }
      }

      if (driver != null) {
        _validateDriverExpiry(
          driver: driver,
          rowNumber: rawRow.rowNumber,
          errors: rowErrors,
        );
      }

      if (rowErrors.isNotEmpty) {
        errors.addAll(rowErrors);
        continue;
      }

      if (unit == null ||
          driver == null ||
          route == null ||
          jsa == null ||
          controlRoom == null ||
          rowLayers == null ||
          shift == null ||
          startTime == null ||
          endTime == null) {
        continue;
      }

      final routeName =
      _readMapText(route, 'route_name');

      final localId =
          '${DateTime.now().microsecondsSinceEpoch}'
          '-${rawRow.rowNumber}';

      final draft = DopActivityDraft(
        localId: localId,
        workPlan:
        rawRow.read('rencana_pekerjaan'),
        areaType:
        _readMapText(route, 'area_type'),
        shift: shift,
        unitId: _readMapText(unit, 'id'),
        unitType:
        _readMapText(unit, 'unit_type'),
        unitNumber:
        _readMapText(unit, 'unit_number'),
        transportCompany:
        _readMapText(unit, 'owner_company'),
        driverId:
        _readMapText(driver, 'id'),
        driverName:
        _readMapText(driver, 'driver_name'),
        sid: _readNullableText(driver, 'sid'),
        sidExpiredDate: _readNullableText(
          driver,
          'sid_expired_date',
        ),
        simperExpiredDate: _readNullableText(
          driver,
          'simper_expired_date',
        ),
        startTime: startTime,
        endTime: endTime,
        routeId:
        _readNullableText(route, 'id'),
        routeName: routeName,
        observer: rawRow.read('observer'),
        jsaId: _readMapText(jsa, 'id'),
        jsaProcedure:
        '${_readMapText(jsa, 'procedure_code')}'
            ' - '
            '${_readMapText(jsa, 'procedure_name')}',
        controlRoomId:
        _readMapText(controlRoom, 'id'),
        controlRoomName: _readMapText(
          controlRoom,
          'control_room_name',
        ),
        layer1UserId:
        rowLayers.layer1UserId,
        layer2UserId:
        rowLayers.layer2UserId,
        layer3UserId:
        rowLayers.layer3UserId,
        layer4UserId:
        rowLayers.layer4UserId,
        layer1: rowLayers.layer1Name,
        layer2: rowLayers.layer2Name,
        layer3: rowLayers.layer3Name,
        layer4: rowLayers.layer4Name,
        notes: '',
      );

      if (duplicateKeys.contains(
        draft.duplicateKey,
      )) {
        errors.add(
          DopExcelImportError(
            rowNumber: rawRow.rowNumber,
            fieldName: 'aktivitas',
            message:
            'Duplikat Unit, waktu, dan rute.',
          ),
        );
        continue;
      }

      duplicateKeys.add(
        draft.duplicateKey,
      );

      validActivities.add(draft);
    }

    return DopExcelImportResult(
      fileName: parsedFile.fileName,
      totalRows: parsedFile.totalRows,
      validActivities: validActivities,
      errors: errors,
      importedLayers: importedLayers,
    );
  }

  Map<String, dynamic>? _findMaster({
    required List<Map<String, dynamic>> items,
    required String field,
    required String value,
    required String jobSiteId,
  }) {
    final normalizedValue =
    _normalizeText(value);

    if (normalizedValue.isEmpty) {
      return null;
    }

    for (final item in items) {
      final itemValue = _normalizeText(
        item[field]?.toString() ?? '',
      );

      if (itemValue != normalizedValue) {
        continue;
      }

      final itemJobSiteId =
      item['job_site_id']
          ?.toString()
          .trim();

      if (itemJobSiteId != null &&
          itemJobSiteId.isNotEmpty &&
          itemJobSiteId != jobSiteId) {
        continue;
      }

      return item;
    }

    return null;
  }

  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  String _readMapText(
      Map<String, dynamic> map,
      String key,
      ) {
    return map[key]?.toString().trim() ?? '';
  }

  String? _readNullableText(
      Map<String, dynamic> map,
      String key,
      ) {
    final value =
    map[key]?.toString().trim();

    if (value == null ||
        value.isEmpty) {
      return null;
    }

    return value;
  }

  String? _normalizeShift(String value) {
    final normalized =
    _normalizeText(value);

    if (normalized == 'shift 1' ||
        normalized == '1') {
      return 'Shift 1';
    }

    if (normalized == 'shift 2' ||
        normalized == '2') {
      return 'Shift 2';
    }

    return null;
  }

  String? _normalizeTime(String value) {
    final normalized = value.trim();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?$',
    ).firstMatch(normalized);

    if (match == null) {
      return null;
    }

    final hour =
    int.tryParse(match.group(1) ?? '');

    final minute =
    int.tryParse(match.group(2) ?? '');

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  DopExcelImportedLayers? _readLayers({
    required DopExcelRawRow rawRow,
    required List<Map<String, dynamic>>
    employees,
    required List<DopExcelImportError>
    errors,
  }) {
    final layer1 = _findEmployeeLayer(
      employees: employees,
      input: rawRow.read('layer_1'),
      expectedLayer: 1,
    );

    final layer2 = _findEmployeeLayer(
      employees: employees,
      input: rawRow.read('layer_2'),
      expectedLayer: 2,
    );

    final layer3 = _findEmployeeLayer(
      employees: employees,
      input: rawRow.read('layer_3'),
      expectedLayer: 3,
    );

    final layer4 = _findEmployeeLayer(
      employees: employees,
      input: rawRow.read('layer_4'),
      expectedLayer: 4,
    );

    if (layer1 == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rawRow.rowNumber,
          fieldName: 'layer_1',
          message:
          'Karyawan Layer 1 tidak ditemukan. '
              'Gunakan SID atau nama lengkap '
              'yang sesuai.',
        ),
      );
    }

    if (layer2 == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rawRow.rowNumber,
          fieldName: 'layer_2',
          message:
          'Karyawan Layer 2 tidak ditemukan. '
              'Gunakan SID atau nama lengkap '
              'yang sesuai.',
        ),
      );
    }

    if (layer3 == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rawRow.rowNumber,
          fieldName: 'layer_3',
          message:
          'Karyawan Layer 3 tidak ditemukan. '
              'Gunakan SID atau nama lengkap '
              'yang sesuai.',
        ),
      );
    }

    if (layer4 == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rawRow.rowNumber,
          fieldName: 'layer_4',
          message:
          'Karyawan Layer 4 tidak ditemukan. '
              'Gunakan SID atau nama lengkap '
              'yang sesuai.',
        ),
      );
    }

    if (layer1 == null ||
        layer2 == null ||
        layer3 == null ||
        layer4 == null) {
      return null;
    }

    return DopExcelImportedLayers(
      layer1UserId:
      _readMapText(layer1, 'id'),
      layer1Name:
      _readEmployeeName(layer1),
      layer2UserId:
      _readMapText(layer2, 'id'),
      layer2Name:
      _readEmployeeName(layer2),
      layer3UserId:
      _readMapText(layer3, 'id'),
      layer3Name:
      _readEmployeeName(layer3),
      layer4UserId:
      _readMapText(layer4, 'id'),
      layer4Name:
      _readEmployeeName(layer4),
    );
  }

  Map<String, dynamic>?
  _findEmployeeLayer({
    required List<Map<String, dynamic>>
    employees,
    required String input,
    required int expectedLayer,
  }) {
    final normalizedInput =
    _normalizeText(input);

    if (normalizedInput.isEmpty) {
      return null;
    }

    final matchedEmployees =
    <Map<String, dynamic>>[];

    for (final employee in employees) {
      final hierarchyLayer =
      _readInteger(
        employee['hierarchy_layer'],
      );

      if (hierarchyLayer != expectedLayer) {
        continue;
      }

      final profile =
      employee['profiles'];

      if (profile is! Map) {
        continue;
      }

      final sid = _normalizeText(
        profile['sid']?.toString() ?? '',
      );

      final fullName = _normalizeText(
        profile['full_name']
            ?.toString() ??
            '',
      );

      if (sid == normalizedInput ||
          fullName == normalizedInput) {
        matchedEmployees.add(employee);
      }
    }

    if (matchedEmployees.length != 1) {
      return null;
    }

    return matchedEmployees.first;
  }

  String _readEmployeeName(
      Map<String, dynamic> employee,
      ) {
    final profile =
    employee['profiles'];

    if (profile is Map) {
      final name = profile['full_name']
          ?.toString()
          .trim();

      if (name != null &&
          name.isNotEmpty) {
        return name;
      }
    }

    return '-';
  }

  int? _readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  void _validateDriverExpiry({
    required Map<String, dynamic> driver,
    required int rowNumber,
    required List<DopExcelImportError>
    errors,
  }) {
    final sidExpiry = _readDate(
      driver['sid_expired_date'],
    );

    final simperExpiry = _readDate(
      driver['simper_expired_date'],
    );

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (sidExpiry == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rowNumber,
          fieldName: 'sid_driver',
          message:
          'Masa berlaku SID Driver '
              'tidak tersedia.',
        ),
      );
    } else if (sidExpiry.isBefore(today)) {
      errors.add(
        DopExcelImportError(
          rowNumber: rowNumber,
          fieldName: 'sid_driver',
          message:
          'SID Driver telah expired pada '
              '${_formatDate(sidExpiry)}.',
        ),
      );
    }

    if (simperExpiry == null) {
      errors.add(
        DopExcelImportError(
          rowNumber: rowNumber,
          fieldName: 'sid_driver',
          message:
          'Masa berlaku SIMPER Driver '
              'tidak tersedia.',
        ),
      );
    } else if (
    simperExpiry.isBefore(today)) {
      errors.add(
        DopExcelImportError(
          rowNumber: rowNumber,
          fieldName: 'sid_driver',
          message:
          'SIMPER Driver telah expired pada '
              '${_formatDate(simperExpiry)}.',
        ),
      );
    }
  }

  DateTime? _readDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return DateTime(
        value.year,
        value.month,
        value.day,
      );
    }

    final text =
    value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    final isoDate =
    DateTime.tryParse(text);

    if (isoDate != null) {
      return DateTime(
        isoDate.year,
        isoDate.month,
        isoDate.day,
      );
    }

    final match = RegExp(
      r'^(\d{1,2})\d{1,2}\d{4}$',
    ).firstMatch(text);

    if (match == null) {
      return null;
    }

    final day =
    int.tryParse(match.group(1) ?? '');

    final month =
    int.tryParse(match.group(2) ?? '');

    final year =
    int.tryParse(match.group(3) ?? '');

    if (day == null ||
        month == null ||
        year == null) {
      return null;
    }

    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      return null;
    }

    return DateTime(
      year,
      month,
      day,
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day
        .toString()
        .padLeft(2, '0');

    final month = value.month
        .toString()
        .padLeft(2, '0');

    final year = value.year
        .toString()
        .padLeft(4, '0');

    return '$day-$month-$year';
  }

  List<String> _readHeaderRow(
      Sheet sheet,
      ) {
    final firstRow = sheet.rows.first;

    final headers = <String>[];

    for (
    var columnIndex = 0;
    columnIndex <
        requiredHeaders.length;
    columnIndex++
    ) {
      Data? cell;

      if (columnIndex < firstRow.length) {
        cell = firstRow[columnIndex];
      }

      headers.add(
        _normalizeHeader(
          _readCellText(cell),
        ),
      );
    }

    return headers;
  }

  void _validateHeaders(
      List<String> actualHeaders,
      ) {
    final errors = <String>[];

    for (
    var index = 0;
    index < requiredHeaders.length;
    index++
    ) {
      final expected =
      requiredHeaders[index];

      final actual =
      index < actualHeaders.length
          ? actualHeaders[index]
          : '';

      if (actual == expected) {
        continue;
      }

      errors.add(
        'Kolom ${index + 1} seharusnya '
            '"$expected", ditemukan '
            '"${actual.isEmpty ? '-' : actual}".',
      );
    }

    if (errors.isEmpty) {
      return;
    }

    throw Exception(
      'Struktur template tidak sesuai.\n'
          '${errors.join('\n')}',
    );
  }

  String _normalizeHeader(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
  }

  String _readCellText(Data? cell) {
    final value = cell?.value;

    if (value == null) {
      return '';
    }

    if (value is TextCellValue) {
      return value.toString().trim();
    }

    if (value is IntCellValue) {
      return value.value.toString();
    }

    if (value is DoubleCellValue) {
      final number = value.value;

      if (number ==
          number.roundToDouble()) {
        return number
            .toInt()
            .toString();
      }

      return number.toString();
    }

    if (value is BoolCellValue) {
      return value.value
          ? 'true'
          : 'false';
    }

    if (value is TimeCellValue) {
      final hour = value.hour
          .toString()
          .padLeft(2, '0');

      final minute = value.minute
          .toString()
          .padLeft(2, '0');

      return '$hour:$minute';
    }

    return value.toString().trim();
  }

  void _buildActivitySheet(
      Sheet sheet,
      ) {
    sheet.appendRow(
      requiredHeaders
          .map<TextCellValue>(
        TextCellValue.new,
      )
          .toList(),
    );

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex:
      ExcelColor.fromHexString(
        '#FFFFFF',
      ),
      backgroundColorHex:
      ExcelColor.fromHexString(
        '#1E3A5F',
      ),
      horizontalAlign:
      HorizontalAlign.Center,
      verticalAlign:
      VerticalAlign.Center,
      textWrapping:
      TextWrapping.WrapText,
    );

    for (
    var column = 0;
    column < requiredHeaders.length;
    column++
    ) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: column,
          rowIndex: 0,
        ),
      );

      cell.cellStyle = headerStyle;
    }

    sheet.setRowHeight(
      0,
      30,
    );

    final columnWidths =
    <double>[
      35,
      14,
      28,
      14,
      14,
      18,
      18,
      24,
      18,
      22,
      22,
      22,
      22,
      22,
    ];

    for (
    var column = 0;
    column < columnWidths.length;
    column++
    ) {
      sheet.setColumnWidth(
        column,
        columnWidths[column],
      );
    }

    for (
    var row = 1;
    row <= 50;
    row++
    ) {
      for (
      var column = 0;
      column < requiredHeaders.length;
      column++
      ) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: column,
            rowIndex: row,
          ),
        );

        cell.cellStyle = CellStyle(
          fontColorHex:
          ExcelColor.fromHexString(
            '#0000FF',
          ),
          verticalAlign:
          VerticalAlign.Center,
        );
      }

      sheet.setRowHeight(
        row,
        22,
      );
    }
  }

  void _buildInstructionSheet(
      Sheet sheet,
      ) {
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex:
      ExcelColor.fromHexString(
        '#FFFFFF',
      ),
      backgroundColorHex:
      ExcelColor.fromHexString(
        '#1E3A5F',
      ),
      verticalAlign:
      VerticalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex:
      ExcelColor.fromHexString(
        '#FFFFFF',
      ),
      backgroundColorHex:
      ExcelColor.fromHexString(
        '#475569',
      ),
      verticalAlign:
      VerticalAlign.Center,
    );

    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('D1'),
    );

    final titleCell = sheet.cell(
      CellIndex.indexByString('A1'),
    );

    titleCell.value = TextCellValue(
      'Petunjuk Import Aktivitas DOP',
    );

    titleCell.cellStyle = titleStyle;

    sheet.appendRow([
      TextCellValue('Nama Kolom'),
      TextCellValue('Wajib'),
      TextCellValue('Contoh'),
      TextCellValue('Keterangan'),
    ]);

    for (var column = 0; column < 4; column++) {
      sheet
          .cell(
        CellIndex.indexByColumnRow(
          columnIndex: column,
          rowIndex: 1,
        ),
      )
          .cellStyle = headerStyle;
    }

    final instructions =
    <List<String>>[
      [
        'rencana_pekerjaan',
        'Ya',
        'Mobilisasi karyawan',
        'Uraian pekerjaan kendaraan',
      ],
      [
        'shift',
        'Ya',
        'Shift 1',
        'Isi Shift 1 atau Shift 2',
      ],
      [
        'nama_rute',
        'Ya',
        'Office - Workshop',
        'Harus sesuai Master Rute',
      ],
      [
        'waktu_mulai',
        'Ya',
        '07:00',
        'Gunakan format 24 jam HH:mm',
      ],
      [
        'waktu_akhir',
        'Ya',
        '08:30',
        'Gunakan format 24 jam HH:mm',
      ],
      [
        'nomor_unit',
        'Ya',
        'TU 104',
        'Harus sesuai Master Unit',
      ],
      [
        'sid_driver',
        'Ya',
        '12345678',
        'SID Driver aktif',
      ],
      [
        'observer',
        'Ya',
        'Nama Observer',
        'Nama observer aktivitas',
      ],
      [
        'kode_jsa',
        'Ya',
        'JSA-TR-001',
        'Harus sesuai kode Master JSA',
      ],
      [
        'ric',
        'Ya',
        'RIC Site A',
        'Harus sesuai Master RIC',
      ],
      [
        'layer_1',
        'Ya',
        '12345678',
        'Disarankan menggunakan SID',
      ],
      [
        'layer_2',
        'Ya',
        '12345679',
        'Disarankan menggunakan SID',
      ],
      [
        'layer_3',
        'Ya',
        '12345680',
        'Disarankan menggunakan SID',
      ],
      [
        'layer_4',
        'Ya',
        '12345681',
        'Disarankan menggunakan SID',
      ],
    ];

    for (final instruction in instructions) {
      sheet.appendRow(
        instruction
            .map<TextCellValue>(
          TextCellValue.new,
        )
            .toList(),
      );
    }

    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 28);
    sheet.setColumnWidth(3, 48);

    sheet.setRowHeight(0, 32);
    sheet.setRowHeight(1, 26);
  }
}