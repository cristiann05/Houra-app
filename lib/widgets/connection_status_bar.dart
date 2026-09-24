// lib/widgets/connection_status_bar.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/theme/app_colors.dart';

enum _ConnState { hidden, offline, reconnecting, restored }

/// Barra fija arriba de la pantalla que avisa del estado de la conexión:
/// - Sin conexión: se queda visible todo el tiempo que estés offline.
/// - Reconectando: aparece un momento nada más detectar que ha vuelto la red,
///   mientras confirmamos que de verdad hay conexión real (no solo wifi sin internet).
/// - Conexión restablecida: confirmación breve en verde, luego desaparece sola.
///
/// Los datos siguen funcionando en caché mientras tanto (eso ya lo hace Firestore
/// solo); esto es solo la parte de avisar al usuario de forma clara.
class ConnectionStatusBar extends StatefulWidget {
  const ConnectionStatusBar({super.key});

  @override
  State<ConnectionStatusBar> createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  _ConnState _state = _ConnState.hidden;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.every((r) => r == ConnectivityResult.none);

  Future<void> _bootstrap() async {
    final initial = await Connectivity().checkConnectivity();
    if (!mounted) return;
    if (!_hasConnection(initial)) {
      setState(() => _state = _ConnState.offline);
    }
    _sub = Connectivity().onConnectivityChanged.listen(_onChange);
  }

  void _onChange(List<ConnectivityResult> results) {
    final hasConn = _hasConnection(results);
    _timer?.cancel();

    if (!hasConn) {
      setState(() => _state = _ConnState.offline);
      return;
    }

    // Solo mostramos "reconectando/restablecida" si veníamos de estar offline.
    if (_state == _ConnState.offline || _state == _ConnState.reconnecting) {
      setState(() => _state = _ConnState.reconnecting);
      _timer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() => _state = _ConnState.restored);
        _timer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _state = _ConnState.hidden);
        });
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: _state == _ConnState.hidden ? const SizedBox(width: double.infinity) : _bar(),
    );
  }

  Widget _bar() {
    late final Color color;
    late final IconData icon;
    late final String text;

    switch (_state) {
      case _ConnState.offline:
        color = AppColors.colorError;
        icon = Icons.cloud_off_rounded;
        text = 'Sin conexión — se guardará cuando vuelva la red';
        break;
      case _ConnState.reconnecting:
        color = AppColors.colorAviso;
        icon = Icons.sync_rounded;
        text = 'Reconectando…';
        break;
      case _ConnState.restored:
        color = AppColors.colorLima;
        icon = Icons.cloud_done_rounded;
        text = 'Conexión restablecida';
        break;
      case _ConnState.hidden:
        return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey(_state),
      width: double.infinity,
      color: color.withValues(alpha: 0.14),
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 9, 16, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(color: color, fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}