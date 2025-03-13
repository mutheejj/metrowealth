import 'package:flutter/material.dart';

class IconManager {
  static const IconData defaultCategoryIcon = Icons.category;
  static const IconData defaultTransactionIcon = Icons.receipt;

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'shopping': Icons.shopping_cart,
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'entertainment': Icons.movie,
    'health': Icons.medical_services,
    'education': Icons.school,
    'bills': Icons.receipt_long,
    'housing': Icons.home,
    'clothing': Icons.checkroom,
    'savings': Icons.savings,
    'investment': Icons.trending_up,
    'salary': Icons.work,
    'gift': Icons.card_giftcard,
    'other': Icons.more_horiz,
  };

  static IconData getCategoryIcon(String iconCode) {
    if (iconCode.isEmpty) return defaultCategoryIcon;
    try {
      return categoryIcons[iconCode] ?? defaultCategoryIcon;
    } catch (e) {
      return defaultCategoryIcon;
    }
  }

  static String getIconCode(IconData icon) {
    for (var entry in categoryIcons.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return '';
  }

  static List<MapEntry<String, IconData>> get availableIcons {
    return categoryIcons.entries.toList();
  }
}