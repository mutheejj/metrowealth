import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/bills/presentation/widgets/bills_action_sheet.dart';

class QuickActions extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActions({
    Key? key,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              'Send',
              Icons.send_rounded,
              AppColors.primary,
              () => onActionSelected('send'),
            ),
            _buildActionItem(
              'Request',
              Icons.request_page_rounded,
              Colors.green,
              () => onActionSelected('request'),
            ),
            _buildActionItem(
              'Scan',
              Icons.qr_code_scanner_rounded,
              Colors.purple,
              () => onActionSelected('scan'),
            ),
            _buildActionItem(
              'Bills',
              Icons.receipt_long_rounded,
              Colors.orange,
              () => _handleBillsAction(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBillsAction() {
    onActionSelected('bills'); // Let the parent handle the bills action
  }
} 