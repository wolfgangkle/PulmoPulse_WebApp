import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientService {
  static final _firestore = FirebaseFirestore.instance;

  /// Loads all patients by fetching `/patients/{id}/meta/meta` subdocs.
  static Future<List<Patient>> loadAllPatients() async {
    print('🔍 [PatientService] Fetching all /meta/meta docs via collectionGroup...');

    final metaDocs = await _firestore.collectionGroup('meta').get();
    print('📁 Found ${metaDocs.docs.length} meta document(s) in collectionGroup(meta)');

    final List<Patient> patients = [];

    for (final doc in metaDocs.docs) {
      if (doc.id != 'meta') continue; // Only want the doc named 'meta'

      final segments = doc.reference.path.split('/');
      final patientId = segments[1]; // /patients/{patientId}/meta/meta

      try {
        final data = doc.data();
        final patient = Patient.fromMetaDoc(patientId, data);
        print('✅ Loaded: ${patient.fullName} (DOB: ${patient.birthDate})');
        patients.add(patient);
      } catch (e) {
        print('❌ Error parsing patient $patientId: $e');
      }
    }

    patients.sort((a, b) => a.fullName.compareTo(b.fullName));
    print('✅ [PatientService] Returning ${patients.length} patient(s).');
    return patients;
  }
}
