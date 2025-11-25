import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/day_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Schedule>> getSchedules(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .get();

      if (snapshot.docs.isEmpty) {
        developer.log('No schedules found for user $userId.',
            name: 'FirestoreService.getSchedules');
        return [];
      }

      return snapshot.docs
          .map((doc) => Schedule.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      developer.log(
        'Error fetching schedules for user $userId.',
        name: 'FirestoreService.getSchedules',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
      );
      rethrow;
    }
  }

  Future<List<Day>> getDays(String userId, String weekId) async {
    try {
      final daysCollectionRef = _db
          .collection('users')
          .doc(userId)
          .collection('schedules')
          .doc(weekId)
          .collection('days');

      final querySnapshot = await daysCollectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        developer.log(
          'No documents found in the days subcollection for week $weekId.',
          name: 'FirestoreService.getDays',
        );
        return [];
      }

      final days = querySnapshot.docs.map((doc) {
        return Day.fromMap(doc.id, doc.data());
      }).toList();

      return days;
    } catch (e, s) {
      developer.log(
        'Error fetching days for week $weekId.',
        name: 'FirestoreService.getDays',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> updateTaskActual(String userId, String weekId, String dayId,
      String taskId, double additionalHours, double planned) async {
    final weekDocRef =
        _db.collection('users').doc(userId).collection('schedules').doc(weekId);
    final dayDocRef = weekDocRef.collection('days').doc(dayId);

    try {
      await _db.runTransaction((transaction) async {
        final dayDocSnapshot = await transaction.get(dayDocRef);

        if (!dayDocSnapshot.exists) {
          throw Exception("Day document $dayId not found!");
        }

        final segments = List<Map<String, dynamic>>.from(
            dayDocSnapshot.data()!['segments'] ?? []);
        final taskIndexStr = taskId.split('-').last;
        final taskIndex = int.tryParse(taskIndexStr);

        if (taskIndex == null ||
            taskIndex < 0 ||
            taskIndex >= segments.length) {
          throw Exception(
              "Task with ID $taskId not found or has invalid index.");
        }

        final currentActual = (segments[taskIndex]['actual'] as num).toDouble();
        final newActual = currentActual + additionalHours;

        segments[taskIndex]['actual'] = newActual;
        segments[taskIndex]['isCompleted'] = newActual >= planned;

        transaction.update(dayDocRef, {'segments': segments});
      });

      final daysSnapshot = await weekDocRef.collection('days').get();

      final allTasks = daysSnapshot.docs.expand((dayDoc) {
        final currentDayId = dayDoc.id;
        final daySegments = List<dynamic>.from(dayDoc.data()['segments'] ?? []);

        return daySegments.asMap().entries.map((entry) {
          final index = entry.key;
          final segmentMap = entry.value as Map<String, dynamic>;
          final constructedTaskId = '$currentDayId-$index';
          return Task.fromMap(constructedTaskId, segmentMap);
        });
      }).toList();

      final newCategoriesSummary = <String, Map<String, double>>{
        'planned': {},
        'actual': {}
      };
      final newSubcategoriesSummary = <String, Map<String, double>>{};

      for (var task in allTasks) {
        final category =
            task.category.isNotEmpty ? task.category : 'Uncategorized';
        final subcategory =
            task.subcategory.isNotEmpty ? task.subcategory : 'Uncategorized';

        newCategoriesSummary['planned']!.update(
            category, (v) => v + task.planned,
            ifAbsent: () => task.planned);
        newCategoriesSummary['actual']!.update(category, (v) => v + task.actual,
            ifAbsent: () => task.actual);

        newSubcategoriesSummary.putIfAbsent(
            subcategory, () => {'planned': 0.0, 'actual': 0.0});
        newSubcategoriesSummary[subcategory]!['planned'] =
            (newSubcategoriesSummary[subcategory]!['planned'] ?? 0) +
                task.planned;
        newSubcategoriesSummary[subcategory]!['actual'] =
            (newSubcategoriesSummary[subcategory]!['actual'] ?? 0) +
                task.actual;
      }

      await weekDocRef.update({
        'categoriesSummary': newCategoriesSummary,
        'subcategoriesSummary': newSubcategoriesSummary,
      });

      developer.log('Task and summaries updated successfully!',
          name: 'FirestoreService.updateTaskActual');
    } catch (e, s) {
      developer.log(
        'Failed to update task and summaries.',
        name: 'FirestoreService.updateTaskActual',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> importNextWeeksTasks(String userId) async {
    try {
      final jsonString = await rootBundle.loadString('nextweekstask.json');
      final jsonData = json.decode(jsonString); // Decode as dynamic
      developer.log('Loaded JSON data: ${json.encode(jsonData)}',
          name: 'Debug');

      final usersData = jsonData['users'];
      if (usersData == null || usersData is! Map) {
        developer.log('JSON Error: "users" node is missing or not a Map.',
            name: 'FirestoreService.importNextWeeksTasks', level: 1000);
        return;
      }

      final userDocData = usersData[userId];
      if (userDocData == null || userDocData is! Map) {
        developer.log(
            'JSON Error: Data for user "$userId" not found or is not a Map.',
            name: 'FirestoreService.importNextWeeksTasks',
            level: 1000);
        return;
      }

      final batch = _db.batch();
      final userDocRef = _db.collection('users').doc(userId);

      final userDocMap = Map<String, dynamic>.from(userDocData);

      // Set user profile and settings safely
      userDocRef.set({
        if (userDocMap['profile'] != null) 'profile': userDocMap['profile'],
        if (userDocMap['settings'] != null) 'settings': userDocMap['settings'],
      }, SetOptions(merge: true));

      final schedules = userDocMap['schedules'];
      if (schedules == null || schedules is! Map) {
        developer.log(
            'JSON Error: "schedules" for user "$userId" is missing or not a Map.',
            name: 'FirestoreService.importNextWeeksTasks',
            level: 1000);
        return;
      }

      // Process each schedule (week)
      for (final entry in (schedules as Map).entries) {
        final weekId = entry.key as String;
        final weekData = entry.value;
        if (weekData == null || weekData is! Map)
          continue; // Skip invalid week data

        final weekDocRef = userDocRef.collection('schedules').doc(weekId);
        final weekDataMap = Map<String, dynamic>.from(weekData);

        final days = weekDataMap.remove('days');
        batch.set(
            weekDocRef, weekDataMap); // Set schedule doc (summaries, etc.)

        if (days == null || days is! Map)
          continue; // Skip if no days or days is invalid

        // Process each day in the sub-collection
        for (final dayEntry in (days as Map).entries) {
          final dayId = dayEntry.key as String;
          final dayData = dayEntry.value;
          if (dayData == null || dayData is! Map)
            continue; // Skip invalid day data

          final dayDocRef = weekDocRef.collection('days').doc(dayId);
          batch.set(dayDocRef, Map<String, dynamic>.from(dayData));
        }
      }

      await batch.commit();
      developer.log('Successfully imported next week\'s tasks.',
          name: 'FirestoreService.importNextWeeksTasks');
    } catch (e, s) {
      developer.log(
        'Error importing tasks: ${e.toString()}',
        name: 'FirestoreService.importNextWeeksTasks',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }
}
