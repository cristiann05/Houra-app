import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final VoidCallback onNext;
  final bool isActive;

  const AuthScreen({super.key, required this.onNext, this.isActive = true});

  @override
  State<AuthScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  AuthMode _authMode = AuthMode.login;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      Container(
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
                          child: GestureDetector(
                            onTap: () => "atrás",
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
                                  //INPUT EMAIL
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
                                      focusNode: _emailFocusNode,
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
                                            listenable: _emailFocusNode,

                                            builder: (context, child) {
                                              final colorIcono =
                                                  _emailFocusNode.hasFocus
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
                                      ),
                                    ),
                                  ),

                                  //INPUT CONTRASEÑA
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
                                      controller:
                                          _passwordController, // 👈 fix #2
                                      focusNode: _passwordFocusNode,
                                      obscureText: _obscureText,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppColors.colorTexto,
                                      ),
                                      cursorErrorColor: AppColors.colorError,

                                      decoration: InputDecoration(
                                        hintText: '••••••••',

                                        prefixIcon: ListenableBuilder(
                                          listenable: Listenable.merge([
                                            _passwordFocusNode,
                                            _passwordController,
                                          ]),
                                          builder: (context, child) {
                                            final colorIcono =
                                                _passwordFocusNode.hasFocus
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
                                          listenable: _passwordController,
                                          builder: (context, child) {
                                            if (_passwordController
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
                                                  colorFilter: ColorFilter.mode(
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
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.colorLima,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15.0,
                                          ), // Curvatura
                                        ),
                                      ),
                                      onPressed: () => "",

                                      child: Container(
                                        height: 55,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                                              style: GoogleFonts.spaceGrotesk(
                                                color: AppColors.colorFondo,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => "enlace a cambiar contraseña",
                                    child: Center(
                                      child: Text(
                                        "¿Olvidaste la contraseña?",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTextoTenue,
                                        ),
                                      ),
                                    ),
                                  ),

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
