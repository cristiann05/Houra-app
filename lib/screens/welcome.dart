import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:houra_app/screens/auth_screen.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final bool isActive;
  const WelcomeScreen({super.key, required this.onNext, this.isActive = true});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _replay = 0;

  @override
  void didUpdateWidget(WelcomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(
        () => _replay++,
      ); // fuerza nuevo montaje de los TweenAnimationBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final onNext = widget.onNext;

    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: Column(
        children: [
          Stack(
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

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 30),
                    child: Image.asset(
                      'assets/png/houra-logo-horizontal.png',
                      height: 55,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, right: 30),
                    child: GestureDetector(
                      child: Text(
                        "Saltar",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTextoTenue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // CARD "+4 h" — arriba a la derecha

              // CARD "Diseño de logo" — centrada
              Positioned(
                top: size.height * 0.275,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: UniqueKey(),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 50.0, end: 0.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      );
                    },
                    child: Transform.rotate(
                      angle: -0.1,
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 16,
                          right: 16,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(23, 232, 255, 210),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          color: AppColors.colorSuperficie,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 45,
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromARGB(
                                      41,
                                      162,
                                      163,
                                      160,
                                    ),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.colorLima,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Diseño de logo",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: AppColors.colorTexto,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Hoy · 4 h",
                                          style: GoogleFonts.spaceGrotesk(
                                            color: AppColors.colorTextoTenue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50),
                                  child: Text(
                                    "72 €",
                                    style: GoogleFonts.spaceGrotesk(
                                      color: AppColors.colorTexto,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: size.height * 0.22,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(120, 0),
                    child: TweenAnimationBuilder<double>(
                      key: UniqueKey(),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      tween: Tween(begin: 50.0, end: 0.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: child,
                        );
                      },
                      child: Transform.rotate(
                        angle: 0.1,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 16,
                            right: 16,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.colorLima,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.colorLima.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            "+4 h",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              color: AppColors.colorTextoNegro,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // CARD "Programación"
              Positioned(
                top: size.height * 0.435,
                left: size.width * 0.37,
                child: TweenAnimationBuilder<double>(
                  key: UniqueKey(),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 50.0, end: 0.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      width: 140,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color.fromARGB(23, 232, 255, 210),
                          width: 0.5,
                        ),
                        color: AppColors.colorSuperficie,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.colorLima,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Programación",
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.colorTexto,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.5,
                        colors: [
                          AppColors.colorLima.withValues(alpha: 0.2),
                          AppColors.colorLima.withValues(alpha: 0.0),
                        ],
                        center: const Alignment(-1.0, 0.0),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "APUNTA",
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: const FontWeight(600),
                                letterSpacing: 0.1,
                                color: AppColors.colorLima,
                              ),
                            ),
                            Text(
                              "Tus horas,",
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: const FontWeight(700),
                                color: AppColors.colorTexto,
                                fontSize: 40,
                              ),
                            ),
                            Text(
                              "en un toque.",
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: const FontWeight(700),
                                color: AppColors.colorTexto,
                                fontSize: 40,
                                height: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: SizedBox(
                                width: size.width * 0.8,
                                child: Text(
                                  "Anota lo que trabajas, el concepto y tu tarifa. Sin líos, sin cronómetros.",
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
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            height: 60,
                            child: ElevatedButton(
                              onPressed: onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.colorLima,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      'assets/iconos/fwd.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Text(
                                    "Siguiente",
                                    style: GoogleFonts.spaceGrotesk(
                                      color: AppColors.colorTextoNegro,
                                      fontSize: 16.5,
                                      fontWeight: const FontWeight(700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿Ya tienes cuenta?",
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.colorTextoTenue,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthScreen(onNext: () {}),
                                  ),
                                ),
                                child: Text(
                                  "Entrar",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.colorLima,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
