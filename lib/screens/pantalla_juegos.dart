import 'package:flutter/material.dart';

import '../quiz_data.dart';
import 'pantalla_ejercicio.dart';
import 'pantalla_juego_infantil.dart';

class PantallaJuegos extends StatelessWidget {
  const PantallaJuegos({super.key});

  static const _fondo = Color(0xFF071326);
  static const _panel = Color(0xFF112541);

  Future<void> _abrir(BuildContext context, Widget pantalla) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pantalla));
  }

  Widget _tarjeta({
    required String titulo,
    required String descripcion,
    required String etiqueta,
    required IconData icono,
    required List<Color> colores,
    required VoidCallback jugar,
  }) => Card(
        color: _panel,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: InkWell(
          onTap: jugar,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(gradient: LinearGradient(colors: colores), borderRadius: BorderRadius.circular(19)),
                child: Icon(icono, color: Colors.white, size: 31),
              ),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(etiqueta.toUpperCase(), style: TextStyle(color: colores.first, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 3),
                Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(descripcion, style: const TextStyle(color: Color(0xFFB7C7D8))),
              ])),
              const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF49D9C4), size: 31),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(title: const Text('Juegos'), backgroundColor: _fondo),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C3DB3), Color(0xFFB14C87)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.sports_esports_rounded, size: 36, color: Colors.white),
                SizedBox(height: 12),
                Text('Jugá y aprendé', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Retos cortos para practicar a tu manera.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('ELEGÍ TU DESAFÍO', style: TextStyle(color: Color(0xFF48D9C5), fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),
            _tarjeta(
              etiqueta: 'Atención y memoria',
              titulo: 'Memoria de palabras',
              descripcion: 'Encontrá las parejas y completá el tablero.',
              icono: Icons.grid_view_rounded,
              colores: const [Color(0xFFFFB35C), Color(0xFFE26B69)],
              jugar: () => _abrir(context, const PantallaJuegoInfantil()),
            ),
            _tarjeta(
              etiqueta: 'Reto de preguntas',
              titulo: 'Saludos básicos',
              descripcion: 'Tres preguntas para sumar puntos y estrellas.',
              icono: Icons.waving_hand_rounded,
              colores: const [Color(0xFF20B9A7), Color(0xFF1682A6)],
              jugar: () => _abrir(context, PantallaEjercicio(preguntas: wichiQuestions, nombreModulo: 'Juego: reto de saludos')),
            ),
            _tarjeta(
              etiqueta: 'Armá la respuesta',
              titulo: 'Palabras en orden',
              descripcion: 'Construí la traducción tocando cada palabra.',
              icono: Icons.extension_rounded,
              colores: const [Color(0xFF4F8DE8), Color(0xFF6956C8)],
              jugar: () => _abrir(context, PantallaEjercicio(preguntas: [wichiQuestions[1]], nombreModulo: 'Reto: palabras en orden')),
            ),
            _tarjeta(
              etiqueta: 'Explorá el monte',
              titulo: 'Reto de animales',
              descripcion: 'Probá lo que sabés sobre la fauna.',
              icono: Icons.pets_rounded,
              colores: const [Color(0xFF58A96A), Color(0xFF238F9D)],
              jugar: () => _abrir(context, PantallaEjercicio(preguntas: animalesQuestions, nombreModulo: 'Juego: reto de animales')),
            ),
          ],
        ),
      );
}
