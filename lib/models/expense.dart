class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String owner;

  Expense(
      {this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.category,
      required this.owner});

  // Convertir un Expense a un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'owner': owner, // Agregar el propietario al Map
    };
  }

  // Crear un Expense desde un Map de SQLite
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'], // Obtener la categoría del Map
      owner: map['owner'], // Obtener el propietario del Map
    );
  }
}
