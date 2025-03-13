import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/features/loans/data/services/loan_service.dart';

class LoanApplicationPage extends StatefulWidget {
  const LoanApplicationPage({super.key});

  @override
  State<LoanApplicationPage> createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _selectedDocumentPath;
  final _loanService = LoanService();
  
  // Form controllers
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _employerController = TextEditingController();
  final _employmentDurationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Selected values
  String? _selectedLoanType;
  int? _selectedTenure;
  String? _selectedEmploymentType = 'Full-time';
  
  // Employment types
  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Business owner',
    'Other'
  ];
  
  // Loan products
  final List<Map<String, dynamic>> _loanProducts = [
    {
      'id': 'personal',
      'name': 'Personal Loan',
      'description': 'Quick unsecured loans for personal use',
      'minAmount': 10000,
      'maxAmount': 500000,
      'interestRate': 14.5,
      'tenures': [6, 12, 24, 36],
      'icon': Icons.person,
    },
    {
      'id': 'business',
      'name': 'Business Loan',
      'description': 'Grow your business with flexible financing',
      'minAmount': 50000,
      'maxAmount': 2000000,
      'interestRate': 16.0,
      'tenures': [12, 24, 36, 48, 60],
      'icon': Icons.business,
    },
    {
      'id': 'education',
      'name': 'Education Loan',
      'description': 'Invest in your future with education financing',
      'minAmount': 20000,
      'maxAmount': 1000000,
      'interestRate': 12.0,
      'tenures': [12, 24, 36, 48, 60],
      'icon': Icons.school,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _monthlyIncomeController.dispose();
    _employerController.dispose();
    _employmentDurationController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final selectedProduct = _loanProducts.firstWhere(
        (product) => product['id'] == _selectedLoanType,
      );

      // Check loan eligibility
      final isEligible = await _loanService.isEligibleForLoan(
        FirebaseAuth.instance.currentUser!.uid,
      );
      
      if (!isEligible) {
        throw 'You have reached the maximum number of active loans';
      }

      // Prepare loan data
      final loanData = {
        'productId': selectedProduct['id'],
        'productName': selectedProduct['name'],
        'amount': double.parse(_amountController.text),
        'tenure': _selectedTenure,
        'purpose': _purposeController.text,
        'interestRate': selectedProduct['interestRate'],
        'monthlyIncome': double.parse(_monthlyIncomeController.text),
        'employer': _employerController.text,
        'employmentDuration': double.parse(_employmentDurationController.text),
      };

      await _loanService.submitLoanApplication(loanData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan application submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Application'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              if (_currentStep == 0 && _selectedLoanType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a loan product')),
                );
                return;
              }
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep++);
              }
            } else {
              _submitApplication();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            _buildLoanProductStep(),
            _buildLoanDetailsStep(),
            _buildPersonalInfoStep(),
            _buildConfirmationStep(),
          ],
        ),
      ),
    );
  }

  Step _buildLoanProductStep() {
    return Step(
      title: const Text('Select Loan Product'),
      content: Column(
        children: _loanProducts.map((product) => _buildLoanProductCard(product)).toList(),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildLoanProductCard(Map<String, dynamic> product) {
    final isSelected = _selectedLoanType == product['id'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedLoanType = product['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  product['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Interest Rate: ${product['interestRate']}% p.a.',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildLoanDetailsStep() {
    final selectedProduct = _loanProducts.firstWhere(
      (product) => product['id'] == _selectedLoanType,
      orElse: () => _loanProducts.first,
    );

    return Step(
      title: const Text('Loan Details'),
      content: Column(
        children: [
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Loan Amount',
              prefixText: 'KSH ',
              helperText:
                  'Min: ${selectedProduct['minAmount']} - Max: ${selectedProduct['maxAmount']}',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final amount = double.tryParse(value);
              if (amount == null) return 'Invalid amount';
              if (amount < selectedProduct['minAmount']) {
                return 'Amount too low';
              }
              if (amount > selectedProduct['maxAmount']) {
                return 'Amount too high';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedTenure,
            decoration: const InputDecoration(
              labelText: 'Loan Tenure',
            ),
            items: (selectedProduct['tenures'] as List<int>).map((tenure) {
              return DropdownMenuItem(
                value: tenure,
                child: Text('$tenure months'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTenure = value),
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _purposeController,
            decoration: const InputDecoration(
              labelText: 'Loan Purpose',
              hintText: 'Briefly describe why you need this loan',
            ),
            maxLines: 3,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please describe loan purpose' : null,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildPersonalInfoStep() {
    return Step(
      title: const Text('Employment Details'),
      content: Column(
        children: [
          TextFormField(
            controller: _monthlyIncomeController,
            decoration: const InputDecoration(
              labelText: 'Monthly Income',
              prefixText: 'KSH ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final amount = double.tryParse(value);
              if (amount == null) return 'Invalid amount';
              if (amount < 10000) return 'Income too low';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _employerController,
            decoration: const InputDecoration(
              labelText: 'Employer Name',
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _employmentDurationController,
            decoration: const InputDecoration(
              labelText: 'Employment Duration (Years)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final years = double.tryParse(value);
              if (years == null) return 'Invalid duration';
              if (years < 0.5) return 'Minimum 6 months required';
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildConfirmationStep() {
    final selectedProduct = _loanProducts.firstWhere(
      (product) => product['id'] == _selectedLoanType,
      orElse: () => _loanProducts.first,
    );

    return Step(
      title: const Text('Confirm Application'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfirmationSection(
            'Loan Product',
            selectedProduct['name'],
          ),
          _buildConfirmationSection(
            'Loan Amount',
            'KSH ${_amountController.text}',
          ),
          _buildConfirmationSection(
            'Tenure',
            '$_selectedTenure months',
          ),
          _buildConfirmationSection(
            'Interest Rate',
            '${selectedProduct['interestRate']}% p.a.',
          ),
          _buildConfirmationSection(
            'Monthly Income',
            'KSH ${_monthlyIncomeController.text}',
          ),
          _buildConfirmationSection(
            'Employer',
            _employerController.text,
          ),
          const SizedBox(height: 24),
          const Text(
            'Terms & Conditions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '• I confirm that all information provided is accurate\n'
            '• I authorize the bank to verify my information\n'
            '• I understand that providing false information may lead to rejection',
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: StepState.indexed,
    );
  }

  Widget _buildConfirmationSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}