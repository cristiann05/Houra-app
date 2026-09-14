// lib/widgets/add_entry_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/models/entry.dart';
import 'package:houra_app/models/houra_user.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/utils/formatters.dart';
import 'package:houra_app/widgets/app_toast.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';

/// Abre el sheet para crear una entrada nueva, o para editar una existente
/// si se pasa [existingEntry].
Future<void> showAddEntrySheet(
  BuildContext context, {
  double? defaultRate,
  Entry? existingEntry,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddEntrySheet(defaultRate: defaultRate, existingEntry: existingEntry),
  );
}

class AddEntrySheet extends StatefulWidget {
  final double? defaultRate;
  final Entry? existingEntry;
  const AddEntrySheet({super.key, this.defaultRate, this.existingEntry});

  bool get isEditing => existingEntry != null;

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _conceptController;
  late final TextEditingController _hoursController;
  late final TextEditingController _rateController;
  final _repo = EntryRepository();
  final _authRepo = AuthRepository();

  String? _tag; // se fija en cuanto llegan las tags disponibles
  List<String> _localExtraTags = []; // tags creadas en esta sesión, por si el stream tarda
  bool _rateInitialized = false;
  late DateTime _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEntry;

    _conceptController = TextEditingController(text: existing?.concept ?? '');
    _hoursController = TextEditingController(
      text: existing != null ? trimZeros(existing.hours) : '',
    );
    _rateController = TextEditingController(
      text: existing != null
          ? trimZeros(existing.rate)
          : (widget.defaultRate != null ? trimZeros(widget.defaultRate!) : ''),
    );
    _date = existing?.date ?? DateTime.now();
    _tag = existing?.tag;
    // si venimos con tarifa ya rellenada (edición o defaultRate), no la pisamos con la del perfil
    _rateInitialized = _rateController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _hoursController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final concept = _conceptController.text.trim();
      final hours = double.parse(_hoursController.text.replaceAll(',', '.'));
      final rate = double.parse(_rateController.text.replaceAll(',', '.'));
      final tag = _tag ?? AppTags.defaults.first;

      if (widget.isEditing) {
        await _repo.updateEntry(
          widget.existingEntry!.id,
          concept: concept,
          hours: hours,
          rate: rate,
          tag: tag,
          date: _date,
        );
      } else {
        await _repo.addEntry(
          concept: concept,
          hours: hours,
          rate: rate,
          tag: tag,
          date: _date,
        );
      }

      if (!mounted) return;
      HouraNotification.show(
        context,
        title: widget.isEditing ? 'Cambios guardados' : '¡Horas apuntadas!',
        subtitle: '$concept · $hours h',
        type: HouraBannerType.success,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'No se ha podido guardar', emoji: '⚠️', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewTag() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorSuperficie,
        title: Text('Nueva categoría', style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
          decoration: InputDecoration(hintText: 'Ej: Mudanzas', hintStyle: TextStyle(color: AppColors.colorTextoTenue)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: AppColors.colorTextoTenue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Crear', style: TextStyle(color: AppColors.colorLima, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      _localExtraTags = [..._localExtraTags, name];
      _tag = name;
    });
    // se guarda en segundo plano para futuras sesiones; no bloqueamos la UI por esto
    _authRepo.addCustomTag(name);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.colorLima,
              onPrimary: AppColors.colorTextoNegro,
              surface: AppColors.colorSuperficie,
              onSurface: AppColors.colorTexto,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.colorFondo),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.colorLima),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue),
        filled: true,
        fillColor: AppColors.colorSuperficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.colorFondo,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.colorTextoTenue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.isEditing ? 'Editar horas' : 'Apuntar horas',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.colorTexto,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _conceptController,
                style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                decoration: _decoration('Concepto'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                      decoration: _decoration('Horas'),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                      decoration: _decoration('€/h'),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<HouraUser?>(
                stream: _authRepo.watchCurrentUser(),
                builder: (context, snap) {
                  final remoteCustom = snap.data?.customTags ?? const <String>[];
                  final merged = AppTags.allFor([...remoteCustom, ..._localExtraTags]);
                  _tag ??= merged.first;

                  if (!_rateInitialized && _rateController.text.isEmpty && snap.data != null) {
                    final fallbackRate = widget.defaultRate ?? snap.data!.hourlyRate;
                    _rateController.text = trimZeros(fallbackRate);
                    _rateInitialized = true;
                  }

                  return SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: merged.length + 1, // +1 = chip "Nueva"
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        if (i == merged.length) {
                          return GestureDetector(
                            onTap: _createNewTag,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.colorSuperficie,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.colorTextoTenue.withValues(alpha: 0.4), style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, size: 15, color: AppColors.colorTextoTenue),
                                  const SizedBox(width: 4),
                                  Text('Nueva',
                                      style: GoogleFonts.spaceGrotesk(color: AppColors.colorTextoTenue, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                          );
                        }
                        final tag = merged[i];
                        final selected = tag == _tag;
                        final color = AppTags.colorOf(tag);
                        return GestureDetector(
                          onTap: () => setState(() => _tag = tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? color.withValues(alpha: 0.18) : AppColors.colorSuperficie,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: selected ? color : Colors.transparent),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.spaceGrotesk(
                                color: selected ? color : AppColors.colorTextoTenue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.colorSuperficie,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.colorTextoTenue),
                      const SizedBox(width: 10),
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.colorTexto),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorLima,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.colorTextoNegro),
                        )
                      : Text(
                          widget.isEditing ? 'Guardar cambios' : 'Guardar',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.colorTextoNegro,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}