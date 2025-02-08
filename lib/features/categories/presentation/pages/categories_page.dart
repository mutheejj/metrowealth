import 'package:flutter/material.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: '1',
      name: 'Food',
      icon: 'assets/icons/food.png',
      budget: 20000.0,
      spent: 7783.0,
    ),
    CategoryModel(
      id: '2',
      name: 'Transport',
      icon: 'assets/icons/transport.png',
      budget: 10000.0,
      spent: 5123.0,
    ),
    CategoryModel(
      id: '3',
      name: 'Medicine',
      icon: 'assets/icons/medicine.png',
      budget: 5000.0,
      spent: 2100.0,
    ),
    CategoryModel(
      id: '4',
      name: 'Groceries',
      icon: 'assets/icons/groceries.png',
      budget: 15000.0,
      spent: 8900.0,
    ),
    CategoryModel(
      id: '5',
      name: 'Rent',
      icon: 'assets/icons/rent.png',
      budget: 30000.0,
      spent: 30000.0,
    ),
    CategoryModel(
      id: '6',
      name: 'Gifts',
      icon: 'assets/icons/gifts.png',
      budget: 5000.0,
      spent: 2500.0,
    ),
    CategoryModel(
      id: '7',
      name: 'Savings',
      icon: 'assets/icons/savings.png',
      budget: 20000.0,
      spent: 15000.0,
    ),
    CategoryModel(
      id: '8',
      name: 'Entertainment',
      icon: 'assets/icons/entertainment.png',
      budget: 8000.0,
      spent: 4500.0,
    ),
  ];

  double get _totalBudget => _categories.fold(0, (sum, cat) => sum + cat.budget);
  double get _totalSpent => _categories.fold(0, (sum, cat) => sum + cat.spent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: Column(
        children: [
          // Top Section with Total Budget and Spent
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Budget',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${_totalBudget.toStringAsFixed(2)}',
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
                          'Spent',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '-\$${_totalSpent.toStringAsFixed(2)}',
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
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _totalSpent / _totalBudget,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _totalSpent > _totalBudget ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
          ),

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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length + 1, // +1 for the "More" button
                itemBuilder: (context, index) {
                  if (index == _categories.length) {
                    return _buildAddCategoryButton();
                  }
                  return _buildCategoryItem(_categories[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category.name),
              size: 32,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: _onAddCategory,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              'More',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
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
    // Navigate to category detail page
    // You can implement this based on your requirements
  }

  void _onAddCategory() {
    // Show dialog to add new category
    // You can implement this based on your requirements
  }
} 