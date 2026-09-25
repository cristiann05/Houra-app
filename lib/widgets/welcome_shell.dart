import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/screens/auth_screen.dart';
import 'package:houra_app/theme/app_colors.dart';

/// Estructura común de las 3 welcome screens:
/// orbe brillante animado arriba, hero (cards) en el centro,
/// textos + botón + "Entrar" abajo, y dots de página.
class WelcomeShell extends StatefulWidget {
  final int page;
  final int pageCount;
  final bool isActive;
  final VoidCallback onNext;
  final List<Color> orbColors; // 3 colores
  final String eyebrow;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Size heroSize;
  final Widget Function(BuildContext context, int replay) heroBuilder;

  const WelcomeShell({
    super.key,
    required this.page,
    required this.onNext,
    required this.orbColors,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.heroSize,
    required this.heroBuilder,
    this.pageCount = 3,
    this.isActive = true,
  });

  @override
  State<WelcomeShell> createState() => _WelcomeShellState();
}

class _WelcomeShellState extends State<WelcomeShell> {
  int _replay = 0;

  @override
  void didUpdateWidget(WelcomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() => _replay++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final titleSize = (mq.size.width * 0.095).clamp(28.0, 38.0);

    return MediaQuery(
      data: mq.copyWith(
        textScaler:
            mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
      ),
      child: Scaffold(
        backgroundColor: AppColors.colorFondo,
        body: Stack(
          children: [
            // Orbe animado de fondo (welcome: sin cambios, blur completo)
            Positioned.fill(child: HouraOrb(colors: widget.orbColors)),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 28),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/png/houra-logo-horizontal.png',
                        height: 44,
                      ),
                    ),
                  ),
                  // Hero: se encoge si no cabe, nunca hace overflow
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: widget.heroSize.width,
                          height: widget.heroSize.height,
                          child: widget.heroBuilder(context, _replay),
                        ),
                      ),
                    ),
                  ),
                  _buildBottom(titleSize),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom(double titleSize) {
    final r = _replay;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Reveal(
            replay: r,
            index: 2,
            child: Text(
              widget.eyebrow,
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                fontSize: 12.5,
                color: AppColors.colorLima,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Reveal(
            replay: r,
            index: 3,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700,
                color: AppColors.colorTexto,
                fontSize: titleSize,
                height: 1.08,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Reveal(
            replay: r,
            index: 4,
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.colorTextoTenue,
                fontSize: 15.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Reveal(
            replay: r,
            index: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorLima.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.colorLima,
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/iconos/fwd.svg',
                          width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.buttonLabel,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTextoNegro,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            replay: r,
            index: 6,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  "¿Ya tienes cuenta?",
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.colorTextoTenue,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(onNext: () {}),
                    ),
                  ),
                  child: Text(
                    "Entrar",
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.colorTexto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pageCount, (i) {
              final active = i == widget.page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 22 : 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: active
                      ? AppColors.colorLima
                      : AppColors.colorTextoTenue.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Orbe: arco con brillo que respira y se desplaza suavemente
// ---------------------------------------------------------------------------
/// Fondo animado reutilizable (welcome + auth). Colócalo en un
/// `Positioned.fill` dentro de un Stack.
class HouraOrb extends StatefulWidget {
  final List<Color> colors; // 3 colores
  final double topFactor; // altura del arco respecto a la pantalla

  /// Si es true, usa un blur más barato y pausa mientras el teclado
  /// está abierto. Se mantiene por compatibilidad, pero en pantallas
  /// con TextFields es mejor usar [animate] = false directamente.
  final bool lightweight;

  /// Si es false, el orbe se pinta UNA sola vez (sin AnimationController,
  /// sin repaint en cada frame) y se queda estático. Ideal para pantallas
  /// con formularios (auth) donde no compensa gastar frame budget en un
  /// fondo decorativo. Welcome screens deben dejar esto en true (default).
  final bool animate;

  const HouraOrb({
    super.key,
    required this.colors,
    this.topFactor = 0.26,
    this.lightweight = false,
    this.animate = true,
  });

  @override
  State<HouraOrb> createState() => _HouraOrbState();
}

class _HouraOrbState extends State<HouraOrb>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 9),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.lightweight || _c == null) return;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardOpen && _c!.isAnimating) {
      _c!.stop();
    } else if (!keyboardOpen && !_c!.isAnimating) {
      _c!.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modo estático: un solo CustomPaint, sin AnimationController ni
    // AnimatedBuilder de por medio. Se pinta una vez y ya. RepaintBoundary
    // lo aisla del resto del árbol para que ni un rebuild de un padre
    // fuerce recomponer esta capa.
    if (_c == null) {
      return RepaintBoundary(
        child: CustomPaint(
          painter: _OrbPainter(
            0.0,
            widget.colors,
            widget.topFactor,
            lightweight: widget.lightweight,
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c!,
        builder: (_, __) => CustomPaint(
          painter: _OrbPainter(
            _c!.value,
            widget.colors,
            widget.topFactor,
            lightweight: widget.lightweight,
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final double topFactor;
  final bool lightweight;
  _OrbPainter(this.t, this.colors, this.topFactor, {this.lightweight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(t * 2 * math.pi);
    final breathe = math.cos(t * 2 * math.pi);
    final r = size.width * 0.9 + breathe * 8;
    final center = Offset(size.width / 2, size.height * topFactor + r);
    final rect = Rect.fromCircle(center: center, radius: r);

    Shader shader(double a) => SweepGradient(
          colors: [
            colors[0].withValues(alpha: a),
            colors[0].withValues(alpha: a),
            colors[1].withValues(alpha: a),
            colors[2].withValues(alpha: a),
            colors[2].withValues(alpha: a),
          ],
          stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
          transform: GradientRotation(math.pi / 2 + sway * 0.35),
        ).createShader(rect);

    // En modo ligero baja mucho el sigma del blur (es lo más caro de
    // pintar en cada frame); el resto del look se queda igual, solo
    // se reduce el difuminado del halo.
    final haloSigma = lightweight ? 18.0 : 40.0;
    final edgeSigma = lightweight ? 6.0 : 14.0;

    // Halo ancho y suave
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 90
        ..shader = shader(0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, haloSigma),
    );
    // Borde más brillante
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..shader = shader(0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, edgeSigma),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.t != t || old.colors != colors || old.topFactor != topFactor;
}

// ---------------------------------------------------------------------------
// Utilidades de animación y estilo compartidas
// ---------------------------------------------------------------------------

/// Entrada con fade + slide, escalonada por [index]. Se reinicia con [replay].
class Reveal extends StatelessWidget {
  final int replay;
  final int index;
  final Widget child;
  final Curve curve;
  final double distance;

  const Reveal({
    super.key,
    required this.replay,
    required this.child,
    this.index = 0,
    this.curve = Curves.easeOutCubic,
    this.distance = 24,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.09).clamp(0.0, 0.7);
    final end = (start + 0.5).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      key: ValueKey('$replay-$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1300),
      curve: Interval(start, end, curve: curve),
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * distance),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// Flotación suave continua (idle).
class Float extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final double phase; // 0..1
  final Duration duration;

  const Float({
    super.key,
    required this.child,
    this.amplitude = 5,
    this.phase = 0,
    this.duration = const Duration(milliseconds: 3200),
  });

  @override
  State<Float> createState() => _FloatState();
}

class _FloatState extends State<Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: widget.duration, value: widget.phase)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          0,
          (Curves.easeInOut.transform(_c.value) - 0.5) * 2 * widget.amplitude,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Decoración de card oscura con borde sutil.
BoxDecoration welcomeCardDecoration({double radius = 22}) => BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(40, 232, 255, 210),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(radius),
      color: AppColors.colorSuperficie,
      boxShadow: const [
        BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10)),
      ],
    );