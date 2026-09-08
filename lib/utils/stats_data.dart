import 'package:houra_app/models/entry.dart';
import 'package:houra_app/utils/home_stats.dart';

class TagStat {
  final String tag;
  final double hours;
  final double earn;
  const TagStat(this.tag, this.hours, this.earn);
}

const _weekdayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

class StatsData {
  final double avgHoursPerDay;
  final String bestWeekday;
  final double monthProjection;
  final List<TagStat> tags; // este mes, ordenado desc por ganado

  const StatsData({
    required this.avgHoursPerDay,
    required this.bestWeekday,
    required this.monthProjection,
    required this.tags,
  });

  factory StatsData.from(List<Entry> entries, HomeStats home) {
    final now = DateTime.now();
    final thisMonth = entries
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

    final avgDay = home.daysWorkedMonth > 0 ? home.totalHoursMonth / home.daysWorkedMonth : 0.0;

    final byWeekday = <int, double>{};
    for (final e in thisMonth) {
      byWeekday[e.date.weekday] = (byWeekday[e.date.weekday] ?? 0) + e.hours;
    }
    var bestWeekday = '—';
    if (byWeekday.isNotEmpty) {
      final bestKey = byWeekday.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      bestWeekday = _weekdayNames[bestKey - 1];
    }

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final projection = now.day > 0 ? (home.totalEarnMonth / now.day) * daysInMonth : 0.0;

    final byTag = <String, TagStat>{};
    for (final e in thisMonth) {
      final prev = byTag[e.tag];
      byTag[e.tag] = TagStat(e.tag, (prev?.hours ?? 0) + e.hours, (prev?.earn ?? 0) + e.amount);
    }
    final tags = byTag.values.toList()..sort((a, b) => b.earn.compareTo(a.earn));

    return StatsData(
      avgHoursPerDay: avgDay,
      bestWeekday: bestWeekday,
      monthProjection: projection,
      tags: tags,
    );
  }
}