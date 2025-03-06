import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            onPressed: () {
              // Mark all as read
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: ListView(
          children: [
            _buildDateSection(
              'Today',
              [
                _buildNotificationItem(
                  icon: Icons.notifications_active_outlined,
                  color: Colors.green,
                  title: 'Reminder!',
                  message: 'Set up your automatic savings to meet your savings goal...',
                  time: '17:00 - April 24',
                ),
                _buildNotificationItem(
                  icon: Icons.system_update_outlined,
                  color: Colors.green,
                  title: 'New Update',
                  message: 'Set up your automatic savings to meet your savings goal...',
                  time: '17:00 - April 24',
                ),
              ],
            ),
            _buildDateSection(
              'Yesterday',
              [
                _buildNotificationItem(
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.blue,
                  title: 'Transactions',
                  message: 'A new transaction has been registered',
                  subtitle: 'Groceries | Pantry | -KSH 100.00',
                  time: '17:00 - April 24',
                  showSubtitle: true,
                ),
                _buildNotificationItem(
                  icon: Icons.notifications_active_outlined,
                  color: Colors.green,
                  title: 'Reminder!',
                  message: 'Set up your automatic savings to meet your savings goal...',
                  time: '17:00 - April 24',
                ),
              ],
            ),
            _buildDateSection(
              'This Weekend',
              [
                _buildNotificationItem(
                  icon: Icons.insert_chart_outlined,
                  color: Colors.orange,
                  title: 'Expense Record',
                  message: 'We recommend that you be more attentive to your finances...',
                  time: '17:00 - April 24',
                ),
                _buildNotificationItem(
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.blue,
                  title: 'Transactions',
                  message: 'A new transaction has been registered',
                  subtitle: 'Food | Dinner | -KSH 74.65',
                  time: '17:00 - April 24',
                  showSubtitle: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(String date, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        ...notifications,
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    String? subtitle,
    bool showSubtitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}