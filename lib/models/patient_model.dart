import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final DateTime? updatedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Patient.fromMetaDoc(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      firstName: (data['firstName'] ?? 'Unknown').toString().trim(),
      lastName: (data['lastName'] ?? '').toString().trim(),
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMetaMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $fullName, birthDate: $birthDate, updatedAt: $updatedAt)';
  }

  int compareByName(Patient other) => fullName.compareTo(other.fullName);

  int compareByUpdatedAt(Patient other) =>
      (updatedAt ?? DateTime(0)).compareTo(other.updatedAt ?? DateTime(0));
}
