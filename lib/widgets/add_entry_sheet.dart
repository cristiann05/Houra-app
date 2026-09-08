// lib/widgets/add_entry_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:houra_app/models/houra_user.dart';
import 'package:houra_app/repositories/auth_repository.dart';
import 'package:houra_app/repositories/entry_repository.dart';
import 'package:houra_app/theme/app_colors.dart';
import 'package:houra_app/theme/app_tags.dart';
import 'package:houra_app/widgets/app_toast.dart';
import 'package:houra_app/widgets/hour_notification_banner.dart';

Future<void> showAddEntrySheet(BuildContext context, {double? defaultRate}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddEntrySheet(defaultRate: defaultRate),
  );
}

class AddEntrySheet extends StatefulWidget {
  final double? defaultRate;
  const AddEntrySheet({super.key, this.defaultRate});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _conceptController = TextEditingController();
  final _hoursController = TextEditingController();
  late final TextEditingController _rateController;
  final _repo = EntryRepository();
  final _authRepo = AuthRepository();

  String? _tag; // se fija en cuanto llegan las tags disponibles
  List<String> _localExtraTags = []; // tags creadas en esta sesión, por si el stream tarda
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.defaultRate != null ? widget.defaultRate!.toStringAsFixed(0) : '',
    );
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
      await _repo.addEntry(
        concept: _conceptController.text.trim(),
        hours: double.parse(_hoursController.text.replaceAll(',', '.')),
        rate: double.parse(_rateController.text.replaceAll(',', '.')),
        tag: _tag ?? AppTags.defaults.first,
        date: _date,
      );
      if (!mounted) return;
      HouraNotification.show(
        context,
        title: '¡Horas apuntadas!',
        subtitle: '${_conceptController.text.trim()} · ${_hoursController.text} h',
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
              primary: AppColors.colorLima, // día seleccionado / header
              onPrimary: AppColors.colorTextoNegro, // texto sobre el día seleccionado
              surface: AppColors.colorSuperficie, // fondo del calendario
              onSurface: AppColors.colorTexto, // texto de los días
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
                'Apuntar horas',
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          'Guardar',
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