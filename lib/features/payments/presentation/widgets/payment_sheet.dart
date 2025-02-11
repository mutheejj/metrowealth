import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

enum PaymentType {
  sendMoney,
  payBill,
  buyGoods,
  pochiBiashara,
}

class PaymentSheet extends StatefulWidget {
  final double amount;
  final String title;
  final Function() onPaymentComplete;

  const PaymentSheet({
    super.key,
    required this.amount,
    required this.title,
    required this.onPaymentComplete,
  });

  static Future<bool?> show({
    required BuildContext context,
    required double amount,
    required String title,
    required Function() onPaymentComplete,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentSheet(
          amount: amount,
          title: title,
          onPaymentComplete: onPaymentComplete,
        ),
      ),
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  PaymentType _selectedType = PaymentType.sendMoney;
  String? _selectedMethod;
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _businessNoController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isProcessing = false;

  final _currencyFormat = NumberFormat.currency(
    symbol: 'KSH ',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    _accountController.dispose();
    _businessNoController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    String? errorMessage;
    switch (_selectedType) {
      case PaymentType.sendMoney:
        if (_phoneController.text.isEmpty) {
          errorMessage = 'Please enter recipient phone number';
        } else if (_phoneController.text.length != 10) {
          errorMessage = 'Please enter a valid phone number';
        }
        break;
      case PaymentType.payBill:
        if (_businessNoController.text.isEmpty) {
          errorMessage = 'Please enter business number';
        } else if (_accountController.text.isEmpty) {
          errorMessage = 'Please enter account number';
        }
        break;
      case PaymentType.buyGoods:
        if (_businessNoController.text.isEmpty) {
          errorMessage = 'Please enter till number';
        }
        break;
      case PaymentType.pochiBiashara:
        if (_phoneController.text.isEmpty) {
          errorMessage = 'Please enter business phone number';
        }
        break;
    }

    // Additional validation for card and bank payments
    if (_selectedMethod == 'card') {
      if (_cardNumberController.text.isEmpty) {
        errorMessage = 'Please enter card number';
      } else if (_expiryController.text.isEmpty) {
        errorMessage = 'Please enter card expiry date';
      } else if (_cvvController.text.isEmpty) {
        errorMessage = 'Please enter CVV';
      }
    } else if (_selectedMethod == 'bank') {
      if (_bankNameController.text.isEmpty) {
        errorMessage = 'Please enter bank name';
      } else if (_accountNameController.text.isEmpty) {
        errorMessage = 'Please enter account name';
      } else if (_accountController.text.isEmpty) {
        errorMessage = 'Please enter account number';
      }
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // TODO: Implement actual payment processing
      await Future.delayed(const Duration(seconds: 2));
      widget.onPaymentComplete();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Money',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(widget.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTransactionTypes(),
            const SizedBox(height: 24),
            if (_selectedType != PaymentType.pochiBiashara) ...[
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
            ],
            _buildInputFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _getActionButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getActionButtonText() {
    switch (_selectedType) {
      case PaymentType.sendMoney:
        return 'Send Money';
      case PaymentType.payBill:
        return 'Pay Bill';
      case PaymentType.buyGoods:
        return 'Pay Now';
      case PaymentType.pochiBiashara:
        return 'Send to Business';
    }
  }

  Widget _buildTransactionTypes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeOption(
            type: PaymentType.sendMoney,
            icon: Icons.send,
            label: 'Send Money',
          ),
          const SizedBox(width: 12),
          _buildTypeOption(
            type: PaymentType.payBill,
            icon: Icons.receipt_long,
            label: 'Pay Bill',
          ),
          const SizedBox(width: 12),
          _buildTypeOption(
            type: PaymentType.buyGoods,
            icon: Icons.shopping_bag,
            label: 'Buy Goods',
          ),
          const SizedBox(width: 12),
          _buildTypeOption(
            type: PaymentType.pochiBiashara,
            icon: Icons.store,
            label: 'Pochi la Biashara',
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required PaymentType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedMethod = null; // Reset payment method when type changes
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentMethodTile(
          icon: Icons.phone_android,
          title: 'M-PESA',
          subtitle: 'Pay via M-PESA',
          value: 'mpesa',
        ),
        if (_selectedType != PaymentType.pochiBiashara) ...[
          const Divider(height: 1),
          _buildPaymentMethodTile(
            icon: Icons.credit_card,
            title: 'Credit/Debit Card',
            subtitle: 'Pay with Visa, Mastercard, or other cards',
            value: 'card',
          ),
          const Divider(height: 1),
          _buildPaymentMethodTile(
            icon: Icons.account_balance,
            title: 'Bank Account',
            subtitle: 'Pay directly from your bank account',
            value: 'bank',
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedMethod == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedMethod,
        onChanged: (value) => setState(() => _selectedMethod = value),
        activeColor: AppColors.primary,
      ),
      onTap: () => setState(() => _selectedMethod = value),
    );
  }

  Widget _buildInputFields() {
    final paymentFields = _selectedMethod == 'card'
        ? _buildCardFields()
        : _selectedMethod == 'bank'
            ? _buildBankFields()
            : null;

    switch (_selectedType) {
      case PaymentType.sendMoney:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                hintText: '07XX XXX XXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            if (paymentFields != null) ...[
              const SizedBox(height: 24),
              paymentFields,
            ],
          ],
        );

      case PaymentType.payBill:
        return Column(
          children: [
            TextField(
              controller: _businessNoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Business Number',
                hintText: 'Enter business number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                hintText: 'Enter account number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.account_box),
              ),
            ),
            if (paymentFields != null) ...[
              const SizedBox(height: 24),
              paymentFields,
            ],
          ],
        );

      case PaymentType.buyGoods:
        return Column(
          children: [
            TextField(
              controller: _businessNoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Till Number',
                hintText: 'Enter till number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.store),
              ),
            ),
            if (paymentFields != null) ...[
              const SizedBox(height: 24),
              paymentFields,
            ],
          ],
        );

      case PaymentType.pochiBiashara:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Business Phone Number',
                hintText: '07XX XXX XXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: ${_currencyFormat.format(widget.amount)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Text(
                    'Transaction Fee: KSH 0.00',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildCardFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.credit_card),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.security),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Account Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            hintText: 'Enter bank name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_balance),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _accountNameController,
          decoration: InputDecoration(
            labelText: 'Account Name',
            hintText: 'Enter account holder name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _accountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter account number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.account_box),
          ),
        ),
      ],
    );
  }
} 