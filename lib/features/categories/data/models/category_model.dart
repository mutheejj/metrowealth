import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum CategoryType { 
  expense,    // Regular expenses
  income,     // Income sources
  savings,    // Savings goals
  investment, // Investment tracking
  debt,       // Debt tracking
  budget      // Budget planning
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final CategoryType type;
  final String userId;
  final bool isDefault;
  final double budget;
  final double spent;
  final DateTime lastUpdated;
  final List<String> tags;
  final String? note;

  CategoryModel({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.userId,
    this.isDefault = false,
    this.budget = 0.0,
    this.spent = 0.0,
    DateTime? lastUpdated,
    this.tags = const [],
    this.note,
  }) : this.id = id ?? const Uuid().v4(),
      this.lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color.value.toString(),
      'type': type.toString().split('.').last,
      'userId': userId,
      'isDefault': isDefault,
      'budget': budget,
      'spent': spent,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'tags': tags,
      'note': note,
    };
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'e5c3',
      color: Color(int.parse(data['color'] ?? '0xFFB71C1C')),
      type: _stringToType(data['type'] ?? 'expense'),
      userId: data['userId'] ?? '',
      isDefault: data['isDefault'] ?? false,
      budget: (data['budget'] ?? 0.0).toDouble(),
      spent: (data['spent'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      note: data['note'],
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    CategoryType? type,
    String? userId,
    bool? isDefault,
    double? budget,
    double? spent,
    DateTime? lastUpdated,
    List<String>? tags,
    String? note,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tags: tags ?? this.tags,
      note: note ?? this.note,
    );
  }

  // Helper getters
  double get percentageSpent => budget > 0 ? (spent / budget * 100) : 0;
  bool get isOverBudget => spent > budget;

  static CategoryType _stringToType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return CategoryType.income;
      case 'expense':
      default:
        return CategoryType.expense;
    }
  }

  static List<CategoryModel> getDefaultCategories(String userId) {
    return [
      CategoryModel(
        name: 'Food & Dining',
        icon: 'e566',
        color: Colors.orange,
        type: CategoryType.expense,
        userId: userId,
      ),
      CategoryModel(
        name: 'Transportation',
        icon: 'e0c9',
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
      ),
      CategoryModel(
        name: 'Shopping',
        icon: 'e8ae',
        color: Colors.purple,
        type: CategoryType.expense,
        userId: userId,
      ),
      CategoryModel(
        name: 'Bills & Utilities',
        icon: 'e0e0',
        color: Colors.red,
        type: CategoryType.expense,
        userId: userId,
      ),
      CategoryModel(
        name: 'Salary',
        icon: 'e227',
        color: Colors.green,
        type: CategoryType.income,
        userId: userId,
      ),
      CategoryModel(
        name: 'Investments',
        icon: 'e850',
        color: Colors.teal,
        type: CategoryType.income,
        userId: userId,
      ),
    ];
  }
} 