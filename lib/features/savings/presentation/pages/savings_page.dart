import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_goal_detail_page.dart';
import 'package:metrowealth/features/savings/presentation/pages/add_savings_goal_page.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:metrowealth/features/savings/presentation/widgets/add_savings_goal_sheet.dart';
import 'package:metrowealth/features/savings/presentation/widgets/savings_goal_card.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSavingsGoalSheet,
          ),
        ],
      ),
      body: StreamBuilder<List<SavingsGoalModel>>(
        stream: _getSavingsGoals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data!;
          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SavingsGoalCard(goal: goals[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSavingsGoalSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No savings goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start saving by creating a new goal',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddSavingsGoalSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
          ),
        ],
      ),
    );
  }

  void _showAddSavingsGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddSavingsGoalSheet(),
    );
  }

  Stream<List<SavingsGoalModel>> _getSavingsGoals() {
    // TODO: Implement getting savings goals from Firebase
    return Stream.value([]);
  }
} 