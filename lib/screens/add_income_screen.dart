import 'package:flutter/material.dart';
import '../models/income.dart';
import '../database_helper.dart';

class AddIncomeScreen extends StatefulWidget {
  final Income?
      income; // Ingreso a editar (puede ser null para agregar uno nuevo)

  AddIncomeScreen({this.income});

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      // Si estamos editando, prellenar los campos
      _title = widget.income!.title;
      _amount = widget.income!.amount;
      _selectedDate = DateTime.parse(widget.income!.date);
      _selectedCategory = widget.income!.category;
    } else {
      // Valores por defecto para agregar un nuevo ingreso
      _title = '';
      _amount = 0.0;
      _selectedDate = DateTime.now();
      _selectedCategory = 'General';
    }
  }

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Income newIncome = Income(
        id: widget.income?.id, // Usar el ID existente si estamos editando
        title: _title,
        amount: _amount,
        date: _selectedDate.toIso8601String(),
        category: _selectedCategory,
      );

      if (widget.income == null) {
        // Agregar un nuevo ingreso
        await DatabaseHelper().insertIncome(newIncome);
      } else {
        // Actualizar un ingreso existente
        await DatabaseHelper().updateIncome(newIncome);
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
        title:
            Text(widget.income == null ? 'Agregar Ingreso' : 'Editar Ingreso'),
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
                decoration: InputDecoration(labelText: 'Título'),
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
              // Dropdown para categoría
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: [
                  'General',
                  'Salary',
                  'Freelance',
                  'Investments',
                  'Gifts',
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
                onPressed: _saveIncome,
                child: Text(widget.income == null
                    ? 'Guardar Ingreso'
                    : 'Editar Ingreso'),
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
