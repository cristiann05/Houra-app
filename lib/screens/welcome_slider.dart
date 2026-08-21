import 'package:flutter/material.dart';
import 'package:houra_app/screens/auth_screen.dart';
import 'package:houra_app/screens/home_screen.dart';
import 'package:houra_app/screens/welcome.dart';
import 'package:houra_app/screens/welcome_2.dart';
import 'package:houra_app/screens/welcome_3.dart';

class WelcomeSlider extends StatefulWidget {
  const WelcomeSlider({super.key});

  @override
  State<WelcomeSlider> createState() => _WelcomeSliderState();
}

class _WelcomeSliderState extends State<WelcomeSlider> {
  int _currentPage = 0;

  void _irAPagina(int index) {
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPage,
        children: [
          WelcomeScreen(onNext: () => _irAPagina(1), isActive: _currentPage == 0),
          Welcome2(onNext: () => _irAPagina(2), isActive: _currentPage == 1),
          Welcome3(onNext: () => _irAPagina(3), isActive: _currentPage == 2),
          AuthScreen(
            isActive: _currentPage == 3,
            onNext: () {},
            onBack: () => _irAPagina(2), // 👈 vuelve a Welcome3
          ),
        ],
      ),
    );
  }
}