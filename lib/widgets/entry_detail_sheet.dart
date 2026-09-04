import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/models/entry.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/formatters.dart';
import 'package:houra_app/widgets/app_toast.dart';

Future<void> showEntryDetailSheet(BuildContext context, Entry entry) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EntryDetailSheet(entry: entry),
  );
}

class EntryDetailSheet extends StatefulWidget {
  final Entry entry;
  const EntryDetailSheet({super.key, required this.entry});

  @override
  State<EntryDetailSheet> createState() => _EntryDetailSheetState();
}

class _EntryDetailSheetState extends State<EntryDetailSheet> {
  bool _deleting = false;

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await EntryRepository().deleteEntry(widget.entry.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, message: 'Entrada borrada', emoji: '🗑️', type: ToastType.info);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      AppToast.show(context, message: 'No se ha podido borrar', emoji: '⚠️', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final color = AppTags.colorOf(e.tag);

    Widget row(String k, String v, {bool mono = true}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.colorGraficosNegrogris)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k, style: TextStyle(color: AppColors.colorTextoTenue, fontSize: 14)),
              Text(
                v,
                style: mono
                    ? GoogleFonts.jetBrainsMono(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5)
                    : GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
            ],
          ),
        );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.colorFondo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.colorTextoTenue, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Container(width: 13, height: 13, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.concept,
                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700, fontSize: 19),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(100)),
                      child: Text(e.tag, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(color: AppColors.colorSuperficie, borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                row('Día', longDay(e.date), mono: false),
                row('Horas', '${hoursFmt.format(e.hours)} h'),
                row('Tarifa', '${e.rate.toStringAsFixed(0)}€/h'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                Text(
                  'TOTAL',
                  style: GoogleFonts.jetBrainsMono(color: AppColors.colorTextoTenue, letterSpacing: 1.2, fontSize: 12),
                ),
                Text(
                  moneyFmt.format(e.amount),
                  style: GoogleFonts.spaceGrotesk(color: AppColors.colorLima, fontWeight: FontWeight.w800, fontSize: 42),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _deleting ? null : _delete,
              icon: _deleting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.colorError))
                  : const Icon(Icons.delete_outline, color: AppColors.colorError),
              label: Text(
                'Borrar',
                style: GoogleFonts.spaceGrotesk(color: AppColors.colorError, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.colorError),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}