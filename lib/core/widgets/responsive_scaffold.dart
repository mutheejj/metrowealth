import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/utils/responsive_helper.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool showDrawer;
  final bool showBottomNavigationBar;
  final int currentIndex;
  final Function(int)? onNavItemTapped;
  final PreferredSizeWidget? appBar;
  final bool centerTitle;
  final Widget? leadingWidget;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.title = '',
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.showDrawer = true,
    this.showBottomNavigationBar = true,
    this.currentIndex = 0,
    this.onNavItemTapped,
    this.appBar,
    this.centerTitle = false,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isWeb = deviceType != DeviceType.mobile;
    final useSideNav = isWeb && showDrawer;

    if (isWeb) {
      // Web layout with side navigation
      return Scaffold(
        appBar: appBar ?? AppBar(
          title: Text(title),
          centerTitle: centerTitle,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: actions,
          leading: leadingWidget,
        ),
        body: Row(
          children: [
            if (useSideNav) _buildWebSideNav(context),
            Expanded(
              child: Container(
                color: backgroundColor ?? Colors.grey[100],
                child: body,
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        appBar: appBar,
        body: Container(
          color: backgroundColor ?? Colors.grey[100],
          child: body,
        ),
        bottomNavigationBar: showBottomNavigationBar
            ? _buildBottomNav(context)
            : null,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: showDrawer ? _buildMobileDrawer(context) : null,
      );
    }
  }

  Widget _buildWebSideNav(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'MetroWealth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.category_outlined,
            activeIcon: Icons.category,
            label: 'Categories',
            index: 1,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Analysis',
            index: 2,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Transactions',
            index: 3,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 4,
            context: context,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMobileNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                context: context,
              ),
              _buildMobileNavItem(
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
                label: 'Categories',
                index: 1,
                context: context,
              ),
              _buildMobileNavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Analysis',
                index: 2,
                context: context,
              ),
              _buildMobileNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Transactions',
                index: 3,
                context: context,
              ),
              _buildMobileNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 4,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'MetroWealth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your finances',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: currentIndex == 0,
            onTap: () => _navigateToScreen(context, 0),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            selected: currentIndex == 1,
            onTap: () => _navigateToScreen(context, 1),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analysis'),
            selected: currentIndex == 2,
            onTap: () => _navigateToScreen(context, 2),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Transactions'),
            selected: currentIndex == 3,
            onTap: () => _navigateToScreen(context, 3),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            selected: currentIndex == 4,
            onTap: () => _navigateToScreen(context, 4),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final bool isSelected = currentIndex == index;
    
    return ListTile(
      leading: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? AppColors.primary : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.red.withOpacity(0.1) : null,
      onTap: () => _navigateToScreen(context, index),
    );
  }

  Widget _buildMobileNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final bool isSelected = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToScreen(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : const Color(0xFF757575),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF757575),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (onNavItemTapped != null) {
      onNavItemTapped!(index);
      Navigator.pop(context);
      return;
    }

    Widget? page;
    
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CategoriesPage();
        break;
      case 2:
        page = const AnalysisPage();
        break;
      case 3:
        page = const TransactionsPage();
        break;
      case 4:
        page = const ProfilePage();
        break;
    }

    if (page != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }
} 