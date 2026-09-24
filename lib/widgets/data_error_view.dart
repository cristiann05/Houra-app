// lib/widgets/data_error_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';

/// Estado amistoso para cuando un stream de Firestore falla (sin conexión,
/// permisos, etc.) en vez de dejar la pantalla en blanco o cargando para
/// siempre. Al recuperar la conexión, el propio stream se reconecta solo
/// y esta vista desaparece.
class DataErrorView extends StatelessWidget {
  final String message;
  const DataErrorView({
    super.key,
    this.message = 'No se han podido cargar los datos.\nComprueba tu conexión a internet.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.colorTextoTenue, size: 40),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}