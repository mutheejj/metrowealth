import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
// Import other pages

class MainNavigation extends StatefulWidget {
  final Widget child;
  
  const MainNavigation({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const TransactionsPage(),
    const AnalysisPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        if (widget.child is! HomePage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
        break;
      case 1:
        if (widget.child is! CategoriesPage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesPage()),
          );
        }
        break;
      case 2:
        if (widget.child is! TransactionsPage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TransactionsPage()),
          );
        }
        break;
      case 3:
        if (widget.child is! AnalysisPage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AnalysisPage()),
          );
        }
        break;
      case 4:
        if (widget.child is! ProfilePage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial selected index based on current page
    if (widget.child is HomePage) {
      _selectedIndex = 0;
    } else if (widget.child is CategoriesPage) {
      _selectedIndex = 1;
    } else if (widget.child is TransactionsPage) {
      _selectedIndex = 2;
    } else if (widget.child is AnalysisPage) {
      _selectedIndex = 3;
    } else if (widget.child is ProfilePage) {
      _selectedIndex = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
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
                  onTap: () => _onItemTapped(0),
                ),
                _buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
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