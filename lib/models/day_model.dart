
import 'package:flutter/foundation.dart';

class Day {
  final String id;
  final List<Task> segments;

  Day({required this.id, required this.segments});

  factory Day.fromMap(String id, Map<String, dynamic> data) {
    final segmentsData = data['segments'] as List<dynamic>? ?? [];
    final segments = segmentsData
        .asMap()
        .entries
        .map((entry) {
          return Task.fromMap('$id-${entry.key}', entry.value as Map<String, dynamic>);
        })
        .toList();

    return Day(id: id, segments: segments);
  }
}

class Task {
  final String id;
  final String activity; // Renamed from title
  final String start;    // Renamed from startTime
  final String end;      // Renamed from endTime
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
    required this.isCompleted,
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      activity: data['activity'] ?? '',         // Read 'activity' from map
      start: data['start'] ?? '',             // Read 'start' from map
      end: data['end'] ?? '',                 // Read 'end' from map
      category: data['category'] ?? 'Uncategorized',
      subcategory: data['subcategory'] ?? 'Uncategorized',
      planned: (data['planned'] as num?)?.toDouble() ?? 0.0,
      actual: (data['actual'] as num?)?.toDouble() ?? 0.0,
      isCompleted: data['isCompleted'] ?? false,
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
