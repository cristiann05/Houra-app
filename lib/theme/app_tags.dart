import 'package:flutter/material.dart';
import 'package:houra_app/theme/app_colors.dart';

class AppTags {
  static const List<String> defaults = [
    'Diseño',
    'Programación',
    'Clases',
    'Vídeo',
    'Reparto',
    'Hostelería',
    'General',
  ];

  static const Map<String, Color> colors = {
    'Diseño': AppColors.colorLima,
    'Programación': AppColors.colorMenta,
    'Clases': AppColors.colorCielo,
    'Vídeo': AppColors.colorLogoMarron,
    'Reparto': AppColors.colorLila,
    'Hostelería': AppColors.colorRosa,
    'General': AppColors.colorIconosAuth,
  };

  // Paleta de reserva para tags creadas por el usuario que no están en `colors`.
  static const List<Color> _extraPalette = [
    AppColors.colorLima,
    AppColors.colorMenta,
    AppColors.colorCielo,
    AppColors.colorLila,
    AppColors.colorRosa,
    AppColors.colorLogoMarron,
  ];

  static Color colorOf(String tag) {
    final fixed = colors[tag];
    if (fixed != null) return fixed;
    // color determinista según el nombre, para que la misma tag custom
    // tenga siempre el mismo color en toda la app.
    final index = tag.codeUnits.fold<int>(0, (sum, c) => sum + c) % _extraPalette.length;
    return _extraPalette[index];
  }

  /// Lista combinada: fijas + las que el usuario se ha creado, sin duplicados.
  static List<String> allFor(List<String> customTags) {
    final combined = [...defaults];
    for (final t in customTags) {
      if (!combined.contains(t)) combined.add(t);
    }
    return combined;
  }
}