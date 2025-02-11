import 'package:flutter/material.dart';
import 'package:metrowealth/features/bills/data/models/bill_model.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';

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
  late String _categoryId;
  late String? _description;
  late String _recurringType;
  late final CategoryRepository _categoryRepository;
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bill.title);
    _amountController = TextEditingController(text: widget.bill.amount.toString());
    _dueDate = widget.bill.dueDate;
    _categoryId = widget.bill.categoryId;
    _description = widget.bill.description;
    _recurringType = widget.bill.recurringType ?? 'none';
    _categoryRepository = CategoryRepository(widget.bill.userId);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories().first;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoryId = value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  _dueDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _dueDate = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBill() {
    if (!_formKey.currentState!.validate()) return;

    final updatedBill = widget.bill.copyWith(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      categoryId: _categoryId,
      description: _description,
      dueDate: _dueDate,
      recurringType: _recurringType,
      updatedAt: DateTime.now(),
    );

    // Save the bill and navigate back
    Navigator.pop(context, updatedBill);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
} 