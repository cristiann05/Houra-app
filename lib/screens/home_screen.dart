// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:houra_app/models/entry.dart';
import 'package:houra_app/models/houra_user.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/home_stats.dart';
import 'package:houra_app/widgets/add_entry_sheet.dart';

final _moneyFmt = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);
final _hoursFmt = NumberFormat.decimalPattern('es_ES');

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final entryRepo = EntryRepository();

    return Scaffold(
      backgroundColor: AppColors.colorFondo,
      body: SafeArea(
        child: StreamBuilder<HouraUser?>(
          stream: authRepo.watchCurrentUser(),
          builder: (context, userSnap) {
            final user = userSnap.data;
            return StreamBuilder<List<Entry>>(
              stream: entryRepo.watchEntries(),
              builder: (context, entriesSnap) {
                final entries = entriesSnap.data ?? const <Entry>[];
                final stats = HomeStats.from(entries);
                final loading = userSnap.connectionState == ConnectionState.waiting ||
                    entriesSnap.connectionState == ConnectionState.waiting;

                if (loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.colorLima),
                  );
                }

                return _HomeBody(
                  user: user,
                  stats: stats,
                  onAdd: () => showAddEntrySheet(context, defaultRate: user?.hourlyRate),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HouraUser? user;
  final HomeStats stats;
  final VoidCallback onAdd;

  const _HomeBody({required this.user, required this.stats, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat('EEEE, d MMM', 'es').format(DateTime.now());
    final fecha = fechaFormateada[0].toUpperCase() + fechaFormateada.substring(1);
    final name = user?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera ─────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Buenas, $name! 👋',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5),
                  ),
                  Text(
                    fecha,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.colorTexto,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.colorSuperficie,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.colorLimaBorde),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.colorTexto, size: 20),
              ),
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.colorLima,
                child: Text(
                  initial,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.colorTextoNegro,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Ganado este mes ──────────────────────
          _EarningsHero(stats: stats),
          const SizedBox(height: 14),

          // ── Botón principal ──────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: AppColors.colorTextoNegro),
              label: Text(
                'Apuntar horas',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.colorTextoNegro,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorLima,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Racha / Días activos ─────────────────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '${stats.streak}',
                  unit: 'días',
                  color: AppColors.colorMenta,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_month,
                  label: 'Días activos',
                  value: '${stats.daysWorkedMonth}',
                  unit: 'este mes',
                  color: AppColors.colorLima,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Últimos 7 días ────────────────────────
          _MiniWeekCard(stats: stats),
          const SizedBox(height: 20),

          // ── Movimientos recientes ────────────────
          Text(
            'Movimientos recientes',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.colorTexto,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _RecentEntriesCard(entries: stats.sorted.take(3).toList()),
        ],
      ),
    );
  }
}

class _EarningsHero extends StatelessWidget {
  final HomeStats stats;
  const _EarningsHero({required this.stats});

  @override
  Widget build(BuildContext context) {
    final trend = stats.trendPct;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorSuperficie,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.colorLimaBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GANADO ESTE MES',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.colorTextoTenue,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trend >= 0 ? AppColors.colorLima : AppColors.colorError).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trend >= 0 ? AppColors.colorLima : AppColors.colorError,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${trend.abs().toStringAsFixed(0)}%',
                        style: GoogleFonts.jetBrainsMono(
                          color: trend >= 0 ? AppColors.colorLima : AppColors.colorError,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _moneyFmt.format(stats.totalEarnMonth),
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.colorTexto,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${_hoursFmt.format(stats.totalHoursMonth)} h',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.colorTexto,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text('·', style: TextStyle(color: AppColors.colorTextoTenue)),
              const SizedBox(width: 8),
              Text(
                'media ${_moneyFmt.format(stats.avgRateMonth)}/h',
                style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.colorSuperficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.colorTexto,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              Text(unit, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5)),
            ],
          ),
          Text(label, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _MiniWeekCard extends StatelessWidget {
  final HomeStats stats;
  const _MiniWeekCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final maxH = stats.last7.map((d) => d.hours).fold<double>(0, (a, b) => a > b ? a : b);
    final totalWeek = stats.last7.fold<double>(0, (s, d) => s + d.hours);
    const dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorSuperficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos 7 días',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.colorTexto,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_hoursFmt.format(totalWeek)} h',
                style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.last7.map((d) {
                final h = maxH > 0 ? (d.hours / maxH) : 0.0;
                final isToday = d.day.day == DateTime.now().day &&
                    d.day.month == DateTime.now().month;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 52 * h + (d.hours > 0 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.colorLima : AppColors.colorLima.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels[d.day.weekday - 1],
                          style: TextStyle(
                            color: isToday ? AppColors.colorTexto : AppColors.colorTextoTenue,
                            fontSize: 11.5,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntriesCard extends StatelessWidget {
  final List<Entry> entries;
  const _RecentEntriesCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.colorSuperficie,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            'Todavía no has apuntado horas',
            style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.colorSuperficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          final color = AppTags.colorOf(e.tag);
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: i == entries.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.colorGraficosNegrogris)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.concept,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.colorTexto,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('d MMM', 'es').format(e.date)} · ${_hoursFmt.format(e.hours)} h',
                        style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _moneyFmt.format(e.amount),
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.colorTexto,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      '${e.rate.toStringAsFixed(0)}€/h',
                      style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 11.5),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}