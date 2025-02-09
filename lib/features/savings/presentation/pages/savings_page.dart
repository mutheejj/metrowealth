import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_goal_detail_page.dart';
import 'package:metrowealth/features/savings/presentation/pages/add_savings_goal_page.dart';

import '../../../notifications/presentation/pages/notification_page.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  
  final List<SavingsGoalModel> _savingsGoals = [
    SavingsGoalModel(
      id: '1',
      name: 'Travel',
      icon: 'travel',
      targetAmount: 5000.0,
      savedAmount: 2500.0,
    ),
    SavingsGoalModel(
      id: '2',
      name: 'New House',
      icon: 'house',
      targetAmount: 100000.0,
      savedAmount: 45000.0,
    ),
    SavingsGoalModel(
      id: '3',
      name: 'Car',
      icon: 'car',
      targetAmount: 30000.0,
      savedAmount: 15000.0,
    ),
    SavingsGoalModel(
      id: '4',
      name: 'Wedding',
      icon: 'wedding',
      targetAmount: 25000.0,
      savedAmount: 10000.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalSaved = _savingsGoals.fold(0.0, (sum, goal) => sum + goal.savedAmount);
    final totalTarget = _savingsGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final progress = totalSaved / totalTarget;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Savings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
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
                  const Expanded(
                    child: Text(
                      'Savings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Balance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalSaved),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Target',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '-${currencyFormat.format(totalTarget - totalSaved)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                    '${(progress * 100).toStringAsFixed(0)}% of Your Savings Target',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Savings Goals Grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    ..._savingsGoals.map((goal) => _buildSavingsGoalCard(goal)),
                    _buildAddMoreCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavItem(
                  icon: Icons.home_outlined,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: true, // Since savings is under categories
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionsPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalysisPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoalCard(SavingsGoalModel goal) {
    return InkWell(
      onTap: () => _onSavingsGoalTap(goal),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(goal.icon),
              size: 32,
              color: Colors.blue[900],
            ),
            const SizedBox(height: 8),
            Text(
              goal.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreCard() {
    return InkWell(
      onTap: _onAddMore,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Add More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
        return Icons.favorite_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'business':
        return Icons.business_outlined;
      case 'gadget':
        return Icons.phone_android_outlined;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      case 'pet':
        return Icons.pets_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'savings':
      default:
        return Icons.savings_outlined;
    }
  }

  void _onSavingsGoalTap(SavingsGoalModel goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsGoalDetailPage(goal: goal),
      ),
    );
  }

  void _onAddMore() {
    Navigator.push<SavingsGoalModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSavingsGoalPage(),
      ),
    ).then((newGoal) {
      if (newGoal != null) {
        setState(() {
          _savingsGoals.add(newGoal);
        });
      }
    });
  }
} 