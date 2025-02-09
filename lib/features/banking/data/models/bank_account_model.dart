class BankAccountModel {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String accountType;
  final double balance;
  final bool isDefault;
  final DateTime linkedAt;

  BankAccountModel({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    this.isDefault = false,
    required this.linkedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'isDefault': isDefault,
      'linkedAt': linkedAt.toIso8601String(),
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountType: map['accountType'] ?? '',
      balance: map['balance']?.toDouble() ?? 0.0,
      isDefault: map['isDefault'] ?? false,
      linkedAt: DateTime.parse(map['linkedAt']),
    );
  }
} 