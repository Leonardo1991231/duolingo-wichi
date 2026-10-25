import 'package:flutter/material.dart';

import '../quiz_data.dart';
import 'pantalla_inicio.dart';
import 'pantalla_preparacion.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  static const Color _fondo = Color(0xFF041E42);

  void _continuar(BuildContext context) {
    final destino = PerfilUsuario.preparacionCompleta
        ? const PantallaInicio()
        : const PantallaPreparacion();
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _continuar(context),
          child: SizedBox.expand(
            child: Image.asset(
              'assets/images/caratula.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
