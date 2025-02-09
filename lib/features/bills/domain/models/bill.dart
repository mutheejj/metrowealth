import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String description;
  final String status; // 'pending', 'paid', 'overdue'
  final String userId;
  final bool isRecurring;
  final String recurringPeriod; // 'monthly', 'weekly', 'yearly'

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.description,
    required this.status,
    required this.userId,
    this.isRecurring = false,
    this.recurringPeriod = 'monthly',
  });

  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bill(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      userId: data['userId'] ?? '',
      isRecurring: data['isRecurring'] ?? false,
      recurringPeriod: data['recurringPeriod'] ?? 'monthly',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'description': description,
      'status': status,
      'userId': userId,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
    };
  }
} 