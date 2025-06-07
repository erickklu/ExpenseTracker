import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/income.dart';

class CategoryPieChartIncomes extends StatelessWidget {
  final List<Income> incomes;

  CategoryPieChartIncomes({required this.incomes});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};

    // Calcular el total por categoría
    for (var income in incomes) {
      categoryTotals[income.category] =
          (categoryTotals[income.category] ?? 0) + income.amount;
    }

    // Convertir los datos a un formato que fl_chart pueda usar
    List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${entry.key}\n\$${entry.value.toStringAsFixed(2)}',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Salary':
        return Colors.blue;
      case 'Freelance':
        return Colors.green;
      case 'Investments':
        return Colors.orange;
      case 'Gifts':
        return Colors.red;
      case 'Others':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }
}
