import 'package:flutter/material.dart';
import '../../data/services/bills_service.dart';
import '../../domain/models/bill.dart';
import 'package:intl/intl.dart';

class ViewBillsPage extends StatelessWidget {
  final bool showPaymentOption;
  final bool filterUpcoming;
  final bool showHistory;

  const ViewBillsPage({
    super.key,
    this.showPaymentOption = false,
    this.filterUpcoming = false,
    this.showHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final billsService = BillsService();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showHistory
              ? 'Bill History'
              : filterUpcoming
                  ? 'Upcoming Bills'
                  : 'View Bills',
        ),
      ),
      body: StreamBuilder<List<Bill>>(
        stream: showHistory
            ? billsService.getBillHistory()
            : filterUpcoming
                ? billsService.getUpcomingBills()
                : billsService.getBills(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bills',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading bills...'),
                ],
              ),
            );
          }

          final bills = snapshot.data ?? [];

          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showHistory ? Icons.history : Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    showHistory
                        ? 'No bill history'
                        : filterUpcoming
                            ? 'No upcoming bills'
                            : 'No bills found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-bill');
                    },
                    child: const Text('Add a new bill'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final dueDate = DateTime.now().difference(bill.dueDate).inDays;
              final isOverdue = dueDate > 0 && bill.status == 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => BillDetailsSheet(bill: bill),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bill.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Text(
                              currencyFormat.format(bill.amount),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isOverdue ? Colors.red : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(bill.category),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(bill.dueDate),
                              style: TextStyle(
                                color: isOverdue ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                        if (bill.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            bill.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (showPaymentOption && bill.status == 'pending') ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.payment),
                                label: const Text('Mark as Paid'),
                                onPressed: () async {
                                  try {
                                    await billsService.markBillAsPaid(bill.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Bill marked as paid'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: !showHistory
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-bill');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class BillDetailsSheet extends StatelessWidget {
  final Bill bill;

  const BillDetailsSheet({
    super.key,
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bill Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Title',
            bill.title,
            Icons.description,
          ),
          _buildDetailRow(
            context,
            'Amount',
            NumberFormat.currency(symbol: '\$').format(bill.amount),
            Icons.attach_money,
          ),
          _buildDetailRow(
            context,
            'Due Date',
            DateFormat('MMMM dd, yyyy').format(bill.dueDate),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            context,
            'Category',
            bill.category,
            Icons.category,
          ),
          _buildDetailRow(
            context,
            'Status',
            bill.status.capitalize(),
            Icons.info,
          ),
          if (bill.isRecurring)
            _buildDetailRow(
              context,
              'Recurring',
              bill.recurringPeriod.capitalize(),
              Icons.repeat,
            ),
          if (bill.description.isNotEmpty)
            _buildDetailRow(
              context,
              'Description',
              bill.description,
              Icons.notes,
            ),
          const SizedBox(height: 24),
          if (bill.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Mark as Paid'),
                onPressed: () async {
                  try {
                    await BillsService().markBillAsPaid(bill.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bill marked as paid'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 