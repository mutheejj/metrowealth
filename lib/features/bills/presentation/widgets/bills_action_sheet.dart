import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/bills/presentation/pages/add_bill_page.dart';
import 'package:metrowealth/features/bills/presentation/pages/view_bills_page.dart';
import 'package:metrowealth/features/bills/presentation/pages/bill_reminder_settings.dart';

class BillsActionSheet extends StatelessWidget {
  const BillsActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add New Bill'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddBillPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('View All Bills'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewBillsPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Pay Bills'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewBillsPage(showPaymentOption: true),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.upcoming),
          title: const Text('Upcoming Bills'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewBillsPage(filterUpcoming: true),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Bill History'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewBillsPage(showHistory: true),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Reminder Settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BillReminderSettings(),
              ),
            );
          },
        ),
      ],
    );
  }
} 