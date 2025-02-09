import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/banking/data/models/bank_account_model.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final double amount;
  final String title;
  final String? billId;
  final VoidCallback? onPaymentComplete;

  const PaymentPage({
    Key? key,
    required this.amount,
    required this.title,
    this.billId,
    this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  bool _isLoading = true;
  List<BankAccountModel> _accounts = [];
  BankAccountModel? _selectedAccount;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await _db.getUserBankAccounts();
      setState(() {
        _accounts = accounts;
        _selectedAccount = accounts.firstWhere(
          (account) => account.isDefault,
          orElse: () => accounts.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error
    }
  }

  Future<void> _processPayment() async {
    if (_selectedAccount == null) return;

    setState(() => _isProcessing = true);
    try {
      await _db.processPayment(
        amount: widget.amount,
        fromAccount: _selectedAccount!.id,
        title: widget.title,
        billId: widget.billId,
      );

      widget.onPaymentComplete?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentSummary(),
                  const SizedBox(height: 24),
                  _buildAccountSelection(),
                  const SizedBox(height: 24),
                  _buildPaymentButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _currencyFormat.format(widget.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_accounts.length, (index) {
          final account = _accounts[index];
          return RadioListTile<BankAccountModel>(
            value: account,
            groupValue: _selectedAccount,
            onChanged: (value) {
              setState(() => _selectedAccount = value);
            },
            title: Text(account.bankName),
            subtitle: Text(
              'xxxx ${account.accountNumber.substring(account.accountNumber.length - 4)}',
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
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
                'Pay ${_currencyFormat.format(widget.amount)}',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
} 