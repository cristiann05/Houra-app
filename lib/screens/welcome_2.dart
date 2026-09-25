import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/widgets/welcome_shell.dart';

class Welcome2 extends StatelessWidget {
  final VoidCallback onNext;
  final bool isActive;
  const Welcome2({super.key, required this.onNext, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return WelcomeShell(
      page: 1,
      isActive: isActive,
      onNext: onNext,
      orbColors: const [
        AppColors.colorLila,
        AppColors.colorLima,
        AppColors.colorLila,
      ],
      eyebrow: "GANA",
      title: "Mira cuánto\nestás ganando.",
      subtitle:
          "Resúmenes y estadísticas claras de tu dinero y tu tiempo, semana a semana.",
      buttonLabel: "Siguiente",
      heroSize: const Size(320, 220),
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
          top: 36,
          left: 20,
          child: Reveal(
            replay: replay,
            index: 0,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              child: Transform.rotate(
                angle: -0.01,
                child: _MonthCard(replay: replay),
              ),
            ),
          ),
        ),
        // Chip "+12%"
        Positioned(
          top: 0,
          right: 18,
          child: Reveal(
            replay: replay,
            index: 1,
            curve: Curves.elasticOut,
            distance: 50,
            child: Float(
              phase: 0.5,
              amplitude: 6,
              child: Transform.rotate(
                angle: 0.05,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFF26330F),
                    border: Border.all(
                      color: AppColors.colorLima.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorLima.withValues(alpha: 0.25),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 5),
                      Text(
                        "+12%",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: AppColors.colorLima,
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

class _MonthCard extends StatelessWidget {
  final int replay;
  const _MonthCard({required this.replay});

  static const _heights = [30.0, 50.0, 20.0, 60.0, 40.0, 70.0, 50.0];

  static String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: welcomeCardDecoration(),
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
          const SizedBox(height: 2),
          // Contador que sube
          TweenAnimationBuilder<double>(
            key: ValueKey('count$replay'),
            tween: Tween(begin: 0, end: 1284),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              "${_fmt(v.round())} €",
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.colorTexto,
                fontWeight: FontWeight.w700,
                fontSize: 38,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_heights.length, (i) {
                return TweenAnimationBuilder<double>(
                  key: ValueKey('bar$replay-$i'),
                  tween: Tween(begin: 0, end: _heights[i]),
                  duration: const Duration(milliseconds: 1100),
                  curve: Interval(i * 0.07, i * 0.07 + 0.5,
                      curve: Curves.easeOutBack),
                  builder: (_, v, __) => Container(
                    width: 26,
                    height: v.clamp(0.0, 72.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: i == 5
                          ? AppColors.colorLima
                          : AppColors.colorGraficosNegrogris,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}