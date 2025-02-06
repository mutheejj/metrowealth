import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:metrowealth/features/auth/data/repositories/auth_repository.dart';
import 'package:metrowealth/features/auth/presentation/pages/welcome_screen.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthRepository().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return const HomePage();
        }

        return const WelcomeScreen();
      },
    );
  }
} 