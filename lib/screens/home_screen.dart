import 'package:flutter/material.dart';
import 'package:ExpenseTracker/screens/add_expense_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../database_helper.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../screens/add_income_screen.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import 'set_budget_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<Expense> _monthlyExpenses = [];

  double _monthlyTotalExpense = 0.0;
  double _budget = 0.0;
  Map<String, double> _monthlyTotalsExpenses = {};
  Map<String, double> _totalsByOwner = {};

  double _totalExpenses = 0.0;
  double _totalIncomes = 0.0;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadExpensesMonthly();
    _loadIncomes();
    _loadMonthlyTotalExpense();
    _loadBudget();
    _loadMonthlyTotalsExpenses();
    _loadTotalsByOwner();
    _loadTotals();

    NotificationService().scheduleDailyNotification(
      id: 2,
      title: 'Daily Reminder',
      body: 'Don\'t forget to log your expenses today!',
      time: Time(21, 0), // 8:00 PM
    );
  }

  Future<void> _loadTotals() async {
    final totalExpenses = await DatabaseHelper().getTotalExpenses();
    final totalIncomes = await DatabaseHelper().getTotalIncomes();
    final balance = await DatabaseHelper().getBalance();

    setState(() {
      _totalExpenses = totalExpenses;
      _totalIncomes = totalIncomes;
      _balance = balance;
    });
  }

  Future<void> _loadTotalsByOwner() async {
    final totals = await DatabaseHelper().getTotalsByOwner();
    setState(() {
      _totalsByOwner = totals;
    });
  }

  Future<void> _exportData() async {
    try {
      final path = await DatabaseHelper().exportExpensesToCSV();
      final file = XFile(path); // Crear un objeto XFile
      Share.shareXFiles([file], text: 'Here are my expenses!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  Future<void> _loadMonthlyTotalExpense() async {
    final now = DateTime.now();
    final total =
        await DatabaseHelper().getMonthlyTotalExpense(now.year, now.month);
    setState(() {
      _monthlyTotalExpense = total;
    });

    // Verificar si el presupuesto ha sido excedido
    if (_budget > 0 && _monthlyTotalExpense > _budget) {
      print('Budget exceeded! Sending notification...');
      await NotificationService().showNotification(
        id: 1,
        title: 'Budget Exceeded',
        body: 'You have exceeded your budget for this month!',
      );
    }
  }

  Future<void> _loadMonthlyTotalsExpenses() async {
    final now = DateTime.now();
    final totals = await DatabaseHelper().getMonthlyTotalsExpenses(now.year);
    setState(() {
      _monthlyTotalsExpenses = totals;
    });
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper().getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _loadExpensesMonthly() async {
    final expensesMonth = await DatabaseHelper().getExpensesMonthly();
    setState(() {
      _monthlyExpenses = expensesMonth;
    });
  }

  Future<void> _loadIncomes() async {
    final incomes = await DatabaseHelper().getIncomes();
    setState(() {
      _incomes = incomes;
    });
  }

  Future<void> _loadBudget() async {
    final now = DateTime.now();
    final budget = await DatabaseHelper().getBudget(now.year, now.month);
    setState(() {
      _budget = budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card para el gasto total, presupuesto y restante
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gasto total con ícono
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gasto Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$ ${_monthlyTotalExpense.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          /* Icon(
                            Icons.account_balance_wallet,
                            size: 40,
                            color: Colors.grey[700],
                          ), */
                        ],
                      ),
                      SizedBox(height: 16),
                      // Presupuesto y Restante en dos tarjetas pequeñas
                      Row(
                        children: [
                          // Card para Presupuesto
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.blue[50],
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Presupuesto',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$ ${_budget.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Card para Restante
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: (_budget - _monthlyTotalExpense) >= 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Restante',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$ ${(_budget - _monthlyTotalExpense).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (_budget - _monthlyTotalExpense) >=
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_incomes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingresos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._incomes.map((income) {
                          return ListTile(
                            title: Text(income.title),
                            subtitle: Text(
                                '${income.amount.toStringAsFixed(2)} - ${income.date} - ${income.category}'),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),

            // Card para el gráfico de pastel
            if (_monthlyExpenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado de la card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gastos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${_monthlyTotalExpense.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Gráfico de pastel
                        SizedBox(
                          height: 200,
                          child: CategoryPieChart(expenses: _monthlyExpenses),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Card para la lista de gastos
            if (_expenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: _expenses.map((expense) {
                        return Dismissible(
                          key: Key(expense.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            await DatabaseHelper().deleteExpense(expense.id!);
                            setState(() {
                              _expenses.remove(expense);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${expense.title} eliminado')),
                            );
                          },
                          child: ListTile(
                            title: Text(expense.title,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            subtitle: Text(
                                '${expense.amount.toStringAsFixed(2)} - ${expense.date.toLocal()} - ${expense.category} - ${expense.owner}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddExpenseScreen(expense: expense),
                                ),
                              ).then((_) {
                                _loadExpenses(); // Recargar los datos al volver
                                _loadExpensesMonthly();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

            // Card para el gráfico de barras
            if (_monthlyTotalsExpenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado de la card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gastos - Mensual',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${_monthlyTotalExpense.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Gráfico de pastel
                        SizedBox(
                          height: 400,
                          child: MonthlyBarChart(
                              monthlyTotals: _monthlyTotalsExpenses),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Agregar Gasto',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              ).then((_) {
                _loadExpenses();
                _loadExpensesMonthly();
                _loadMonthlyTotalExpense();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Agregar Ingreso',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddIncomeScreen()),
              ).then((_) {
                _loadIncomes(); // Recargar los ingresos al volver
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.attach_money),
            label: 'Establecer Presupuesto',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetBudgetScreen()),
              ).then((_) {
                _loadBudget();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.file_download),
            label: 'Exportar Datos',
            onTap: _exportData,
          ),
        ],
      ),
    );
  }
}
