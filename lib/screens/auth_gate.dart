// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:houra_app/main.dart' show flutterLocalNotificationsPlugin;
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/screens/main_shell.dart';
import 'package:houra_app/screens/welcome_slider.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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
          return const _AuthenticatedShell();
        }
        return const WelcomeSlider();
      },
    );
  }
}

/// Envuelve MainShell y programa el recordatorio diario una sola vez
/// cuando el usuario ya está autenticado.
class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell();

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  @override
  void initState() {
    super.initState();
    _loadUserAndScheduleReminder();
  }

  Future<void> _loadUserAndScheduleReminder() async {
    final user = await AuthRepository().watchCurrentUser().first;
    final fullName = user?.name ?? '';
    final firstName = fullName.trim().isNotEmpty ? fullName.trim().split(' ').first : 'crack';
    await _scheduleDailyReminder(firstName);
  }

  Future<void> _scheduleDailyReminder(String userName) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // id fijo: si vuelve a programarse, reemplaza la anterior en vez de duplicarla
      '¡Hora de cerrar el día, $userName! 👋',
      'No olvides apuntar tus horas de hoy antes de desconectar.',
      _nextInstanceOf19h(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorio diario',
          channelDescription: 'Recordatorio para apuntar tus horas',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf19h() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Widget build(BuildContext context) {
    return const MainShell();
  }
}