import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';

class HouraBottomNav extends StatelessWidget {
  final int currentIndex; // 0 Inicio, 1 Horas, 2 Stats, 3 Perfil
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const HouraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.colorFondo,
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.colorGraficosNegrogris)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.home_rounded, label: 'Inicio', selected: currentIndex == 0, onTap: () => onTap(0)),
                    _NavItem(icon: Icons.access_time_rounded, label: 'Horas', selected: currentIndex == 1, onTap: () => onTap(1)),
                    // Hueco reservado para el botón central, que va en el Stack encima
                    const SizedBox(width: 58),
                    _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats', selected: currentIndex == 2, onTap: () => onTap(2)),
                    _NavItem(icon: Icons.person_rounded, label: 'Perfil', selected: currentIndex == 3, onTap: () => onTap(3)),
                  ],
                ),
                // Botón central "Apuntar horas", con su propio hit-target limpio (sin solaparse con los tabs)
                Positioned(
                  top: -26,
                  child: Material(
                    color: AppColors.colorLima,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.colorFondo, width: 4),
                    ),
                    elevation: 0,
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.colorLima.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: AppColors.colorTextoNegro, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.colorLima : AppColors.colorTextoTenue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 64,
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.08 : 1.0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(icon, key: ValueKey(selected), size: 23, color: color),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}