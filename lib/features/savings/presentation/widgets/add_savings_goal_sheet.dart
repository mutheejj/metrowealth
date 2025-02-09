import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';

class AddSavingsGoalSheet extends StatefulWidget {
  const AddSavingsGoalSheet({super.key});

  @override
  State<AddSavingsGoalSheet> createState() => _AddSavingsGoalSheetState();
}

class _AddSavingsGoalSheetState extends State<AddSavingsGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Savings Goal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
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
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid amount';
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Create Goal'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM d, y').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final goal = SavingsGoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: DatabaseService().currentUserId!,
        title: _titleController.text,
        name: _titleController.text,
        description: _descriptionController.text,
        targetAmount: double.parse(_amountController.text),
        currentAmount: 0,
        savedAmount: 0,
        targetDate: _selectedDate!,
        createdAt: DateTime.now(),
        status: SavingsGoalStatus.active,
        icon: 'savings',
      );

      try {
        await DatabaseService().createSavingsGoal(goal);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
} 