import 'package:flutter/material.dart';
import 'package:houra_app/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.colorFondo, // para verlo claramente
    body: Center(child: Text("Login", style: TextStyle(color:AppColors.colorTexto)),),
  );
}
}