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
        title: Text(widget.expense == null ? 'Agregar Gasto' : 'Editar Gasto'),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        titleTextStyle: TextStyle(
            color: const Color.fromARGB(255, 241, 241, 241), fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Titulo'),
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
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(labelText: 'Monto'),
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
              // Dropdowns para categoría y propietario
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'),
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
              DropdownButtonFormField(
                value: _selectedOwner,
                decoration: InputDecoration(labelText: 'Propietario'),
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
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Fecha: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(
                    widget.expense == null ? 'Guardar Gasto' : 'Editar Gasto'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 0, 0, 0),
                  onPrimary: Color.fromARGB(255, 241, 241, 241),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
