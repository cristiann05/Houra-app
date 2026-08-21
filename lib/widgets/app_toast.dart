// lib/widgets/app_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/theme/app_colors.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    String? emoji,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) =>
          _ToastWidget(message: message, emoji: emoji, type: type),
    );

    overlay.insert(entry);

    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? emoji;
  final ToastType type;

  const _ToastWidget({
    required this.message,
    required this.emoji,
    required this.type,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.colorLima;
      case ToastType.error:
        return AppColors.colorError;
      case ToastType.info:
        return AppColors.colorSuperficie;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case ToastType.success:
      case ToastType.error:
        return AppColors.colorTextoNegro;
      case ToastType.info:
        return AppColors.colorTexto;
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  return Positioned(
    bottom: MediaQuery.of(context).padding.bottom,
    left: 0,
    right: 0,
    child: Center(
      child: IgnorePointer(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.spaceGrotesk(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.emoji != null) ...[
                      const SizedBox(width: 6),
                      Text(widget.emoji!, style: const TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
