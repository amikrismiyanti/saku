class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;

  /// Diisi terpisah oleh provider berdasarkan hasil agregasi transaksi,
  /// bukan dari tabel budgets langsung.
  final double spent;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.spent = 0,
  });

  double get progress => amount == 0 ? 0 : (spent / amount).clamp(0, 1).toDouble();
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => progress >= 0.8 && !isOverBudget;

  factory BudgetModel.fromJson(Map<String, dynamic> json, {double spent = 0}) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      spent: spent,
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'amount': amount, 'month': month, 'year': year};
  }

  BudgetModel copyWithSpent(double newSpent) {
    return BudgetModel(
      id: id,
      category: category,
      amount: amount,
      month: month,
      year: year,
      createdAt: createdAt,
      spent: newSpent,
    );
  }
}
