import 'package:intl/intl.dart';

final moneyFmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);
final hoursFmt = NumberFormat.decimalPattern('es_ES');

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