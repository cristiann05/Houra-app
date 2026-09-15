import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:houra_app/firebase_options.dart';
import 'package:houra_app/screens/auth_gate.dart';
import 'package:houra_app/theme/app_colors.dart';

void main() async {
  // Asegura la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones de la plataforma actual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa los datos de idioma para poder usar DateFormat(..., 'es')
  await initializeDateFormatting('es', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Quita la etiqueta roja de debug en la esquina
      debugShowCheckedModeBanner: false,

      // Configuración de colores globales para la selección de texto
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.colorLima,
          selectionColor: AppColors.colorLima.withOpacity(0.3), // Usamos .withOpacity para mantener compatibilidad estable
          selectionHandleColor: AppColors.colorLima,
        ),
      ),

      // Acceso directo al flujo de autenticación (limpio de simuladores)
      home: const AuthGate(),
    );
  }
}