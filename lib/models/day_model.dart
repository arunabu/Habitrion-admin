
import 'dart:developer' as developer;

class Day {
  final String id;
  final DateTime date;
  final List<Task> tasks;

  Day({required this.id, required this.date, required this.tasks});

  // The `weekId` parameter is no longer needed. The `id` is the date string.
  factory Day.fromMap(String id, Map<String, dynamic> data) {
    List<Task> parsedTasks = [];
    var segmentsData = data['segments'];
    if (segmentsData is List) {
      for (var entry in segmentsData.asMap().entries) {
        final index = entry.key;
        final segmentData = entry.value;
        try {
          if (segmentData is Map<String, dynamic>) {
            // Use the date and index to create a unique task ID
            final taskId = '$id-$index'; 
            parsedTasks.add(Task.fromMap(taskId, segmentData));
          } else {
            developer.log(
              'Invalid segment data format in day $id. Expected a map, but got ${segmentData.runtimeType}.',
              name: 'Day.fromMap',
              level: 900, // Warning
            );
          }
        } catch (e, s) {
          developer.log(
            'Error parsing a segment in day $id.',
            name: 'Day.fromMap',
            error: e,
            stackTrace: s,
            level: 1000, // Severe
          );
        }
      }
    }

    return Day(
      id: id,
      // CORRECTED LOGIC: Directly parse the ID which is the date string.
      date: DateTime.parse(id),
      tasks: parsedTasks,
    );
  }

  // The entire `parseDate` function was incorrect and has been removed.
}

class Task {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String category;
  final List<String> tags;
  final double planned;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.tags,
    required this.planned,
    this.isCompleted = false,
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    double safeParseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    List<String> parseTags(dynamic subcategory) {
        if (subcategory is String && subcategory.isNotEmpty) {
            return [subcategory];
        }
        return [];
    }

    return Task(
      id: id,
      title: data['activity'] as String? ?? '',
      startTime: data['start'] as String? ?? '',
      endTime: data['end'] as String? ?? '',
      category: data['category'] as String? ?? '',
      tags: parseTags(data['subcategory']),
      planned: safeParseDouble(data['planned']),
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity': title,
      'start': startTime,
      'end': endTime,
      'category': category,
      'subcategory': tags.isNotEmpty ? tags.first : '',
      'planned': planned,
      'isCompleted': isCompleted,
    };
  }
}
