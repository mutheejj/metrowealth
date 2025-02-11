import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:intl/intl.dart';

class BudgetOverview extends StatefulWidget {
  final String userId;

  const BudgetOverview({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<BudgetOverview> createState() => _BudgetOverviewState();
}

class _BudgetOverviewState extends State<BudgetOverview> {
  final DatabaseService _db = DatabaseService();
  Map<String, double> _categorySpending = {};
  bool _isLoading = true;
  String _error = '';
  final _currencyFormat = NumberFormat.currency(symbol: 'KSH ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final overview = await _db.getFinancialOverview(widget.userId);
      final categorySpending = overview['categorySpending'] as Map<dynamic, dynamic>?;
      
      if (categorySpending != null) {
        setState(() {
          _categorySpending = categorySpending.map((key, value) => 
            MapEntry(key.toString(), (value as num).toDouble()));
          _isLoading = false;
        });
      } else {
        setState(() {
          _categorySpending = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
      );
    }

    if (_categorySpending.isEmpty) {
      return const Center(
        child: Text('No spending data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to detailed budget page
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._categorySpending.entries.map((entry) {
          return _buildBudgetItem(
            category: entry.key,
            spent: entry.value,
            budget: 1000, // Replace with actual budget from user settings
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBudgetItem({
    required String category,
    required double spent,
    required double budget,
  }) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    final isOverBudget = spent > budget;
    final progressColor = isOverBudget ? Colors.red : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  '${_currencyFormat.format(spent)} / ${_currencyFormat.format(budget)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          if (isOverBudget) ...[
            const SizedBox(height: 4),
            Text(
              'Over budget by ${_currencyFormat.format(spent - budget)}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 