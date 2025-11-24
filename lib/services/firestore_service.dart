import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';
import '../models/day_model.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<List<Schedule>> getSchedules(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('schedules').get();
    return snapshot.docs.map((doc) => Schedule.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Day>> getDays(String userId, String weekId) async {
    // Note: The `days` collection in Firestore is not ideal. 
    // It's better to store days as a map within the week document itself.
    // However, to match the requested JSON structure, we query the subcollection.
    final scheduleDoc = await _db.collection('users').doc(userId).collection('schedules').doc(weekId).get();
    
    if (!scheduleDoc.exists || scheduleDoc.data() == null || scheduleDoc.data()!['days'] == null) {
      return []; // Return empty if the structure is not as expected.
    }

    final daysData = scheduleDoc.data()!['days'] as Map<String, dynamic>;
    List<Day> days = [];

    daysData.forEach((dayId, dayData) {
      try {
        if (dayData is Map<String, dynamic>) {
          days.add(Day.fromMap(dayId, dayData));
        }
      } catch (e, s) {
        developer.log(
          'Error parsing day document $dayId in week $weekId for user $userId. Skipping.',
          name: 'FirestoreService.getDays',
          error: e,
          stackTrace: s,
          level: 1000, // Severe
        );
      }
    });
    
    // Sort days chronologically just in case they are not ordered in the map.
    days.sort((a, b) => a.date.compareTo(b.date));
    
    return days;
  }

  Future<void> updateTaskCompletion(String userId, String weekId, String dayId, String taskId, bool isCompleted) async {
    final weekDocRef = _db.collection('users').doc(userId).collection('schedules').doc(weekId);

    return _db.runTransaction((transaction) async {
      final weekDoc = await transaction.get(weekDocRef);

      if (!weekDoc.exists) {
        throw Exception("Schedule document not found!");
      }

      final weekData = weekDoc.data();
      if (weekData == null) {
        throw Exception("Schedule data is null!");
      }

      // --- 1. Locate the Task and Get its Data ---
      final days = Map<String, dynamic>.from(weekData['days'] ?? {});
      final dayData = Map<String, dynamic>.from(days[dayId] ?? {});
      final segments = List<Map<String, dynamic>>.from(dayData['segments'] ?? []);
      
      final taskIndex = segments.indexWhere((task) {
        // Recreate the task ID to find the correct index
        final datePart = dayId;
        final indexPart = segments.indexOf(task);
        return '$datePart-$indexPart' == taskId;
      });

      if (taskIndex == -1) {
        throw Exception("Task with ID $taskId not found in day $dayId.");
      }

      final taskData = segments[taskIndex];
      final double plannedHours = (taskData['planned'] as num?)?.toDouble() ?? 0.0;
      final String mainCategory = taskData['category'] as String? ?? '';
      final String subCategory = taskData['subcategory'] as String? ?? '';

      // Determine the change in actual hours
      final double changeInHours = isCompleted ? plannedHours : -plannedHours;

      // --- 2. Prepare the updates using dot notation for nested fields ---
      final Map<String, dynamic> updates = {};

      // Update the specific segment
      updates['days.$dayId.segments.$taskIndex.isCompleted'] = isCompleted;
      updates['days.$dayId.segments.$taskIndex.actual'] = isCompleted ? plannedHours : 0.0;

      // Update the week summary
      if (mainCategory.isNotEmpty) {
        updates['weekSummary.actual.$mainCategory'] = FieldValue.increment(changeInHours);
      }
      
      // Update the category summary
      if (subCategory.isNotEmpty) {
        updates['categoriesSummary.$subCategory.actual'] = FieldValue.increment(changeInHours);
      }

      // --- 3. Perform the atomic update ---
      transaction.update(weekDocRef, updates);
    });
  }
}
