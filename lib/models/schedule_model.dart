
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
  final CategoriesSummary categoriesSummary;
  final Map<String, SubcategorySummary> subcategoriesSummary;

  Schedule({
    required this.id,
    required this.categoriesSummary,
    required this.subcategoriesSummary,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    var categoriesData = data['categoriesSummary'];
    var subcategoriesData = data['subcategoriesSummary'] as Map<String, dynamic>? ?? {};

    final subcategories = subcategoriesData.map(
      (key, value) => MapEntry(
        key,
        SubcategorySummary.fromMap(value as Map<String, dynamic>),
      ),
    );

    return Schedule(
      id: id,
      categoriesSummary: categoriesData is Map<String, dynamic>
          ? CategoriesSummary.fromMap(categoriesData)
          : CategoriesSummary(planned: {}, actual: {}),
      subcategoriesSummary: subcategories,
    );
  }
}

class CategoriesSummary {
  final Map<String, double> planned;
  final Map<String, double> actual;

  CategoriesSummary({required this.planned, required this.actual});

  factory CategoriesSummary.fromMap(Map<String, dynamic> data) {
    final plannedData = data['planned'] as Map<String, dynamic>? ?? {};
    final actualData = data['actual'] as Map<String, dynamic>? ?? {};

    return CategoriesSummary(
      planned: plannedData.map((key, value) => MapEntry(key, _safeParseDouble(value))),
      actual: actualData.map((key, value) => MapEntry(key, _safeParseDouble(value))),
    );
  }
}

class SubcategorySummary {
  final double planned;
  final double actual;

  SubcategorySummary({required this.planned, required this.actual});

  factory SubcategorySummary.fromMap(Map<String, dynamic> data) {
    return SubcategorySummary(
      planned: _safeParseDouble(data['planned']),
      actual: _safeParseDouble(data['actual']),
    );
  }
}
