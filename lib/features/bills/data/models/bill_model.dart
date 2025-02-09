import 'package:cloud_firestore/cloud_firestore.dart';

enum BillFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  custom
}

class BillModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final BillFrequency frequency;
  final DateTime dueDate;
  final bool isAutoPay;
  final String category;
  final String? description;
  final String? paymentMethod;
  final List<BillPaymentModel> paymentHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.dueDate,
    this.isAutoPay = false,
    required this.category,
    this.description,
    this.paymentMethod,
    List<BillPaymentModel>? paymentHistory,
    DateTime? createdAt,
    this.updatedAt,
  })  : paymentHistory = paymentHistory ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'frequency': frequency.toString(),
      'dueDate': dueDate.toIso8601String(),
      'isAutoPay': isAutoPay,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'paymentHistory': paymentHistory.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      frequency: BillFrequency.values.firstWhere(
        (e) => e.toString() == map['frequency'],
        orElse: () => BillFrequency.monthly,
      ),
      dueDate: map['dueDate'] is Timestamp 
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.parse(map['dueDate']),
      isAutoPay: map['isAutoPay'] ?? false,
      category: map['category'] ?? '',
      description: map['description'],
      paymentMethod: map['paymentMethod'],
      paymentHistory: (map['paymentHistory'] as List<dynamic>?)
          ?.map((x) => BillPaymentModel.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

class BillPaymentModel {
  final String id;
  final String billId;
  final double amount;
  final DateTime paymentDate;
  final String transactionId;
  final String? receipt;

  BillPaymentModel({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentDate,
    required this.transactionId,
    this.receipt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billId': billId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'receipt': receipt,
    };
  }

  factory BillPaymentModel.fromMap(Map<String, dynamic> map) {
    return BillPaymentModel(
      id: map['id'] ?? '',
      billId: map['billId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentDate: map['paymentDate'] is Timestamp 
          ? (map['paymentDate'] as Timestamp).toDate()
          : DateTime.parse(map['paymentDate']),
      transactionId: map['transactionId'] ?? '',
      receipt: map['receipt'],
    );
  }
} 