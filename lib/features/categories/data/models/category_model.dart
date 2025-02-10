import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoryType { 
  expense,    // Regular expenses
  income,     // Income sources
  savings,    // Savings goals
  investment, // Investment tracking
  debt,       // Debt tracking
  budget      // Budget planning
}

enum TransactionFrequency {
  oneTime,
  daily,
  weekly,
  monthly,
  yearly
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
  final List<TransactionModel> transactions;
  final BudgetSettings budgetSettings;
  final List<String> tags;
  final String? note;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.userId,
    this.isDefault = false,
    this.budget = 0.0,
    this.spent = 0.0,
    required this.lastUpdated,
    this.transactions = const [],
    BudgetSettings? budgetSettings,
    this.tags = const [],
    this.note,
  }) : budgetSettings = budgetSettings ?? BudgetSettings();

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
      budget: (data['budget'] ?? 0.0).toDouble(),
      spent: (data['spent'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactions: (data['transactions'] as List<dynamic>? ?? [])
          .map((e) => TransactionModel.fromMap(e))
          .toList(),
      budgetSettings: BudgetSettings.fromMap(data['budgetSettings'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      note: data['note'],
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
      'budget': budget,
      'spent': spent,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'transactions': transactions.map((e) => e.toMap()).toList(),
      'budgetSettings': budgetSettings.toMap(),
      'tags': tags,
      'note': note,
    };
  }

  CategoryModel copyWith({
    String? name,
    String? icon,
    Color? color,
    CategoryType? type,
    bool? isDefault,
    double? budget,
    double? spent,
    DateTime? lastUpdated,
    List<TransactionModel>? transactions,
    BudgetSettings? budgetSettings,
    List<String>? tags,
    String? note,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      userId: userId,
      isDefault: isDefault ?? this.isDefault,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
      budgetSettings: budgetSettings ?? this.budgetSettings,
      tags: tags ?? this.tags,
      note: note ?? this.note,
    );
  }

  // Helper getters
  double get percentageSpent => budget > 0 ? (spent / budget * 100) : 0;
  bool get isOverBudget => spent > budget;
  bool get hasTransactions => transactions.isNotEmpty;
  
  // Budget analysis
  double get dailyAverage => transactions.isEmpty 
    ? 0 
    : transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length;
  
  double get monthlyTotal {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return transactions
        .where((t) => t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Trend analysis
  double get monthOverMonthGrowth {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    
    final thisMonthTotal = transactions
        .where((t) => t.date.isAfter(thisMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final lastMonthTotal = transactions
        .where((t) => t.date.isAfter(lastMonth) && t.date.isBefore(thisMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return lastMonthTotal == 0 ? 0 : (thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100;
  }

  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  // Get recurring transactions
  List<TransactionModel> getRecurringTransactions() {
    return transactions.where((t) => t.frequency != TransactionFrequency.oneTime).toList();
  }
}

class TransactionModel {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionFrequency frequency;
  final List<String> tags;
  final String? note;
  final String? attachmentUrl;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    this.frequency = TransactionFrequency.oneTime,
    this.tags = const [],
    this.note,
    this.attachmentUrl,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      frequency: TransactionFrequency.values.firstWhere(
        (e) => e.toString() == 'TransactionFrequency.${map['frequency']}',
        orElse: () => TransactionFrequency.oneTime,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      note: map['note'],
      attachmentUrl: map['attachmentUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'frequency': frequency.toString().split('.').last,
      'tags': tags,
      'note': note,
      'attachmentUrl': attachmentUrl,
    };
  }
}

class BudgetSettings {
  final double monthlyLimit;
  final double warningThreshold; // Percentage (0-100) when to show warning
  final bool enableNotifications;
  final List<DateTime> excludedDates;
  final Map<String, double> categoryLimits; // Sub-category specific limits

  BudgetSettings({
    this.monthlyLimit = 0.0,
    this.warningThreshold = 80.0,
    this.enableNotifications = true,
    this.excludedDates = const [],
    this.categoryLimits = const {},
  });

  factory BudgetSettings.fromMap(Map<String, dynamic> map) {
    return BudgetSettings(
      monthlyLimit: (map['monthlyLimit'] ?? 0.0).toDouble(),
      warningThreshold: (map['warningThreshold'] ?? 80.0).toDouble(),
      enableNotifications: map['enableNotifications'] ?? true,
      excludedDates: (map['excludedDates'] as List<dynamic>? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      categoryLimits: Map<String, double>.from(map['categoryLimits'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyLimit': monthlyLimit,
      'warningThreshold': warningThreshold,
      'enableNotifications': enableNotifications,
      'excludedDates': excludedDates.map((d) => Timestamp.fromDate(d)).toList(),
      'categoryLimits': categoryLimits,
    };
  }
} 