class Income {
  final int? id;
  final String title;
  final double amount;
  final String date;
  final String category;

  Income({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }
}
