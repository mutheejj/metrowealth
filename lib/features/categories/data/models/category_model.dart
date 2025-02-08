import 'expense_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final double budget;
  final double spent;
  final List<ExpenseItem> expenses;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.budget,
    required this.spent,
    List<ExpenseItem>? expenses,
  }) : expenses = expenses ?? const [];

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    double? budget,
    double? spent,
    List<ExpenseItem>? expenses,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      expenses: expenses ?? this.expenses,
    );
  }
} 