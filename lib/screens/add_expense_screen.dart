import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense?
      expense; // Gasto a editar (puede ser null para agregar uno nuevo)

  AddExpenseScreen({this.expense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedOwner;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Si estamos editando, prellenar los campos
      _title = widget.expense!.title;
      _amount = widget.expense!.amount;
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
      _selectedOwner = widget.expense!.owner;
    } else {
      // Valores por defecto para agregar un nuevo gasto
      _title = '';
      _amount = 0.0;
      _selectedDate = DateTime.now();
      _selectedCategory = 'General';
      _selectedOwner = 'Person 1';
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Expense newExpense = Expense(
        id: widget.expense?.id, // Usar el ID existente si estamos editando
        title: _title,
        amount: _amount,
        date: _selectedDate,
        category: _selectedCategory,
        owner: _selectedOwner,
      );

      if (widget.expense == null) {
        // Agregar un nuevo gasto
        await DatabaseHelper().insertExpense(newExpense);
      } else {
        // Actualizar un gasto existente
        await DatabaseHelper().updateExpense(newExpense);
      }

      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.expense == null ? 'Agregar Gasto' : 'Editar Gasto',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.blue[600]), // Ícono moderno
            onPressed: _saveExpense, // Llama al método para guardar
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card para el título
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    initialValue: _title,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un título';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Card para el monto
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    initialValue: _amount.toString(),
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Por favor ingrese un monto válido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _amount = double.parse(value!);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Card para la categoría
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: InputBorder.none,
                    ),
                    items: [
                      'General',
                      'Food',
                      'Transport',
                      'Entertainment',
                      'Bills',
                      'Others'
                    ]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value as String;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Card para el propietario
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField(
                    value: _selectedOwner,
                    decoration: InputDecoration(
                      labelText: 'Propietario',
                      border: InputBorder.none,
                    ),
                    items: ['Person 1', 'Person 2']
                        .map((owner) => DropdownMenuItem(
                              value: owner,
                              child: Text(owner),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOwner = value as String;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Card para la fecha
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fecha: ${_selectedDate.toLocal()}'.split(' ')[0]),
                      TextButton(
                        onPressed: _pickDate,
                        child: Text('Seleccionar Fecha'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
