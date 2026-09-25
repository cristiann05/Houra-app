import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/welcome_shell.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final bool isActive;
  const WelcomeScreen({super.key, required this.onNext, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return WelcomeShell(
      page: 0,
      isActive: isActive,
      onNext: onNext,
      orbColors: const [
        AppColors.colorLima,
        AppColors.colorLila,
        AppColors.colorLima,
      ],
      eyebrow: "APUNTA",
      title: "Tus horas,\nen un toque.",
      subtitle:
          "Anota lo que trabajas, el concepto y tu tarifa. Sin líos, sin cronómetros.",
      buttonLabel: "Siguiente",
      heroSize: const Size(320, 210),
      heroBuilder: (_, r) => _Hero(replay: r),
    );
  }
}

class _Hero extends StatelessWidget {
  final int replay;
  const _Hero({required this.replay});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card "Diseño de logo"
        Positioned(
          top: 52,
          left: 10,
          child: Reveal(
            replay: replay,
            index: 0,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              child: Transform.rotate(angle: -0.1, child: const _LogoCard()),
            ),
          ),
        ),
        // Chip "+4 h"
        Positioned(
          top: 6,
          right: 14,
          child: Reveal(
            replay: replay,
            index: 1,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              phase: 0.5,
              amplitude: 6,
              child: Transform.rotate(
                angle: 0.1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.colorLima,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorLima.withValues(alpha: 0.4),
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
        // Pill "Programación"
        Positioned(
          top: 158,
          left: 92,
          child: Reveal(
            replay: replay,
            index: 2,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              phase: 0.25,
              amplitude: 4,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  width: 140,
                  height: 36,
                  decoration: welcomeCardDecoration(radius: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.colorLima,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Programación",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTexto,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: welcomeCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(41, 162, 163, 160),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.colorLima,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Diseño de logo",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.colorTexto,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Hoy · 4 h",
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.colorTextoTenue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "72 €",
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.colorTexto,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}