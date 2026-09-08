// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:houra_app/models/entry.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/formatters.dart';
import 'package:houra_app/utils/home_stats.dart';
import 'package:houra_app/utils/stats_data.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _resumen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: StreamBuilder<List<Entry>>(
          stream: EntryRepository().watchEntries(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.colorLima));
            }
            final entries = snap.data ?? const <Entry>[];
            final stats = HomeStats.from(entries);
            final extra = StatsData.from(entries, stats);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Text(
                  'Estadísticas',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w800, fontSize: 26),
                ),
                const SizedBox(height: 16),
                _Segmented(
                  resumen: _resumen,
                  onChange: (v) => setState(() => _resumen = v),
                ),
                const SizedBox(height: 16),
                if (_resumen)
                  _ResumenTab(stats: stats, extra: extra)
                else
                  _ConceptosTab(stats: stats, extra: extra),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final bool resumen;
  final ValueChanged<bool> onChange;
  const _Segmented({required this.resumen, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.colorFondo : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: selected ? AppColors.colorTexto : AppColors.colorTextoTenue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          seg('Resumen', resumen, () => onChange(true)),
          seg('Conceptos', !resumen, () => onChange(false)),
        ],
      ),
    );
  }
}

class _ResumenTab extends StatelessWidget {
  final HomeStats stats;
  final StatsData extra;
  const _ResumenTab({required this.stats, required this.extra});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BigStat(
                label: 'HORAS · MES',
                value: hoursFmt.format(stats.totalHoursMonth),
                unit: 'h',
                sub: '${stats.daysWorkedMonth} días activos',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _BigStat(
                label: 'GANADO',
                value: moneyFmt.format(stats.totalEarnMonth),
                unit: '',
                sub: 'media ${moneyFmt.format(stats.avgRateMonth)}/h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Últimos 7 días',
                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${hoursFmt.format(stats.last7.fold<double>(0, (s, d) => s + d.hours))} h',
                      style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              _BarRow(data: stats.last7, height: 110),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Insight(
                icon: Icons.local_fire_department,
                color: AppColors.colorMenta,
                value: '${stats.streak} días',
                label: 'Racha actual',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _Insight(
                icon: Icons.trending_up,
                color: AppColors.colorLima,
                value: '${hoursFmt.format(extra.avgHoursPerDay)} h',
                label: 'Media por día',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Insight(
                icon: Icons.star,
                color: AppColors.colorAviso,
                value: extra.bestWeekday,
                label: 'Mejor día semana',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _Insight(
                icon: Icons.flag,
                color: AppColors.colorLima,
                value: moneyFmt.format(extra.monthProjection),
                label: 'Ritmo del mes',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConceptosTab extends StatelessWidget {
  final HomeStats stats;
  final StatsData extra;
  const _ConceptosTab({required this.stats, required this.extra});

  @override
  Widget build(BuildContext context) {
    if (extra.tags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: Text('Aún no hay datos este mes',
              style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue)),
        ),
      );
    }

    final maxEarn = extra.tags.map((t) => t.earn).reduce((a, b) => a > b ? a : b);
    final total = stats.totalEarnMonth;
    final top = extra.tags.first;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿En qué se va el tiempo?',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: extra.tags
                        .map((t) => Expanded(
                              flex: (t.earn * 1000 / total).round().clamp(1, 100000),
                              child: Container(color: AppTags.colorOf(t.tag)),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              for (final t in extra.tags) _CatRow(t: t, total: total, maxEarn: maxEarn),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.colorLima.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.colorLima, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu categoría más rentable', style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 13)),
                    Text('${top.tag} · ${moneyFmt.format(top.earn)}',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 17)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CatRow extends StatelessWidget {
  final TagStat t;
  final double total;
  final double maxEarn;
  const _CatRow({required this.t, required this.total, required this.maxEarn});

  @override
  Widget build(BuildContext context) {
    final color = AppTags.colorOf(t.tag);
    final pct = total > 0 ? (t.earn / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        t.tag,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('· ${hoursFmt.format(t.hours)} h', style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(moneyFmt.format(t.earn),
                      style: GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(width: 6),
                  Text('$pct%', style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: maxEarn > 0 ? t.earn / maxEarn : 0,
              minHeight: 7,
              backgroundColor: AppColors.colorFondo,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String sub;
  const _BigStat({required this.label, required this.value, required this.unit, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 10.5, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w800, fontSize: 26)),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 14)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _Insight({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 11),
          Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 19)),
          const SizedBox(height: 1),
          Text(label, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final List<DayHours> data;
  final double height;
  const _BarRow({required this.data, required this.height});

  @override
  Widget build(BuildContext context) {
    final maxH = data.map((d) => d.hours).fold<double>(0, (a, b) => a > b ? a : b);
    const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final h = maxH > 0 ? (d.hours / maxH) : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: (height - 40) * h + (d.hours > 0 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: AppColors.colorLima.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dayLabels[d.day.weekday - 1], style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 11.5)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}