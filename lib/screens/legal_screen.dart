import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;
  const LegalScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    // Cada bloque separado por línea en mayúsculas se pinta como cabecera de sección.
    final paragraphs = body.trim().split('\n\n');

    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.colorTexto),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                itemCount: paragraphs.length,
                itemBuilder: (context, i) {
                  final p = paragraphs[i].trim();
                  final isHeader = p.isNotEmpty &&
                      p == p.toUpperCase() &&
                      p.length < 60 &&
                      !p.contains(RegExp(r'[a-záéíóúñ]'));
                  final isNumberedTitle = RegExp(r'^\d+\.\s[A-ZÁÉÍÓÚÑ]').hasMatch(p) && p.split('\n').first.length < 70;

                  if (isHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        p,
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorLima, fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                    );
                  }
                  if (isNumberedTitle) {
                    final lines = p.split('\n');
                    final headline = lines.first;
                    final rest = lines.skip(1).join('\n');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(headline,
                              style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 15)),
                          if (rest.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(rest,
                                style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5, height: 1.45)),
                          ],
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(p, style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5, height: 1.45)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}