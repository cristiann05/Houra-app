import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/models/entry.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/formatters.dart';
import 'package:houra_app/widgets/add_entry_sheet.dart';
import 'package:houra_app/widgets/entry_detail_sheet.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  String _filter = 'Todo';

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
            final all = snap.data ?? const <Entry>[];
            final usedTags = all.map((e) => e.tag).toSet().toList();
            final list = _filter == 'Todo' ? all : all.where((e) => e.tag == _filter).toList();

            // agrupar por día relativo, manteniendo el orden (ya viene desc del repo)
            final groups = <String, List<Entry>>{};
            for (final e in list) {
              groups.putIfAbsent(relDay(e.date), () => []).add(e);
            }

            final totalHours = list.fold<double>(0, (s, e) => s + e.hours);
            final totalEarn = list.fold<double>(0, (s, e) => s + e.amount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tus horas',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w800, fontSize: 26),
                      ),
                      GestureDetector(
                        onTap: () => showAddEntrySheet(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.colorLima, borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.add, color: AppColors.colorTextoNegro),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Text(
                    '${hoursFmt.format(totalHours)} h · ${moneyFmt.format(totalEarn)} · ${list.length} entradas',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontSize: 13.5),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    children: [
                      _FilterChip(label: 'Todo', selected: _filter == 'Todo', color: AppColors.colorLima, onTap: () => setState(() => _filter = 'Todo')),
                      const SizedBox(width: 8),
                      for (final tag in usedTags) ...[
                        _FilterChip(
                          label: tag,
                          selected: _filter == tag,
                          color: AppTags.colorOf(tag),
                          onTap: () => setState(() => _filter = tag),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            'Sin entradas en este filtro',
                            style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          children: [
                            for (final entry in groups.entries) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 4, 0, 8),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.colorTextoTenue,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.colorSuperficie,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: List.generate(entry.value.length, (i) {
                                    final e = entry.value[i];
                                    final color = AppTags.colorOf(e.tag);
                                    final isLast = i == entry.value.length - 1;
                                    return GestureDetector(
                                      onTap: () => showEntryDetailSheet(context, e),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        decoration: BoxDecoration(
                                          border: isLast
                                              ? null
                                              : const Border(bottom: BorderSide(color: AppColors.colorGraficosNegrogris)),
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
                                                    '${hoursFmt.format(e.hours)} h',
                                                    style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 12.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              moneyFmt.format(e.amount),
                                              style: GoogleFonts.jetBrainsMono(
                                                color: AppColors.colorTexto,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : AppColors.colorSuperficie,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'Todo') ...[
              Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: selected ? color : AppColors.colorTextoTenue,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}