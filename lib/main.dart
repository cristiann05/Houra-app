import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Detecta si es modo debug
import 'package:device_preview/device_preview.dart';
import 'theme/app_colors.dart';

// Importamos el nuevo contenedor que creamos con el PageView
import 'package:houra_app/screens/welcome_slider.dart'; 

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Activo solo en desarrollo, no en producción
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //el themeData le cambia el color de fondo sombreado cuando seleccionas una palabra directo en toda la app con nuestro lima
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.colorLima, 
      selectionColor: AppColors.colorLima.withOpacity(0.3), 
      selectionHandleColor: AppColors.colorLima, 
    ),
      ),
      debugShowCheckedModeBanner: false, // Quita la etiqueta de debug roja
      
      // Configuración obligatoria para DevicePreview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      // Aquí cargamos el contenedor principal de tus bienvenidas
      home: const WelcomeSlider(),
    );
  }
}