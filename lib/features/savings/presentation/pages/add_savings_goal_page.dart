import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:metrowealth/core/services/database_service.dart';

import '../../../../core/widgets/bottom_nav_bar.dart';

class AddSavingsGoalPage extends StatefulWidget {
  const AddSavingsGoalPage({Key? key}) : super(key: key);

  @override
  State<AddSavingsGoalPage> createState() => _AddSavingsGoalPageState();
}

class _AddSavingsGoalPageState extends State<AddSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime(2025, 12, 31);
  String _selectedIcon = 'savings';
  final _descriptionController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                      'Add Savings Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // For balance
                ],
              ),
            ),

            // Form
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goal Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Goal Name',
                            filled: true,
                            fillColor: const Color(0xFFF0FFF0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a goal name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Target Amount
                        TextFormField(
                          controller: _targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Target Amount',
                            prefixText: '\$ ',
                            filled: true,
                            fillColor: const Color(0xFFF0FFF0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter target amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Target Date
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FFF0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Target Date: ${DateFormat('MMM dd, yyyy').format(_targetDate)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Icon Selection
                        const Text(
                          'Choose Icon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildIconOption('savings', Icons.savings),
                            _buildIconOption('house', Icons.home_outlined),
                            _buildIconOption('car', Icons.directions_car_outlined),
                            _buildIconOption('travel', Icons.flight_outlined),
                            _buildIconOption('wedding', Icons.favorite_outlined),
                            _buildIconOption('education', Icons.school_outlined),
                            _buildIconOption('business', Icons.business_outlined),
                            _buildIconOption('gadget', Icons.phone_android_outlined),
                            _buildIconOption('gift', Icons.card_giftcard_outlined),
                            _buildIconOption('health', Icons.medical_services_outlined),
                            _buildIconOption('pet', Icons.pets_outlined),
                            _buildIconOption('shopping', Icons.shopping_bag_outlined),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            filled: true,
                            fillColor: const Color(0xFFF0FFF0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createSavingsGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Save Goal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Home tab
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildIconOption(String iconName, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _selectedIcon = iconName),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedIcon == iconName ? AppColors.primary : const Color(0xFFF0FFF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: _selectedIcon == iconName ? Colors.white : Colors.grey[800],
          size: 32,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _createSavingsGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newGoal = SavingsGoalModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _db.currentUserId!,
          title: _nameController.text,
          name: _nameController.text,
          description: _descriptionController.text,
          targetAmount: double.parse(_targetAmountController.text),
          currentAmount: 0,
          savedAmount: 0,
          targetDate: _targetDate,
          createdAt: DateTime.now(),
          status: SavingsGoalStatus.active,
          icon: _selectedIcon,
        );

        await _db.createSavingsGoal(newGoal);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Savings goal created successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating savings goal: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
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
} 