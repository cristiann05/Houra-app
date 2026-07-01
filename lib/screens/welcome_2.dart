import 'package:flutter/material.dart';
import 'package:houra_app/screens/welcome_3.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/screens/auth_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Welcome2 extends StatefulWidget {
  final VoidCallback onNext;
  final bool isActive;
  const Welcome2({super.key, required this.onNext, this.isActive = true});

  @override
  State<Welcome2> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<Welcome2> {
  int _replay = 0;

  @override
  void didUpdateWidget(Welcome2 oldWidget) {
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

              // CARD "ESTE MES" — la grande con la gráfica
              Positioned(
                top: size.height * 0.31,
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
                      angle: -0.01,
                      child: Container(
                        width: 280,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(23, 232, 255, 210),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          color: AppColors.colorSuperficie,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ESTE MES",
                              style: GoogleFonts.jetBrainsMono(
                                color: AppColors.colorTextoTenue,
                                fontSize: 12,
                              ),
                            ),

                            Transform.translate(
                              offset: const Offset(0, -10),
                              child: Text(
                                "1.284 €",
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.colorTexto,
                                  fontWeight: const FontWeight(700),
                                  fontSize: 40,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 30,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 50,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 20,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 60,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 40,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 70,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorLima,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                    height: 50,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.colorGraficosNegrogris,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // CARD "+12%" — flotando arriba a la derecha
              Positioned(
                top: size.height * 0.265,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(100, 0),
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
                        angle: 0.05,
                        child: Container(
                          width: 90,
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 16,
                            right: 16,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: const Color.fromARGB(41, 196, 240, 66),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/iconos/arrowup.svg",
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.colorLima,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "+12%",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    color: AppColors.colorLima,
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
                              "GANA",
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: const FontWeight(600),
                                letterSpacing: 0.1,
                                color: AppColors.colorLima,
                              ),
                            ),
                            Text(
                              "Mira cuánto",
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: const FontWeight(700),
                                color: AppColors.colorTexto,
                                fontSize: 40,
                              ),
                            ),
                            Text(
                              "estás ganando.",
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
                                  "Resúmenes y estadísticas claras de tu dinero y tu tiempo, semana a semana.",
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
                                    builder: (context) => AuthScreen(
                                      onNext: () {},
                                    ),
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
