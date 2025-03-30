import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/presentation/pages/add_savings_goal_page.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/notifications/data/services/email_service.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_goal_detail_page.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _savingsService = SavingsService();
  User? _currentUser;
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }
  int _currentIndex = 2; // Index for bottom navigation

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;
    
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CategoriesPage();
        break;
      case 3:
        page = const AnalysisPage();
        break;
      case 4:
        page = const ProfilePage();
        break;
      default:
        return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  final _emailService = EmailService();

  Future<void> _sendSavingsReport() async {
    if (_currentUser?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please update your email in profile settings')),
      );
      return;
    }

    try {
      final goals = await _savingsService.getSavingsGoals(_currentUser?.uid ?? '').first;

      await _emailService.sendSavingsStatementEmail(goals);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Savings report sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Savings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: _sendSavingsReport,
            tooltip: 'Get savings statement - Click to receive your savings report via email',
          ),
        ],
      ),
      body: StreamBuilder<List<SavingsGoalModel>>(
        stream: _savingsService.getSavingsGoals(_currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data ?? [];

          final totalTarget = goals.fold(
              0.0, (sum, goal) => sum + goal.targetAmount);
          final totalSaved = goals.fold(
              0.0, (sum, goal) => sum + goal.currentAmount);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.savings_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Total Saved',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(totalSaved),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flag_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Target Amount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(totalTarget),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${((totalTarget > 0 ? totalSaved / totalTarget : 0) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalTarget > 0 ? totalSaved / totalTarget : 0,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.savings_outlined,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Start Your Savings Journey',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Create your first savings goal and track your progress towards financial success!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddSavingsGoalPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Your First Goal'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          final progress = goal.progressPercentage;
                          
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SavingsGoalDetailPage(goal: goal),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.savings_outlined,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: progress >= 1
                                                ? Colors.green
                                                : AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      goal.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _currencyFormat.format(goal.currentAmount),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'of ${_currencyFormat.format(goal.targetAmount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 1 ? Colors.green : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSavingsGoalPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}