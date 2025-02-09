import 'package:flutter/material.dart';

class BillReminderSettings extends StatelessWidget {
  const BillReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminder Settings'),
      ),
      body: const Center(
        child: Text('Reminder Settings Form Here'),
      ),
    );
  }
} 