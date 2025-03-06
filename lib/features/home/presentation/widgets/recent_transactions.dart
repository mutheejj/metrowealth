import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';

class RecentTransactions extends StatefulWidget {
  final String userId;

  const RecentTransactions({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: 'KSH ');
  final _dateFormat = DateFormat('MMM dd');
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  late final CategoryRepository _categoryRepository;

  @override
  void initState() {
    super.initState();
    _categoryRepository = CategoryRepository(widget.userId);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _db.getRecentTransactions(widget.userId);
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to transactions page
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_transactions.isEmpty)
          const Center(
            child: Text('No recent transactions'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final amount = isExpense ? -transaction.amount : transaction.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isExpense ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<CategoryModel?>(
                    future: _categoryRepository.getCategoryById(transaction.categoryId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final category = snapshot.data!;
                        return Text(
                          category.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        );
                      }
                      return const Text('Loading...');
                    },
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(transaction.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}