import 'package:flutter/material.dart';
import 'package:metrowealth/features/bills/data/models/bill_model.dart';

class EditBillPage extends StatefulWidget {
  final BillModel bill;

  const EditBillPage({super.key, required this.bill});

  @override
  State<EditBillPage> createState() => _EditBillPageState();
}

class _EditBillPageState extends State<EditBillPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _dueDate;
  late String _category;
  late String? _description;
  late String _recurringType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bill.title);
    _amountController = TextEditingController(text: widget.bill.amount.toString());
    _dueDate = widget.bill.dueDate;
    _category = widget.bill.category;
    _description = widget.bill.description;
    _recurringType = widget.bill.recurringType ?? 'none';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bill')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Bill Title'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            // Add more form fields
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveBill,
            child: const Text('Save Changes'),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save bill logic
      Navigator.pop(context);
    }
  }
} 