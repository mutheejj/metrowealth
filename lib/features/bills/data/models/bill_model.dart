import 'package:cloud_firestore/cloud_firestore.dart';

enum BillFrequency {
  once,
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly
}

enum BillStatus {
  pending,
  paid,
  overdue,
  cancelled
}

enum ReminderFrequency {
  none,
  onDueDate,
  oneDayBefore,
  threeDaysBefore,
  oneWeekBefore
}

class BillModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime dueDate;
  final BillStatus status;
  final String? description;
  final String? recurringType;
  final int? recurringInterval;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<BillPaymentModel> payments;
  final String? accountNumber;

  BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.dueDate,
    this.status = BillStatus.pending,
    this.description,
    this.recurringType,
    this.recurringInterval,
    this.nextDueDate,
    required this.createdAt,
    this.updatedAt,
    this.payments = const [],
    this.accountNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString(),
      'description': description,
      'recurringType': recurringType,
      'recurringInterval': recurringInterval,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'payments': payments.map((p) => p.toMap()).toList(),
      'accountNumber': accountNumber,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      dueDate: map['dueDate'] is Timestamp 
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.parse(map['dueDate']),
      status: BillStatus.values[int.parse(map['status'] ?? '0')],
      description: map['description'],
      recurringType: map['recurringType'],
      recurringInterval: map['recurringInterval'],
      nextDueDate: map['nextDueDate'] != null
          ? map['nextDueDate'] is Timestamp
              ? (map['nextDueDate'] as Timestamp).toDate()
              : DateTime.parse(map['nextDueDate'])
          : null,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt'])
          : null,
      payments: (map['payments'] as List<dynamic>?)
          ?.map((x) => BillPaymentModel.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
      accountNumber: map['accountNumber'],
    );
  }

  BillModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? dueDate,
    BillStatus? status,
    String? description,
    String? recurringType,
    int? recurringInterval,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BillPaymentModel>? payments,
    String? accountNumber,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payments: payments ?? this.payments,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      dueDate: data['dueDate'] is Timestamp 
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.parse(data['dueDate'].toString()),
      status: BillStatus.values[int.parse(data['status'] ?? '0')],
      description: data['description'],
      recurringType: data['recurringType'],
      recurringInterval: data['recurringInterval'],
      nextDueDate: data['nextDueDate'] != null
          ? data['nextDueDate'] is Timestamp
              ? (data['nextDueDate'] as Timestamp).toDate()
              : DateTime.parse(data['nextDueDate'].toString())
          : null,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'].toString()),
      updatedAt: data['updatedAt'] != null 
          ? data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['updatedAt'].toString())
          : null,
      payments: (data['payments'] as List<dynamic>?)
          ?.map((x) => BillPaymentModel.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
      accountNumber: data['accountNumber'],
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
  final String? paymentMethod;
  final String? notes;
  final bool isAutoPayment;
  final DateTime createdAt;

  BillPaymentModel({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentDate,
    required this.transactionId,
    this.receipt,
    this.paymentMethod,
    this.notes,
    this.isAutoPayment = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billId': billId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'receipt': receipt,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'isAutoPayment': isAutoPayment,
      'createdAt': createdAt.toIso8601String(),
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
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      isAutoPayment: map['isAutoPayment'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }
} 