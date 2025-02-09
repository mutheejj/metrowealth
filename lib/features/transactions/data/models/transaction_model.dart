import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final String? attachmentUrl;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'attachmentUrl': attachmentUrl,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] == 'TransactionType.expense' 
          ? TransactionType.expense 
          : TransactionType.income,
      category: map['category'] ?? '',
      description: map['description'],
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      attachmentUrl: map['attachmentUrl'],
    );
  }
} 