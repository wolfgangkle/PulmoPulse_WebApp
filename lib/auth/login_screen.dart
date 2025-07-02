import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_service.dart';
import '../widgets/glass_login_button.dart'; // ✅ Glassy button

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  // Updated login to fetch role and navigate after successful fetch
  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        // Fetch role with retries inside AuthService (assumed)
        final role = await _authService.getUserRole(user.uid);

        if (role != null && role.trim().isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardScreen(initialRole: role.trim().toLowerCase()),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ));
        }
        else {
          // Role missing, show error and stop loading
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load user role. Please try again.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? 'Authentication failed';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unknown error occurred';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            cursorColor: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // allow global background to show
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PulmoPulse',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 48),

                // Narrow Glass-style Email Field
                SizedBox(
                  width: 260,
                  child: _buildGlassTextField(
                    controller: _emailController,
                    hintText: 'Email',
                  ),
                ),

                const SizedBox(height: 16),

                // Narrow Glass-style Password Field
                SizedBox(
                  width: 260,
                  child: _buildGlassTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else ...[
                  // Narrow Glass Login Button
                  SizedBox(
                    width: 260,
                    child: GlassLoginButton(
                      text: 'Login',
                      onPressed: _login,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Outlined Auto-Login as Admin Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _emailController.text = 'admin@pulmopulse.com';
                      _passwordController.text = 'wert1234';
                      _login();
                    },
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    label: const Text('Auto-Login as Admin'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Outlined Auto-Login as Clinician Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _emailController.text = 'doctor@pp.com';
                      _passwordController.text = 'wert1234';
                      _login();
                    },
                    icon: const Icon(Icons.local_hospital, color: Colors.white),
                    label: const Text('Auto-Login as Clinician'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
