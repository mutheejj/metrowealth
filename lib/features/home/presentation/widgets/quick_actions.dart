import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/payments/presentation/widgets/send_money_sheet.dart';
import 'package:metrowealth/features/payments/presentation/widgets/request_money_sheet.dart';
import 'package:metrowealth/features/payments/presentation/widgets/deposit_sheet.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_page.dart';
import 'package:metrowealth/features/loans/presentation/pages/loans_page.dart';

class QuickActions extends StatelessWidget {
  final Function(String) onActionSelected;
  final String userId;

  const QuickActions({
    super.key,
    required this.onActionSelected,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              context,
              icon: Icons.send,
              label: 'Send',
              onTap: () => _showSendMoneySheet(context),
            ),
            _buildActionItem(
              context,
              icon: Icons.savings,
              label: 'Savings',
              onTap: () => _navigateToSavings(context),
            ),
            _buildActionItem(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Deposit',
              onTap: () => _showDepositSheet(context),
            ),
            _buildActionItem(
              context,
              icon: Icons.account_balance,
              label: 'Loans',
              onTap: () => _navigateToLoans(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showSendMoneySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SendMoneySheet(),
    );
  }

  void _navigateToSavings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavingsPage()),
    );
  }

  void _navigateToLoans(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoansPage()),
    );
  }

  void _showDepositSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DepositSheet(userId: userId),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}