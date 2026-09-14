// lib/widgets/responsive_page.dart
import 'package:flutter/material.dart';

/// Envuelve el contenido de una pantalla para que se comporte bien en
/// cualquier tamaño:
/// - Móvil (lo normal): ocupa todo el ancho, exactamente igual que ahora.
/// - Tablet / web / escritorio: centra el contenido con un ancho máximo
///   cómodo de leer (como hacen Revolut, Instagram, etc.), en vez de
///   estirar las cards y el texto de un lado a otro de la pantalla.
///
/// Se usa envolviendo el `body` (o el scroll principal) de cada pantalla:
///   body: ResponsivePage(child: SingleChildScrollView(...))
class ResponsivePage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsivePage({super.key, required this.child, this.maxWidth = 520});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Atajos para tomar decisiones de layout según el ancho disponible,
/// sin repetir los mismos números mágicos en cada pantalla.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  bool get isCompact => screenWidth < 360; // móviles muy pequeños (ej. iPhone SE)
  bool get isTablet => screenWidth >= 700;
}