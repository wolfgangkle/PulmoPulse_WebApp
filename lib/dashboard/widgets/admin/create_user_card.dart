import 'dart:ui';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 24),

              // Email TextField
              _glassTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password TextField
              _glassTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    dropdownColor: Colors.white.withOpacity(0.15),
                    items: const [
                      DropdownMenuItem(value: 'clinician', child: Text('Clinician', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Create User Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createUser,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    elevation: 0,
                  ),
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Error') ? Colors.redAccent : Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      cursorColor: Colors.white,
    );
  }
}
