import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';

/// Campo con label mono arriba, icono que se ilumina con el foco,
/// toggle de contraseña integrado y estados de error unificados.
class HouraTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String icon; // ruta del svg
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final String? suffixText;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  const HouraTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.suffixText,
    this.readOnly = false,
    this.onSubmitted,
  });

  @override
  State<HouraTextField> createState() => _HouraTextFieldState();
}

class _HouraTextFieldState extends State<HouraTextField> {
  final FocusNode _focus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.controller,
        builder: (_, value, __) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _obscure = !_obscure),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SvgPicture.asset(
                _obscure ? "assets/iconos/eye-off.svg" : "assets/iconos/eye.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.colorTexto,
                  BlendMode.srcIn,
                ),
                width: 18,
                height: 18,
              ),
            ),
          );
        },
      );
    }
    if (widget.suffixText != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          widget.suffixText!,
          style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.keyboardType == TextInputType.emailAddress;
    final plainText = widget.isPassword || isEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.colorTextoTenue,
            letterSpacing: 0.5,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focus,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autocorrect: !plainText,
          enableSuggestions: !plainText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          cursorColor: AppColors.colorLima,
          cursorErrorColor: AppColors.colorError,
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.colorTexto,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.spaceGrotesk(
              color: AppColors.colorTextoTenue,
            ),
            filled: true,
            fillColor: AppColors.colorFondo.withValues(alpha: 0.55),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            prefixIcon: ListenableBuilder(
              listenable: _focus,
              builder: (_, __) => Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: SvgPicture.asset(
                  widget.icon,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    _focus.hasFocus
                        ? AppColors.colorLima
                        : AppColors.colorIconosAuth,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: _buildSuffix(),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: _border(AppColors.colorGraficosNegrogris, 1),
            focusedBorder: _border(AppColors.colorLima, 1.2),
            errorBorder: _border(AppColors.colorError, 1.5),
            focusedErrorBorder: _border(AppColors.colorError, 1.5),
            errorStyle: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppColors.colorError,
            ),
          ),
        ),
      ],
    );
  }
}