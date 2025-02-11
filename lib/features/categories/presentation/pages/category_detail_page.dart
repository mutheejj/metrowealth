import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import 'package:metrowealth/features/transactions/data/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/categories/presentation/pages/add_expense_page.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryDetailPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final CategoryRepository _categoryRepository;
  late final TransactionRepository _transactionRepository;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  bool _isLoading = false;
  List<TransactionModel> _transactions = [];
  Map<String, double> _weeklySpending = {};
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _categoryRepository = CategoryRepository(userId);
    _transactionRepository = TransactionRepository(userId);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load category transactions
      _transactionRepository
          .getTransactionsByCategory(widget.category.id)
          .listen((transactions) {
        setState(() {
          _transactions = transactions;
          _calculateWeeklySpending();
          _totalSpent = transactions.fold(
            0.0,
            (sum, transaction) => sum + transaction.amount,
          );
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateWeeklySpending() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final Map<String, double> weeklyData = {};

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayTransactions = _transactions.where((t) {
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day;
      });
      weeklyData[DateFormat('EEE').format(date)] = dayTransactions.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
    }

    setState(() => _weeklySpending = weeklyData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Implement edit category
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    if (_weeklySpending.isNotEmpty) _buildChart(),
                    _buildTransactionsList(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage(category: widget.category),
            ),
          );
        },
        backgroundColor: widget.category.color,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    final percentageSpent = widget.category.budget > 0
        ? (_totalSpent / widget.category.budget * 100).clamp(0, 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconData(
                  int.parse('0x${widget.category.icon}'),
                  fontFamily: 'MaterialIcons',
                ),
                color: widget.category.color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_transactions.length} transactions',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.category.budget > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currencyFormat.format(_totalSpent),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _totalSpent > widget.category.budget
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    Text(
                      'of ${_currencyFormat.format(widget.category.budget)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${percentageSpent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _totalSpent > widget.category.budget
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    Text(
                      'spent',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentageSpent / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _totalSpent > widget.category.budget
                      ? Colors.red
                      : Colors.green,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _weeklySpending.values.reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(_weeklySpending.keys.elementAt(value.toInt())),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _weeklySpending.entries.map((entry) {
            return BarChartGroupData(
              x: _weeklySpending.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: widget.category.color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first transaction by tapping the + button',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.category.color.withOpacity(0.2),
            child: Icon(
              IconData(
                int.parse('0x${widget.category.icon}'),
                fontFamily: 'MaterialIcons',
              ),
              color: widget.category.color,
            ),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            DateFormat('MMM d, y').format(transaction.date),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          trailing: Text(
            _currencyFormat.format(transaction.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // TODO: Show transaction details
          },
        );
      },
    );
  }
} 