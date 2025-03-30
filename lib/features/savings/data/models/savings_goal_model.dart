import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SavingsGoalStatus {
  active,
  completed,
  paused,
  cancelled
}

enum SavingsFrequency {
  daily,
  weekly,
  biweekly,
  monthly
}

class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String icon;
  final String? imageUrl;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? lastContributionDate;
  final SavingsGoalStatus status;
  final SavingsFrequency contributionFrequency;
  final double recommendedContributionAmount;
  final List<String> milestones;
  final Map<String, bool> achievements;
  final bool isAutomatedSavingEnabled;
  final Map<String, dynamic> automationRules;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.imageUrl,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    this.lastContributionDate,
    this.status = SavingsGoalStatus.active,
    required this.contributionFrequency,
    required this.recommendedContributionAmount,
    List<String>? milestones,
    Map<String, bool>? achievements,
    this.isAutomatedSavingEnabled = false,
    Map<String, dynamic>? automationRules,
  })  : milestones = milestones ?? [],
        achievements = achievements ?? {},
        automationRules = automationRules ?? {};

  double get progressPercentage => (currentAmount / targetAmount).clamp(0.0, 1.0);

  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  bool get isOverdue => targetDate.isBefore(DateTime.now()) && status == SavingsGoalStatus.active;

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoalModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      category: data['category'],
      icon: data['icon'],
      imageUrl: data['imageUrl'],
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastContributionDate: data['lastContributionDate'] != null
          ? (data['lastContributionDate'] as Timestamp).toDate()
          : null,
      status: SavingsGoalStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => SavingsGoalStatus.active,
      ),
      contributionFrequency: SavingsFrequency.values.firstWhere(
        (e) => e.toString() == data['contributionFrequency'],
        orElse: () => SavingsFrequency.monthly,
      ),
      recommendedContributionAmount: (data['recommendedContributionAmount'] as num).toDouble(),
      milestones: List<String>.from(data['milestones'] ?? []),
      achievements: Map<String, bool>.from(data['achievements'] ?? {}),
      isAutomatedSavingEnabled: data['isAutomatedSavingEnabled'] ?? false,
      automationRules: Map<String, dynamic>.from(data['automationRules'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'imageUrl': imageUrl,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastContributionDate': lastContributionDate != null
          ? Timestamp.fromDate(lastContributionDate!)
          : null,
      'status': status.toString(),
      'contributionFrequency': contributionFrequency.toString(),
      'recommendedContributionAmount': recommendedContributionAmount,
      'milestones': milestones,
      'achievements': achievements,
      'isAutomatedSavingEnabled': isAutomatedSavingEnabled,
      'automationRules': automationRules,
    };
  }
}