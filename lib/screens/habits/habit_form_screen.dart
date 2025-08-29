import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habits_provider.dart';
import '../../models/habit.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _category = 'Health';
  HabitFrequency _frequency = HabitFrequency.daily;
  DateTime? _startDate;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Health', child: Text('Health')),
                  DropdownMenuItem(value: 'Study', child: Text('Study')),
                  DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                  DropdownMenuItem(value: 'Productivity', child: Text('Productivity')),
                  DropdownMenuItem(value: 'Mental Health', child: Text('Mental Health')),
                  DropdownMenuItem(value: 'Others', child: Text('Others')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Others'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HabitFrequency>(
                value: _frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: const [
                  DropdownMenuItem(value: HabitFrequency.daily, child: Text('Daily')),
                  DropdownMenuItem(value: HabitFrequency.weekly, child: Text('Weekly')),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? HabitFrequency.daily),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Start Date: '),
                  Text(_startDate == null ? 'Not set' : _startDate!.toIso8601String().substring(0, 10)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: const Text('Pick'),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await provider.createHabit(
                            title: _titleController.text.trim(),
                            category: _category,
                            frequency: _frequency,
                            startDate: _startDate,
                            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                          );
                          if (mounted) Navigator.of(context).pop();
                        }
                      },
                child: provider.isLoading ? const CircularProgressIndicator() : const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


