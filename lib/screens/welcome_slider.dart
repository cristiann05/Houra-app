import 'package:flutter/material.dart';
import 'package:houra_app/screens/auth_screen.dart';
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

  void _irAPagina(int index) => setState(() => _currentPage = index);

  Widget _page(int index, Widget child) =>
      // Pausa las animaciones (orbe, flotación) de las pantallas ocultas
      TickerMode(enabled: _currentPage == index, child: child);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // En la primera página se sale de la app; en el resto, atrás = página anterior
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irAPagina(_currentPage - 1);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentPage,
          children: [
            _page(0, WelcomeScreen(onNext: () => _irAPagina(1), isActive: _currentPage == 0)),
            _page(1, Welcome2(onNext: () => _irAPagina(2), isActive: _currentPage == 1)),
            _page(2, Welcome3(onNext: () => _irAPagina(3), isActive: _currentPage == 2)),
            _page(3, AuthScreen(onNext: () {}, isActive: _currentPage == 3)),
          ],
        ),
      ),
    );
  }
}