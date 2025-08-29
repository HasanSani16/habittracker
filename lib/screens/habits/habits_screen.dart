import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habits_provider.dart';
import '../../models/habit.dart';
import 'habit_form_screen.dart';
import '../../widgets/habit_chart.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());
    return ChangeNotifierProvider(
      create: (_) => HabitsProvider(uid),
      child: const _HabitsBody(),
    );
  }
}

class _HabitsBody extends StatefulWidget {
  const _HabitsBody();

  @override
  State<_HabitsBody> createState() => _HabitsBodyState();
}

class _HabitsBodyState extends State<_HabitsBody> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final habits = provider.habits;
    final filtered = selectedCategory == null ? habits : habits.where((h) => h.category == selectedCategory).toList();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Habits', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Track, complete, and grow daily', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    selected: selectedCategory == null,
                    label: const Text('All'),
                    onSelected: (_) => setState(() => selectedCategory = null),
                  ),
                  for (final c in const ['Health', 'Study', 'Fitness', 'Productivity', 'Mental Health', 'Others'])
                    FilterChip(
                      selected: selectedCategory == c,
                      label: Text(c),
                      onSelected: (_) => setState(() => selectedCategory = c),
                    ),
                ],
              ),
            ),
            if (filtered.isNotEmpty)
              HabitCompletionChart(habits: filtered)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48),
                        const SizedBox(height: 8),
                        Text('No habits yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Tap + to create your first habit', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ...filtered.map((habit) {
              final now = DateTime.now();
              final completedToday = habit.completionHistory.any((d) => d.year == now.year && d.month == now.month && d.day == now.day);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: _categoryIcon(habit.category)),
                    title: Text(habit.title),
                    subtitle: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(label: Text(habit.category)),
                        Chip(label: Text(habit.frequency.name)),
                        Text('Streak: ${habit.currentStreak}'),
                      ],
                    ),
                    trailing: Checkbox(
                      value: completedToday,
                      onChanged: (v) => provider.toggleCompletion(habit, DateTime.now(), v ?? false),
                    ),
                    onLongPress: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete habit?'),
                          content: const Text('This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await provider.deleteHabit(habit.id);
                      }
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = context.read<HabitsProvider>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider<HabitsProvider>.value(
                value: provider,
                child: const HabitFormScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    switch (category) {
      case 'Health':
        return const Icon(Icons.favorite_outline);
      case 'Study':
        return const Icon(Icons.menu_book_outlined);
      case 'Fitness':
        return const Icon(Icons.fitness_center_outlined);
      case 'Productivity':
        return const Icon(Icons.task_alt_outlined);
      case 'Mental Health':
        return const Icon(Icons.self_improvement_outlined);
      default:
        return const Icon(Icons.category_outlined);
    }
  }
}


