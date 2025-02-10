import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryType type;
  final Function(CategoryModel) onAdd;

  const AddCategoryDialog({
    super.key,
    required this.type,
    required this.onAdd,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  Color _selectedColor = AppColors.primary;
  String _selectedIcon = 'e84f'; // Default icon code

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    ...AppColors.chartColors,
  ];

  final List<String> _iconCodes = [
    'e84f', // account_balance
    'e850', // account_balance_wallet
    'e851', // account_box
    'e853', // account_circle
    'e85c', // add_shopping_cart
    'e85d', // alarm
    'e85e', // alarm_add
    'e85f', // alarm_off
    'e860', // alarm_on
    'e861', // album
    'e862', // assignment
    'e863', // assignment_ind
    'e864', // assignment_late
    'e865', // assignment_return
    'e866', // assignment_returned
    'e867', // assignment_turned_in
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.type.toString().split('.').last} Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (Optional)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number < 0) {
                      return 'Budget cannot be negative';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _iconCodes.length,
                  itemBuilder: (context, index) {
                    final iconCode = _iconCodes[index];
                    final isSelected = iconCode == _selectedIcon;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedIcon = iconCode),
                        child: CircleAvatar(
                          backgroundColor: isSelected
                              ? _selectedColor
                              : AppColors.grey.withOpacity(0.2),
                          child: Icon(
                            IconData(
                              int.parse('0x$iconCode'),
                              fontFamily: 'MaterialIcons',
                            ),
                            color: isSelected ? AppColors.white : AppColors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = color == _selectedColor;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: isSelected
                              ? const Icon(Icons.check, color: AppColors.white)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: const Text('ADD'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = CategoryModel(
        id: '', // Will be set by Firestore
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        type: widget.type,
        userId: FirebaseAuth.instance.currentUser!.uid,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        lastUpdated: DateTime.now(),
      );

      widget.onAdd(category);
      Navigator.pop(context);
    }
  }
} 