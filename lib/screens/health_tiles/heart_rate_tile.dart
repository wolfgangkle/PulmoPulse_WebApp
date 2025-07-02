import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screens/health_details/heart_rate_details.dart'; // 👈 make sure this file exists

class HeartRateTile extends StatefulWidget {
  final String patientId;

  const HeartRateTile({super.key, required this.patientId});

  @override
  State<HeartRateTile> createState() => _HeartRateTileState();
}

class _HeartRateTileState extends State<HeartRateTile> {
  int _entryCount = 0;
  DateTime? _latestDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeartRateSummary();
  }

  Future<void> _loadHeartRateSummary() async {
    final dailyRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('healthData')
        .doc('heartRate')
        .collection('daily');

    try {
      final snapshot = await dailyRef.orderBy('date', descending: true).get();

      if (snapshot.docs.isNotEmpty) {
        final latestDoc = snapshot.docs.first;
        final latestDate = latestDoc.data()['date']?.toDate();

        setState(() {
          _entryCount = snapshot.docs.length;
          _latestDate = latestDate;
          _isLoading = false;
        });
      } else {
        setState(() {
          _entryCount = 0;
          _latestDate = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load heart rate summary: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HeartRateDetailsScreen(patientId: widget.patientId),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❤️ Heart Rate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_entryCount entries',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _latestDate != null
                      ? 'Last update: ${DateFormat('yyyy-MM-dd').format(_latestDate!)}'
                      : 'No recent data',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
