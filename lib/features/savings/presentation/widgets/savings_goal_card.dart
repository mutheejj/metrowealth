import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_goal_detail_page.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback? onContribute;
  late final NumberFormat currencyFormat;

  SavingsGoalCard({
    super.key,
    required this.goal,
    this.onContribute,
  }) {
    currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
  }

  String _getRemainingTimeText() {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return 'Overdue';
    if (daysLeft == 0) return 'Due today';
    if (daysLeft <= 30) return '$daysLeft days left';
    final months = (daysLeft / 30).floor();
    return '$months months left';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage;
    final progressColor = _getProgressColor(progress);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavingsGoalDetailPage(goal: goal),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onContribute,
                    tooltip: 'Add contribution',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(goal.currentAmount),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'of ${currencyFormat.format(goal.targetAmount)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: progressColor,
                            ),
                      ),
                      Text(
                        _getRemainingTimeText(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: progressColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
              if (goal.isAutomatedSavingEnabled) ...[  
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-saving enabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}