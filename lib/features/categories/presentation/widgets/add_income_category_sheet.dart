import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:intl/intl.dart';

class AddIncomeCategorySheet extends StatefulWidget {
  final Function(CategoryModel) onAdd;

  const AddIncomeCategorySheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddIncomeCategorySheet> createState() => _AddIncomeCategorySheetState();
}

class _AddIncomeCategorySheetState extends State<AddIncomeCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expectedAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = 'e227'; // Default icon (money)
  Color _selectedColor = Colors.green;
  bool _isSubmitting = false;
  bool _isRegularIncome = false;
  String _selectedFrequency = 'monthly';

  final currencyFormat = NumberFormat.currency(
    symbol: 'KSH ',
    decimalDigits: 2,
  );

  // Income-specific icon options
  final List<String> _iconOptions = [
    'e227', // attach_money
    'e850', // account_balance_wallet
    'eb44', // house (rental income)
    'ef3d', // work
    'e8f6', // business
    'e8cc', // restaurant (business income)
    'e0b9', // interest
    'e8b6', // investment
    'e8ae', // sales
    'e0e0', // payments
    'e88a', // receipts
    'e8f1', // entertainment (performance income)
    'e332', // fitness (trainer income)
    'e7f1', // education (teaching income)
    'e8f8', // store (retail income)
  ];

  // Income-specific color options (greens and blues)
  final List<Color> _colorOptions = [
    Colors.green,
    Colors.green[700]!,
    Colors.green[900]!,
    Colors.teal,
    Colors.teal[700]!,
    Colors.blue,
    Colors.blue[700]!,
    Colors.lightBlue,
    Colors.cyan,
    Colors.cyan[700]!,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _expectedAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final category = CategoryModel(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          budget: double.tryParse(_expectedAmountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
          type: CategoryType.income,
          userId: userId,
          lastUpdated: DateTime.now(),
          tags: [
            if (_isRegularIncome) 'regular_income',
            _selectedFrequency,
            'income_category',
          ],
          note: _descriptionController.text.trim(),
        );

        widget.onAdd(category);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating income category: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Income Source',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Income Source Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                    hintText: 'e.g., Salary, Freelance, Rental Income',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an income source name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expectedAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Expected Monthly Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    prefixText: 'KSH ',
                    helperText: 'Estimated monthly income from this source',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // Optional field
                    }
                    final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
                    if (amount == null || amount < 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Add notes about this income source',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Regular Income'),
                  subtitle: const Text('Toggle if this is a recurring income source'),
                  value: _isRegularIncome,
                  onChanged: (value) => setState(() => _isRegularIncome = value),
                  activeColor: Colors.green,
                ),
                if (_isRegularIncome) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'biweekly', child: Text('Bi-weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                      DropdownMenuItem(value: 'annually', child: Text('Annually')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFrequency = value);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _iconOptions.length,
                    itemBuilder: (context, index) {
                      final iconCode = _iconOptions[index];
                      final isSelected = _selectedIcon == iconCode;
                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = iconCode),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? _selectedColor : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            const IconData(0xe000, fontFamily: 'MaterialIcons'),
                            color: isSelected ? _selectedColor : Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _colorOptions.length,
                    itemBuilder: (context, index) {
                      final color = _colorOptions[index];
                      final isSelected = _selectedColor == color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedColor = color),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Income Source',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}