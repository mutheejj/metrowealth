import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  deposit,
  withdrawal,
  savingsDeposit,
  savingsWithdrawal,
  loanPayment,
  loanDisbursement,
  billPayment,
  investment
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  reversed
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String title;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? accountId;
  final String? billId;
  final String? description;
  final String? recipientId;
  final String? attachmentUrl;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.title,
    required this.category,
    required this.type,
    required this.date,
    this.accountId,
    this.billId,
    this.description,
    this.recipientId,
    this.attachmentUrl,
    this.status = TransactionStatus.completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      title: data['title'],
      category: data['category'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => TransactionType.expense,
      ),
      date: data['date'] is Timestamp 
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date'].toString()),
      accountId: data['accountId'],
      billId: data['billId'],
      description: data['description'],
      recipientId: data['recipientId'],
      attachmentUrl: data['attachmentUrl'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'].toString()),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(data['updatedAt'].toString()),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'title': title,
      'category': category,
      'type': type.toString(),
      'date': date,
      'accountId': accountId,
      'billId': billId,
      'description': description,
      'recipientId': recipientId,
      'attachmentUrl': attachmentUrl,
      'status': status.toString(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'metadata': metadata,
    };
  }
} 