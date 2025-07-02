import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HeartRateLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String label;

  const HeartRateLineChart({
    super.key,
    required this.data,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No data available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Sort data by date (ascending)
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => a['date'].compareTo(b['date']));

    final spots = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final date = item['date'] as DateTime;
      final value = (item['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
      labels.add(DateFormat('MM-dd').format(date));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Transform.rotate(
                          angle: -1.57, // 90 degrees
                          child: Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    interval: 1,
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.redAccent,
                  dotData: FlDotData(show: true),
                )
              ],
              minY: 0,
            ),
          ),
        ),
      ],
    );
  }
}