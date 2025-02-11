import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { 
  expense, 
  income, 
  transfer,
  savingsDeposit,
  savingsWithdrawal,
  loanPayment,
  loanDisbursement,
  billPayment
}

enum TransactionStatus { completed, pending, cancelled }
enum TransactionFrequency { oneTime, daily, weekly, monthly, yearly }

class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final String? recipientId;
  final double amount;
  final String description;
  final String title;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionFrequency frequency;
  final String? paymentMethod;
  final List<String> tags;
  final String? notes;
  final GeoPoint? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? attachmentUrl;
  final String? billId;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.recipientId,
    required this.amount,
    required this.description,
    required this.title,
    required this.date,
    required this.type,
    this.status = TransactionStatus.completed,
    this.frequency = TransactionFrequency.oneTime,
    this.paymentMethod,
    this.tags = const [],
    this.notes,
    this.location,
    DateTime? createdAt,
    this.updatedAt,
    this.attachmentUrl,
    this.billId,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'recipientId': recipientId,
      'amount': amount,
      'description': description,
      'title': title,
      'date': Timestamp.fromDate(date),
      'type': type.toString(),
      'status': status.toString(),
      'frequency': frequency.toString(),
      'paymentMethod': paymentMethod,
      'tags': tags,
      'notes': notes,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'attachmentUrl': attachmentUrl,
      'billId': billId,
      'metadata': metadata,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryId: map['categoryId'] as String,
      recipientId: map['recipientId'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String? ?? '',
      title: map['title'] as String? ?? '',
      date: (map['date'] as Timestamp).toDate(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TransactionStatus.completed,
      ),
      frequency: TransactionFrequency.values.firstWhere(
        (e) => e.toString() == map['frequency'],
        orElse: () => TransactionFrequency.oneTime,
      ),
      paymentMethod: map['paymentMethod'],
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      attachmentUrl: map['attachmentUrl'],
      billId: map['billId'],
      metadata: map['metadata'],
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel.fromMap({...data, 'id': doc.id});
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? recipientId,
    double? amount,
    String? description,
    String? title,
    DateTime? date,
    TransactionType? type,
    TransactionStatus? status,
    TransactionFrequency? frequency,
    String? paymentMethod,
    List<String>? tags,
    String? notes,
    GeoPoint? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? attachmentUrl,
    String? billId,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      recipientId: recipientId ?? this.recipientId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      billId: billId ?? this.billId,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isCancelled => status == TransactionStatus.cancelled;
  bool get isRecurring => frequency != TransactionFrequency.oneTime;
} 