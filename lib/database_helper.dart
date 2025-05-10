import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'package:csv/csv.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      /* onUpgrade: _onUpgrade, */
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        owner TEXT NOT NULL
      )
    ''');

    // Nueva tabla para ingresos
    await db.execute('''
    CREATE TABLE incomes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount REAL,
      date TEXT,
      category TEXT
    )
  ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear la tabla incomes si no existe
      await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        category TEXT
      )
    ''');
    }
  }

  // Métodos CRUD para gastos
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<List<Expense>> getExpensesMonthly() async {
    final db = await database;

    // Obtén la fecha actual
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month
        .toString()
        .padLeft(2, '0'); // Asegura que el mes tenga dos dígitos

    // Consulta para obtener los gastos del mes y año actuales
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT *
    FROM expenses
    WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ?
  ''', [year, month]);

    // Convierte los resultados en una lista de objetos Expense
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<Map<String, List<Expense>>> getMonthlyExpensesByCategory(
      int year, int month) async {
    final db = await database;

    // Consulta para obtener los gastos del mes y año especificados
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT *
    FROM expenses
    WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ?
    ORDER BY category
  ''', [year.toString(), month.toString().padLeft(2, '0')]);

    // Agrupar los gastos por categoría
    Map<String, List<Expense>> expensesByCategory = {};
    for (var row in result) {
      final expense = Expense.fromMap(row);
      if (!expensesByCategory.containsKey(expense.category)) {
        expensesByCategory[expense.category] = [];
      }
      expensesByCategory[expense.category]!.add(expense);
    }

    return expensesByCategory;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para ingresos
  // Agregar un ingreso
  Future<int> insertIncome(Income income) async {
    final db = await database;
    return await db.insert('incomes', income.toMap());
  }

  // Actualizar un ingreso
  Future<int> updateIncome(Income income) async {
    final db = await database;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  // Eliminar un ingreso
  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Obtener todos los ingresos
  Future<List<Income>> getIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

// Obtener ingresos mensuales
  Future<List<Income>> getMonthlyIncomes(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT *
    FROM incomes
    WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ?
  ''', [year.toString(), month.toString().padLeft(2, '0')]);

    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  // Métodos CRUD para presupuestos
  Future<void> setBudget(int year, int month, double amount) async {
    final db = await database;

    // Verifica si ya existe un presupuesto para este mes
    final result = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    if (result.isNotEmpty) {
      // Actualiza el presupuesto existente
      await db.update(
        'budgets',
        {'amount': amount},
        where: 'year = ? AND month = ?',
        whereArgs: [year, month],
      );
    } else {
      // Inserta un nuevo presupuesto
      await db.insert('budgets', {
        'year': year,
        'month': month,
        'amount': amount,
      });
    }
  }

  Future<double> getBudget(int year, int month) async {
    final db = await database;

    final result = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    if (result.isNotEmpty) {
      return result.first['amount'] as double;
    }

    return 0.0; // Si no hay presupuesto, devuelve 0.0
  }

  // Calculos de totales mensuales
  Future<double> getMonthlyTotalExpense(int year, int month) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(amount) as total
    FROM expenses
    WHERE strftime('%Y', date) = ? AND strftime('%m', date) = ?
  ''', [year.toString(), month.toString().padLeft(2, '0')]);

    // Asegúrate de manejar el caso donde el resultado sea null
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0; // Si no hay resultados, devuelve 0.0
  }

  // Método para obtener los totales mensuales de un año específico
  Future<Map<String, double>> getMonthlyTotalsExpenses(int year) async {
    final db = await database;

    // Consulta para agrupar los gastos por mes y calcular el total
    final result = await db.rawQuery('''
    SELECT strftime('%m', date) AS month, SUM(amount) AS total
    FROM expenses
    WHERE strftime('%Y', date) = ?
    GROUP BY strftime('%m', date)
    ORDER BY strftime('%m', date)
  ''', [year.toString()]);

    // Convertir el resultado en un mapa
    Map<String, double> monthlyTotals = {};
    for (var row in result) {
      monthlyTotals[row['month'] as String] = (row['total'] as num).toDouble();
    }

    return monthlyTotals;
  }

  // Método para exportar gastos a CSV
  Future<String> exportExpensesToCSV() async {
    final db = await database;

    // Obtener todos los gastos
    final List<Map<String, dynamic>> expenses = await db.query('expenses');

    // Convertir los datos a formato CSV
    List<List<dynamic>> csvData = [
      // Encabezados
      ['ID', 'Title', 'Amount', 'Date', 'Category'],
      // Datos
      ...expenses.map((expense) => [
            expense['id'],
            expense['title'],
            expense['amount'],
            expense['date'],
            expense['category'],
          ]),
    ];

    // Generar el archivo CSV
    String csv = const ListToCsvConverter().convert(csvData);

    // Guardar el archivo en el almacenamiento local
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expenses.csv';
    final file = File(path);
    await file.writeAsString(csv);

    return path; // Retorna la ruta del archivo generado
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(amount) as total
    FROM expenses
  ''');

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0; // Si no hay resultados, devuelve 0.0
  }

  Future<double> getTotalIncomes() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(amount) as total
    FROM incomes
  ''');

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0; // Si no hay resultados, devuelve 0.0
  }

  Future<double> getBalance() async {
    final totalExpenses = await getTotalExpenses();
    final totalIncomes = await getTotalIncomes();
    return totalIncomes - totalExpenses; // Saldo = Ingresos - Gastos
  }

  Future<Map<String, double>> getTotalsByOwner() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT owner, SUM(amount) as total
    FROM expenses
    GROUP BY owner
  ''');

    Map<String, double> totalsByOwner = {};
    for (var row in result) {
      totalsByOwner[row['owner'] as String] = (row['total'] as num).toDouble();
    }

    return totalsByOwner;
  }
}
