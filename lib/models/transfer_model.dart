class TransferModel {
  final String id;
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  TransferModel({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as String,
      fromWalletId: json['from_wallet'] as String,
      toWalletId: json['to_wallet'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_wallet': fromWalletId,
      'to_wallet': toWalletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
