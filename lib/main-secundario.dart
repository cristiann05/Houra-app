import 'package:flutter/material.dart';
import 'package:houra_app/screens/welcome_slider.dart';
import 'package:houra_app/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.colorLima,
          selectionColor: AppColors.colorLima.withOpacity(0.3),
          selectionHandleColor: AppColors.colorLima,
        ),
      ),
      home: const WelcomeSlider(),
    );
  }
}