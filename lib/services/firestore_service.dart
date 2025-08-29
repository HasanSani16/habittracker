import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _habitsRef(String uid) =>
      _db.collection('users').doc(uid).collection('habits');

  Future<void> createHabit(String uid, Habit habit) async {
    await _habitsRef(uid).doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    await _habitsRef(uid).doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await _habitsRef(uid).doc(habitId).delete();
  }

  Stream<List<Habit>> watchHabits(String uid) {
    return _habitsRef(uid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Habit.fromDoc(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> toggleCompletion({
    required String uid,
    required Habit habit,
    required DateTime date,
    required bool completed,
  }) async {
    final history = List<DateTime>.from(habit.completionHistory);
    final normalized = DateTime(date.year, date.month, date.day);
    final contains = history.any((d) => _isSameDay(d, normalized));
    if (completed && !contains) {
      history.add(normalized);
    } else if (!completed && contains) {
      history.removeWhere((d) => _isSameDay(d, normalized));
    }
    final updated = habit.copyWith(
      completionHistory: history,
      currentStreak: _calculateStreak(habit.frequency, history),
    );
    await updateHabit(uid, updated);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _calculateStreak(HabitFrequency frequency, List<DateTime> history) {
    if (history.isEmpty) return 0;
    history.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime cursor = _truncate(DateTime.now());
    for (;;) {
      final expected = frequency == HabitFrequency.daily
          ? cursor
          : _startOfWeek(cursor);
      final match = history.any((d) =>
          frequency == HabitFrequency.daily
              ? _isSameDay(d, expected)
              : _isSameWeek(d, expected));
      if (match) {
        streak++;
        cursor = frequency == HabitFrequency.daily
            ? cursor.subtract(const Duration(days: 1))
            : cursor.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }

  DateTime _truncate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _startOfWeek(DateTime d) {
    // ISO week: Monday as start
    final weekday = d.weekday; // 1..7
    return _truncate(d.subtract(Duration(days: weekday - 1)));
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    return _startOfWeek(a) == _startOfWeek(b);
  }
}


