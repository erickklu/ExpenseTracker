import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<String, double> monthlyTotals;

  MonthlyBarChart({required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = monthlyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: int.parse(entry.key), // El mes como entero
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: const Color.fromARGB(255, 0, 0, 0),
            width: 16,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
