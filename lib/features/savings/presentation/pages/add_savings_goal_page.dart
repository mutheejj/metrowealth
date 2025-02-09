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

  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
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

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
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
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.category_outlined,
                  isSelected: true, // Keep categories selected since savings is under it
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionsPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.analytics_outlined,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalysisPage()),
                  ),
                ),
                buildNavItem(
                  icon: Icons.person_outline,
                  isSelected: false,
                  onTap: () => Navigator.pushReplacement(
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

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final newGoal = SavingsGoalModel(
        id: DateTime.now().toString(),
        name: _nameController.text,
        icon: _selectedIcon,
        targetAmount: double.parse(_targetAmountController.text),
        savedAmount: 0,
        targetDate: _targetDate,
      );
      Navigator.pop(context, newGoal);
    }
  }
} 