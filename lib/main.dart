// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:houra_app/firebase_options.dart';
import 'package:houra_app/screens/splash_screen.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:houra_app/services/ad_service.dart';

/// Instancia global del plugin de notificaciones locales,
/// usada también desde auth_gate.dart para programar el recordatorio diario.
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // Todo lo que puede lanzar un error antes de runApp va dentro de la misma
  // zona que runApp, así Crashlytics también captura errores de arranque.
  runZonedGuarded(
    () async {
      // Asegura la inicialización de los bindings de Flutter
      WidgetsFlutterBinding.ensureInitialized();

      // Inicializa Firebase con las opciones de la plataforma actual
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // App Check: en debug usa el proveedor de depuración (necesita registrar el
      // token que sale en el log la primera vez, en Firebase Console > App Check).
      // En release usa Play Integrity de verdad. Mientras no actives "Enforce" en
      // la consola, esto solo informa y no bloquea nada.
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider: kReleaseMode
            ? AppleProvider.appAttest
            : AppleProvider.debug,
      );

      // Manda a Crashlytics los errores de Flutter (widgets) y los no capturados.
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Inicializa los datos de idioma para poder usar DateFormat(..., 'es')
      await initializeDateFormatting('es', null);

      // Inicializa el sistema de notificaciones locales (recordatorio diario)
      await _initNotifications();

      // AdMob: consentimiento GDPR + inicialización de anuncios
      await AdService.instance.init();

      runApp(const MyApp());
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

Future<void> _initNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Pide el permiso explícito de notificaciones (obligatorio en Android 13+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android: iconos claros
        statusBarBrightness: Brightness.dark, // iOS: fondo oscuro
      ),
      child: MaterialApp(
        // Quita la etiqueta roja de debug en la esquina
        debugShowCheckedModeBanner: false,

        // Configuración de colores globales para la selección de texto
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.colorFondo,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.colorLima,
            selectionColor: AppColors.colorLima.withOpacity(0.3),
            selectionHandleColor: AppColors.colorLima,
          ),
        ),

        // Arranca por el splash animado; de ahí pasa solo a AuthGate.
        home: const SplashScreen(),
      ),
    );
  }
}
