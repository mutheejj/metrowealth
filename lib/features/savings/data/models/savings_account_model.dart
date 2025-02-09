enum SavingsType {
  regular,
  fixedDeposit,
  retirement,
  emergency,
  education,
  vacation
}

class SavingsAccountModel {
  final String id;
  final String userId;
  final String name;
  final SavingsType type;
  final double balance;
  final double targetAmount;
  final DateTime startDate;
  final DateTime? maturityDate;
  final double interestRate;
  final bool isLocked;
  final Map<String, dynamic> terms;
  final List<Map<String, dynamic>> transactionHistory;

  SavingsAccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.targetAmount,
    required this.startDate,
    this.maturityDate,
    required this.interestRate,
    this.isLocked = false,
    Map<String, dynamic>? terms,
    List<Map<String, dynamic>>? transactionHistory,
  })  : terms = terms ?? {},
        transactionHistory = transactionHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.toString(),
      'balance': balance,
      'targetAmount': targetAmount,
      'startDate': startDate.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'interestRate': interestRate,
      'isLocked': isLocked,
      'terms': terms,
      'transactionHistory': transactionHistory,
    };
  }

  factory SavingsAccountModel.fromMap(Map<String, dynamic> map) {
    return SavingsAccountModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: SavingsType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SavingsType.regular,
      ),
      balance: map['balance']?.toDouble() ?? 0.0,
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['startDate']),
      maturityDate: map['maturityDate'] != null 
          ? DateTime.parse(map['maturityDate']) 
          : null,
      interestRate: map['interestRate']?.toDouble() ?? 0.0,
      isLocked: map['isLocked'] ?? false,
      terms: Map<String, dynamic>.from(map['terms'] ?? {}),
      transactionHistory: List<Map<String, dynamic>>.from(
          map['transactionHistory'] ?? []),
    );
  }
} 