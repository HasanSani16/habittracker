import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('Sign in to continue', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
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
                validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 characters',
              ),
              const SizedBox(height: 16),
              if (auth.error != null) Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await auth.login(email: _emailController.text.trim(), password: _passwordController.text);
                        }
                      },
                child: auth.isLoading ? const CircularProgressIndicator() : const Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                child: const Text('Create an account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


