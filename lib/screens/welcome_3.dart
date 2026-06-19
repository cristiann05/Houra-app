import 'package:flutter/material.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/screens/login.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Welcome3 extends StatelessWidget {
  const Welcome3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 500,
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
                    padding: const EdgeInsets.only(top: 10, left: 30),
                    child: Image.asset(
                      'assets/png/houra-logo-horizontal.png',
                      height: 55,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 30),
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

              Positioned(
                top: 250,
                right: 120,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(
                            (0.09 * 255).round(),
                            232,
                            255,
                            210,
                          ),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        color: AppColors.colorSuperficie,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // La coma va aquí, cerrando esta propiedad
                          children: [
                            // Quitamos la coma suelta que estaba arriba de esta línea
                            Row(
                              children: [
                                Text(
                                  "1",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    color: AppColors.colorTextoTenue,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.colorLila,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "IS",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16,
                                          color: AppColors.colorTextoNegro,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Iván",
                                    style: GoogleFonts.spaceGrotesk(
                                      color: AppColors.colorTexto,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 85),
                                  child: Text(
                                    "98",
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.colorTexto,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "h",
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.colorTextoTenue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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

              Positioned(
                top: 200,
                right: 110,
                child: TweenAnimationBuilder<double>(
                  key: UniqueKey(),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 50.0, end: 0.0), // empieza 50px más abajo
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value), // mueve verticalmente
                      child: child,
                    );
                  },

                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),

                      child: SvgPicture.asset(
                        "assets/iconos/crown.svg",
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          AppColors.colorAviso,
                          BlendMode.srcIn,
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
                    height: double.infinity, // ocupa todo el Expanded
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.5,
                        colors: [
                          AppColors.colorLima.withValues(alpha: 0.2),
                          AppColors.colorLima.withValues(alpha: 0.0),
                        ],
                        center: Alignment(-1.0, 0.0),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "COMPITE",
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight(600),
                          letterSpacing: 0.1,
                          color: AppColors.colorLima,
                        ),
                      ),
                      Text(
                        "Pica a tus",
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight(700),
                          color: AppColors.colorTexto,
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        "colegas.",
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight(700),
                          color: AppColors.colorTexto,
                          fontSize: 40,
                          height: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: SizedBox(
                          width: 310,
                          child: Text(
                            "Añade amigos, mira sus horas y pelead por el primer puesto del ranking.",
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
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -60),
            child: Padding(
              padding: const EdgeInsets.only(),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 40),
                height: 60,

                child: ElevatedButton(
                  onPressed: () => {},
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
                          fontWeight: FontWeight(700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -40),
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
                        builder: (context) => const LoginScreen(),
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
    );
  }
}
