import 'package:flutter/material.dart';
import 'patient_selection_card.dart';
import 'package:pulmopulse_webapp/screens/patient_dashboard_screen.dart';


class ClinicianSection extends StatelessWidget {
  const ClinicianSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatientSelectionCard(
          onPatientSelected: (patient) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDashboardScreen(patientId: patient.id),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white30),
        const SizedBox(height: 16),
        const Text(
          'More features coming soon...',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
