import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulmopulse_webapp/core/firebase_config.dart';
import 'package:pulmopulse_webapp/auth/login_screen.dart';
import 'package:pulmopulse_webapp/dashboard/dashboard_screen.dart';
import 'package:pulmopulse_webapp/widgets/pulmopulse_background.dart'; // ✅ Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    debugPrint('✅ Firebase initialized successfully');
    debugPrint('✅ Firebase app name: ${Firebase.app().name}');
    runApp(const PulmoPulseApp());
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class PulmoPulseApp extends StatelessWidget {
  const PulmoPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoPulse WebApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen(); // 👉 we can style this later too
        }

        return const PulmoPulseBackground(
          child: LoginScreen(),
        );
      },
    );
  }
}
