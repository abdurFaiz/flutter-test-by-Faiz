class Transaction {
  final int? id;
  final String title;
  final String desc;
  final String category;
  final String type;
  final double amount;
  final DateTime date;

  Transaction({
    this.id,
    required this.title,
    required this.desc,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'category': category,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      desc: map['desc'],
      category: map['category'],
      type: map['type'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
  Transaction copyWith({
    int? id,
    String? title,
    String? desc,
    String? category,
    String? type,
    double? amount,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
