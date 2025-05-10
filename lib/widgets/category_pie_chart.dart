import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Expense> expenses;

  CategoryPieChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};

    // Calcular el total por categoría
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Convertir los datos a un formato que fl_chart pueda usar
    List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${entry.key}\n\$${entry.value.toStringAsFixed(2)}',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  // Asignar colores a las categorías
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.blue;
      case 'Transport':
        return Colors.green;
      case 'Entertainment':
        return Colors.orange;
      case 'Bills':
        return Colors.red;
      case 'Others':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }
}
