import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/utils/legal_text.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.colorTexto),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text('Recuperar acceso',
                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 17)),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(color: AppColors.colorLima.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.mail_outline_rounded, color: AppColors.colorLima, size: 36),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: Text(
                  '¿Has olvidado tu contraseña?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w800, fontSize: 21),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'De momento no tenemos recuperación automática. Escríbenos indicando el correo con el que te registraste y te ayudamos a recuperar el acceso lo antes posible.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    const Icon(Icons.alternate_email, color: AppColors.colorLima),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kContactoEmail,
                        style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: kContactoEmail));
                        HouraNotification.show(
                          context,
                          title: 'Email copiado',
                          subtitle: 'Pégalo en tu app de correo',
                          type: HouraBannerType.info,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.colorFondo, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.copy, color: AppColors.colorTextoTenue, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Consejo: escribe en el asunto "Recuperar acceso Houra" para que lo veamos rápido.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}