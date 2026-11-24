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

  final List<(String, String)> _pares = [
    ('Wityan', 'Hola / Buenos días'),
    ('Nhiyuwílh', 'Arcoíris'),
    ('Asno', 'Burro'),
  ];

  @override
  void initState() {
    super.initState();
    _inicializarJuego();
  }

  void _inicializarJuego() {
    _tarjetas = [
      for (final par in _pares) ...[
        TarjetaJuego(palabra: par.$1, idPareja: par.$1),
        TarjetaJuego(palabra: par.$2, idPareja: par.$1),
      ],
    ]..shuffle();
    _primerIndiceSeleccionado = null;
    _bloquearInteraccion = false;
    _paresEncontrados = 0;
  }

  void _alTocarTarjeta(int index) {
    if (_bloquearInteraccion || _tarjetas[index].estaVolteada || _tarjetas[index].estaEmparejada) return;
    setState(() => _tarjetas[index].estaVolteada = true);

    if (_primerIndiceSeleccionado == null) {
      _primerIndiceSeleccionado = index;
      return;
    }

    final primerIndex = _primerIndiceSeleccionado!;
    _bloquearInteraccion = true;
    if (_tarjetas[primerIndex].idPareja == _tarjetas[index].idPareja) {
      setState(() {
        _tarjetas[primerIndex].estaEmparejada = true;
        _tarjetas[index].estaEmparejada = true;
        _primerIndiceSeleccionado = null;
        _bloquearInteraccion = false;
        _paresEncontrados++;
      });
      if (_paresEncontrados == _tarjetas.length ~/ 2) _finalizarJuego();
    } else {
      Future.delayed(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        setState(() {
          _tarjetas[primerIndex].estaVolteada = false;
          _tarjetas[index].estaVolteada = false;
          _primerIndiceSeleccionado = null;
          _bloquearInteraccion = false;
        });
      });
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
        title: const Text('¡Parejas completas!'),
        content: const Text('Relacionaste las palabras con sus significados. Ganaste 30 estrellas.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Seguir jugando'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF071326),
        appBar: AppBar(
          title: const Text('Memoria de palabras'),
          backgroundColor: const Color(0xFF071326),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Uní cada palabra con su significado.', style: TextStyle(color: Color(0xFFB8CAD8))),
                  ),
                  Chip(
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_paresEncontrados.toString() + ' / ' + _pares.length.toString()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _tarjetas.length,
                  itemBuilder: (context, index) {
                    final tarjeta = _tarjetas[index];
                    final visible = tarjeta.estaVolteada || tarjeta.estaEmparejada;
                    final colores = tarjeta.estaEmparejada
                        ? const [Color(0xFF168F83), Color(0xFF146D78)]
                        : visible
                            ? const [Color(0xFF188B9B), Color(0xFF176A9A)]
                            : const [Color(0xFF1B3555), Color(0xFF244D70)];
                    return Semantics(
                      button: true,
                      label: visible ? tarjeta.palabra : 'Tarjeta oculta',
                      child: GestureDetector(
                        onTap: () => _alTocarTarjeta(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colores, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: visible ? const Color(0xFF4BE0CB) : Colors.white12, width: visible ? 2 : 1),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 5))],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: FittedBox(
                                key: ValueKey(visible ? tarjeta.palabra : 'oculta'),
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    visible ? tarjeta.palabra : '✦',
                                    style: TextStyle(fontSize: visible ? 20 : 34, fontWeight: FontWeight.bold, color: visible ? Colors.white : const Color(0xFF62DFD0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
