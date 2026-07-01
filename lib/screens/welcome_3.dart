import 'package:flutter/material.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/screens/auth_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Welcome3 extends StatefulWidget {
  final VoidCallback onNext;
  final bool isActive;
  const Welcome3({super.key, required this.onNext, this.isActive = true});

  @override
  State<Welcome3> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<Welcome3> {
  int _replay = 0;

  @override
  void didUpdateWidget(Welcome3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() => _replay++); // fuerza nuevo montaje de los TweenAnimationBuilder
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
              // FONDO CON GRADIENTE (Responsive: ocupa el 55% de la altura total)
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

              // HEADER: LOGO Y BOTÓN SALTAR
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 30,
                    ), // Subido a 50 para evitar la barra de estado del móvil
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

              // ---------------------------------------------------------
              // EL BLOQUE RESPONSIVE DE LA TARJETA Y LA CORONA
              // ---------------------------------------------------------
              Positioned(
                top:
                    size.height *
                    0.22, // Bajamos la tarjeta un 22% de la pantalla
                left: 0, // Estiramos de izquierda...
                right: 0, // ...a derecha para que ocupe todo el ancho
                child: Center(
                  // Centramos el contenido dentro de ese ancho
                  child: SizedBox(
                    // Límite: Ocupa el 85% en móvil, pero máximo 350px en tablet
                    width: (size.width * 0.85).clamp(280.0, 350.0),

                    // Creamos un Stack LOCAL para juntar Tarjeta + Corona
                    child: Stack(
                      clipBehavior:
                          Clip.none, // Permite que la corona sobresalga
                      children: [
                        // 1. LA TARJETA DE USUARIOS
                        TweenAnimationBuilder<double>(
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
                                vertical: 16,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    23,
                                    232,
                                    255,
                                    210,
                                  ),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                color: AppColors.colorSuperficie,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FILA 1: IVÁN
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "1",
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16,
                                            color: AppColors.colorTextoTenue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.colorLila,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                "IS",
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.colorTextoNegro,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            "Iván",
                                            style: GoogleFonts.spaceGrotesk(
                                              color: AppColors.colorTexto,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "98",
                                          style: GoogleFonts.jetBrainsMono(
                                            color: AppColors.colorTexto,
                                            fontWeight: FontWeight.bold,
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
                                  ),

                                  // FILA 2: TÚ
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.colorLimaTransparente,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.colorLimaBorde,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "2",
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16,
                                            color: AppColors.colorLima,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.colorLima,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                "M",
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.colorTextoNegro,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            "Tú",
                                            style: GoogleFonts.spaceGrotesk(
                                              color: AppColors.colorTexto,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "90",
                                          style: GoogleFonts.jetBrainsMono(
                                            color: AppColors.colorTexto,
                                            fontWeight: FontWeight.bold,
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
                                  ),

                                  // FILA 3: LUCÍA
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "3",
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16,
                                            color: AppColors.colorTextoTenue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.colorLogoMarron,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                "LR",
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.colorTextoNegro,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            "Lucía",
                                            style: GoogleFonts.spaceGrotesk(
                                              color: AppColors.colorTexto,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "84",
                                          style: GoogleFonts.jetBrainsMono(
                                            color: AppColors.colorTexto,
                                            fontWeight: FontWeight.bold,
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. LA CORONA ANIMADA
                        // Como está dentro del mismo Stack que la tarjeta, la posicionamos respecto a ella
                        Positioned(
                          top:
                              -35, // Sube 25px por encima del borde superior de la tarjeta
                          right:
                              -15, // Sale 15px por el borde derecho de la tarjeta
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
                              angle: 0.2,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  "assets/iconos/crown.svg",
                                  width: 40,
                                  height: 40,
                                  colorFilter: const ColorFilter.mode(
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
                  ),
                ),
              ),
            ],
          ),

          // LA MITAD INFERIOR DE LA PANTALLA (COMPITE + BOTONES)
          Expanded(
            child: Stack(
              children: [
                // 1. GRADIENTE DE FONDO
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

                // 2. CONTENIDO (Textos arriba y botón abajo del texto)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ), // Sin márgenes laterales aquí para no romper el centro
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Margen de 40 exclusivo para los textos
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "COMPITE",
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: const FontWeight(600),
                                letterSpacing: 0.1,
                                color: AppColors.colorLima,
                              ),
                            ),
                            Text(
                              "Pica a tus",
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: const FontWeight(700),
                                color: AppColors.colorTexto,
                                fontSize: 40,
                              ),
                            ),
                            Text(
                              "colegas.",
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

                      // Tu bloque de botón perfectamente centrado horizontalmente en la pantalla
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
                                    "Crear cuenta gratis",
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
