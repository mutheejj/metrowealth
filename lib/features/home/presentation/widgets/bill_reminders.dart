import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/bills/data/models/bill_model.dart';
import 'package:intl/intl.dart';

import '../../../bills/presentation/pages/view_bills_page.dart';
import '../../../payments/presentation/pages/payment_page.dart';

class BillReminders extends StatefulWidget {
  final String userId;

  const BillReminders({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<BillReminders> createState() => _BillRemindersState();
}

class _BillRemindersState extends State<BillReminders> {
  final DatabaseService _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _dateFormat = DateFormat('MMM dd');
  bool _isLoading = true;
  List<BillModel> _upcomingBills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      final overview = await _db.getFinancialOverview(widget.userId);
      setState(() {
        _upcomingBills = (overview['upcomingBills'] as List? ?? [])
            .cast<BillModel>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Bills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewBillsPage(userId: widget.userId),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_upcomingBills.isEmpty)
          const Center(
            child: Text('No upcoming bills'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingBills.length.clamp(0, 3),
            itemBuilder: (context, index) {
              final bill = _upcomingBills[index];
              return _buildBillItem(bill);
            },
          ),
      ],
    );
  }

  Widget _buildBillItem(BillModel bill) {
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysUntilDue <= 3;

    return GestureDetector(
      onTap: () => _showBillActions(bill),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUrgent ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent ? Colors.red : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_outlined,
                  color: isUrgent ? Colors.red : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due ${_dateFormat.format(bill.dueDate)}',
                      style: TextStyle(
                        color: isUrgent ? Colors.red : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currencyFormat.format(bill.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.red : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillActions(BillModel bill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Pay Now'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPayment(bill);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Bill'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditBill(bill);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                await _db.deleteBill(bill.id);
                Navigator.pop(context);
                _loadBills();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(BillModel bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: bill.amount,
          title: bill.title,
          billId: bill.id,
          onPaymentComplete: () {
            _loadBills();
          },
        ),
      ),
    );
  }

  void _navigateToEditBill(BillModel bill) {
    // Implement the logic to navigate to edit bill page
  }
} 