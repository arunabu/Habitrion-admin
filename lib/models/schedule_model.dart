import 'dart:developer' as developer;

// Helper to safely parse a double from various numeric types
double _safeParseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class Schedule {
  final String id;
  final WeekSummary weekSummary;
  final Map<String, CategorySummary> categoriesSummary;

  Schedule({
    required this.id,
    required this.weekSummary,
    required this.categoriesSummary,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    var summaryData = data['weekSummary'];
    var categoriesData = data['categoriesSummary'];

    return Schedule(
      id: id,
      weekSummary: summaryData is Map<String, dynamic>
          ? WeekSummary.fromMap(summaryData)
          : WeekSummary.empty(), // Use an empty summary if data is invalid
      categoriesSummary: categoriesData is Map<String, dynamic>
          ? categoriesData.map((key, value) {
              if (value is Map<String, dynamic>) {
                return MapEntry(key, CategorySummary.fromMap(value));
              }
              // Log error and skip invalid entry
              developer.log(
                'Invalid data for category summary for key: $key in schedule: $id',
                name: 'Schedule.fromMap',
                level: 900,
              );
              return MapEntry(key, CategorySummary.empty());
            })
          : {},
    );
  }
}

class WeekSummary {
  final PlannedActual planned;
  final PlannedActual actual;

  WeekSummary({required this.planned, required this.actual});

  factory WeekSummary.fromMap(Map<String, dynamic> data) {
    var plannedData = data['planned'];
    var actualData = data['actual'];

    return WeekSummary(
      planned: plannedData is Map<String, dynamic>
          ? PlannedActual.fromMap(plannedData)
          : PlannedActual.empty(),
      actual: actualData is Map<String, dynamic>
          ? PlannedActual.fromMap(actualData)
          : PlannedActual.empty(),
    );
  }

  factory WeekSummary.empty() {
    return WeekSummary(planned: PlannedActual.empty(), actual: PlannedActual.empty());
  }
}

class CategorySummary {
  final double planned;
  final double actual;

  CategorySummary({required this.planned, required this.actual});

  factory CategorySummary.fromMap(Map<String, dynamic> data) {
    return CategorySummary(
      planned: _safeParseDouble(data['planned']),
      actual: _safeParseDouble(data['actual']),
    );
  }

  factory CategorySummary.empty() {
    return CategorySummary(planned: 0.0, actual: 0.0);
  }
}

class PlannedActual {
  final double learning;
  final double office;
  final double sideHustle;
  final double balance;

  PlannedActual({
    required this.learning,
    required this.office,
    required this.sideHustle,
    required this.balance,
  });

  factory PlannedActual.fromMap(Map<String, dynamic> data) {
    return PlannedActual(
      learning: _safeParseDouble(data['learning']),
      office: _safeParseDouble(data['office']),
      sideHustle: _safeParseDouble(data['side_hustle']),
      balance: _safeParseDouble(data['balance']),
    );
  }

  factory PlannedActual.empty() {
    return PlannedActual(learning: 0.0, office: 0.0, sideHustle: 0.0, balance: 0.0);
  }
}
