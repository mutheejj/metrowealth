import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';

Widget buildNavItem({
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF757575),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              _getNavLabel(icon),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF757575),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

String _getNavLabel(IconData icon) {
  if (icon == Icons.home_outlined) return 'Home';
  if (icon == Icons.category_outlined) return 'Categories';
  if (icon == Icons.receipt_long_outlined) return 'Transaction';
  if (icon == Icons.analytics_outlined) return 'Analysis';
  if (icon == Icons.person_outline) return 'Account';
  return '';
} 