
import 'package:flutter/foundation.dart';

class Day {
  final String id;
  final List<Task> segments;

  Day({required this.id, required this.segments});

  factory Day.fromMap(String id, Map<String, dynamic> data) {
    final segmentsData = data['segments'];
    List<Task> segments = [];

    if (segmentsData is List) {
      segments = segmentsData
          .asMap()
          .entries
          .map((entry) {
            final segmentData = entry.value;
            if (segmentData is Map<String, dynamic>) {
              return Task.fromMap('$id-${entry.key}', segmentData);
            } else {
              // Handle cases where a segment is not a valid map
              return null;
            }
          })
          .where((task) => task != null) // Filter out null tasks
          .cast<Task>()
          .toList();
    }

    return Day(id: id, segments: segments);
  }
}

class Task {
  final String id;
  final String activity;
  final String start;
  final String end;
  final String category;
  final String subcategory;
  final double planned;
  final double actual;
  final bool isCompleted;

  Task({
    required this.id,
    required this.activity,
    required this.start,
    required this.end,
    required this.category,
    required this.subcategory,
    required this.planned,
    required this.actual,
    this.isCompleted = false, // is completed variable is optional
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      activity: data['activity'] as String? ?? '',
      start: data['start'] as String? ?? '',
      end: data['end'] as String? ?? '',
      category: data['category'] as String? ?? 'Uncategorized',
      subcategory: data['subcategory'] as String? ?? 'Uncategorized',
      planned: (data['planned'] as num?)?.toDouble() ?? 0.0,
      actual: (data['actual'] as num?)?.toDouble() ?? 0.0,
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
