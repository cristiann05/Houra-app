import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';

class HouraBottomNav extends StatelessWidget {
  final int currentIndex; // 0 = Inicio, 1 = Horas
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
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: AppColors.colorFondo,
        border: Border(top: BorderSide(color: AppColors.colorGraficosNegrogris)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.access_time_rounded,
              label: 'Horas',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Botón central "Apuntar horas"
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 58,
                height: 58,
                margin: const EdgeInsets.only(top: -26),
                decoration: BoxDecoration(
                  color: AppColors.colorLima,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.colorFondo, width: 4),
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
          ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}