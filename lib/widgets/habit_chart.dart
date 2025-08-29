import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class HabitCompletionChart extends StatelessWidget {
  final List<Habit> habits;
  const HabitCompletionChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i)));
    final values = days
        .map((d) => habits
            .where((h) => h.completionHistory.any((c) => c.year == d.year && c.month == d.month && c.day == d.day))
            .length
            .toDouble())
        .toList();
    final maxY = (values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b)).clamp(1.0, double.infinity);

    return SizedBox(
      height: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY + 1,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                      return Text(DateFormat('E').format(days[idx]));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(values.length, (i) {
                return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: values[i], color: Theme.of(context).colorScheme.primary)]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}


