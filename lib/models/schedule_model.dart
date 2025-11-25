import 'package:myapp/models/day_model.dart';

class Schedule {
  final String id;
  final CategoriesSummary categoriesSummary;
  final Map<String, SubcategorySummary> subcategoriesSummary;
  final Map<String, Day> days;  // ← THIS IS REQUIRED!

  Schedule({
    required this.id,
    required this.categoriesSummary,
    required this.subcategoriesSummary,
    required this.days,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    // Safely get nested maps
    final catMap = data['categoriesSummary'] as Map<String, dynamic>? ?? {};
    final subcatMap = data['subcategoriesSummary'] as Map<String, dynamic>? ?? {};
    final daysMap = data['days'] as Map<String, dynamic>? ?? {};

    return Schedule(
      id: id,
      categoriesSummary: CategoriesSummary.fromMap(catMap),
      subcategoriesSummary: subcatMap.map(
        (key, value) => MapEntry(
          key,
          SubcategorySummary.fromMap(value as Map<String, dynamic>),
        ),
      ),
      days: daysMap.map(
        (dayId, dayData) => MapEntry(
          dayId,
          Day.fromMap(dayId, dayData as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class CategoriesSummary {
  final Map<String, double> planned;
  final Map<String, double> actual;

  CategoriesSummary({required this.planned, required this.actual});

  factory CategoriesSummary.fromMap(Map<String, dynamic> map) {
    final p = (map['planned'] as Map<String, dynamic>?) ?? {};
    final a = (map['actual'] as Map<String, dynamic>?) ?? {};

    return CategoriesSummary(
      planned: p.map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0)),
      actual: a.map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0)),
    );
  }
}

class SubcategorySummary {
  final double planned;
  final double actual;

  SubcategorySummary({required this.planned, required this.actual});

  factory SubcategorySummary.fromMap(Map<String, dynamic> map) {
    return SubcategorySummary(
      planned: (map['planned'] is num) ? (map['planned'] as num).toDouble() : 0.0,
      actual: (map['actual'] is num) ? (map['actual'] as num).toDouble() : 0.0,
    );
  }
}