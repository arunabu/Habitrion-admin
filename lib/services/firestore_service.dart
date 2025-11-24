
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';
import '../models/day_model.dart';

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
    final snapshot = await _db.collection('users').doc(userId).collection('schedules').doc(weekId).collection('days').get();
    return snapshot.docs.map((doc) => Day.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> updateTaskActual(String userId, String weekId, String dayId, int segmentIndex, double actual) async {
    final dayDocRef = _db.collection('users').doc(userId).collection('schedules').doc(weekId).collection('days').doc(dayId);

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(dayDocRef);
      if (!snapshot.exists) {
        throw Exception("Day document does not exist!");
      }

      final day = Day.fromMap(snapshot.id, snapshot.data()!);
      final segments = day.segments;

      if (segmentIndex < 0 || segmentIndex >= segments.length) {
        throw Exception("Segment index out of bounds");
      }

      segments[segmentIndex].actual = actual;

      transaction.update(dayDocRef, {
        'segments': segments.map((s) => {
          'start': s.start,
          'end': s.end,
          'activity': s.activity,
          'category': s.category,
          'subcategory': s.subcategory,
          'planned': s.planned,
          'actual': s.actual,
        }).toList(),
      });
    });
  }
}
