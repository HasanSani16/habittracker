import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/habits_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<app_auth.AuthProvider>().firebaseUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());
    return ChangeNotifierProvider(create: (_) => HabitsProvider(uid), child: const _AnalyticsBody());
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsProvider>().habits;
    final categoryToCount = <String, int>{};
    for (final h in habits) {
      categoryToCount[h.category] = (categoryToCount[h.category] ?? 0) + 1;
    }
    final sections = categoryToCount.entries
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              title: e.key,
              radius: 60,
            ))
        .toList();

    final today = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i)));
    final values = days
        .map((d) => habits
            .where((h) => h.completionHistory.any((c) => c.year == d.year && c.month == d.month && c.day == d.day))
            .length
            .toDouble())
        .toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ]),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Week', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text('Completed habits per day', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: BarChart(BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                            const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Text(labels[idx], style: const TextStyle(color: Colors.white));
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(values.length, (i) =>
                        BarChartGroupData(x: i, barRods: [BarChartRodData(toY: values[i], color: Colors.white, width: 12)])),
                  )),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('Count of completed habits each day', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: sections)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categoryToCount.keys.map((k) => Chip(label: Text(k))).toList(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


