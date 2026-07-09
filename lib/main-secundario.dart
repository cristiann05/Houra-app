import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:houra_app/firebase_options.dart';
import 'package:houra_app/screens/welcome_slider.dart';
import 'package:houra_app/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          selectionColor: AppColors.colorLima.withValues(alpha: 0.3),
          selectionHandleColor: AppColors.colorLima,
        ),
      ),
      home: const WelcomeSlider(),
    );
  }
}