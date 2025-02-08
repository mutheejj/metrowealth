import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  String _selectedPeriod = 'Daily'; // Daily, Weekly, Monthly, Year
  int _selectedIndex = 3; // Set to 3 for analysis tab
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Analysis',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance and Progress Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(7783.00),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(1187.40),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.3, // 30%
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '30% of Your Expenses Looks Good',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Period Selection
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton('Daily'),
                _buildPeriodButton('Weekly'),
                _buildPeriodButton('Monthly'),
                _buildPeriodButton('Year'),
              ],
            ),
          ),

          // Chart Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Income & Expenses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward, 
                              color: Colors.green, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_downward, 
                              color: Colors.red, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        maxY: 5000,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                return Text(
                                  days[value.toInt() % 7],
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: [
                          _generateBarGroup(0, 4000, 1200),
                          _generateBarGroup(1, 3000, 800),
                          _generateBarGroup(2, 4500, 1500),
                          _generateBarGroup(3, 3500, 900),
                          _generateBarGroup(4, 4200, 1100),
                          _generateBarGroup(5, 3800, 1300),
                          _generateBarGroup(6, 4100, 1000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Income',
                    amount: 4120.00,
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Expense',
                    amount: 1187.40,
                    isIncome: false,
                  ),
                ),
              ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionsPage()),
                    );
                  },
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: _selectedIndex == 3,
                  onTap: () {}, // Already on analysis page
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: _selectedIndex == 4,
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

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  BarChartGroupData _generateBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.blue,
          width: 8,
        ),
        BarChartRodData(
          toY: expense,
          color: Colors.red,
          width: 8,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF757575),
          size: 24,
        ),
      ),
    );
  }
} 