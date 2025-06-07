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
      _title = widget.income!.title;
      _amount = widget.income!.amount;
      _selectedDate = DateTime.parse(widget.income!.date);
      _selectedCategory = widget.income!.category;
    } else {
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
        id: widget.income?.id,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.income == null ? 'Agregar Ingreso' : 'Editar Ingreso',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centra el título
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.blue[600]),
            onPressed: _saveIncome, // Llama al método para guardar
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
