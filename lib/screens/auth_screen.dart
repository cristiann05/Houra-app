import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/screens/forgot_password_screen.dart';
import 'package:houra_app/screens/main_shell.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/app_toast.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';
import 'package:houra_app/widgets/houra_text_field.dart';
import 'package:houra_app/widgets/welcome_shell.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final VoidCallback onNext;
  final bool isActive;

  const AuthScreen({super.key, required this.onNext, this.isActive = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _timeout = Duration(seconds: 25);
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Estilos cacheados: GoogleFonts.xxx() construye un TextStyle nuevo cada
  // vez que se llama. Tras el primer build ya no hace falta reconstruirlos,
  // así que se calculan una sola vez por instancia de la pantalla en vez de
  // en cada build().
  static final _subtitleStyle = GoogleFonts.spaceGrotesk(
    color: AppColors.colorTextoTenue,
    fontSize: 15.5,
    height: 1.4,
  );
  static final _forgotPasswordStyle = GoogleFonts.spaceGrotesk(
    color: AppColors.colorTextoTenue,
  );
  static final _termsStyle = GoogleFonts.spaceGrotesk(
    color: AppColors.colorTextoTenue,
    fontSize: 12,
  );

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _authRepository = AuthRepository();

  AuthMode _mode = AuthMode.login;
  bool _loading = false;
  int _replay = 0;

  bool get _isLogin => _mode == AuthMode.login;

  @override
  void didUpdateWidget(AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() => _replay++);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ modo

  void _setMode(AuthMode mode) {
    if (_loading || mode == _mode) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      _passCtrl.clear(); // el email se conserva al cambiar de pestaña
    });
  }

  // ------------------------------------------------------------ validación

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Introduce tu email';
    if (!_emailRegex.hasMatch(value)) return 'Email no válido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Introduce tu contraseña';
    // En login no imponemos longitud: no bloqueamos cuentas antiguas
    if (!_isLogin && value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateName(String? v) {
    if ((v ?? '').trim().length < 2) return 'Introduce tu nombre';
    return null;
  }

  double? _parseRate(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  String? _validateRate(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Introduce cuánto cobras';
    final n = _parseRate(v);
    if (n == null || n <= 0) return 'Introduce un número válido';
    if (n > 9999) return 'Ese importe parece demasiado alto';
    return null;
  }

  // --------------------------------------------------------------- errores

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return _isLogin
            ? 'Email o contraseña incorrectos'
            : 'No se ha podido crear la cuenta con esos datos';
      case 'email-already-in-use':
        return 'Ese email ya tiene una cuenta. Prueba a entrar';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El formato de email no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada';
      case 'operation-not-allowed':
        return 'El acceso con email no está disponible ahora mismo';
      case 'network-request-failed':
        return 'Sin conexión. Comprueba tu wifi o datos móviles';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento y vuelve a probar';
      default:
        return 'No se ha podido completar la operación (${e.code})';
    }
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Servicio no disponible. Revisa tu conexión e inténtalo de nuevo';
      case 'permission-denied':
        return 'No tienes permisos para completar esta acción';
      default:
        return 'Error del servidor. Inténtalo de nuevo';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    HouraNotification.show(
      context,
      title: message,
      type: HouraBannerType.error,
    );
  }

  // ---------------------------------------------------------------- submit

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.lightImpact();
      return;
    }

    final isLogin = _isLogin;
    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      if (isLogin) {
        await _authRepository
            .signIn(email: email, password: _passCtrl.text)
            .timeout(_timeout);
      } else {
        await _authRepository
            .register(
              name: _nameCtrl.text.trim(),
              email: email,
              password: _passCtrl.text,
              hourlyRate: _parseRate(_rateCtrl.text)!,
            )
            .timeout(_timeout);
      }

      TextInput.finishAutofillContext();
      if (!mounted) return;

      HouraNotification.show(
        context,
        title: isLogin ? '¡Bienvenido de vuelta!' : '¡Cuenta creada!',
        subtitle: isLogin ? null : 'Ya puedes empezar a apuntar tus horas',
        type: HouraBannerType.success,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on TimeoutException {
      _showError(
        'La conexión está tardando demasiado. Revisa tu internet e inténtalo de nuevo',
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } on FirebaseException catch (e) {
      _showError(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('Auth error: $e\n$st');
      _showError('Ha ocurrido un error inesperado. Inténtalo de nuevo');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final titleSize = (mq.size.width * 0.09).clamp(28.0, 36.0);

    return MediaQuery(
      data: mq.copyWith(
        textScaler:
            mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
      ),
      child: Scaffold(
        backgroundColor: AppColors.colorFondo,
        body: Stack(
          children: [
            const Positioned.fill(
              child: _AuthBackground(),
            ),
            SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // RepaintBoundary: aísla el header (con su
                              // animación de entrada) del resto del árbol,
                              // para que no arrastre repaints innecesarios.
                              RepaintBoundary(child: _buildHeader(titleSize)),
                              RepaintBoundary(child: _buildCard()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double titleSize) {
    final titleStyle = GoogleFonts.spaceGrotesk(
      color: AppColors.colorTexto,
      fontSize: titleSize,
      fontWeight: FontWeight.w700,
      height: 1.08,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            replay: _replay,
            index: 0,
            child: Image.asset(
              'assets/png/houra-logo-horizontal.png',
              height: 48,
            ),
          ),
          const SizedBox(height: 18),
          Reveal(
            replay: _replay,
            index: 1,
            child: Text.rich(
              TextSpan(
                style: titleStyle,
                children: [
                  const TextSpan(text: "Tus horas,\nen "),
                  TextSpan(
                    text: "oro",
                    style: titleStyle.copyWith(color: AppColors.colorLima),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Reveal(
            replay: _replay,
            index: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                "Apunta lo que trabajas, mira cuánto ganas y compite con tus colegas en el ranking.",
                style: _subtitleStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final mode = _mode.name; // para resetear el estado de error al cambiar

    return Reveal(
      replay: _replay,
      index: 3,
      distance: 40,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: welcomeCardDecoration(radius: 32).copyWith(
          color: AppColors.colorSuperficie.withValues(alpha: 0.94),
        ),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModeToggle(mode: _mode, onChanged: _setMode),
                const SizedBox(height: 22),

                // Nombre (solo registro)
                _Section(
                  visible: !_isLogin,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: HouraTextField(
                      label: "NOMBRE",
                      hint: "¿Cómo te llamas?",
                      icon: "assets/iconos/user.svg",
                      controller: _nameCtrl,
                      readOnly: _loading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: _validateName,
                    ),
                  ),
                ),

                HouraTextField(
                  key: ValueKey('email-$mode'),
                  label: "EMAIL",
                  hint: "tu@correo.com",
                  icon: "assets/iconos/user.svg",
                  controller: _emailCtrl,
                  readOnly: _loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                HouraTextField(
                  key: ValueKey('pass-$mode'),
                  label: "CONTRASEÑA",
                  hint: "••••••••",
                  icon: "assets/iconos/password.svg",
                  controller: _passCtrl,
                  readOnly: _loading,
                  isPassword: true,
                  textInputAction:
                      _isLogin ? TextInputAction.done : TextInputAction.next,
                  autofillHints: [
                    _isLogin
                        ? AutofillHints.password
                        : AutofillHints.newPassword,
                  ],
                  validator: _validatePassword,
                  onSubmitted: _isLogin ? (_) => _submit() : null,
                ),

                // Tarifa (solo registro)
                _Section(
                  visible: !_isLogin,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: HouraTextField(
                      label: "¿CUÁNTO COBRAS LA HORA?",
                      hint: "18",
                      icon: "assets/iconos/euro.svg",
                      controller: _rateCtrl,
                      readOnly: _loading,
                      suffixText: "€/h",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      validator: _validateRate,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _PrimaryButton(
                  loading: _loading,
                  label: _isLogin ? "Entrar" : "Empezar a sumar",
                  icon: _isLogin
                      ? "assets/iconos/fwd.svg"
                      : "assets/iconos/check.svg",
                  onTap: _submit,
                ),

                // ¿Olvidaste la contraseña? (solo login)
                _Section(
                  visible: _isLogin,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _loading
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Center(
                        child: Text(
                          "¿Olvidaste la contraseña?",
                          style: _forgotPasswordStyle,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Al continuar aceptas los Términos y la Política de privacidad de Houra.',
                    textAlign: TextAlign.center,
                    style: _termsStyle,
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

// ---------------------------------------------------------------------------
// Fondo de auth: SIN blur, SIN animación. Un gradiente estático que se
// pinta una vez y ya. Cero coste en cada frame, escribas lo que escribas.
// ---------------------------------------------------------------------------
class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.1,
            colors: [
              AppColors.colorLima.withValues(alpha: 0.20),
              AppColors.colorLima.withValues(alpha: 0.08),
              AppColors.colorFondo,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle Entrar / Crear cuenta con pastilla deslizante
// ---------------------------------------------------------------------------
class _ModeToggle extends StatelessWidget {
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == AuthMode.login;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.colorFondo,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.colorLima,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.colorLima.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ToggleLabel(
                  text: "Entrar",
                  selected: isLogin,
                  onTap: () => onChanged(AuthMode.login),
                ),
              ),
              Expanded(
                child: _ToggleLabel(
                  text: "Crear cuenta",
                  selected: !isLogin,
                  onTap: () => onChanged(AuthMode.register),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleLabel extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleLabel({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: selected
                  ? AppColors.colorTextoNegro
                  : AppColors.colorTextoTenue,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sección que aparece/desaparece con fade + animación de altura
// ---------------------------------------------------------------------------
class _Section extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _Section({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
        child: visible
            ? KeyedSubtree(key: const ValueKey('on'), child: child)
            : const SizedBox(key: ValueKey('off'), width: double.infinity),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botón principal con loading y efecto de pulsado (solo repinta él mismo)
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final bool loading;
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.loading,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: loading
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.colorLima,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorLima.withValues(alpha: 0.3),
              blurRadius: 24,
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: loading
                ? const SizedBox(
                    key: ValueKey('spinner'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.colorTextoNegro,
                    ),
                  )
                : Row(
                    key: ValueKey(label),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(icon, width: 18, height: 18),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTextoNegro,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
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

class _PressScale extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _PressScale({required this.onTap, required this.child});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}