// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:houra_app/main.dart' show flutterLocalNotificationsPlugin;
import 'package:houra_app/models/entry.dart';
import 'package:houra_app/models/houra_user.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/screens/change_password_screen.dart';
import 'package:houra_app/screens/legal_screen.dart';
import 'package:houra_app/screens/welcome_slider.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/formatters.dart';
import 'package:houra_app/utils/home_stats.dart';
import 'package:houra_app/utils/legal_text.dart';
import 'package:houra_app/widgets/app_toast.dart';
import 'package:houra_app/widgets/data_error_view.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  bool _editingRate = false;
  late final TextEditingController _rateController;
  bool _savingRate = false;

  bool _editingGoal = false;
  late final TextEditingController _goalController;
  bool _savingGoal = false;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _rateController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveRate() async {
    final value = double.tryParse(_rateController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      AppToast.show(context, message: 'Tarifa no válida', emoji: '⚠️', type: ToastType.error);
      return;
    }
    setState(() => _savingRate = true);
    try {
      var timedOut = false;
      await _authRepo.updateHourlyRate(value).timeout(const Duration(seconds: 4), onTimeout: () => timedOut = true);
      if (!mounted) return;
      setState(() {
        _editingRate = false;
        _savingRate = false;
      });
      HouraNotification.show(
        context,
        title: timedOut ? 'Guardado sin conexión' : 'Tarifa actualizada',
        subtitle: timedOut ? 'Se sincronizará solo' : '${trimZeros(value)}€/h',
        type: timedOut ? HouraBannerType.info : HouraBannerType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingRate = false);
      AppToast.show(context, message: 'No se ha podido guardar', emoji: '⚠️', type: ToastType.error);
    }
  }

  Future<void> _saveGoal() async {
    final value = double.tryParse(_goalController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      AppToast.show(context, message: 'Meta no válida', emoji: '⚠️', type: ToastType.error);
      return;
    }
    setState(() => _savingGoal = true);
    try {
      var timedOut = false;
      await _authRepo.updateGoalHours(value).timeout(const Duration(seconds: 4), onTimeout: () => timedOut = true);
      if (!mounted) return;
      setState(() {
        _editingGoal = false;
        _savingGoal = false;
      });
      HouraNotification.show(
        context,
        title: timedOut ? 'Guardado sin conexión' : 'Meta actualizada',
        subtitle: timedOut ? 'Se sincronizará solo' : '${trimZeros(value)} h al mes',
        type: timedOut ? HouraBannerType.info : HouraBannerType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingGoal = false);
      AppToast.show(context, message: 'No se ha podido guardar', emoji: '⚠️', type: ToastType.error);
    }
  }

  Future<void> _editName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorSuperficie,
        title: Text('Cambiar nombre', style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
          decoration: InputDecoration(hintText: 'Tu nombre', hintStyle: TextStyle(color: AppColors.colorTextoTenue)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar', style: TextStyle(color: AppColors.colorTextoTenue))),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Guardar', style: TextStyle(color: AppColors.colorLima, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == currentName) return;
    try {
      await _authRepo.updateName(newName);
      if (!mounted) return;
      HouraNotification.show(context, title: 'Nombre actualizado', subtitle: newName, type: HouraBannerType.success);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'No se ha podido guardar', emoji: '⚠️', type: ToastType.error);
    }
  }

  Future<void> _editCustomTag(String tag) async {
    final controller = TextEditingController(text: tag);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorSuperficie,
        title: Text('Editar categoría', style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: Text('Borrar', style: TextStyle(color: AppColors.colorError, fontWeight: FontWeight.w700)),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar', style: TextStyle(color: AppColors.colorTextoTenue))),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save:${controller.text.trim()}'),
            child: Text('Guardar', style: TextStyle(color: AppColors.colorLima, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (action == null) return;

    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.colorSuperficie,
          title: Text('Borrar "$tag"', style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700)),
          content: Text(
            'Las entradas ya guardadas con esta categoría no se borran, solo desaparece de la lista para crear nuevas.',
            style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar', style: TextStyle(color: AppColors.colorTextoTenue))),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Borrar', style: TextStyle(color: AppColors.colorError, fontWeight: FontWeight.w700))),
          ],
        ),
      );
      if (confirmed != true) return;
      try {
        await _authRepo.removeCustomTag(tag);
        if (!mounted) return;
        HouraNotification.show(context, title: 'Categoría borrada', subtitle: tag, type: HouraBannerType.info);
      } catch (e) {
        if (!mounted) return;
        AppToast.show(context, message: 'No se ha podido borrar', emoji: '⚠️', type: ToastType.error);
      }
      return;
    }

    if (action.startsWith('save:')) {
      final newName = action.substring(5);
      if (newName.isEmpty || newName == tag) return;
      try {
        await _authRepo.renameCustomTag(tag, newName);
        await EntryRepository().renameTagInEntries(tag, newName);
        if (!mounted) return;
        HouraNotification.show(context, title: 'Categoría renombrada', subtitle: '$tag → $newName', type: HouraBannerType.success);
      } catch (e) {
        if (!mounted) return;
        AppToast.show(context, message: 'No se ha podido renombrar', emoji: '⚠️', type: ToastType.error);
      }
    }
  }

  Future<void> _testNotification() async {
    await flutterLocalNotificationsPlugin.show(
      999,
      '¡Funciona! 🎉',
      'Las notificaciones de Houra están activas en este dispositivo.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Prueba',
          channelDescription: 'Notificación de prueba manual',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authRepo.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeSlider()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorSuperficie,
        title: Text('Eliminar cuenta', style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700)),
        content: Text(
          'Se borrará tu perfil y todas tus horas registradas de forma permanente. Esta acción no se puede deshacer.',
          style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: AppColors.colorTextoTenue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar', style: TextStyle(color: AppColors.colorError, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await _authRepo.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeSlider()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        AppToast.show(
          context,
          message: 'Por seguridad, cierra sesión y vuelve a entrar antes de borrar la cuenta',
          emoji: '🔒',
          type: ToastType.error,
        );
      } else {
        AppToast.show(context, message: 'No se ha podido eliminar la cuenta', emoji: '⚠️', type: ToastType.error);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'No se ha podido eliminar la cuenta', emoji: '⚠️', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: StreamBuilder<HouraUser?>(
          stream: _authRepo.watchCurrentUser(),
          builder: (context, userSnap) {
            final user = userSnap.data;
            return StreamBuilder<List<Entry>>(
              stream: EntryRepository().watchEntries(),
              builder: (context, entriesSnap) {
                final entries = entriesSnap.data ?? const <Entry>[];
                final stats = HomeStats.from(entries);

                if (userSnap.hasError && user == null) {
                  return const DataErrorView();
                }

                if (user != null && !_editingRate && _rateController.text.isEmpty) {
                  _rateController.text = trimZeros(user.hourlyRate);
                }
                if (user != null && !_editingGoal && _goalController.text.isEmpty) {
                  _goalController.text = trimZeros(user.goalHours);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    Center(
                      child: Text('Perfil',
                          style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 20)),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.colorLima,
                            child: Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                              style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoNegro, fontWeight: FontWeight.w800, fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _editName(user?.name ?? ''),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(user?.name ?? '',
                                    style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 22)),
                                const SizedBox(width: 8),
                                const Icon(Icons.edit, size: 16, color: AppColors.colorTextoTenue),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(user?.email ?? '', style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: _MiniStat(label: 'Horas', value: hoursFmt.format(stats.totalHoursMonth))),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniStat(label: 'Ganado', value: moneyFmt.format(stats.totalEarnMonth))),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniStat(label: 'Racha', value: '${stats.streak}d')),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SectionLabel('Trabajo'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _Row(
                            icon: Icons.euro,
                            color: AppColors.colorLima,
                            label: 'Tarifa por hora',
                            trailing: _editingRate
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller: _rateController,
                                          autofocus: true,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                          style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 15),
                                          decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('€/h', style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      _savingRate
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.colorLima))
                                          : GestureDetector(
                                              onTap: _saveRate,
                                              child: const Icon(Icons.check_circle, color: AppColors.colorLima, size: 22),
                                            ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () => setState(() => _editingRate = true),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${user != null ? trimZeros(user.hourlyRate) : '—'}€/h',
                                            style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.edit, size: 15, color: AppColors.colorTextoTenue),
                                      ],
                                    ),
                                  ),
                          ),
                          _Row(
                            icon: Icons.flag,
                            color: AppColors.colorMenta,
                            label: 'Meta mensual',
                            last: true,
                            trailing: _editingGoal
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: TextField(
                                          controller: _goalController,
                                          autofocus: true,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                          style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 15),
                                          decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('h', style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      _savingGoal
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.colorLima))
                                          : GestureDetector(
                                              onTap: _saveGoal,
                                              child: const Icon(Icons.check_circle, color: AppColors.colorLima, size: 22),
                                            ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () => setState(() => _editingGoal = true),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${user != null ? trimZeros(user.goalHours) : '—'} h/mes',
                                            style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.edit, size: 15, color: AppColors.colorTextoTenue),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Cuenta'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(16)),
                      child: _Row(
                        icon: Icons.lock_outline,
                        color: AppColors.colorLila,
                        label: 'Cambiar contraseña',
                        last: true,
                        trailing: const Icon(Icons.chevron_right, color: AppColors.colorTextoTenue),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                      ),
                    ),
                    if (user != null && user.customTags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionLabel('Mis categorías'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            for (int i = 0; i < user.customTags.length; i++)
                              _Row(
                                icon: Icons.label_outline,
                                color: AppTags.colorOf(user.customTags[i]),
                                label: user.customTags[i],
                                last: i == user.customTags.length - 1,
                                trailing: const Icon(Icons.edit, size: 16, color: AppColors.colorTextoTenue),
                                onTap: () => _editCustomTag(user.customTags[i]),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionLabel('Notificaciones'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(16)),
                      child: _Row(
                        icon: Icons.notifications_active_outlined,
                        color: AppColors.colorMenta,
                        label: 'Probar notificación',
                        last: true,
                        trailing: const Icon(Icons.chevron_right, color: AppColors.colorTextoTenue),
                        onTap: _testNotification,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Legal'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _Row(
                            icon: Icons.shield_outlined,
                            color: AppColors.colorCielo,
                            label: 'Política de privacidad',
                            trailing: const Icon(Icons.chevron_right, color: AppColors.colorTextoTenue),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const LegalScreen(title: 'Política de privacidad', body: kPrivacyPolicy),
                            )),
                          ),
                          _Row(
                            icon: Icons.description_outlined,
                            color: AppColors.colorLila,
                            label: 'Términos y condiciones',
                            trailing: const Icon(Icons.chevron_right, color: AppColors.colorTextoTenue),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const LegalScreen(title: 'Términos y condiciones', body: kTermsAndConditions),
                            )),
                          ),
                          _Row(
                            icon: Icons.delete_forever_outlined,
                            color: AppColors.colorError,
                            label: 'Eliminar cuenta',
                            last: true,
                            trailing: const Icon(Icons.chevron_right, color: AppColors.colorTextoTenue),
                            onTap: _confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: AppColors.colorTextoTenue, size: 19),
                        label: Text('Cerrar sesión',
                            style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.colorGraficosNegrogris),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text('Houra · v1.0',
                          style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 11)),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Text(text.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 11, letterSpacing: 1.1)),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final bool last;
  final VoidCallback? onTap;
  const _Row({required this.icon, required this.color, required this.label, required this.trailing, this.last = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: AppColors.colorGraficosNegrogris)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label, style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}