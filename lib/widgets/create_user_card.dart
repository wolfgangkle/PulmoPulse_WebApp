import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseFunctions get functions => FirebaseFunctions.instanceFor(app: Firebase.app());


class CreateUserCard extends StatefulWidget {
  const CreateUserCard({super.key});

  @override
  State<CreateUserCard> createState() => _CreateUserCardState();
}

class _CreateUserCardState extends State<CreateUserCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'clinician';
  String? _statusMessage;

  Future<void> _createUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final role = _selectedRole;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _statusMessage = 'Please enter email and password.');
      return;
    }

    try {
      final app = Firebase.app(); // just for confirmation
      debugPrint('✅ Firebase app "${app.name}" is initialized');

      // 🔥 Correct way to get Functions (lazy)
      final functions = FirebaseFunctions.instanceFor(app: app);

      final function = functions.httpsCallable('createUserWithRole');

      final result = await function.call({
        'email': email,
        'password': password,
        'role': role,
      });

      setState(() {
        _statusMessage = 'User created: ${result.data['uid']}';
        _emailController.clear();
        _passwordController.clear();
        _selectedRole = 'clinician';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'clinician', child: Text('Clinician')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createUser,
              icon: const Icon(Icons.person_add),
              label: const Text('Create User'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Error') ? Colors.red : Colors.green,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
