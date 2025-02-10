import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoryType { expense, income, savings, investment }

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final CategoryType type;
  final String userId;
  final bool isDefault;
  final List<SubcategoryModel> subcategories;
  final double budget;
  final double spent;
  final DateTime lastUpdated;
  final List<ExpenseModel> expenses;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.userId,
    this.isDefault = false,
    this.subcategories = const [],
    this.budget = 0.0,
    this.spent = 0.0,
    required this.lastUpdated,
    this.expenses = const [],
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'shopping_bag',
      color: Color(int.parse(data['color'] ?? '0xFF000000')),
      type: CategoryType.values.firstWhere(
        (e) => e.toString() == 'CategoryType.${data['type']}',
        orElse: () => CategoryType.expense,
      ),
      userId: data['userId'] ?? '',
      isDefault: data['isDefault'] ?? false,
      subcategories: (data['subcategories'] as List<dynamic>? ?? [])
          .map((e) => SubcategoryModel.fromMap(e))
          .toList(),
      budget: (data['budget'] ?? 0.0).toDouble(),
      spent: (data['spent'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expenses: (data['expenses'] as List<dynamic>? ?? [])
          .map((e) => ExpenseModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color.value.toRadixString(16),
      'type': type.toString().split('.').last,
      'userId': userId,
      'isDefault': isDefault,
      'subcategories': subcategories.map((e) => e.toMap()).toList(),
      'budget': budget,
      'spent': spent,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'expenses': expenses.map((e) => e.toMap()).toList(),
    };
  }

  CategoryModel copyWith({
    String? name,
    String? icon,
    Color? color,
    CategoryType? type,
    bool? isDefault,
    List<SubcategoryModel>? subcategories,
    double? budget,
    double? spent,
    DateTime? lastUpdated,
    List<ExpenseModel>? expenses,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      userId: userId,
      isDefault: isDefault ?? this.isDefault,
      subcategories: subcategories ?? this.subcategories,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      expenses: expenses ?? this.expenses,
    );
  }

  double get percentageSpent => budget > 0 ? (spent / budget * 100) : 0;
  bool get isOverBudget => spent > budget;
  bool get hasSubcategories => subcategories.isNotEmpty;
}

class SubcategoryModel {
  final String id;
  final String name;
  final String icon;
  final double budget;
  final double spent;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.budget = 0.0,
    this.spent = 0.0,
  });

  factory SubcategoryModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      spent: (map['spent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'budget': budget,
      'spent': spent,
    };
  }
}

class ExpenseModel {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final String subcategoryId;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.subcategoryId,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      subcategoryId: map['subcategoryId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'subcategoryId': subcategoryId,
    };
  }
} 