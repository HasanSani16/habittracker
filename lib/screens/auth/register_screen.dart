import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  String? _gender;
  DateTime? _dob;
  bool _agree = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('Join Habit Tracker', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Display name required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  final value = v ?? '';
                  final hasUpper = value.contains(RegExp(r'[A-Z]'));
                  final hasLower = value.contains(RegExp(r'[a-z]'));
                  final hasDigit = value.contains(RegExp(r'\d'));
                  if (value.length < 8 || !hasUpper || !hasLower || !hasDigit) {
                    return 'Min 8 chars with upper, lower, number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender (optional)'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(_dob == null ? 'Date of Birth (optional)' : _dob!.toIso8601String().substring(0, 10)),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(now.year - 18, now.month, now.day),
                          firstDate: DateTime(now.year - 100),
                          lastDate: now,
                        );
                        if (picked != null) setState(() => _dob = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height in cm (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
                  const Expanded(child: Text('I agree to the Terms & Conditions')),
                ],
              ),
              if (auth.error != null) Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (!_agree) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to Terms & Conditions')));
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          await auth.register(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            displayName: _displayNameController.text.trim(),
                            gender: _gender,
                            dateOfBirth: _dob,
                            heightCm: _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
                          );
                          if (auth.error == null && mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                child: auth.isLoading ? const CircularProgressIndicator() : const Text('Create Account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


