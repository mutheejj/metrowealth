enum LoanStatus {
  pending,
  approved,
  rejected,
  active,
  completed,
  defaulted
}

class LoanModel {
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final int termMonths;
  final double monthlyPayment;
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final DateTime? dueDate;
  final LoanStatus status;
  final String purpose;
  final List<Map<String, dynamic>> paymentHistory;
  final Map<String, dynamic> creditScore;
  final List<String> documents;

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.applicationDate,
    this.approvalDate,
    this.dueDate,
    required this.status,
    required this.purpose,
    List<Map<String, dynamic>>? paymentHistory,
    Map<String, dynamic>? creditScore,
    List<String>? documents,
  })  : paymentHistory = paymentHistory ?? [],
        creditScore = creditScore ?? {
          'score': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        documents = documents ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'monthlyPayment': monthlyPayment,
      'applicationDate': applicationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString(),
      'purpose': purpose,
      'paymentHistory': paymentHistory,
      'creditScore': creditScore,
      'documents': documents,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      interestRate: map['interestRate']?.toDouble() ?? 0.0,
      termMonths: map['termMonths']?.toInt() ?? 0,
      monthlyPayment: map['monthlyPayment']?.toDouble() ?? 0.0,
      applicationDate: DateTime.parse(map['applicationDate']),
      approvalDate: map['approvalDate'] != null 
          ? DateTime.parse(map['approvalDate']) 
          : null,
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate']) 
          : null,
      status: LoanStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => LoanStatus.pending,
      ),
      purpose: map['purpose'] ?? '',
      paymentHistory: List<Map<String, dynamic>>.from(
          map['paymentHistory'] ?? []),
      creditScore: Map<String, dynamic>.from(map['creditScore'] ?? {}),
      documents: List<String>.from(map['documents'] ?? []),
    );
  }
} 