class Expense {
  String? id;
  DateTime date;
  String category;
  double amount;
  String? description;
  
  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.description,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'amount': amount,
      'description': description,
    };
  }
  
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      amount: map['amount'].toDouble(),
      description: map['description'],
    );
  }
}
