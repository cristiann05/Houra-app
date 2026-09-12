// lib/screens/change_password_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/app_toast.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authRepo.reauthenticate(_currentController.text);
      await _authRepo.updatePassword(_newController.text);
      if (!mounted) return;
      HouraNotification.show(context, title: 'Contraseña actualizada', type: HouraBannerType.success);
      Navigator.of(context).maybePop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'La contraseña actual no es correcta';
          break;
        case 'weak-password':
          msg = 'La nueva contraseña es demasiado débil';
          break;
        case 'requires-recent-login':
          msg = 'Por seguridad, cierra sesión y vuelve a entrar para cambiarla';
          break;
        default:
          msg = 'No se ha podido cambiar la contraseña';
      }
      AppToast.show(context, message: msg, emoji: '⚠️', type: ToastType.error);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'No se ha podido cambiar la contraseña', emoji: '⚠️', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, {required bool obscure, required VoidCallback toggle}) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
        filled: true,
        fillColor: AppColors.colorSuperficie,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.colorTextoTenue, size: 19),
          onPressed: toggle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.colorTexto),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Text('Cambiar contraseña',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                  decoration: _decoration('Contraseña actual',
                      obscure: _obscureCurrent, toggle: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _newController,
                  obscureText: _obscureNew,
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                  decoration: _decoration('Nueva contraseña',
                      obscure: _obscureNew, toggle: () => setState(() => _obscureNew = !_obscureNew)),
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureNew,
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                  decoration: _decoration('Repite la nueva contraseña',
                      obscure: _obscureNew, toggle: () => setState(() => _obscureNew = !_obscureNew)),
                  validator: (v) => v != _newController.text ? 'No coincide' : null,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorLima,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.colorTextoNegro))
                        : Text('Guardar',
                            style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoNegro, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}