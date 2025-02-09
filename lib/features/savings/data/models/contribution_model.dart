import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;

  ContributionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  factory ContributionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContributionModel(
      id: doc.id,
      goalId: data['goalId'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
    );
  }
} 