
class Day {
  final String id;
  final String day;
  final List<Segment> segments;

  Day({required this.id, required this.day, required this.segments});

  factory Day.fromMap(String id, Map<String, dynamic> data) {
    return Day(
      id: id,
      day: data['day'] ?? '',
      segments: (data['segments'] as List<dynamic>? ?? [])
          .map((segment) => Segment.fromMap(segment as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Segment {
  final String start;
  final String end;
  final String activity;
  final String category;
  final String subcategory;
  final double planned;
  double actual;

  Segment({
    required this.start,
    required this.end,
    required this.activity,
    required this.category,
    required this.subcategory,
    required this.planned,
    required this.actual,
  });

  factory Segment.fromMap(Map<String, dynamic> data) {
    return Segment(
      start: data['start'] ?? '',
      end: data['end'] ?? '',
      activity: data['activity'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      planned: (data['planned'] ?? 0).toDouble(),
      actual: (data['actual'] ?? 0).toDouble(),
    );
  }
}
