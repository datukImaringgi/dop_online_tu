import 'dop_activity_draft.dart';

class DopExcelRawRow {
  final int rowNumber;
  final Map<String, String> values;

  const DopExcelRawRow({
    required this.rowNumber,
    required this.values,
  });

  String read(String header) {
    return values[header]?.trim() ?? '';
  }

  bool get isEmpty {
    for (final value in values.values) {
      if (value.trim().isNotEmpty) {
        return false;
      }
    }

    return true;
  }
}

class DopExcelParsedFile {
  final String fileName;
  final List<DopExcelRawRow> rows;

  const DopExcelParsedFile({
    required this.fileName,
    required this.rows,
  });

  int get totalRows {
    return rows.length;
  }
}

class DopExcelImportError {
  final int rowNumber;
  final String fieldName;
  final String message;

  const DopExcelImportError({
    required this.rowNumber,
    required this.fieldName,
    required this.message,
  });

  String get displayMessage {
    if (fieldName.trim().isEmpty) {
      return 'Baris $rowNumber: $message';
    }

    return 'Baris $rowNumber - '
        '$fieldName: $message';
  }
}

class DopExcelImportedLayers {
  final String layer1UserId;
  final String layer1Name;

  final String layer2UserId;
  final String layer2Name;

  final String layer3UserId;
  final String layer3Name;

  final String layer4UserId;
  final String layer4Name;

  const DopExcelImportedLayers({
    required this.layer1UserId,
    required this.layer1Name,
    required this.layer2UserId,
    required this.layer2Name,
    required this.layer3UserId,
    required this.layer3Name,
    required this.layer4UserId,
    required this.layer4Name,
  });

  List<String> get comparisonKey {
    return [
      layer1UserId,
      layer2UserId,
      layer3UserId,
      layer4UserId,
    ];
  }

  bool hasSameSelection(
      DopExcelImportedLayers other,
      ) {
    final current = comparisonKey;
    final candidate = other.comparisonKey;

    for (
    var index = 0;
    index < current.length;
    index++
    ) {
      if (current[index] != candidate[index]) {
        return false;
      }
    }

    return true;
  }
}

class DopExcelImportResult {
  final String fileName;
  final int totalRows;

  final List<DopActivityDraft>
  validActivities;

  final List<DopExcelImportError>
  errors;

  final DopExcelImportedLayers?
  importedLayers;

  const DopExcelImportResult({
    required this.fileName,
    required this.totalRows,
    required this.validActivities,
    required this.errors,
    required this.importedLayers,
  });

  int get validRowCount {
    return validActivities.length;
  }

  int get invalidRowCount {
    final invalidRows = <int>{};

    for (final error in errors) {
      invalidRows.add(error.rowNumber);
    }

    return invalidRows.length;
  }

  bool get hasValidActivities {
    return validActivities.isNotEmpty;
  }

  bool get hasErrors {
    return errors.isNotEmpty;
  }

  bool get canImport {
    return hasValidActivities &&
        importedLayers != null;
  }

  String get summaryText {
    return 'Total $totalRows baris, '
        '$validRowCount valid, '
        '$invalidRowCount perlu diperbaiki.';
  }
}