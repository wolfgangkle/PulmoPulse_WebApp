import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pulmopulse_webapp/models/patient_model.dart';
import 'package:pulmopulse_webapp/services/patient_service.dart';
import 'package:intl/intl.dart';


class PatientSelectionCard extends StatefulWidget {
  final Function(Patient) onPatientSelected;

  const PatientSelectionCard({super.key, required this.onPatientSelected});

  @override
  State<PatientSelectionCard> createState() => _PatientSelectionCardState();
}

class _PatientSelectionCardState extends State<PatientSelectionCard> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    print('🔍 [PatientSelectionCard] Loading patients...');

    final patients = await PatientService.loadAllPatients();

    print('✅ [PatientSelectionCard] Loaded ${patients.length} patients.');
    for (final p in patients) {
      print('👤 ${p.fullName} (DOB: ${p.birthDate})');
    }

    setState(() {
      _patients = patients;
      _filteredPatients = patients;
      _isLoading = false;
    });
  }


  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPatients = _patients.where((p) {
        final queryLower = query.toLowerCase();
        return p.fullName.toLowerCase().contains(queryLower) ||
            p.birthDate?.toIso8601String().contains(queryLower) == true;
      }).toList();
    });
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
                'Select a Patient',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: _filterPatients,
                decoration: InputDecoration(
                  hintText: 'Search by name or date of birth...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (_filteredPatients.isEmpty)
                const Text('No patients found.', style: TextStyle(color: Colors.white70))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return ListTile(
                      title: Text(patient.fullName, style: const TextStyle(color: Colors.white)),
                      subtitle: patient.birthDate != null
                          ? Text(
                          'Date of Birth: ${DateFormat('yyyy-MM-dd').format(patient.birthDate!.toLocal())}',
                          style: const TextStyle(color: Colors.white70),
                      )
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                      onTap: () => widget.onPatientSelected(patient),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
