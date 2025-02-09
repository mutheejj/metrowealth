import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/bills/data/models/bill_model.dart';
import 'package:metrowealth/features/bills/data/repositories/bill_repository.dart';
import 'package:metrowealth/features/bills/presentation/pages/bill_details_page.dart';
import 'package:metrowealth/core/constants/app_colors.dart';

class BillsList extends StatelessWidget {
  final String status;

  const BillsList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BillModel>>(
      stream: _getBillsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bills = snapshot.data!;
        if (bills.isEmpty) {
          return Center(child: Text('No ${status.toLowerCase()} bills'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bills.length,
          itemBuilder: (context, index) => _buildBillCard(bills[index]),
        );
      },
    );
  }

  Widget _buildBillCard(BillModel bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(bill.category),
          child: Icon(_getCategoryIcon(bill.category), color: Colors.white),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(bill.title),
            Text(
              DateFormat('MMM d, y').format(bill.dueDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Due: ${DateFormat('MMM d, y').format(bill.dueDate)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${bill.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _getStatusText(bill.status),
              style: TextStyle(
                color: _getStatusColor(bill.status),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _navigateToBillDetails(bill),
      ),
    );
  }

  Stream<List<BillModel>> _getBillsStream() {
    final repository = BillRepository(FirebaseAuth.instance.currentUser!.uid);
    
    switch (status.toLowerCase()) {
      case 'upcoming':
        return repository.getUpcomingBills();
      case 'paid':
        return repository.getPaidBills();
      default:
        return repository.getAllBills();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'utilities':
        return Colors.blue;
      case 'rent':
        return Colors.green;
      case 'insurance':
        return Colors.purple;
      case 'phone':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'utilities':
        return Icons.flash_on;
      case 'rent':
        return Icons.home;
      case 'insurance':
        return Icons.security;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return Colors.green;
      case BillStatus.overdue:
        return Colors.red;
      case BillStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(BillStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }

  void _navigateToBillDetails(BillModel bill) {
    // Navigate to bill details page
  }
} 