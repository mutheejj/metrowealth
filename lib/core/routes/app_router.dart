import 'package:flutter/material.dart';
import 'package:metrowealth/features/home/presentation/pages/home_container.dart';
import 'package:metrowealth/features/bills/presentation/pages/bills_page.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/home/presentation/pages/not_found_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/bills':
        return MaterialPageRoute(builder: (_) => const BillsPage());
      // Add other routes
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }
} 