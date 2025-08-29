import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      _displayNameController.text = (data['displayName'] ?? '') as String;
      _gender = data['gender'] as String?;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 36, backgroundColor: Colors.white24, child: const Icon(Icons.person, color: Colors.white, size: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? '', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(_displayNameController.text.isEmpty ? 'Your Name' : _displayNameController.text,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Consumer<ThemeProvider>(
                        builder: (context, theme, _) => SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: theme.mode == ThemeMode.dark,
                          onChanged: (v) => theme.toggle(v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(labelText: 'Display Name'),
                            validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: user.email ?? '',
                            decoration: const InputDecoration(labelText: 'Email'),
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                            'displayName': _displayNameController.text.trim(),
                            'gender': _gender,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                          }
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


