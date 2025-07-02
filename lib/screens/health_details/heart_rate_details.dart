import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/pulmopulse_background.dart';
import '../../widgets/heart_rate_chart.dart';


class HeartRateDetailsScreen extends StatefulWidget {
  final String patientId;

  const HeartRateDetailsScreen({super.key, required this.patientId});

  @override
  State<HeartRateDetailsScreen> createState() => _HeartRateDetailsScreenState();
}

class _HeartRateDetailsScreenState extends State<HeartRateDetailsScreen> {
  String? _patientName;
  bool _loading = true;
  List<Map<String, dynamic>> _heartRateData = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadPatientName();
    await _loadHeartRateData();
  }

  Future<void> _loadPatientName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('meta')
          .doc('meta')
          .get();

      final data = doc.data();
      if (data != null) {
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        _patientName = '$firstName $lastName'.trim();
      } else {
        _patientName = 'Unknown';
      }
    } catch (e) {
      debugPrint('❌ Error loading patient name: $e');
      _patientName = 'Error loading name';
    }
  }

  Future<void> _loadHeartRateData() async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('healthData')
          .doc('heartRate')
          .collection('daily');

      final snapshot = await ref.orderBy('date', descending: true).limit(7).get();

      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'date': data['date']?.toDate(),
          'avg': data['bpmAvg'] ?? 0,
          'max': data['bpmMax'] ?? 0,
          'min': data['bpmMin'] ?? 0,
        };
      }).toList().reversed.toList();

      setState(() {
        _heartRateData = entries;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading heart rate data: $e');
      setState(() => _loading = false);
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
          title: const Text('Heart Rate Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💓 Detailed heart rate data for:\n$_patientName',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 24),
                HeartRateLineChart(
                  label: '📈 Average BPM',
                  data: _heartRateData.map((e) => {
                    'date': e['date'],
                    'value': e['avg'],
                  }).toList(),
                ),
                HeartRateLineChart(
                  label: '📈 Max BPM',
                  data: _heartRateData.map((e) => {
                    'date': e['date'],
                    'value': e['max'],
                  }).toList(),
                ),
                HeartRateLineChart(
                  label: '📈 Min BPM',
                  data: _heartRateData.map((e) => {
                    'date': e['date'],
                    'value': e['min'],
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
