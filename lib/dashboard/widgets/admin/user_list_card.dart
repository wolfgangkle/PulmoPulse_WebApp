import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserListCard extends StatefulWidget {
  const UserListCard({super.key});

  @override
  State<UserListCard> createState() => _UserListCardState();
}

class _UserListCardState extends State<UserListCard> {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  String? _status;

  Future<void> _changeRole(String uid, String newRole) async {
    setState(() => _status = 'Updating...');
    try {
      final function = FirebaseFunctions.instance.httpsCallable('updateUserRole');
      await function.call({'uid': uid, 'newRole': newRole});
      setState(() => _status = 'Role updated!');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Users',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _usersRef.orderBy('createdAt').snapshots().handleError((error) {
                  debugPrint('❌ Firestore stream error: $error');
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('⚠️ Firestore error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text('No users found.', style: TextStyle(color: Colors.white70));
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final uid = doc.id;
                      final email = data['email'] ?? '–';
                      final role = data['role'] ?? 'unknown';

                      return ListTile(
                        title: Text(email, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Role: $role', style: const TextStyle(color: Colors.white70)),
                        trailing: _glassDropdown(
                          value: role,
                          onChanged: (newRole) {
                            if (newRole != null && newRole != role) {
                              _changeRole(uid, newRole);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (_status != null) ...[
                const SizedBox(height: 16),
                Text(
                  _status!,
                  style: TextStyle(
                    color: _status!.startsWith('Error') ? Colors.redAccent : Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.white.withOpacity(0.15),
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: 'clinician', child: Text('Clinician', style: TextStyle(color: Colors.white))),
        ],
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
