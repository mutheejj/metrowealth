import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final String name;
  final String icon;
  final double targetAmount;
  final double currentAmount;
  final double savedAmount;
  final DateTime targetDate;
  final String? category;
  final String? description;
  final bool isCompleted;
  final List<ContributionModel> contributions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    String? name,
    String? icon,
    required this.targetAmount,
    required this.currentAmount,
    double? savedAmount,
    DateTime? targetDate,
    this.category,
    this.description,
    this.isCompleted = false,
    this.contributions = const [],
    DateTime? createdAt,
    this.updatedAt,
  })  : name = name ?? title,
        icon = icon ?? 'savings',
        savedAmount = savedAmount ?? currentAmount,
        targetDate = targetDate ?? DateTime(2025, 12, 31),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'description': description,
      'isCompleted': isCompleted,
      'contributions': contributions.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'savings',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0.0).toDouble(),
      targetDate: map['targetDate'] is Timestamp 
          ? (map['targetDate'] as Timestamp).toDate()
          : DateTime.parse(map['targetDate']),
      category: map['category'],
      description: map['description'],
      isCompleted: map['isCompleted'] ?? false,
      contributions: (map['contributions'] as List<dynamic>?)
          ?.map((x) => ContributionModel.fromMap(x as Map<String, dynamic>))
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory ContributionModel.fromMap(Map<String, dynamic> map) {
    return ContributionModel(
      id: map['id'] ?? '',
      goalId: map['goalId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      note: map['note'],
    );
  }
} 