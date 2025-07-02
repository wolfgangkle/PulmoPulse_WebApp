import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';

class RoleGuard extends StatelessWidget {
  final Widget Function() builder;
  final List<String> allowedRoles;
  final Widget? fallback;

  const RoleGuard({
    required this.builder,
    required this.allowedRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return fallback ?? const Text('Not signed in');

    return FutureBuilder<String?>(
      future: AuthService().getUserRole(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return allowedRoles.contains(snapshot.data)
            ? builder()
            : fallback ?? const Text('Access denied');
      },
    );
  }
}
