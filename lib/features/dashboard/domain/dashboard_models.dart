import '../../dop/domain/dop_list_item_model.dart';

enum DashboardPeriod {
  all,
  tomorrow,
  today,
  currentWeek,
  currentMonth,
}

class DashboardComplianceCounter {
  int comply;
  int overdueTwo;
  int overdueTwelve;

  DashboardComplianceCounter({
    this.comply = 0,
    this.overdueTwo = 0,
    this.overdueTwelve = 0,
  });
}

class DashboardComplianceRow {
  final String companyName;
  final int comply;
  final int overdueTwo;
  final int overdueTwelve;

  const DashboardComplianceRow({
    required this.companyName,
    required this.comply,
    required this.overdueTwo,
    required this.overdueTwelve,
  });

  int get total {
    return comply +
        overdueTwo +
        overdueTwelve;
  }

  double get compliancePercentage {
    final totalOverdue =
        overdueTwo + overdueTwelve;

    if (totalOverdue == 0) {
      if (comply > 0) {
        return 100;
      }

      return 0;
    }

    return comply / totalOverdue * 100;
  }

  String get compliancePercentageText {
    final percentage =
        compliancePercentage;

    if (percentage ==
        percentage.roundToDouble()) {
      return '${percentage.toStringAsFixed(0)}%';
    }

    return '${percentage.toStringAsFixed(1)}%';
  }
}

class DashboardTransportAreaCounter {
  int massal;
  int nonMassal;

  DashboardTransportAreaCounter({
    this.massal = 0,
    this.nonMassal = 0,
  });
}

class DashboardTransportAreaRow {
  final String companyName;
  final int massal;
  final int nonMassal;

  const DashboardTransportAreaRow({
    required this.companyName,
    required this.massal,
    required this.nonMassal,
  });
}

class DashboardMetrics {
  final int totalDop;
  final int approved;
  final int rejected;
  final int pendingLayer3;
  final int pendingLayer4;
  final int revisionRequired;
  final int incomplete;
  final int overdueTwo;
  final int overdueTwelve;

  const DashboardMetrics({
    required this.totalDop,
    required this.approved,
    required this.rejected,
    required this.pendingLayer3,
    required this.pendingLayer4,
    required this.revisionRequired,
    required this.incomplete,
    required this.overdueTwo,
    required this.overdueTwelve,
  });

  double get approvalRate {
    if (totalDop == 0) {
      return 0;
    }

    return approved / totalDop * 100;
  }

  factory DashboardMetrics.empty() {
    return const DashboardMetrics(
      totalDop: 0,
      approved: 0,
      rejected: 0,
      pendingLayer3: 0,
      pendingLayer4: 0,
      revisionRequired: 0,
      incomplete: 0,
      overdueTwo: 0,
      overdueTwelve: 0,
    );
  }
}

class DashboardCalculation {
  final DashboardMetrics metrics;
  final Map<String, DopListItemModel>
  uniqueDopItems;
  final List<DashboardComplianceRow>
  complianceRows;

  const DashboardCalculation({
    required this.metrics,
    required this.uniqueDopItems,
    required this.complianceRows,
  });

  factory DashboardCalculation.calculate({
    required List<DopListItemModel> dopItems,
    required DateTime now,
  }) {
    final uniqueDopItems =
    <String, DopListItemModel>{};

    for (final item in dopItems) {
      uniqueDopItems[item.dopHeaderId] = item;
    }

    var approved = 0;
    var rejected = 0;
    var pendingLayer3 = 0;
    var pendingLayer4 = 0;
    var revisionRequired = 0;
    var incomplete = 0;
    var overdueTwo = 0;
    var overdueTwelve = 0;

    final complianceCounters =
    <String, DashboardComplianceCounter>{};

    for (final item in uniqueDopItems.values) {
      final status = item.status;

      if (status == 'approved') {
        approved++;
      }

      if (status == 'rejected') {
        rejected++;
      }

      if (status == 'pending_layer_3') {
        pendingLayer3++;
      }

      if (status == 'pending_layer_4') {
        pendingLayer4++;
      }

      if (status == 'revision_required') {
        revisionRequired++;
      }

      if (status == 'pending_layer_3' ||
          status == 'pending_layer_4' ||
          status == 'revision_required') {
        incomplete++;
      }

      if (status == 'rejected') {
        continue;
      }

      final submittedAt = item.submittedAt;

      if (submittedAt == null) {
        continue;
      }

      final submittedLocal =
      submittedAt.toLocal();

      final benchmark = DateTime(
        submittedLocal.year,
        submittedLocal.month,
        submittedLocal.day,
        16,
      );

      var calculationTime = now;

      if (status == 'approved') {
        final approvedAt = item.approvedAt;

        if (approvedAt == null) {
          continue;
        }

        calculationTime = approvedAt.toLocal();
      }

      final duration =
      calculationTime.difference(
        benchmark,
      );

      final companyName =
      item.companyName.trim();

      if (companyName.isEmpty ||
          companyName == '-') {
        continue;
      }

      final counter =
      complianceCounters.putIfAbsent(
        companyName,
        DashboardComplianceCounter.new,
      );

      if (duration >
          const Duration(hours: 12)) {
        overdueTwelve++;
        counter.overdueTwelve++;
        continue;
      }

      if (duration >
          const Duration(hours: 2)) {
        overdueTwo++;
        counter.overdueTwo++;
        continue;
      }

      counter.comply++;
    }

    final companyNames =
    complianceCounters.keys.toList();

    companyNames.sort();

    final complianceRows =
    <DashboardComplianceRow>[];

    for (final companyName in companyNames) {
      final counter =
      complianceCounters[companyName]!;

      complianceRows.add(
        DashboardComplianceRow(
          companyName: companyName,
          comply: counter.comply,
          overdueTwo: counter.overdueTwo,
          overdueTwelve:
          counter.overdueTwelve,
        ),
      );
    }

    final metrics = DashboardMetrics(
      totalDop: uniqueDopItems.length,
      approved: approved,
      rejected: rejected,
      pendingLayer3: pendingLayer3,
      pendingLayer4: pendingLayer4,
      revisionRequired: revisionRequired,
      incomplete: incomplete,
      overdueTwo: overdueTwo,
      overdueTwelve: overdueTwelve,
    );

    return DashboardCalculation(
      metrics: metrics,
      uniqueDopItems: uniqueDopItems,
      complianceRows: complianceRows,
    );
  }
}

class DashboardTransportAreaCalculation {
  final List<DashboardTransportAreaRow>
  jalanNegaraRows;

  final List<DashboardTransportAreaRow>
  siteRows;

  const DashboardTransportAreaCalculation({
    required this.jalanNegaraRows,
    required this.siteRows,
  });

  factory DashboardTransportAreaCalculation.calculate({
    required List<DopListItemModel> dopItems,
  }) {
    final jalanNegaraRows =
    _buildRowsByArea(
      dopItems: dopItems,
      areaType: 'jalan_negara',
    );

    final siteRows =
    _buildRowsByArea(
      dopItems: dopItems,
      areaType: 'site',
    );

    return DashboardTransportAreaCalculation(
      jalanNegaraRows: jalanNegaraRows,
      siteRows: siteRows,
    );
  }

  static List<DashboardTransportAreaRow>
  _buildRowsByArea({
    required List<DopListItemModel> dopItems,
    required String areaType,
  }) {
    final companyCounters =
    <String, DashboardTransportAreaCounter>{};

    for (final item in dopItems) {
      final normalizedAreaType =
      item.areaType.trim().toLowerCase();

      if (normalizedAreaType != areaType) {
        continue;
      }

      final companyName =
      item.companyName.trim();

      if (companyName.isEmpty ||
          companyName == '-') {
        continue;
      }

      final unitType =
      item.unitType.trim().toUpperCase();

      var counter =
      companyCounters[companyName];

      if (counter == null) {
        counter =
            DashboardTransportAreaCounter();

        companyCounters[companyName] =
            counter;
      }

      if (unitType == 'BUS') {
        counter.massal++;
        continue;
      }

      if (unitType == 'LV') {
        counter.nonMassal++;
      }
    }

    final companyNames =
    companyCounters.keys.toList();

    companyNames.sort();

    final rows =
    <DashboardTransportAreaRow>[];

    for (final companyName in companyNames) {
      final counter =
      companyCounters[companyName];

      if (counter == null) {
        continue;
      }

      rows.add(
        DashboardTransportAreaRow(
          companyName: companyName,
          massal: counter.massal,
          nonMassal: counter.nonMassal,
        ),
      );
    }

    return rows;
  }
}