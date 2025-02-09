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
  final BillFrequency frequency;
  final DateTime dueDate;
  final DateTime? nextDueDate;
  final bool isAutoPay;
  final String category;
  final String? description;
  final String? paymentMethod;
  final BillStatus status;
  final ReminderFrequency reminderFrequency;
  final bool isRecurring;
  final List<BillPaymentModel> paymentHistory;
  final String? billerId;
  final String? accountNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.dueDate,
    this.nextDueDate,
    this.isAutoPay = false,
    required this.category,
    this.description,
    this.paymentMethod,
    this.status = BillStatus.pending,
    this.reminderFrequency = ReminderFrequency.oneDayBefore,
    this.isRecurring = true,
    List<BillPaymentModel>? paymentHistory,
    this.billerId,
    this.accountNumber,
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
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isAutoPay': isAutoPay,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'status': status.toString(),
      'reminderFrequency': reminderFrequency.toString(),
      'isRecurring': isRecurring,
      'paymentHistory': paymentHistory.map((p) => p.toMap()).toList(),
      'billerId': billerId,
      'accountNumber': accountNumber,
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
      nextDueDate: map['nextDueDate'] != null
          ? map['nextDueDate'] is Timestamp
              ? (map['nextDueDate'] as Timestamp).toDate()
              : DateTime.parse(map['nextDueDate'])
          : null,
      isAutoPay: map['isAutoPay'] ?? false,
      category: map['category'] ?? '',
      description: map['description'],
      paymentMethod: map['paymentMethod'],
      status: BillStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => BillStatus.pending,
      ),
      reminderFrequency: ReminderFrequency.values.firstWhere(
        (e) => e.toString() == map['reminderFrequency'],
        orElse: () => ReminderFrequency.oneDayBefore,
      ),
      isRecurring: map['isRecurring'] ?? true,
      paymentHistory: (map['paymentHistory'] as List<dynamic>?)
          ?.map((x) => BillPaymentModel.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
      billerId: map['billerId'],
      accountNumber: map['accountNumber'],
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

  BillModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    BillFrequency? frequency,
    DateTime? dueDate,
    DateTime? nextDueDate,
    bool? isAutoPay,
    String? category,
    String? description,
    String? paymentMethod,
    BillStatus? status,
    ReminderFrequency? reminderFrequency,
    bool? isRecurring,
    List<BillPaymentModel>? paymentHistory,
    String? billerId,
    String? accountNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dueDate: dueDate ?? this.dueDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      isRecurring: isRecurring ?? this.isRecurring,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      billerId: billerId ?? this.billerId,
      accountNumber: accountNumber ?? this.accountNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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