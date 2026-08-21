import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/screens/home_screen.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/app_toast.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isActive;

  const AuthScreen({
    super.key,
    required this.onNext,
    this.isActive = true,
    this.onBack,
  });

  @override
  State<AuthScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  // focus de los inputs
  final FocusNode _emailLoginFocusNode = FocusNode();
  final FocusNode _passwordLoginFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailRegisterFocusNode = FocusNode();
  final FocusNode _passwordRegisterFocusNode = FocusNode();
  final FocusNode _hourRegisterFocusNode = FocusNode();
  //controladores de inputs
  final TextEditingController _passwordLoginController =
      TextEditingController();
  final TextEditingController _passwordRegisterController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _emailRegisterController =
      TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  bool _obscureText = true;
  AuthMode _authMode = AuthMode.login;
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _isPressedLogin = false;
  bool _isPressedRegister = false;
  bool _isPressedBack = false;

  @override
  void dispose() {
    _emailLoginFocusNode.dispose();
    _passwordLoginFocusNode.dispose();
    _passwordLoginController.dispose();
    _nameFocusNode.dispose();
    _emailRegisterFocusNode.dispose();
    _passwordRegisterFocusNode.dispose();
    _hourRegisterFocusNode.dispose();
    _nameController.dispose();
    _emailLoginController.dispose();
    _emailRegisterController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  void clearLoginFields() {
    _emailLoginController.clear();
    _passwordLoginController.clear();
  }

  void _clearRegisterFields() {
    _nameController.clear();
    _emailRegisterController.clear();
    _passwordRegisterController.clear();
    _hourController.clear();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe ninguna cuenta con ese email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ese email ya tiene una cuenta';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El formato de email no es válido';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }

  void _showError(String message) {
    AppToast.show(
      context,
      message: message,
      emoji: "⚠️",
      type: ToastType.error,
    );
  }

  Future<void> _handleSubmit() async {
    final esValido = _formKey.currentState!.validate();

    if (!esValido) return;
    // 2. Activar el loading (muestra spinner, desactiva el botón)
    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.login) {
        await _authRepository.signIn(
          email: _emailLoginController.text.trim(),
          password: _passwordLoginController.text,
        );
      } else {
        await _authRepository.register(
          name: _nameController.text.trim(),
          email: _emailRegisterController.text.trim(),
          password: _passwordRegisterController.text,
          hourlyRate: double.parse(_hourController.text),
        );
      }
      // Si llegamos aquí, no hubo excepción → todo fue bien
      if (!mounted) return;
      AppToast.show(
        context,
        message: _authMode == AuthMode.login
            ? "¡Bienvenido de vuelta!"
            : "Cuenta creada",
        emoji: "🎉",
        type: ToastType.success,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapFirebaseError(e));
    } catch (e) {
      _showError('Ha ocurrido un error inesperado');
    } finally {
      // Esto se ejecuta SIEMPRE, haya ido bien o mal
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height * 0.55,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.70,
                  colors: [
                    AppColors.colorLima.withValues(alpha: 0.2),
                    AppColors.colorLima.withValues(alpha: 0.0),
                  ],
                  center: Alignment.topRight,
                ),
              ),
            ),
            Container(
              height: size.height * 0.55,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.70,
                  colors: [
                    AppColors.colorLima.withValues(alpha: 0.2),
                    AppColors.colorLima.withValues(alpha: 0.0),
                  ],
                  center: Alignment.topLeft,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isPressedBack = true),
                        onTapUp: (_) => setState(() => _isPressedBack = false),
                        onTapCancel: () =>
                            setState(() => _isPressedBack = false),
                        onTap: () => widget.onBack?.call(),
                        child: AnimatedScale(
                          scale: _isPressedBack ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.colorSuperficie,
                              border: Border.all(
                                width: 1.5,
                                color: const Color.fromARGB(23, 232, 255, 210),
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/iconos/back.svg",
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  AppColors.colorTexto,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.asset(
                          "assets/png/houra-logo-horizontal.png",
                          height: 55,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          "Tus horas,",
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.colorTexto,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "en ",
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.colorTexto,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                          children: [
                            TextSpan(
                              text: "oro",
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.colorLima,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: size.width * 0.8,
                          child: Text(
                            "Apunta lo que trabajas, mira cuánto ganas y compite con tus colegas en el ranking.",
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.colorTextoTenue,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Container(
                    //  height: size.height,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: AppColors.colorSuperficie,
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(
                        width: 1.5,
                        color: AppColors.colorGraficosNegrogris,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            width: size.width * 0.90,
                            height: 50,

                            decoration: BoxDecoration(
                              color: AppColors.colorFondo,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: size.width * 0.40,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: _authMode == AuthMode.login
                                          ? AppColors.colorLima
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _authMode = AuthMode.login;
                                          clearLoginFields();
                                        }),

                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ), // Más rápido para que se sienta responsivo
                                          switchInCurve: Curves.linear,
                                          switchOutCurve: Curves.linear,
                                          transitionBuilder:
                                              (
                                                Widget child,
                                                Animation<double> animation,
                                              ) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                          child: Text(
                                            "Entrar",
                                            key: ValueKey(
                                              _authMode == AuthMode.login,
                                            ),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: _authMode == AuthMode.login
                                                  ? AppColors.colorFondo
                                                  : AppColors.colorTextoTenue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: size.width * 0.44,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: _authMode == AuthMode.register
                                          ? AppColors.colorLima
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _authMode = AuthMode.register;
                                          _clearRegisterFields();
                                        }),
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeInOut,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color:
                                                _authMode == AuthMode.register
                                                ? AppColors.colorFondo
                                                : AppColors.colorTextoTenue,
                                          ),
                                          child: const Text("Crear cuenta"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: Form(
                              key: _formKey,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  if (_authMode == AuthMode.login) ...[
                                    //INPUT EMAIL - INICIAR SESIÓN
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 30,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "EMAIL",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: const ValueKey(
                                          "email_login_field",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce tu email';
                                          }
                                          final emailRegex = RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          );
                                          if (!emailRegex.hasMatch(value)) {
                                            return 'Email no válido';
                                          }
                                          return null;
                                        },
                                        controller: _emailLoginController,
                                        focusNode: _emailLoginFocusNode,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 15,
                                            ),
                                            child: ListenableBuilder(
                                              listenable: _emailLoginFocusNode,

                                              builder: (context, child) {
                                                final colorIcono =
                                                    _emailLoginFocusNode
                                                        .hasFocus
                                                    ? AppColors.colorLima
                                                    : AppColors.colorIconosAuth;

                                                return SvgPicture.asset(
                                                  "assets/iconos/user.svg",

                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 5,
                                                  height: 5,
                                                );
                                              },
                                            ),
                                          ),

                                          hintText: "tu@correo.com",
                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),

                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),

                                    //INPUT CONTRASEÑA LOGIN
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "CONTRASEÑA",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: ValueKey("password_login_field"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce tu contraseña';
                                          }

                                          if (value.length < 6) {
                                            return 'Mínimo 6 caracteres';
                                          }

                                          return null;
                                        },
                                        controller: _passwordLoginController,
                                        focusNode: _passwordLoginFocusNode,
                                        obscureText: _obscureText,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          hintText: '••••••••',

                                          prefixIcon: ListenableBuilder(
                                            listenable: Listenable.merge([
                                              _passwordLoginFocusNode,
                                              _passwordLoginController,
                                            ]),
                                            builder: (context, child) {
                                              final colorIcono =
                                                  _passwordLoginFocusNode
                                                      .hasFocus
                                                  ? AppColors.colorLima
                                                  : AppColors.colorIconosAuth;

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                  left: 15,
                                                ),
                                                child: SvgPicture.asset(
                                                  "assets/iconos/password.svg",
                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 18,
                                                  height: 18,
                                                ),
                                              );
                                            },
                                          ),

                                          suffixIcon: ListenableBuilder(
                                            listenable:
                                                _passwordLoginController,
                                            builder: (context, child) {
                                              if (_passwordLoginController
                                                  .text
                                                  .isEmpty) {
                                                return const SizedBox.shrink(); // botón no aparece si no hay texto
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 15,
                                                  left: 10,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () => setState(
                                                    () => _obscureText =
                                                        !_obscureText,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    _obscureText
                                                        ? "assets/iconos/eye-off.svg"
                                                        : "assets/iconos/eye.svg",
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          AppColors.colorTexto,
                                                          BlendMode.srcIn,
                                                        ),
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: GestureDetector(
                                        onTapDown: (_) => setState(
                                          () => _isPressedLogin = true,
                                        ),
                                        onTapUp: (_) => setState(
                                          () => _isPressedLogin = false,
                                        ),
                                        onTapCancel: () => setState(
                                          () => _isPressedLogin = false,
                                        ),
                                        onTap: _handleSubmit,
                                        child: AnimatedScale(
                                          scale: _isPressedLogin ? 0.96 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          curve: Curves.easeOut,
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                              color: AppColors.colorLima,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 10,
                                                        ),
                                                    child: SvgPicture.asset(
                                                      "assets/iconos/fwd.svg",
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Entrar",
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: AppColors
                                                              .colorFondo,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          "enlace a cambiar contraseña",
                                      child: Center(
                                        child: Text(
                                          "¿Olvidaste la contraseña?",
                                          style: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (_authMode == AuthMode.register) ...[
                                    //INPUT NOMBRE
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 30,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "NOMBRE",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: ValueKey("name_field"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce tu nombre completo';
                                          }
                                          return null;
                                        },
                                        focusNode: _nameFocusNode,
                                        controller: _nameController,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 15,
                                            ),
                                            child: ListenableBuilder(
                                              listenable: _nameFocusNode,

                                              builder: (context, child) {
                                                final colorIcono =
                                                    _nameFocusNode.hasFocus
                                                    ? AppColors.colorLima
                                                    : AppColors.colorIconosAuth;

                                                return SvgPicture.asset(
                                                  "assets/iconos/user.svg",

                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 5,
                                                  height: 5,
                                                );
                                              },
                                            ),
                                          ),

                                          hintText: "¿Cómo te llamas?",
                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),

                                    //INPUT EMAIL - REGISTRO
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "EMAIL",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: ValueKey("email_register_field"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce tu email';
                                          }
                                          final emailRegex = RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          );
                                          if (!emailRegex.hasMatch(value)) {
                                            return 'Email no válido';
                                          }
                                          return null;
                                        },
                                        controller: _emailRegisterController,
                                        focusNode: _emailRegisterFocusNode,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 15,
                                            ),
                                            child: ListenableBuilder(
                                              listenable:
                                                  _emailRegisterFocusNode,

                                              builder: (context, child) {
                                                final colorIcono =
                                                    _emailRegisterFocusNode
                                                        .hasFocus
                                                    ? AppColors.colorLima
                                                    : AppColors.colorIconosAuth;

                                                return SvgPicture.asset(
                                                  "assets/iconos/user.svg",

                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 5,
                                                  height: 5,
                                                );
                                              },
                                            ),
                                          ),

                                          hintText: "tu@correo.com",
                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),

                                    //INPUT CONTRASEÑA REGISTRO
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "CONTRASEÑA",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: ValueKey(
                                          "password_register_field",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce tu contraseña';
                                          }

                                          if (value.length < 6) {
                                            return 'Mínimo 6 caracteres';
                                          }

                                          return null;
                                        },
                                        controller:
                                            _passwordRegisterController, // 👈 fix #2
                                        focusNode: _passwordRegisterFocusNode,
                                        obscureText: _obscureText,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          hintText: '••••••••',

                                          prefixIcon: ListenableBuilder(
                                            listenable: Listenable.merge([
                                              _passwordRegisterFocusNode,
                                              _passwordRegisterController,
                                            ]),
                                            builder: (context, child) {
                                              final colorIcono =
                                                  _passwordRegisterFocusNode
                                                      .hasFocus
                                                  ? AppColors.colorLima
                                                  : AppColors.colorIconosAuth;

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                  left: 15,
                                                ),
                                                child: SvgPicture.asset(
                                                  "assets/iconos/password.svg",
                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 18,
                                                  height: 18,
                                                ),
                                              );
                                            },
                                          ),

                                          suffixIcon: ListenableBuilder(
                                            listenable:
                                                _passwordRegisterController,
                                            builder: (context, child) {
                                              if (_passwordRegisterController
                                                  .text
                                                  .isEmpty) {
                                                return const SizedBox.shrink(); // botón no aparece si no hay texto
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 15,
                                                  left: 10,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () => setState(
                                                    () => _obscureText =
                                                        !_obscureText,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    _obscureText
                                                        ? "assets/iconos/eye-off.svg"
                                                        : "assets/iconos/eye.svg",
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          AppColors.colorTexto,
                                                          BlendMode.srcIn,
                                                        ),
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),

                                    //INPUT € LA HORA - REGISTRO
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                      ),
                                      child: Text(
                                        "¿CUÁNTO COBRAS LA HORA?",
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.colorTextoTenue,
                                          letterSpacing: 0.5,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        key: ValueKey("hour_field"),
                                        controller: _hourController,
                                        focusNode: _hourRegisterFocusNode,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}'),
                                          ),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Introduce cuánto cobras';
                                          }

                                          final numero = double.tryParse(value);
                                          if (numero == null || numero <= 0) {
                                            return 'Introduce un número válido';
                                          }

                                          return null;
                                        },
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                        ),
                                        cursorErrorColor: AppColors.colorError,

                                        decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 15,
                                            ),
                                            child: ListenableBuilder(
                                              listenable:
                                                  _hourRegisterFocusNode,

                                              builder: (context, child) {
                                                final colorIcono =
                                                    _hourRegisterFocusNode
                                                        .hasFocus
                                                    ? AppColors.colorLima
                                                    : AppColors.colorIconosAuth;

                                                return SvgPicture.asset(
                                                  "assets/iconos/euro.svg",

                                                  colorFilter: ColorFilter.mode(
                                                    colorIcono,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 5,
                                                  height: 5,
                                                );
                                              },
                                            ),
                                          ),

                                          suffixIcon: Padding(
                                            padding:
                                                const EdgeInsetsGeometry.only(
                                                  right: 15,
                                                  top: 15,
                                                ),
                                            child: Text(
                                              "€/h",
                                              style: GoogleFonts.jetBrainsMono(
                                                color:
                                                    AppColors.colorTextoTenue,
                                              ),
                                            ),
                                          ),
                                          hintText: "18",
                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors
                                                  .colorGraficosNegrogris,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: AppColors.colorLima,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: AppColors.colorError,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: AppColors.colorError,
                                                ),
                                              ),
                                          errorStyle: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            color: AppColors.colorError,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: GestureDetector(
                                        onTapDown: (_) => setState(
                                          () => _isPressedRegister = true,
                                        ),
                                        onTapUp: (_) => setState(
                                          () => _isPressedRegister = false,
                                        ),
                                        onTapCancel: () => setState(
                                          () => _isPressedRegister = false,
                                        ),
                                        onTap: _handleSubmit,
                                        child: AnimatedScale(
                                          scale: _isPressedRegister
                                              ? 0.96
                                              : 1.0,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          curve: Curves.easeOut,
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                              color: AppColors.colorLima,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 10,
                                                        ),
                                                    child: SvgPicture.asset(
                                                      "assets/iconos/check.svg",
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Empezar a sumar",
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: AppColors
                                                              .colorFondo,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: size.width * 0.40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.colorTextoTenue,
                                              width: 0.1,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                          ),
                                          child: Text(
                                            "o",
                                            style: GoogleFonts.jetBrainsMono(
                                              color: AppColors.colorTextoTenue,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.colorTextoTenue,
                                              width: 0.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 30,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 300,
                                          ), // Evita que se estire más de esto
                                          child: Text(
                                            'Al continuar aceptas los Términos y la Política de privacidad de Houra.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.spaceGrotesk(
                                              color: AppColors.colorTextoTenue,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
