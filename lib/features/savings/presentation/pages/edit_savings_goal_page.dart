import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';

class EditSavingsGoalPage extends StatefulWidget {
  final SavingsGoalModel goal;

  const EditSavingsGoalPage({super.key, required this.goal});

  @override
  State<EditSavingsGoalPage> createState() => _EditSavingsGoalPageState();
}

class _EditSavingsGoalPageState extends State<EditSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  late TextEditingController _dateController;
  late DateTime _targetDate;
  late String _selectedIcon;
  bool _isAutoSave = false;
  double _monthlyContribution = 0;
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

  final List<Map<String, dynamic>> _icons = [
    {'id': 'savings', 'icon': Icons.savings, 'label': 'General Savings'},
    {'id': 'house', 'icon': Icons.house, 'label': 'House'},
    {'id': 'car', 'icon': Icons.directions_car, 'label': 'Car'},
    {'id': 'flight', 'icon': Icons.flight, 'label': 'Travel'},
    {'id': 'school', 'icon': Icons.school, 'label': 'Education'},
    {'id': 'shopping', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'id': 'celebration', 'icon': Icons.celebration, 'label': 'Event'},
    {'id': 'pets', 'icon': Icons.pets, 'label': 'Pet'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description);
    _targetAmountController = TextEditingController(
      text: widget.goal.targetAmount.toString(),
    );
    _targetDate = widget.goal.targetDate;
    _dateController = TextEditingController(
      text: DateFormat('MMM d, y').format(_targetDate),
    );
    _selectedIcon = widget.goal.icon;
    _calculateMonthlyContribution();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _calculateMonthlyContribution() {
    final remaining = widget.goal.targetAmount - widget.goal.savedAmount;
    final months = _targetDate.difference(DateTime.now()).inDays / 30;
    if (months > 0) {
      setState(() {
        _monthlyContribution = remaining / months;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Savings Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => 
                value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              validator: (value) => 
                value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final amount = double.tryParse(value!);
                if (amount == null) return 'Invalid amount';
                if (amount <= widget.goal.savedAmount) {
                  return 'Must be greater than saved amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Target Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) => 
                value?.isEmpty ?? true ? 'Required' : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleSave,
            child: const Text('Save Changes'),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final icon = _icons[index];
          final isSelected = _selectedIcon == icon['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _selectedIcon = icon['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  icon['label'],
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAutoSaveSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Auto-Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isAutoSave,
                  onChanged: (value) => setState(() => _isAutoSave = value),
                ),
              ],
            ),
            if (_isAutoSave) ...[
              const SizedBox(height: 16),
              Text(
                'Recommended monthly contribution: ${_currencyFormat.format(_monthlyContribution)}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Saved Amount', widget.goal.savedAmount),
            _buildSummaryRow('Remaining', 
              double.tryParse(_targetAmountController.text)?.toDouble() ?? 0 - widget.goal.savedAmount),
            _buildSummaryRow('Days Left', 
              _targetDate.difference(DateTime.now()).inDays),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value is double 
                ? _currencyFormat.format(value)
                : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
        _dateController.text = DateFormat('MMM d, y').format(picked);
        _calculateMonthlyContribution();
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedGoal = SavingsGoalModel(
          id: widget.goal.id,
          userId: widget.goal.userId,
          title: _titleController.text,
          name: _titleController.text,
          description: _descriptionController.text,
          targetAmount: double.parse(_targetAmountController.text),
          currentAmount: widget.goal.currentAmount,
          savedAmount: widget.goal.savedAmount,
          targetDate: _targetDate,
          createdAt: widget.goal.createdAt,
          status: widget.goal.status,
          icon: _selectedIcon,
          imageUrl: widget.goal.imageUrl,
        );

        await DatabaseService().updateSavingsGoal(updatedGoal);
        if (mounted) {
          Navigator.pop(context, updatedGoal);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating goal: $e')),
          );
        }
      }
    }
  }
} 