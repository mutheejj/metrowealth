import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:metrowealth/features/navigation/presentation/pages/main_navigation.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/categories/presentation/pages/category_detail_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: '1',
      name: 'Food',
      icon: 'food',
      budget: 20000.0,
      spent: 7783.0,
    ),
    CategoryModel(
      id: '2',
      name: 'Transport',
      icon: 'transport',
      budget: 10000.0,
      spent: 5123.0,
    ),
    CategoryModel(
      id: '3',
      name: 'Medicine',
      icon: 'medicine',
      budget: 5000.0,
      spent: 2500.0,
    ),
    CategoryModel(
      id: '4',
      name: 'Groceries',
      icon: 'groceries',
      budget: 15000.0,
      spent: 8900.0,
    ),
    CategoryModel(
      id: '5',
      name: 'Rent',
      icon: 'rent',
      budget: 50000.0,
      spent: 50000.0,
    ),
    CategoryModel(
      id: '6',
      name: 'Gifts',
      icon: 'gifts',
      budget: 5000.0,
      spent: 2100.0,
    ),
    CategoryModel(
      id: '7',
      name: 'Savings',
      icon: 'savings',
      budget: 30000.0,
      spent: 30000.0,
    ),
    CategoryModel(
      id: '8',
      name: 'Entertainment',
      icon: 'entertainment',
      budget: 8000.0,
      spent: 4500.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalSpent = _categories.fold(0.0, (sum, cat) => sum + cat.spent);
    final totalBudget = _categories.fold(0.0, (sum, cat) => sum + cat.budget);
    final progress = totalSpent / totalBudget;

    return MainNavigation(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              // Header with back button and notification
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
                        'Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {}, // TODO: Handle notifications
                    ),
                  ],
                ),
              ),

              // Total Balance and Expenses
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
                              currencyFormat.format(totalSpent),
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
                              'Total Expense',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '-${currencyFormat.format(totalBudget - totalSpent)}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% Of Your Expenses',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          currencyFormat.format(totalBudget),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // Categories Grid
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: _categories.length + 1, // +1 for "More" button
                    itemBuilder: (context, index) {
                      if (index == _categories.length) {
                        return _buildMoreCard();
                      }
                      return _buildCategoryCard(_categories[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return InkWell(
      onTap: () => _onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: category.name == 'Food' 
              ? AppColors.primary 
              : Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(category.icon),
              size: 32,
              color: category.name == 'Food' 
                  ? Colors.white 
                  : Colors.blue[900],
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: category.name == 'Food' 
                    ? Colors.white 
                    : Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCard() {
    return InkWell(
      onTap: _onAddCategory,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 32,
              color: Colors.blue[900],
            ),
            const SizedBox(height: 8),
            Text(
              'More',
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

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_bus_outlined;
      case 'medicine':
        return Icons.medical_services_outlined;
      case 'groceries':
        return Icons.shopping_basket_outlined;
      case 'rent':
        return Icons.home_outlined;
      case 'gifts':
        return Icons.card_giftcard_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  void _onCategoryTap(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(category: category),
      ),
    );
  }

  void _onAddCategory() {
    // TODO: Show dialog to add new category
  }
} 