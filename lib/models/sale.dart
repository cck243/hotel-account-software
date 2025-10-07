class Sale {
  String? id;
  DateTime date;
  double amount;
  String paymentMode; // Cash, UPI, Card
  String? description;
  
  Sale({
    this.id,
    required this.date,
    required this.amount,
    required this.paymentMode,
    this.description,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'paymentMode': paymentMode,
      'description': description,
    };
  }
  
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      amount: map['amount'].toDouble(),
      paymentMode: map['paymentMode'],
      description: map['description'],
    );
  }
}
