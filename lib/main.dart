import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:metrowealth/core/services/firebase_service.dart';
import 'package:metrowealth/features/auth/presentation/pages/splash_screen.dart';
import 'package:metrowealth/features/home/presentation/pages/home_container.dart';
import 'package:metrowealth/features/budget/presentation/pages/budget_page.dart';
import 'package:metrowealth/features/savings/presentation/pages/savings_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Sign out any existing session on app start
  await FirebaseAuth.instance.signOut();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroWealth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Welcome to MetroWealth'),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error initializing app',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
