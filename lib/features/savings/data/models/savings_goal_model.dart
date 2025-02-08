class SavingsGoalModel {
  final String id;
  final String name;
  final String icon;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    DateTime? targetDate,
  }) : targetDate = targetDate ?? DateTime(2025, 12, 31);
} 