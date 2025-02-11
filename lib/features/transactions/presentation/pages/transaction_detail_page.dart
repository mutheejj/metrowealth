import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  const TransactionDetailPage({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  }) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final currencyFormat = NumberFormat.currency(symbol: 'KSH ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Detail',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountSection(),
                    const SizedBox(height: 30),
                    _buildDetailItem('Title', widget.title),
                    _buildDetailItem(
                      'Date',
                      DateFormat('dd MMM yyyy, HH:mm').format(widget.date),
                    ),
                    _buildDetailItem('Category', widget.category),
                    _buildDetailItem(
                      'Type',
                      widget.isIncome ? 'Income' : 'Expense',
                      textColor: widget.isIncome ? Colors.green : Colors.red,
                    ),
                  ],
                ),
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
                  Icons.home_outlined,
                  'Home',
                  false,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
                ),
                buildNavItem(
                  Icons.category_outlined,
                  'Categories',
                  false,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()),
                  ),
                ),
                buildNavItem(
                  Icons.receipt_long_outlined,
                  'Transactions',
                  true,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionsPage()),
                  ),
                ),
                buildNavItem(
                  Icons.analytics_outlined,
                  'Analysis',
                  false,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalysisPage()),
                  ),
                ),
                buildNavItem(
                  Icons.person_outline,
                  'Profile',
                  false,
                  () => Navigator.pushReplacement(
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

  Widget _buildAmountSection() {
    return Center(
      child: Column(
        children: [
          Text(
            currencyFormat.format(widget.amount),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: widget.isIncome ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isIncome ? 'Income' : 'Expense',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 