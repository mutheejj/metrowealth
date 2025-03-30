import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';
import 'package:intl/intl.dart';

class SavingsGoalDetailPage extends StatefulWidget {
  final SavingsGoalModel goal;

  const SavingsGoalDetailPage({super.key, required this.goal});

  @override
  State<SavingsGoalDetailPage> createState() => _SavingsGoalDetailPageState();
}

class _SavingsGoalDetailPageState extends State<SavingsGoalDetailPage> {
  final _savingsService = SavingsService();
  final _amountController = TextEditingController();
  late final NumberFormat _currencyFormat;

  @override
  void initState() {
    super.initState();
    _currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showAddContributionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Contribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'KES ',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  await _savingsService.addContribution(widget.goal.id, amount);
                  if (mounted) {
                    Navigator.pop(context);
                    _amountController.clear();
                  }
                }
              },
              child: const Text('Add Contribution'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement goal settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressCard(),
            _buildInfoCard(),
            _buildMilestonesCard(),
            _buildAchievementsCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContributionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Money'),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      _currencyFormat.format(widget.goal.currentAmount),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'of ${_currencyFormat.format(widget.goal.targetAmount)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                CircularProgressIndicator(
                  value: widget.goal.progressPercentage,
                  backgroundColor: Colors.grey[200],
                  strokeWidth: 8,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.goal.progressPercentage,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text(
              '${(widget.goal.progressPercentage * 100).toStringAsFixed(1)}% Complete',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Category', widget.goal.category),
            _buildInfoRow('Target Date', DateFormat.yMMMd().format(widget.goal.targetDate)),
            _buildInfoRow('Days Remaining', '${widget.goal.daysRemaining} days'),
            _buildInfoRow(
              'Recommended Contribution',
              _currencyFormat.format(widget.goal.recommendedContributionAmount),
            ),
            _buildInfoRow(
              'Contribution Frequency',
              widget.goal.contributionFrequency.toString().split('.').last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milestones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implement add milestone
                  },
                ),
              ],
            ),
            if (widget.goal.milestones.isEmpty)
              const Center(child: Text('No milestones yet'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.goal.milestones.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.flag),
                    title: Text(widget.goal.milestones[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _savingsService.removeMilestone(
                          widget.goal.id,
                          widget.goal.milestones[index],
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (widget.goal.achievements.isEmpty)
              const Center(child: Text('No achievements yet'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.goal.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = widget.goal.achievements.entries.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      achievement.value ? Icons.star : Icons.star_border,
                      color: achievement.value ? Colors.amber : Colors.grey,
                    ),
                    title: Text(achievement.key.replaceAll('_', ' ').toUpperCase()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}