import 'package:flutter/material.dart';
import '../../../../core/services/mpesa_service.dart';
import 'package:intl/intl.dart';

class SendMoneySheet extends StatefulWidget {
  const SendMoneySheet({super.key});

  @override
  State<SendMoneySheet> createState() => _SendMoneySheetState();
}

class _SendMoneySheetState extends State<SendMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _noteController = TextEditingController();
  final _accountController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedTransactionType = 'send_money';
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _transactionTypes = [
    {'id': 'send_money', 'name': 'Send Money', 'icon': Icons.send},
    {'id': 'pay_bill', 'name': 'Pay Bill', 'icon': Icons.receipt},
    {'id': 'buy_goods', 'name': 'Buy Goods', 'icon': Icons.shopping_cart},
    {'id': 'bank_transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'mpesa', 'name': 'M-PESA', 'icon': Icons.phone_android},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'id': 'bank', 'name': 'Bank Account', 'icon': Icons.account_balance},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _noteController.dispose();
    _accountController.dispose();
    _billNumberController.dispose();
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTransactionTypes(),
                      const SizedBox(height: 24),
                      _buildPaymentMethods(),
                      const SizedBox(height: 24),
                      _buildTransactionForm(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleTransaction,
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
        Text(
          _getHeaderTitle(),
          style: const TextStyle(
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

  String _getHeaderTitle() {
    switch (_selectedTransactionType) {
      case 'pay_bill':
        return 'Pay Bill';
      case 'buy_goods':
        return 'Buy Goods';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return 'Send Money';
    }
  }

  Widget _buildTransactionTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _transactionTypes.map((type) {
              final isSelected = _selectedTransactionType == type['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type['name']),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTransactionType = type['id']);
                    }
                  },
                  avatar: Icon(type['icon']),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _paymentMethods.length,
          (index) => _buildMethodTile(_paymentMethods[index]),
        ),
      ],
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    return ListTile(
      leading: Icon(method['icon'] as IconData),
      title: Text(method['name']),
      trailing: isSelected ? const Icon(Icons.check_circle) : null,
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
        ),
      ),
      onTap: () => setState(() => _selectedPaymentMethod = method['id']),
    );
  }

  Widget _buildTransactionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixIcon: Icon(Icons.attach_money),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        if (_selectedPaymentMethod == 'mpesa') ...[          
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '254XXXXXXXXX',
              prefixIcon: Icon(Icons.phone_android),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (!value.startsWith('254')) {
                return 'Phone number must start with 254';
              }
              if (value.length != 12) {
                return 'Phone number must be 12 digits';
              }
              return null;
            },
          ),
        ] else ...[          
          TextFormField(
            controller: _recipientController,
            decoration: const InputDecoration(
              labelText: 'Recipient',
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSendMoneyForm() {
    return Column(
      children: [
        TextFormField(
          controller: _recipientController,
          decoration: const InputDecoration(
            labelText: 'Recipient Phone/Account',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Note (Optional)',
            prefixIcon: Icon(Icons.note),
          ),
        ),
      ],
    );
  }

  Widget _buildPayBillForm() {
    return Column(
      children: [
        TextFormField(
          controller: _billNumberController,
          decoration: const InputDecoration(
            labelText: 'Business Number',
            prefixIcon: Icon(Icons.business),
            hintText: 'Enter business/paybill number',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            prefixIcon: Icon(Icons.account_box),
            hintText: 'Enter account number',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
      ],
    );
  }

  Widget _buildBuyGoodsForm() {
    return Column(
      children: [
        TextFormField(
          controller: _billNumberController,
          decoration: const InputDecoration(
            labelText: 'Till Number',
            prefixIcon: Icon(Icons.store),
            hintText: 'Enter till number',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Note (Optional)',
            prefixIcon: Icon(Icons.note),
            hintText: 'Add a note for this purchase',
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
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
          controller: _accountController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            prefixIcon: Icon(Icons.account_box),
            hintText: 'Enter account number',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
            prefixIcon: Icon(Icons.person),
            hintText: 'Enter account holder name',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Transfer Purpose (Optional)',
            prefixIcon: Icon(Icons.note),
            hintText: 'e.g., Rent payment, Business transaction',
          ),
        ),
      ],
    );
  }

  void _handleTransaction() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      try {
        if (_selectedPaymentMethod == 'mpesa') {
          final mpesaService = MPesaService(
            consumerKey: '26T9o63rBICAgJBXd7ZkpyJOVxCNfIF5FraNIbEQsznoqMyc',
            consumerSecret: 'nrS2pXck3cLLiKPE23vBkJYN1c3sTXTAGVcdIjPUhiHyudpYITso49Qul2ihxfAD',
          );

          final result = await mpesaService.initiateSTKPush(
            phoneNumber: _phoneController.text,
            amount: double.parse(_amountController.text),
            userId: 'USER_ID', // Replace with actual user ID
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction initiated successfully')),
            );
            Navigator.pop(context);
          }
        } else {
          // Handle other payment methods
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction failed: $e')),
          );
        }
      }
    }
  }

  // Add this method to handle card payments
  void _handleCardPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
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
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement card payment logic
              Navigator.pop(context);
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }
}