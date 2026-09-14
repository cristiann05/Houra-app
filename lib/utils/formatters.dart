// lib/utils/formatters.dart
import 'package:intl/intl.dart';

final moneyFmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);
final hoursFmt = NumberFormat.decimalPattern('es_ES');

/// Convierte un número a texto SIN forzar decimales ni truncarlos:
/// 7.0 -> "7", 7.5 -> "7,5", 7.25 -> "7,25". Se usa para precargar campos
/// editables (tarifa, meta, horas) sin perder nunca la parte decimal real.
String trimZeros(double v) {
  final fixed = v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0*$'), '');
  return fixed.replaceAll('.', ',');
}

/// Formatea dinero con separador de miles, mostrando 2 decimales SOLO si el
/// número no es entero: 1227.0 -> "1.227 €", 1227.45 -> "1.227,45 €".
String formatMoney(double v) {
  final hasDecimals = v != v.roundToDouble();
  final fmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: hasDecimals ? 2 : 0);
  return fmt.format(v);
}

/// "Hoy", "Ayer" o "Lun 2 jun" para fechas más lejanas.
String relDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return DateFormat('EEE d MMM', 'es').format(date);
}

/// "Jueves, 4 de junio" para la pantalla de detalle.
String longDay(DateTime date) {
  final s = DateFormat('EEEE, d MMMM', 'es').format(date);
  return s[0].toUpperCase() + s.substring(1);
}