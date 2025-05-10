import 'package:flutter/material.dart';
import '../database_helper.dart';

class SetBudgetScreen extends StatefulWidget {
  @override
  _SetBudgetScreenState createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _budget = 0.0;

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final now = DateTime.now();
      await DatabaseHelper().setBudget(now.year, now.month, _budget);
      Navigator.pop(context); // Regresa a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Establecer Presupuesto'),
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
                decoration: InputDecoration(labelText: 'Presupuesto Mensual'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingrese un monto válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _budget = double.parse(value!);
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text('Guardar Presupuesto'),
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
