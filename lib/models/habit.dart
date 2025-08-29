import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitFrequency { daily, weekly }

class Habit {
  final String id;
  final String title;
  final String category; // Health, Study, Fitness, Productivity, Mental Health, Others
  final HabitFrequency frequency;
  final DateTime createdAt;
  final DateTime? startDate;
  final int currentStreak;
  final List<DateTime> completionHistory; // store dates completed
  final String? notes;

  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    required this.createdAt,
    this.startDate,
    this.currentStreak = 0,
    this.completionHistory = const [],
    this.notes,
  });

  Habit copyWith({
    String? title,
    String? category,
    HabitFrequency? frequency,
    DateTime? startDate,
    int? currentStreak,
    List<DateTime>? completionHistory,
    String? notes,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      currentStreak: currentStreak ?? this.currentStreak,
      completionHistory: completionHistory ?? this.completionHistory,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'frequency': frequency.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'notes': notes,
    };
  }

  factory Habit.fromDoc(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final List<dynamic> historyRaw = (data['completionHistory'] as List<dynamic>? ?? []);
    return Habit(
      id: id,
      title: (data['title'] ?? '') as String,
      category: (data['category'] ?? 'Others') as String,
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == (data['frequency'] ?? 'daily'),
        orElse: () => HabitFrequency.daily,
      ),
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
      startDate: (data['startDate'] != null)
          ? DateTime.tryParse(data['startDate'] as String)
          : null,
      currentStreak: (data['currentStreak'] as int?) ?? 0,
      completionHistory: historyRaw
          .map((e) => DateTime.tryParse(e.toString()))
          .whereType<DateTime>()
          .toList(),
      notes: data['notes'] as String?,
    );
  }
}


