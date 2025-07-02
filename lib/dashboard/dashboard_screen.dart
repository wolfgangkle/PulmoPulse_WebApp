import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import 'widgets/admin/admin_section.dart';
import 'widgets/clinician/clinician_section.dart';
import '../widgets/pulmopulse_background.dart'; // pulmo background

class DashboardScreen extends StatefulWidget {
  final String? initialRole;

  const DashboardScreen({super.key, this.initialRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _role;
  bool _isLoading = true;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.initialRole != null) {
      // Use role passed from login screen directly
      _role = widget.initialRole;
      _isLoading = false;
    } else {
      // Listen to auth changes and load role
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          await _loadRole();
        } else {
          setState(() {
            _role = null;
            _isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final roleRaw = await AuthService().getUserRole(user.uid);
    final roleNormalized = roleRaw?.trim().toLowerCase();

    setState(() {
      _role = roleNormalized;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    await AuthService().signOut();
    // Navigation handled elsewhere
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return PulmoPulseBackground(
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return PulmoPulseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.15),
          elevation: 0,
          title: const Text('PulmoPulse Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white.withOpacity(0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome to the PulmoPulse WebApp',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (user != null)
                          Text(
                            'Logged in as: ${user.email} ($_role)',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 40),

                        // 🔐 Role-based sections
                        if (_role == 'admin') const AdminSection(),
                        if (_role == 'clinician') const ClinicianSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
