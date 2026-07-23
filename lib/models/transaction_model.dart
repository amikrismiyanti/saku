import '../core/constants/app_constants.dart';

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String walletId;
  final DateTime date;
  final String? paymentMethod;
  final String? description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.walletId,
    required this.date,
    this.paymentMethod,
    this.description,
    required this.createdAt,
  });

  bool get isIncome => type == TransactionType.income;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: (json['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      walletId: json['wallet_id'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['payment_method'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'wallet_id': walletId,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'description': description,
    };
  }
}
