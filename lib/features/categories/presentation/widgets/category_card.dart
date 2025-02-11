import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:intl/intl.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = category.budget > 0 ? (category.spent / category.budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = category.spent > category.budget && category.budget > 0;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Safely parse the icon code with error handling
    IconData iconData;
    try {
      iconData = IconData(
        int.parse('0x${category.icon}'),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      iconData = Icons.category_outlined;
    }

    return Hero(
      tag: 'category_${category.id}',
      child: Card(
        elevation: 2,
        shadowColor: category.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: category.color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (category.budget > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${currencyFormat.format(category.spent)} of ${currencyFormat.format(category.budget)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isOverBudget ? Colors.red : Colors.grey[600],
                                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[300],
                      onPressed: onDelete,
                      tooltip: 'Delete Category',
                    ),
                  ],
                ),
                if (category.budget > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}% spent',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverBudget ? Colors.red : Colors.grey[600],
                            ),
                          ),
                          Text(
                            isOverBudget
                                ? 'Over budget by ${currencyFormat.format(category.spent - category.budget)}'
                                : 'Remaining: ${currencyFormat.format(category.budget - category.spent)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverBudget ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 300),
                            widthFactor: progress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOverBudget ? Colors.red : category.color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isOverBudget ? Colors.red : category.color).withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 