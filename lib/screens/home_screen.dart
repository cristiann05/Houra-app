import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    DateTime fechaActual = DateTime.now();
    String fechaFormateada = DateFormat(
      'EEEE, d MMM',
      'es',
    ).format(fechaActual);
    String fechaConMayuscula =
        fechaFormateada[0].toUpperCase() + fechaFormateada.substring(1);

    int numeroPorcentaje = 0;

    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SingleChildScrollView(
        child: Padding(
          // Añadimos padding derecho (20) global para no tener que ponerlo dentro
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea las secciones a la izquierda
            children: [
              // ==========================================
              // SECCIÓN 1: CABECERA (Tu código original)
              // ==========================================
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¡Buenas, nombre! 👋",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorIconosAuth,
                        ),
                      ),
                      Text(
                        fechaConMayuscula,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTexto,
                          fontSize: 22,
                          fontWeight: FontWeight.w800, // Corregido: .w800
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.colorLima,
                    child: Text(
                      "M",
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.colorFondo,
                        fontWeight: FontWeight.w800, // Corregido: .w800
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),

              // Espacio de separación entre la cabecera y la nueva sección
              const SizedBox(height: 30),

              Container(
                width: 400,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.colorSuperficie,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.colorLimaBorde),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "GANADO ESTE MES",
                              style: GoogleFonts.jetBrainsMono(
                                color: AppColors.colorIconosAuth,
                                letterSpacing: 1.2,
                                fontSize: 13,
                              ),
                            ),
                            SvgPicture.asset('/assets/iconos/arrowup.svg'),
                            Text("+$numeroPorcentaje%")

                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
