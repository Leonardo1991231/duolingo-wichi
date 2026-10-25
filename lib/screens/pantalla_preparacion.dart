import 'package:flutter/material.dart';

import '../quiz_data.dart';
import 'pantalla_inicio.dart';

class PantallaPreparacion extends StatefulWidget {
  const PantallaPreparacion({super.key});

  @override
  State<PantallaPreparacion> createState() => _PantallaPreparacionState();
}

class _PantallaPreparacionState extends State<PantallaPreparacion> {
  static const Color _fondo = Color(0xFF071B30);
  static const Color _panel = Color(0xFF102B45);
  static const Color _turquesa = Color(0xFF29D6C1);

  static const List<(String, String, IconData)> _motivos = [
    ('Conocer mi lengua y cultura', 'Aprender y valorar las palabras Wichí.', Icons.auto_stories_rounded),
    ('Compartir con mi familia', 'Practicar para conversar con quienes quiero.', Icons.people_alt_rounded),
    ('Acompañar mis estudios', 'Sumar palabras y conocimientos nuevos.', Icons.school_rounded),
    ('Por curiosidad', 'Descubrir algo distinto cada día.', Icons.explore_rounded),
  ];

  int _paso = 0;
  String? _motivo;
  int? _dias;
  bool _guardando = false;

  Future<void> _continuar() async {
    if (_paso == 0) {
      if (_motivo == null) return;
      setState(() => _paso = 1);
      return;
    }
    if (_dias == null || _guardando) return;
    setState(() => _guardando = true);
    await PerfilUsuario.guardarPreparacion(motivo: _motivo!, diasMeta: _dias!);
    if (!mounted) return;
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const PantallaInicio()),
    );
  }

  Widget _opcion({
    required bool seleccionada,
    required IconData icono,
    required String titulo,
    required String detalle,
    required VoidCallback alTocar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: seleccionada ? const Color(0xFF123D57) : _panel,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: alTocar,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: seleccionada ? _turquesa : Colors.white24, width: seleccionada ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(icono, color: seleccionada ? _turquesa : Colors.white70, size: 28),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(detalle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
                if (seleccionada) const Icon(Icons.check_circle_rounded, color: _turquesa),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: _fondo,
        foregroundColor: Colors.white,
        leading: _paso == 0 ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _paso = 0)),
        title: LinearProgressIndicator(value: _paso == 0 ? 0.5 : 1, color: _turquesa, backgroundColor: Colors.white12, minHeight: 8),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  Icon(_paso == 0 ? Icons.favorite_rounded : Icons.calendar_month_rounded, color: _turquesa, size: 48),
                  const SizedBox(height: 18),
                  Text(
                    _paso == 0 ? '¿Qué te motiva a aprender Wichí?' : 'Elegí tu meta semanal',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _paso == 0 ? 'Así preparamos un camino que tenga sentido para vos.' : 'Un ritmo que puedas sostener vale más que apurarse.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  if (_paso == 0)
                    for (final opcion in _motivos)
                      _opcion(
                        seleccionada: _motivo == opcion.$1,
                        icono: opcion.$3,
                        titulo: opcion.$1,
                        detalle: opcion.$2,
                        alTocar: () => setState(() => _motivo = opcion.$1),
                      )
                  else
                    for (final opcion in [(3, 'Tranquila', '3 días por semana'), (5, 'Constante', '5 días por semana'), (7, 'Todos los días', '7 días por semana')])
                      _opcion(
                        seleccionada: _dias == opcion.$1,
                        icono: Icons.local_fire_department_rounded,
                        titulo: opcion.$2,
                        detalle: opcion.$3,
                        alTocar: () => setState(() => _dias = opcion.$1),
                      ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_paso == 0 ? _motivo != null : _dias != null) && !_guardando ? _continuar : null,
                    style: FilledButton.styleFrom(backgroundColor: _turquesa, foregroundColor: _fondo, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _guardando
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_paso == 0 ? 'CONTINUAR' : 'EMPEZAR A APRENDER', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
