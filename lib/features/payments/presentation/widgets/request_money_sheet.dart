import 'package:flutter/material.dart';

class RequestMoneySheet extends StatefulWidget {
  @override
  State<RequestMoneySheet> createState() => _RequestMoneySheetState();
}

class _RequestMoneySheetState extends State<RequestMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _fromController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Request Money',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => 
                value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
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
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) => 
                value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date (Optional)',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDueDate(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRequest,
              child: const Text('Request'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleRequest() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement request logic
      Navigator.pop(context);
    }
  }
} 