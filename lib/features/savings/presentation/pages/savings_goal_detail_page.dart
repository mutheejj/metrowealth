import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/presentation/pages/add_savings_page.dart';
import 'package:metrowealth/features/savings/data/models/savings_deposit_model.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';
import 'package:metrowealth/features/savings/data/models/contribution_model.dart';
import 'package:metrowealth/features/savings/presentation/pages/edit_savings_goal_page.dart';
import 'package:metrowealth/features/savings/presentation/widgets/add_contribution_sheet.dart';

class SavingsGoalDetailPage extends StatefulWidget {
  final SavingsGoalModel goal;

  const SavingsGoalDetailPage({
    super.key,
    required this.goal,
  });

  @override
  State<SavingsGoalDetailPage> createState() => _SavingsGoalDetailPageState();
}

class _SavingsGoalDetailPageState extends State<SavingsGoalDetailPage> {
  final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

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
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Goal'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Goal'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProgress(),
            const SizedBox(height: 24),
            _buildDetails(),
            const SizedBox(height: 24),
            _buildContributions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContributionSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Contribution'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final progress = widget.goal.savedAmount / widget.goal.targetAmount;
    final remainingAmount = widget.goal.targetAmount - widget.goal.savedAmount;
    final daysLeft = widget.goal.targetDate.difference(DateTime.now()).inDays;
    final dailyNeeded = remainingAmount / daysLeft;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormat.format(widget.goal.savedAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Saved so far',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(widget.goal.targetAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Target',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (daysLeft > 0) Text(
                'Need ${currencyFormat.format(dailyNeeded)} / day',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
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
    );
  }

  Widget _buildContributions() {
    return Expanded(
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
              child: _buildContributionsList(),
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

  void _handleMenuAction(String value) async {
    switch (value) {
      case 'edit':
        final result = await Navigator.push<SavingsGoalModel>(
          context,
          MaterialPageRoute(
            builder: (_) => EditSavingsGoalPage(goal: widget.goal),
          ),
        );
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal updated successfully')),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text(
          'Are you sure you want to delete this savings goal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteGoal,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal() async {
    try {
      await DatabaseService().deleteSavingsGoal(widget.goal.id);
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Return to goals list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting goal: $e')),
        );
      }
    }
  }

  void _showAddContributionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddContributionSheet(
          goal: widget.goal,
          onContribute: _handleContribution,
        ),
      ),
    );
  }

  Future<void> _handleContribution(double amount, String? note) async {
    try {
      final contribution = ContributionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: widget.goal.id,
        amount: amount,
        date: DateTime.now(),
        note: note,
      );

      await DatabaseService().addContribution(widget.goal.id, contribution);
      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contribution: $e')),
        );
      }
    }
  }

  Widget _buildContributionsList() {
    return StreamBuilder<List<ContributionModel>>(
      stream: DatabaseService().getContributions(widget.goal.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final contributions = snapshot.data!;
        if (contributions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No contributions yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start saving towards your goal',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: contributions.length,
          itemBuilder: (context, index) {
            final contribution = contributions[index];
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                currencyFormat.format(contribution.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                DateFormat('MMM d, y HH:mm').format(contribution.date),
              ),
              trailing: contribution.note != null
                  ? IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showNoteDialog(contribution.note!),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  void _showNoteDialog(String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contribution Note'),
        content: Text(note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}