import 'package:houra_app/models/entry.dart';

class DayHours {
  final DateTime day;
  final double hours;
  const DayHours(this.day, this.hours);
}

class HomeStats {
  final double totalEarnMonth;
  final double totalHoursMonth;
  final double avgRateMonth;
  final double? trendPct; // null si no hay datos del mes anterior para comparar
  final int streak;
  final int daysWorkedMonth;
  final List<DayHours> last7;
  final List<Entry> sorted;

  const HomeStats({
    required this.totalEarnMonth,
    required this.totalHoursMonth,
    required this.avgRateMonth,
    required this.trendPct,
    required this.streak,
    required this.daysWorkedMonth,
    required this.last7,
    required this.sorted,
  });

  factory HomeStats.from(List<Entry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isSameMonth(DateTime d, int y, int m) => d.year == y && d.month == m;

    final thisMonth = entries.where((e) => isSameMonth(e.date, now.year, now.month)).toList();
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final prevMonth = entries
        .where((e) => isSameMonth(e.date, prevMonthDate.year, prevMonthDate.month))
        .toList();

    final totalEarn = thisMonth.fold<double>(0, (s, e) => s + e.amount);
    final totalHours = thisMonth.fold<double>(0, (s, e) => s + e.hours);
    final avgRate = totalHours > 0 ? totalEarn / totalHours : 0.0;

    final prevEarn = prevMonth.fold<double>(0, (s, e) => s + e.amount);
    final trend = prevEarn > 0 ? ((totalEarn - prevEarn) / prevEarn) * 100 : null;

    // Días distintos (normalizados a medianoche) con al menos un entry.
    final daySet = entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet();

    // Racha: cuenta hacia atrás desde hoy (o desde ayer si hoy aún no se ha apuntado nada).
    int streak = 0;
    DateTime cursor = daySet.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (daySet.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final daysWorkedMonth =
        daySet.where((d) => isSameMonth(d, now.year, now.month)).length;

    // Últimos 7 días (incluye hoy), orden cronológico.
    final last7 = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final hours = entries
          .where((e) =>
              e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
          .fold<double>(0, (s, e) => s + e.hours);
      return DayHours(day, hours);
    });

    return HomeStats(
      totalEarnMonth: totalEarn,
      totalHoursMonth: totalHours,
      avgRateMonth: avgRate,
      trendPct: trend,
      streak: streak,
      daysWorkedMonth: daysWorkedMonth,
      last7: last7,
      sorted: entries, // ya viene ordenado desc por el repositorio
    );
  }
}