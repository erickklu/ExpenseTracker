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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Establecer Presupuesto',
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
            onPressed: _saveBudget, // Llama al método para guardar
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.black, // Cambia el color del ícono de retorno
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card para el presupuesto
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Presupuesto Mensual',
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
                      _budget = double.parse(value!);
                    },
                  ),
                ),
              ),
              /* SizedBox(height: 16), */

              /*
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text('Guardar Presupuesto'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 0, 0, 0),
                  onPrimary: Color.fromARGB(255, 241, 241, 241),
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
