import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpendingInsights extends StatefulWidget {
  final String userId;

  const SpendingInsights({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SpendingInsights> createState() => _SpendingInsightsState();
}

class _SpendingInsightsState extends State<SpendingInsights> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  Map<String, double> _categorySpending = {};
  Map<String, String> _categoryNames = {};
  final _currencyFormat = NumberFormat.currency(
    symbol: 'KSH ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  Future<void> _loadSpendingData() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final transactions = await _db.getTransactions(
        widget.userId,
        startOfMonth,
        endOfMonth,
      );

      final transactionSpending = <String, double>{};
      final categoryNames = <String, String>{};
      
      for (var transaction in transactions) {
        if (transaction.categoryId.isNotEmpty && transaction.type == 'expense') {
          transactionSpending[transaction.categoryId] = 
              (transactionSpending[transaction.categoryId] ?? 0) + transaction.amount;
              
          // Fetch category name if not already fetched
          if (!categoryNames.containsKey(transaction.categoryId)) {
            final categoryDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('categories')
                .doc(transaction.categoryId)
                .get();
            
            if (categoryDoc.exists) {
              categoryNames[transaction.categoryId] = categoryDoc.data()?['name'] ?? 'Unknown';
            } else {
              categoryNames[transaction.categoryId] = 'Unknown';
            }
          }
        }
      }

      setState(() {
        _categorySpending = transactionSpending;
        _categoryNames = categoryNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: _buildLegendItems(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _categorySpending.values.fold(0.0, (a, b) => a + b);
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return _categorySpending.entries.map((entry) {
      final index = _categorySpending.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / total) * 100;
      final categoryName = _categoryNames[entry.key] ?? 'Unknown';
      final displayName = categoryName.length > 10 
          ? '${categoryName.substring(0, 8)}...' 
          : categoryName;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '$displayName\n${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  List<Widget> _buildLegendItems() {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return _categorySpending.entries.map((entry) {
      final index = _categorySpending.keys.toList().indexOf(entry.key);
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _categoryNames[entry.key] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _currencyFormat.format(entry.value),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}