import 'package:flutter/material.dart';

import '../quiz_data.dart';

class PantallaJuegoInfantil extends StatefulWidget {
  const PantallaJuegoInfantil({super.key});

  @override
  State<PantallaJuegoInfantil> createState() => _PantallaJuegoInfantilState();
}

class _PantallaJuegoInfantilState extends State<PantallaJuegoInfantil> {
  late List<TarjetaJuego> _tarjetas;
  int? _primerIndiceSeleccionado;
  bool _bloquearInteraccion = false;
  int _paresEncontrados = 0;

  final List<String> _palabrasBase = [
    "Wityan",
    "Nhiyuwílh",
    "Asno",
    "Asno",
    "Wityan",
    "Nhiyuwílh",
  ];

  @override
  void initState() {
    super.initState();
    _inicializarJuego();
  }

  void _inicializarJuego() {
    _tarjetas = _palabrasBase.map((p) => TarjetaJuego(palabra: p)).toList();
    _tarjetas.shuffle(); // Mezcla las tarjetas de forma aleatoria
    _primerIndiceSeleccionado = null;
    _bloquearInteraccion = false;
    _paresEncontrados = 0;
  }

  void _alTocarTarjeta(int index) {
    if (_bloquearInteraccion ||
        _tarjetas[index].estaVolteada ||
        _tarjetas[index].estaEmparejada)
      return;

    setState(() {
      _tarjetas[index].estaVolteada = true;
    });

    if (_primerIndiceSeleccionado == null) {
      _primerIndiceSeleccionado = index;
    } else {
      _bloquearInteraccion = true;
      int primerIndex = _primerIndiceSeleccionado!;

      if (_tarjetas[primerIndex].palabra == _tarjetas[index].palabra) {
        // ¡Encontró un par!
        setState(() {
          _tarjetas[primerIndex].estaEmparejada = true;
          _tarjetas[index].estaEmparejada = true;
          _primerIndiceSeleccionado = null;
          _bloquearInteraccion = false;
          _paresEncontrados++;
        });

        if (_paresEncontrados == _tarjetas.length ~/ 2) {
          _finalizarJuego();
        }
      } else {
        // No coinciden, se dan vuelta otra vez
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            _tarjetas[primerIndex].estaVolteada = false;
            _tarjetas[index].estaVolteada = false;
            _primerIndiceSeleccionado = null;
            _bloquearInteraccion = false;
          });
        });
      }
    }
  }

  Future<void> _finalizarJuego() async {
    await PerfilUsuario.registrarResultado(
      nombreModulo: 'Juego de memoria',
      estrellasGanadas: 30,
      respuestasCorrectas: _paresEncontrados,
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Excelente Memoria! 🧠🎉"),
        content: const Text(
          "Completaste el juego de parejas con éxito.\n¡Ganaste +30 Estrellas! ⭐",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver al Menú"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Juego de Parejas para Niños"),
        backgroundColor: const Color(0xFF0C2A43),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _tarjetas.length,
          itemBuilder: (context, index) {
            final tarjeta = _tarjetas[index];
            return GestureDetector(
              onTap: () => _alTocarTarjeta(index),
              child: Card(
                color: tarjeta.estaVolteada || tarjeta.estaEmparejada
                    ? Colors.teal
                    : Colors.orange,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    tarjeta.estaVolteada || tarjeta.estaEmparejada
                        ? tarjeta.palabra
                        : "❓",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
