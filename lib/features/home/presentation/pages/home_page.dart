import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/navigation/presentation/pages/main_navigation.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import 'package:metrowealth/features/home/presentation/widgets/account_balance_card.dart';
import 'package:metrowealth/features/home/presentation/widgets/quick_actions.dart';
import 'package:metrowealth/features/home/presentation/widgets/recent_transactions.dart';
import 'package:metrowealth/features/home/presentation/widgets/spending_insights.dart';
import 'package:metrowealth/features/home/presentation/widgets/budget_overview.dart';
import 'package:metrowealth/features/home/presentation/widgets/savings_goals_overview.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';

// Move enum to top level, outside of any class
enum AnalysisPeriod { daily, weekly, monthly }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(
    symbol: 'KSH ',
    decimalDigits: 2,
  );
  UserModel? _user;
  bool _isLoading = true;
  int _currentIndex = 0;
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.monthly;
  late final CategoryRepository _categoryRepository;
  late DateTime _startDate;
  late DateTime _endDate;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      final user = await _db.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
        if (user != null) {
          _categoryRepository = CategoryRepository(user.id);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error snackbar
    }
  }
  void _handleNavigation(int index) {
    if (index == 0) return; // Already on home page
    
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnalysisPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TransactionsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadUserData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 120,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_user != null) ...[                            
                            Text(
                              'Welcome back,',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _user!.fullName ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationPage()),
                      ),
                    ),
                  ],
                ),
                if (_user != null) ...[                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountBalanceCard(user: _user!),
                          const SizedBox(height: 20),
                          QuickActions(onActionSelected: _handleQuickAction, userId: _user!.id),
                          const SizedBox(height: 20),
                          SpendingInsights(userId: _user!.id),
                          const SizedBox(height: 20),
                          BudgetOverview(userId: _user!.id),
                          const SizedBox(height: 20),
                          SavingsGoalsOverview(userId: _user!.id),
                          const SizedBox(height: 20),
                          RecentTransactions(userId: _user!.id),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
  void _handleQuickAction(String action) {
    switch (action) {
      case 'scan':
        // Handle scan action
        break;
      case 'bills':
        // Handle bills action
        break;
    }
  }
}