import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';

class AddContributionSheet extends StatefulWidget {
  final SavingsGoalModel goal;
  final Function(double amount, String? note) onContribute;

  const AddContributionSheet({
    super.key,
    required this.goal,
    required this.onContribute,
  });

  @override
  State<AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Contribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final amount = double.tryParse(value!);
                if (amount == null) return 'Invalid amount';
                if (amount <= 0) return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Add Contribution'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;
      widget.onContribute(amount, note);
    }
  }
} 