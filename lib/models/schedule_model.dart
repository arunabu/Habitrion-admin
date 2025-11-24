
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
    return Schedule(
      id: id,
      weekSummary: WeekSummary.fromMap(data['weekSummary'] ?? {}),
      categoriesSummary: (data['categoriesSummary'] as Map<String, dynamic> ?? {})
          .map((key, value) => MapEntry(key, CategorySummary.fromMap(value))),
    );
  }
}

class WeekSummary {
  final PlannedActual planned;
  final PlannedActual actual;

  WeekSummary({required this.planned, required this.actual});

  factory WeekSummary.fromMap(Map<String, dynamic> data) {
    return WeekSummary(
      planned: PlannedActual.fromMap(data['planned'] ?? {}),
      actual: PlannedActual.fromMap(data['actual'] ?? {}),
    );
  }
}

class CategorySummary {
  final double planned;
  final double actual;

  CategorySummary({required this.planned, required this.actual});

  factory CategorySummary.fromMap(Map<String, dynamic> data) {
    return CategorySummary(
      planned: (data['planned'] ?? 0).toDouble(),
      actual: (data['actual'] ?? 0).toDouble(),
    );
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
      learning: (data['learning'] ?? 0).toDouble(),
      office: (data['office'] ?? 0).toDouble(),
      sideHustle: (data['side_hustle'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }
}
