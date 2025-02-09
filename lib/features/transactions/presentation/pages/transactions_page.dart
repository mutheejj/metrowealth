import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  int _selectedIndex = 2; // For bottom navigation
  int _selectedTab = 0; // 0: All, 1: Income, 2: Expense
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Transaction',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisPage()),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Balance Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(7783.00),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Income/Expense Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: _buildSummaryCard(
                      title: 'Income',
                      amount: 4120.00,
                      isIncome: true,
                      isSelected: _selectedTab == 1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 2),
                    child: _buildSummaryCard(
                      title: 'Expense',
                      amount: 1187.40,
                      isIncome: false,
                      isSelected: _selectedTab == 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _buildTransactionsList(),
              ),
            ),
          ),
        ],
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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                ),
                buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: true, // Transactions page is selected
                  onTap: () {}, // Already on transactions page
                ),
                buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalysisPage()),
                    );
                  },
                ),
                buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTransactionsList() {
    if (_selectedTab == 1) {
      // Income transactions
      return [
        _buildMonthSection('April', [
          _buildTransactionItem(
            icon: Icons.work_outline,
            title: 'Salary',
            subtitle: '12:07 - April 30',
            category: 'Monthly',
            amount: 4000.00,
            isIncome: true,
          ),
          _buildTransactionItem(
            icon: Icons.payment,
            title: 'Others',
            subtitle: '17:00 - April 24',
            category: 'Payments',
            amount: 120.00,
            isIncome: true,
          ),
        ]),
        _buildMonthSection('March', [
          _buildTransactionItem(
            icon: Icons.work_outline,
            title: 'Salary',
            subtitle: '10:15 - March 31',
            category: 'Monthly',
            amount: 4000.00,
            isIncome: true,
          ),
        ]),
      ];
    } else if (_selectedTab == 2) {
      // Expense transactions
      return [
        _buildMonthSection('April', [
          _buildTransactionItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Groceries',
            subtitle: '17:00 - April 24',
            category: 'Pantry',
            amount: -100.00,
            isIncome: false,
          ),
          _buildTransactionItem(
            icon: Icons.home_outlined,
            title: 'Rent',
            subtitle: '9:30 - April 15',
            category: 'Rent',
            amount: -674.40,
            isIncome: false,
          ),
        ]),
        _buildMonthSection('March', [
          _buildTransactionItem(
            icon: Icons.directions_car_outlined,
            title: 'Transport',
            subtitle: '14:30 - March 28',
            category: 'Fuel',
            amount: -4.13,
            isIncome: false,
          ),
          _buildTransactionItem(
            icon: Icons.restaurant_outlined,
            title: 'Food',
            subtitle: '19:30 - March 21',
            category: 'Dinner',
            amount: -70.40,
            isIncome: false,
          ),
        ]),
      ];
    }

    // All transactions
    return [
      _buildMonthSection('April', [
        _buildTransactionItem(
          icon: Icons.work_outline,
          title: 'Salary',
          subtitle: '12:07 - April 30',
          category: 'Monthly',
          amount: 4000.00,
          isIncome: true,
        ),
        _buildTransactionItem(
          icon: Icons.shopping_bag_outlined,
          title: 'Groceries',
          subtitle: '17:00 - April 24',
          category: 'Pantry',
          amount: -100.00,
          isIncome: false,
        ),
        _buildTransactionItem(
          icon: Icons.home_outlined,
          title: 'Rent',
          subtitle: '9:30 - April 15',
          category: 'Rent',
          amount: -674.40,
          isIncome: false,
        ),
      ]),
      _buildMonthSection('March', [
        _buildTransactionItem(
          icon: Icons.directions_car_outlined,
          title: 'Transport',
          subtitle: '14:30 - March 28',
          category: 'Fuel',
          amount: -4.13,
          isIncome: false,
        ),
        _buildTransactionItem(
          icon: Icons.restaurant_outlined,
          title: 'Food',
          subtitle: '19:30 - March 21',
          category: 'Dinner',
          amount: -70.40,
          isIncome: false,
        ),
      ]),
    ];
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required bool isIncome,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? (isIncome ? Colors.blue : Colors.red) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSelected ? Colors.white : (isIncome ? Colors.green : Colors.red),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isIncome ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Widget> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long, size: 20),
            ],
          ),
        ),
        ...transactions,
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String category,
    required double amount,
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}${currencyFormat.format(amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}