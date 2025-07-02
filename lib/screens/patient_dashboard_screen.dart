import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/pulmopulse_background.dart';
import '../screens/health_tiles/heart_rate_tile.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String patientId;

  const PatientDashboardScreen({super.key, required this.patientId});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  String? _patientName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('meta')
          .doc('meta');

      final doc = await docRef.get();
      final data = doc.data();

      if (data != null) {
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();

        setState(() {
          _patientName = fullName.isNotEmpty ? fullName : 'Unknown';
          _loading = false;
        });

        print('✅ Assembled patient name: $_patientName');
      } else {
        setState(() {
          _patientName = 'Unknown';
          _loading = false;
        });
        print('⚠️ Patient meta doc is null');
      }
    } catch (e) {
      print('❌ Error loading patient name: $e');
      setState(() {
        _patientName = 'Error loading name';
        _loading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return PulmoPulseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.15),
          elevation: 0,
          title: const Text('Patient Dashboard'),
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
                          'Patient Dashboard',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Patient: $_patientName',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          children: [
                            HeartRateTile(patientId: widget.patientId),
                          ],
                        ),
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
