import 'package:flutter/material.dart';

import '../models/estado_asistente.dart';
import '../quiz_data.dart';
import '../widgets/zorro_asistente.dart';
import 'pantalla_comunidad.dart';
import 'pantalla_diccionario.dart';
import 'pantalla_ejercicio.dart';
import 'pantalla_inicio.dart';
import 'pantalla_juegos.dart';

class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({super.key});

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  int _tab = 0;
  final _claves = List<GlobalKey<NavigatorState>>.generate(5, (_) => GlobalKey<NavigatorState>());
  final _creadas = <bool>[true, false, false, false, false];

  @override
  void initState() {
    super.initState();
    ContextoLocalZorro.cambiarSeccion = _irASeccion;
  }

  @override
  void dispose() {
    ContextoLocalZorro.cambiarSeccion = null;
    super.dispose();
  }

  void _irASeccion(int indice) {
    if (indice < 0 || indice >= _claves.length) return;
    if (indice == _tab) {
      _claves[indice].currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _creadas[indice] = true;
      _tab = indice;
    });
    ContextoLocalZorro.seccionActual = indice;
    if (indice == 0) {
      ContextoLocalZorro.entrarInicio();
      return;
    }

    final seccion = switch (indice) {
      1 => 'lecciones',
      2 => 'juegos',
      3 => 'comunidad',
      _ => 'progreso',
    };
    ContextoLocalZorro.emitirEvento(
      EventoZorro.sectionOpened,
      detalle: seccion,
    );
  }

  Widget _pantalla(int indice) => switch (indice) {
    0 => const PantallaInicio(),
    1 => const _Lecciones(),
    2 => const PantallaJuegos(),
    3 => const PantallaComunidad(),
    _ => const _Progreso(),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(
            index: _tab,
            children: List<Widget>.generate(5, (indice) {
              if (!_creadas[indice]) return const SizedBox.shrink();
              return Navigator(
                key: _claves[indice],
                onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => _pantalla(indice)),
              );
            }),
          ),
        ),
        if (_tab != 0)
          const Positioned(
            right: 8,
            bottom: 10,
            child: SafeArea(child: ZorroAsistente()),
          ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      backgroundColor: const Color(0xFF10243D),
      indicatorColor: const Color(0xFF17405A),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: _irASeccion,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Aprender'),
        NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports_rounded), label: 'Jugar'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'Comunidad'),
        NavigationDestination(icon: Icon(Icons.donut_large_outlined), selectedIcon: Icon(Icons.donut_large_rounded), label: 'Progreso'),
      ],
    ),
  );
}

class _Lecciones extends StatelessWidget {
  const _Lecciones();
  static const _fondo = Color(0xFF071326);
  static const _panel = Color(0xFF112541);
  static const _suave = Color(0xFFADBDD0);

  void _abrirEjercicio(BuildContext context, String nombre, List<Question> preguntas) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PantallaEjercicio(preguntas: preguntas, nombreModulo: nombre),
    ));
  }

  Widget _tarjeta({
    required BuildContext context,
    required int numero,
    required String titulo,
    required String detalle,
    required bool completada,
    required bool habilitada,
    required VoidCallback alTocar,
  }) {
    final acento = completada ? const Color(0xFF39D4C2) : const Color(0xFF62C9F4);
    return Card(
      color: _panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: acento.withOpacity(.13),
          child: Text(numero.toString().padLeft(2, '0'), style: TextStyle(color: acento, fontWeight: FontWeight.bold)),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(detalle, style: const TextStyle(color: _suave))),
        trailing: Icon(completada ? Icons.check_circle_rounded : habilitada ? Icons.chevron_right_rounded : Icons.lock_outline_rounded, color: acento),
        onTap: habilitada ? alTocar : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saludos = PerfilUsuario.leccionCompletada('Módulo 1: Saludos');
    final animales = PerfilUsuario.leccionCompletada('Módulo 2: Animales del Monte');
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(title: const Text('Aprendé paso a paso'), backgroundColor: _fondo),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Text('TU CAMINO', style: TextStyle(color: Color(0xFF35D4C4), fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Aprendé a tu ritmo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Elegí una misión, practicá y volvé cuando quieras.', style: TextStyle(color: _suave)),
          const SizedBox(height: 20),
          _tarjeta(context: context, numero: 1, titulo: 'Saludos básicos', detalle: 'Aprendé a saludar y presentarte.', completada: saludos, habilitada: true, alTocar: () => _abrirEjercicio(context, 'Módulo 1: Saludos', wichiQuestions)),
          _tarjeta(context: context, numero: 2, titulo: 'Animales del monte', detalle: 'Descubrí la fauna del Chaco.', completada: animales, habilitada: saludos, alTocar: () => _abrirEjercicio(context, 'Módulo 2: Animales del Monte', animalesQuestions)),
          const SizedBox(height: 8),
          Card(
            color: _panel,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF164B58), child: Icon(Icons.menu_book_rounded, color: Color(0xFF55E0CD))),
              title: const Text('Diccionario comunitario', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Consultá palabras, fotos y grabaciones', style: TextStyle(color: _suave)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF55E0CD)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PantallaDiccionario())),
            ),
          ),
        ],
      ),
    );
  }
}

class _Progreso extends StatelessWidget {
  const _Progreso();
  static const _fondo = Color(0xFF071326);
  static const _panel = Color(0xFF112541);
  static const _turquesa = Color(0xFF35D4C4);
  static const _suave = Color(0xFFADBDD0);

  @override
  Widget build(BuildContext context) {
    final completadas = [
      PerfilUsuario.leccionCompletada('Módulo 1: Saludos'),
      PerfilUsuario.leccionCompletada('Módulo 2: Animales del Monte'),
    ].where((valor) => valor).length;
    final avance = completadas / 2;
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(title: const Text('Aprendé paso a paso'), backgroundColor: _fondo),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text('TU PROGRESO', style: TextStyle(color: _turquesa, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Cada paso cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22)),
            child: Column(children: [
              const Text('RUTA DE APRENDIZAJE', style: TextStyle(color: _suave, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text((avance * 100).round().toString() + '%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: avance, minHeight: 10, backgroundColor: const Color(0xFF1B3555), color: const Color(0xFF2589FF))),
              const SizedBox(height: 10),
              Text(completadas.toString() + ' de 2 misiones completadas', style: const TextStyle(color: _suave)),
            ]),
          ),
          const SizedBox(height: 26),
          const Text('Tus objetivos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _objetivo(Icons.check_circle_outline_rounded, 'Saludos básicos', completadas > 0 ? 'Lección completada' : 'Disponible para practicar', completadas > 0),
          _objetivo(Icons.pets_rounded, 'Animales del monte', completadas > 1 ? 'Lección completada' : completadas > 0 ? 'Disponible para practicar' : 'Se habilita al completar la primera misión', completadas > 1),
          _objetivo(Icons.local_fire_department_rounded, 'Racha actual', PerfilUsuario.rachaVigente == 0 ? 'Empezá tu racha hoy' : PerfilUsuario.rachaVigente.toString() + ' días seguidos', false),
        ],
      ),
    );
  }

  Widget _objetivo(IconData icono, String titulo, String detalle, bool completo) => Card(
    color: _panel,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: ListTile(
      leading: Icon(icono, color: completo ? _turquesa : const Color(0xFF71CBEA)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(detalle, style: const TextStyle(color: _suave)),
    ),
  );
}
