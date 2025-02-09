import 'package:cloud_firestore/cloud_firestore.dart';

enum SavingsGoalStatus {
  active,
  completed,
  cancelled
}

class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final double savedAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final SavingsGoalStatus status;
  final String icon;
  final String? imageUrl;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.createdAt,
    required this.status,
    required this.icon,
    this.imageUrl,
  });

  double get progressPercentage => (currentAmount / targetAmount).clamp(0.0, 1.0);

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoalModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      name: data['name'],
      description: data['description'],
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      savedAmount: (data['savedAmount'] as num).toDouble(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: SavingsGoalStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => SavingsGoalStatus.active,
      ),
      icon: data['icon'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'savedAmount': savedAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString(),
      'icon': icon,
      'imageUrl': imageUrl,
    };
  }
} 