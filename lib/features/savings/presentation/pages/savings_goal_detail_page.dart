import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/presentation/pages/add_savings_page.dart';
import 'package:metrowealth/features/savings/data/models/savings_deposit_model.dart';

class SavingsGoalDetailPage extends StatefulWidget {
  final SavingsGoalModel goal;

  const SavingsGoalDetailPage({
    Key? key,
    required this.goal,
  }) : super(key: key);

  @override
  State<SavingsGoalDetailPage> createState() => _SavingsGoalDetailPageState();
}

class _SavingsGoalDetailPageState extends State<SavingsGoalDetailPage> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  final List<SavingsDeposit> _deposits = [
    SavingsDeposit(
      amount: 217.77,
      dateTime: DateTime(2024, 4, 30, 15, 55),
      title: 'Travel Deposit',
    ),
    SavingsDeposit(
      amount: 217.77,
      dateTime: DateTime(2024, 4, 14, 17, 42),
      title: 'Travel Deposit',
    ),
    SavingsDeposit(
      amount: 217.77,
      dateTime: DateTime(2024, 4, 2, 12, 30),
      title: 'Travel Deposit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal.savedAmount / widget.goal.targetAmount;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {}, // TODO: Handle notifications
                  ),
                ],
              ),
            ),

            // Goal Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getIconData(widget.goal.icon),
                      size: 40,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currencyFormat.format(widget.goal.targetAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Amount Saved',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        currencyFormat.format(widget.goal.savedAmount),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% of Your Goal',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deposits List
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'April',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _deposits.length,
                        itemBuilder: (context, index) => _buildDepositItem(_deposits[index]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showAddDepositDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Savings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositItem(SavingsDeposit deposit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(widget.goal.icon),
              color: Colors.blue[900],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deposit.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${DateFormat('HH:mm').format(deposit.dateTime)} - ${DateFormat('MMM dd').format(deposit.dateTime)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(deposit.amount),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'travel':
        return Icons.flight_outlined;
      case 'house':
        return Icons.home_outlined;
      case 'car':
        return Icons.directions_car_outlined;
      case 'wedding':
        return Icons.favorite_outline;
      default:
        return Icons.savings_outlined;
    }
  }

  void _showAddDepositDialog() {
    Navigator.push<SavingsDeposit>(
      context,
      MaterialPageRoute(
        builder: (context) => AddSavingsPage(goal: widget.goal),
      ),
    ).then((newDeposit) {
      if (newDeposit != null) {
        setState(() {
          _deposits.insert(0, newDeposit);
        });
      }
    });
  }
} 