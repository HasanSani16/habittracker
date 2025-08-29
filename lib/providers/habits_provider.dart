import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';

class HabitsProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService.instance;
  final String uid;

  List<Habit> _habits = [];
  bool _loading = false;

  HabitsProvider(this.uid) {
    _subscribe();
  }

  List<Habit> get habits => _habits;
  bool get isLoading => _loading;

  void _subscribe() {
    _db.watchHabits(uid).listen((items) {
      _habits = items;
      notifyListeners();
    });
  }

  Future<void> createHabit({
    required String title,
    required String category,
    required HabitFrequency frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final id = const Uuid().v4();
      final habit = Habit(
        id: id,
        title: title,
        category: category,
        frequency: frequency,
        createdAt: DateTime.now(),
        startDate: startDate,
        notes: notes,
      );
      await _db.createHabit(uid, habit);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(uid, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(uid, id);
  }

  Future<void> toggleCompletion(Habit habit, DateTime date, bool completed) async {
    await _db.toggleCompletion(uid: uid, habit: habit, date: date, completed: completed);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}


