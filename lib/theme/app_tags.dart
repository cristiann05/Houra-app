import 'package:flutter/material.dart';
import 'package:houra_app/theme/app_colors.dart';

class AppTags {
  static const List<String> all = [
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

  static Color colorOf(String tag) => colors[tag] ?? AppColors.colorLima;
}