import 'package:flutter/material.dart';
import '../widgets/mpesa_payment_button.dart';

class PaymentScreen extends StatelessWidget {
  final String userId;

  const PaymentScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: Center(
        child: MPesaPaymentButton(userId: userId),
      ),
    );
  }
}