import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/transactions/data/repositories/transaction_repository.dart';
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
  late final TransactionRepository _transactionRepository;
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
    _transactionRepository = TransactionRepository(widget.userId);
    _loadSpendingData();
    
    // Listen to transaction changes and reload data
    _transactionRepository.getTransactions().listen((_) {
      if (mounted) {
        _loadSpendingData();
      }
    });
  }

  Future<void> _loadSpendingData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final categorySpending = await _transactionRepository.getSpendingByCategory(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final categoryNames = <String, String>{};
      
      // Fetch category names
      for (var categoryId in categorySpending.keys) {
        if (categoryId.isNotEmpty) {
          try {
            final categoryDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('categories')
                .doc(categoryId)
                .get();
            
            categoryNames[categoryId] = categoryDoc.exists
                ? (categoryDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
                : 'Unknown';
          } catch (e) {
            print('Error fetching category name: $e');
            categoryNames[categoryId] = 'Unknown';
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _categorySpending = categorySpending;
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

    if (_categorySpending.isEmpty) {
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
        child: const Center(
          child: Text(
            'No spending data available for this month',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
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
    if (_categorySpending.isEmpty || _categorySpending.values.fold(0.0, (a, b) => a + b) <= 0) {
      return [];
    }

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

    final total = _categorySpending.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      if (total > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Total Spending: ${_currencyFormat.format(total)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      if (sortedEntries.isNotEmpty)
        ...sortedEntries.map((entry) {
        final index = _categorySpending.keys.toList().indexOf(entry.key);
        final percentage = (entry.value / total) * 100;
        final categoryName = _categoryNames[entry.key] ?? 'Unknown';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${_currencyFormat.format(entry.value)}\n(${percentage.toStringAsFixed(1)}%)',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }
}