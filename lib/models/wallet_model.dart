class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String type; // cash | bank | e-wallet
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'type': type,
    };
  }

  WalletModel copyWith({String? name, double? balance, String? type}) {
    return WalletModel(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      createdAt: createdAt,
    );
  }
}
