import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add new transaction
                      },
                      child: const Text(
                        'Add New',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildTransactionItem(
                    'Grocery Shopping',
                    'Food',
                    -2500.00,
                    DateTime.now(),
                  ),
                  _buildTransactionItem(
                    'Salary Deposit',
                    'Income',
                    45000.00,
                    DateTime.now().subtract(const Duration(days: 1)),
                  ),
                  _buildTransactionItem(
                    'Electricity Bill',
                    'Utilities',
                    -1200.00,
                    DateTime.now().subtract(const Duration(days: 2)),
                  ),
                  // Add more transactions...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String category,
    double amount,
    DateTime date,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB71C1C).withOpacity(0.1),
          child: Icon(
            amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
            color: const Color(0xFFB71C1C),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$category • ${_formatDate(date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '${amount > 0 ? '+' : ''}${amount.toStringAsFixed(2)} KSh',
          style: TextStyle(
            color: amount > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}