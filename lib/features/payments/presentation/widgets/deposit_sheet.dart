import 'package:flutter/material.dart';

class DepositSheet extends StatefulWidget {
  const DepositSheet({super.key});

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedMethod;
  bool _savePaymentMethod = false;

  final List<Map<String, dynamic>> _depositMethods = [
    {
      'id': 'mpesa',
      'name': 'M-PESA',
      'icon': Icons.phone_android,
      'description': 'Instant deposit via M-PESA',
      'fee': '0%',
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, etc.',
      'fee': '2.5%',
    },
    {
      'id': 'bank',
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'description': 'Direct bank transfer',
      'fee': '1%',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAmountInput(),
                      const SizedBox(height: 24),
                      _buildDepositMethods(),
                      if (_selectedMethod != null) ...[
                        const SizedBox(height: 24),
                        _buildMethodDetails(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedMethod != null ? _handleDeposit : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Deposit Money',
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
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Deposit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            hintText: 'Enter amount',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            final amount = double.tryParse(value!);
            if (amount == null) return 'Invalid amount';
            if (amount < 100) return 'Minimum deposit is 100';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepositMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Deposit Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _depositMethods.length,
          (index) => _buildMethodTile(_depositMethods[index]),
        ),
      ],
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      method['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Text(
                      'Fee: ${method['fee']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedMethod == 'card')
          _buildCardDetails()
        else if (_selectedMethod == 'bank')
          _buildBankDetails()
        else if (_selectedMethod == 'mpesa')
          _buildMpesaDetails()
        else
          _buildCashDetails(),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(Icons.credit_card),
            hintText: '•••• •••• •••• ••••',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _savePaymentMethod,
          onChanged: (value) => setState(() => _savePaymentMethod = value ?? false),
          title: const Text('Save card for future use'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Text(
          'Your card details are securely encrypted',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Bank',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: [
            'KCB Bank',
            'Equity Bank',
            'Co-operative Bank',
            'NCBA Bank',
            'Standard Chartered',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {},
          validator: (value) => value == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Number',
            prefixIcon: Icon(Icons.account_box),
            hintText: 'Enter account number',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Name',
            prefixIcon: Icon(Icons.person),
            hintText: 'Enter account holder name',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Bank transfers may take 1-3 business days to process',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMpesaDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            hintText: 'Enter M-PESA registered number',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '1. You will receive an M-PESA prompt on your phone\n'
                '2. Enter your M-PESA PIN to complete the transaction\n'
                '3. Your account will be credited instantly',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashDetails() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visit any of our agent locations:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildAgentLocation(
                'Central Business District',
                'Main Street, Building A, Ground Floor',
                '8:00 AM - 6:00 PM',
              ),
              const Divider(),
              _buildAgentLocation(
                'Westlands Branch',
                'Shopping Mall, 2nd Floor, Shop 23',
                '9:00 AM - 7:00 PM',
              ),
              const Divider(),
              _buildAgentLocation(
                'Eastlands Branch',
                'Market Complex, Ground Floor',
                '8:30 AM - 5:30 PM',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please carry a valid ID for verification',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentLocation(String name, String address, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Operating Hours: $hours',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeposit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement deposit logic based on _selectedMethod
      Navigator.pop(context);
    }
  }
} 