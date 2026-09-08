// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:houra_app/screens/main_shell.dart';
import 'package:houra_app/screens/welcome_slider.dart';
import 'package:houra_app/theme/app_colors.dart';

/// Decide si el usuario entra directo a la app (sesión ya iniciada,
/// persistida por Firebase Auth) o si tiene que pasar por welcome/login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.colorFondo,
            body: Center(child: CircularProgressIndicator(color: AppColors.colorLima)),
          );
        }
        if (snapshot.hasData) {
          return const MainShell();
        }
        return const WelcomeSlider();
      },
    );
  }
}