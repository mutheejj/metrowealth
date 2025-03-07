import 'package:flutter/material.dart';
import '../core/services/mpesa_service.dart';

class MPesaPaymentButton extends StatelessWidget {
  final String userId;
  final MPesaService _mpesaService = MPesaService();

  MPesaPaymentButton({super.key, required this.userId});

  Future<void> _showPaymentDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String phoneNumber = '';
    double amount = 0;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('M-Pesa Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '254XXXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!value.startsWith('254')) {
                    return 'Phone number must start with 254';
                  }
                  return null;
                },
                onSaved: (value) => phoneNumber = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                try {
                  Navigator.pop(context);
                  // Show loading indicator
                  _showLoadingDialog(context);
                  
                  final result = await _mpesaService.initiateSTKPush(
                    phoneNumber: phoneNumber,
                    amount: amount,
                    userId: userId,
                  );
                  
                  // Remove loading dialog
                  Navigator.pop(context);
                  
                  // Show success message
                  _showResultDialog(
                    context,
                    'Payment Initiated',
                    'Please check your phone to complete the payment.',
                  );
                } catch (e) {
                  Navigator.pop(context);
                  _showResultDialog(context, 'Error', e.toString());
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showResultDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showPaymentDialog(context),
      icon: const Icon(Icons.payment),
      label: const Text('Pay with M-Pesa'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}