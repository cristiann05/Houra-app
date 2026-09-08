import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';

enum HouraBannerType { success, error, info }

/// Banner deslizante desde arriba, estilo notificación push in-app (como Revolut).
/// No usa notificaciones del sistema: se dibuja dentro de la propia app con un Overlay,
/// así que funciona igual en iOS/Android sin pedir permisos.
class HouraNotification {
  static OverlayEntry? _current;
  static final AudioPlayer _player = AudioPlayer();

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    HouraBannerType type = HouraBannerType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // feedback táctil + sonido propio (no depende de ajustes del sistema)
    switch (type) {
      case HouraBannerType.success:
        HapticFeedback.mediumImpact();
        _player.play(AssetSource('sounds/notify.wav'), volume: 0.6);
        break;
      case HouraBannerType.error:
        HapticFeedback.heavyImpact();
        break;
      case HouraBannerType.info:
        HapticFeedback.lightImpact();
        break;
    }

    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _BannerWidget(
        title: title,
        subtitle: subtitle,
        type: type,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _BannerWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final HouraBannerType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _BannerWidget({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  double _dragDy = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _offset = Tween<Offset>(begin: const Offset(0, -1.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color, IconData) get _style {
    switch (widget.type) {
      case HouraBannerType.success:
        return (AppColors.colorLima, Icons.check_circle_rounded);
      case HouraBannerType.error:
        return (AppColors.colorError, Icons.error_rounded);
      case HouraBannerType.info:
        return (AppColors.colorCielo, Icons.info_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _offset,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, topPadding > 0 ? 4 : 10, 14, 0),
            child: GestureDetector(
              onVerticalDragUpdate: (d) => setState(() => _dragDy += d.delta.dy),
              onVerticalDragEnd: (_) {
                if (_dragDy < -12) {
                  _dismiss();
                } else {
                  setState(() => _dragDy = 0);
                }
              },
              onTap: _dismiss,
              child: Transform.translate(
                offset: Offset(0, _dragDy.clamp(-40, 0)),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.colorSuperficie,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.colorGraficosNegrogris),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.colorTexto,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.colorTextoTenue,
                                    fontSize: 12.5,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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