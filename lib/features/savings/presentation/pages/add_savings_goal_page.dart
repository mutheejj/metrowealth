import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';
import 'package:uuid/uuid.dart';

class AddSavingsGoalPage extends StatefulWidget {
  const AddSavingsGoalPage({super.key});

  @override
  State<AddSavingsGoalPage> createState() => _AddSavingsGoalPageState();
}

class _AddSavingsGoalPageState extends State<AddSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _savingsService = SavingsService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  
  String _selectedCategory = 'Emergency';
  String _selectedIcon = '💰';
  SavingsFrequency _selectedFrequency = SavingsFrequency.monthly;
  DateTime? _targetDate;
  bool _isAutomatedSaving = false;

  final List<String> _categories = [
    'Emergency',
    'Vacation',
    'Education',
    'Home',
    'Car',
    'Wedding',
    'Investment',
    'Other'
  ];

  final List<String> _icons = ['💰', '🏠', '🚗', '✈️', '📚', '💍', '📈', '🎯'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  double _calculateRecommendedContribution() {
    if (_targetDate == null || _amountController.text.isEmpty) return 0;
    
    final targetAmount = double.tryParse(_amountController.text) ?? 0;
    final daysUntilTarget = _targetDate!.difference(DateTime.now()).inDays;
    
    switch (_selectedFrequency) {
      case SavingsFrequency.daily:
        return targetAmount / daysUntilTarget;
      case SavingsFrequency.weekly:
        return targetAmount / (daysUntilTarget / 7);
      case SavingsFrequency.biweekly:
        return targetAmount / (daysUntilTarget / 14);
      case SavingsFrequency.monthly:
        return targetAmount / (daysUntilTarget / 30);
    }
  }

  Future<void> _createSavingsGoal() async {
    if (!_formKey.currentState!.validate() || _targetDate == null) return;

    try {
      final goal = SavingsGoalModel(
        id: const Uuid().v4(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        icon: _selectedIcon,
        targetAmount: double.parse(_amountController.text),
        targetDate: _targetDate!,
        createdAt: DateTime.now(),
        contributionFrequency: _selectedFrequency,
        recommendedContributionAmount: _calculateRecommendedContribution(),
        isAutomatedSavingEnabled: _isAutomatedSaving,
      );

      await _savingsService.createSavingsGoal(goal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings goal created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating savings goal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Savings Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIconSelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: 'KES ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter an amount';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Target Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SavingsFrequency>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Contribution Frequency',
                  border: OutlineInputBorder(),
                ),
                items: SavingsFrequency.values
                    .map((frequency) => DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFrequency = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Automated Saving'),
                subtitle: const Text(
                  'Automatically save money based on your frequency',
                ),
                value: _isAutomatedSaving,
                onChanged: (value) {
                  setState(() => _isAutomatedSaving = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createSavingsGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _icons.map((icon) {
        final isSelected = icon == _selectedIcon;
        return InkWell(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
}