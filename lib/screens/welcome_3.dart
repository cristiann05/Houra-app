import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/welcome_shell.dart';

class Welcome3 extends StatelessWidget {
  final VoidCallback onNext;
  final bool isActive;
  const Welcome3({super.key, required this.onNext, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return WelcomeShell(
      page: 2,
      isActive: isActive,
      onNext: onNext,
      orbColors: const [
        AppColors.colorAviso,
        AppColors.colorLima,
        AppColors.colorLogoMarron,
      ],
      eyebrow: "COMPITE",
      title: "Pica a tus\ncolegas.",
      subtitle:
          "Añade amigos, mira sus horas y pelead por el primer puesto del ranking.",
      buttonLabel: "Crear cuenta gratis",
      heroSize: const Size(320, 250),
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
        Positioned(
          top: 30,
          left: 10,
          child: Reveal(
            replay: replay,
            index: 0,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              child: Transform.rotate(
                angle: -0.01,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(14),
                  decoration: welcomeCardDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RankRow(
                        replay: replay,
                        index: 1,
                        rank: "1",
                        initials: "IS",
                        name: "Iván",
                        hours: "98",
                        color: AppColors.colorLila,
                      ),
                      _RankRow(
                        replay: replay,
                        index: 2,
                        rank: "2",
                        initials: "M",
                        name: "Tú",
                        hours: "90",
                        color: AppColors.colorLima,
                        highlight: true,
                      ),
                      _RankRow(
                        replay: replay,
                        index: 3,
                        rank: "3",
                        initials: "LR",
                        name: "Lucía",
                        hours: "84",
                        color: AppColors.colorLogoMarron,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Corona
        Positioned(
          top: -4,
          right: 0,
          child: Reveal(
            replay: replay,
            index: 4,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              phase: 0.5,
              amplitude: 6,
              child: Transform.rotate(
                angle: 0.2,
                child: SvgPicture.asset(
                  "assets/iconos/crown.svg",
                  width: 44,
                  height: 44,
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
    );
  }
}

class _RankRow extends StatelessWidget {
  final int replay;
  final int index;
  final String rank;
  final String initials;
  final String name;
  final String hours;
  final Color color;
  final bool highlight;

  const _RankRow({
    required this.replay,
    required this.index,
    required this.rank,
    required this.initials,
    required this.name,
    required this.hours,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Reveal(
      replay: replay,
      index: index,
      distance: 18,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? AppColors.colorLimaTransparente : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight ? AppColors.colorLimaBorde : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              child: Text(
                rank,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: highlight
                      ? AppColors.colorLima
                      : AppColors.colorTextoTenue,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Text(
                initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: AppColors.colorTextoNegro,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.colorTexto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              hours,
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
    );
  }
}