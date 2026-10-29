import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../quiz_data.dart';
import '../widgets/ilustracion_educativa.dart';
import '../widgets/zorro_asistente.dart';
import 'pantalla_diccionario.dart';
import 'pantalla_ejercicio.dart';
import 'pantalla_juego_infantil.dart';
import 'pantalla_perfil.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  static const Color _fondo = Color(0xFF071B30);
  static const Color _panel = Color(0xFF102B45);
  static const Color _turquesa = Color(0xFF29D6C1);
  static const Color _textoSuave = Color(0xFFB8CAD8);

  Future<void> _abrirLeccion({
    required List<Question> preguntas,
    required String nombreModulo,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            PantallaEjercicio(preguntas: preguntas, nombreModulo: nombreModulo),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _abrirJuego() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PantallaJuegoInfantil(),
      ),
    );
    if (mounted) setState(() {});
  }

  void _avisarBloqueo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completá la misión anterior para seguir por el camino.'),
      ),
    );
  }

  Future<void> _abrirDiccionario({bool sincronizarAhora = false}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaDiccionario(sincronizarAlAbrir: sincronizarAhora),
      ),
    );
  }

  Future<void> _abrirPerfil() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const PantallaPerfil()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _actualizarAplicacion() async {
    final url = Uri.parse(
      'https://github.com/Leonardo1991231/duolingo-wichi/releases/download/android-latest/app-release.apk',
    );
    try {
      final abierto = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la descarga de la actualización.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la descarga de la actualización.'),
          ),
        );
      }
    }
  }

  Widget _crearMenu() {
    return Drawer(
      backgroundColor: _fondo,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 185,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/caratula.png',
                    fit: BoxFit.contain,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, _fondo.withOpacity(0.96)],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wichí Fácil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Aprendé, compartí y avanzá',
                          style: TextStyle(color: _textoSuave),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _opcionMenu(
              icono: Icons.map_rounded,
              titulo: 'Mapa de misiones',
              subtitulo: 'Seguí aprendiendo paso a paso',
              accion: () => Navigator.pop(context),
            ),
            _opcionMenu(
              icono: Icons.menu_book_rounded,
              titulo: 'Diccionario comunitario',
              subtitulo: 'Consultá y agregá palabras, fotos o audios',
              accion: () {
                Navigator.pop(context);
                _abrirDiccionario();
              },
            ),
            _opcionMenu(
              icono: Icons.sync_rounded,
              titulo: 'Sincronizar diccionario',
              subtitulo: 'Traé las palabras más recientes',
              accion: () {
                Navigator.pop(context);
                _abrirDiccionario(sincronizarAhora: true);
              },
            ),
            _opcionMenu(
              icono: Icons.extension_rounded,
              titulo: 'Rincón infantil',
              subtitulo: 'Jugá a encontrar las parejas',
              accion: () {
                Navigator.pop(context);
                _abrirJuego();
              },
            ),
            _opcionMenu(
              icono: Icons.system_update_alt_rounded,
              titulo: 'Actualizar aplicación',
              subtitulo: 'Descargá la última versión',
              accion: _actualizarAplicacion,
            ),
            _opcionMenu(
              icono: Icons.account_circle_rounded,
              titulo: 'Mi perfil y progreso',
              subtitulo: 'Estrellas, resultados y logros',
              accion: () {
                Navigator.pop(context);
                _abrirPerfil();
              },
            ),
            const Spacer(),
            const Divider(color: Colors.white12, indent: 18, endIndent: 18),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Text(
                'Gratis para aprender y compartir',
                style: TextStyle(color: _textoSuave, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionMenu({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback accion,
  }) {
    return ListTile(
      leading: Icon(icono, color: _turquesa),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(color: _textoSuave, fontSize: 12),
      ),
      onTap: accion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estrellas = PerfilUsuario.estrellasTotales;
    final modulo1Completado = PerfilUsuario.leccionCompletada(
      'Módulo 1: Saludos',
    );
    final modulo2Completado = PerfilUsuario.leccionCompletada(
      'Módulo 2: Animales del Monte',
    );
    final modulo2Habilitado = modulo1Completado;
    final misionesCompletadas = [
      modulo1Completado,
      modulo2Completado,
    ].where((completa) => completa).length;
    ContextoLocalZorro.entrarInicio();
    return Scaffold(
      backgroundColor: _fondo,
      drawer: _crearMenu(),
      appBar: AppBar(
        backgroundColor: _fondo,
        foregroundColor: Colors.white,
        title: const Text(
          'Wichí Fácil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 9),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD166),
                  size: 21,
                ),
                const SizedBox(width: 5),
                Text(
                  '$estrellas',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: _abrirPerfil,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF123D57), Color(0xFF0D675F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _turquesa.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Vamos a aprender!',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seguí el camino y descubrí nuevas palabras en Wichí.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$misionesCompletadas de 2 misiones completadas',
                          style: const TextStyle(
                            color: Color(0xFF9CF4E9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tu meta: ${PerfilUsuario.metaSemanal} días por semana',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Esta semana: ${PerfilUsuario.diasActivosEstaSemana}/${PerfilUsuario.metaSemanal} días',
                          style: const TextStyle(color: Color(0xFF9CF4E9), fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (PerfilUsuario.diasActivosEstaSemana / PerfilUsuario.metaSemanal).clamp(0.0, 1.0).toDouble(),
                            minHeight: 7,
                            backgroundColor: Colors.white24,
                            color: _turquesa,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Color(0xFFFFA45B),
                              size: 19,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              PerfilUsuario.rachaVigente == 0
                                  ? 'Empezá tu racha hoy'
                                  : '${PerfilUsuario.rachaVigente} días seguidos',
                              style: const TextStyle(
                                color: Color(0xFFFFC17E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const IlustracionEducativa(tipo: TipoIlustracion.territorio, width: 88, height: 72),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Mapa de misiones',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completá una misión para avanzar por el camino.',
              style: TextStyle(color: _textoSuave),
            ),
            const SizedBox(height: 18),
            _buildMision(
              numero: 1,
              titulo: 'Saludos básicos',
              ilustracion: TipoIlustracion.saludos,
              descripcion: 'Aprendé a saludar y presentarte.',
              icono: Icons.waving_hand_rounded,
              completada: modulo1Completado,
              habilitada: true,
              mejorPuntaje: PerfilUsuario.mejorPuntaje('Módulo 1: Saludos'),
              ultima: false,
              alTocar: () => _abrirLeccion(
                preguntas: wichiQuestions,
                nombreModulo: 'Módulo 1: Saludos',
              ),
            ),
            _buildMision(
              numero: 2,
              titulo: 'Animales del monte',
              ilustracion: TipoIlustracion.animales,
              descripcion: 'Descubrí la fauna del Chaco.',
              icono: Icons.pets_rounded,
              completada: modulo2Completado,
              habilitada: modulo2Habilitado,
              mejorPuntaje: PerfilUsuario.mejorPuntaje(
                'Módulo 2: Animales del Monte',
              ),
              ultima: true,
              alTocar: () {
                if (modulo2Habilitado) {
                  _abrirLeccion(
                    preguntas: animalesQuestions,
                    nombreModulo: 'Módulo 2: Animales del Monte',
                  );
                } else {
                  _avisarBloqueo();
                }
              },
            ),
            const SizedBox(height: 18),
            Material(
              color: _panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7561C9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.extension_rounded,
                    color: Color(0xFFB9A9FF),
                  ),
                ),
                title: const Text(
                  'Rincón infantil',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Juego de memoria con palabras',
                  style: TextStyle(color: _textoSuave),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: _turquesa,
                ),
                onTap: _abrirJuego,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMision({
    required int numero,
    required String titulo,
    required String descripcion,
    required TipoIlustracion ilustracion,
    required IconData icono,
    required bool completada,
    required bool habilitada,
    required int mejorPuntaje,
    required bool ultima,
    required VoidCallback alTocar,
  }) {
    final colorAcento = completada
        ? _turquesa
        : habilitada
        ? const Color(0xFF59C9FF)
        : const Color(0xFF708397);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 54,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: habilitada ? colorAcento.withOpacity(0.16) : _panel,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorAcento, width: 2),
                  ),
                  child: Icon(
                    completada
                        ? Icons.check_rounded
                        : habilitada
                        ? icono
                        : Icons.lock_rounded,
                    color: colorAcento,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: alTocar,
                  borderRadius: BorderRadius.circular(19),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: habilitada
                            ? colorAcento.withOpacity(0.55)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Misión $numero',
                                style: TextStyle(
                                  color: colorAcento,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                titulo,
                                style: TextStyle(
                                  color: habilitada
                                      ? Colors.white
                                      : _textoSuave,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                descripcion,
                                style: const TextStyle(
                                  color: _textoSuave,
                                  fontSize: 13,
                                ),
                              ),
                              if (completada) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFD166),
                                      size: 17,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mejor resultado: $mejorPuntaje',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD166),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (!habilitada) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Completá la misión anterior para desbloquearla',
                                  style: TextStyle(
                                    color: _textoSuave,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 58, height: 58,
                          child: Stack(alignment: Alignment.center, children: [
                            Opacity(opacity: habilitada ? 1 : 0.45, child: IlustracionEducativa(tipo: ilustracion, width: 56, height: 50)),
                            Positioned(right: 0, bottom: 0, child: DecoratedBox(
                              decoration: BoxDecoration(color: _panel, shape: BoxShape.circle, border: Border.all(color: colorAcento)),
                              child: Padding(padding: const EdgeInsets.all(3), child: Icon(completada ? Icons.check_rounded : habilitada ? Icons.play_arrow_rounded : Icons.lock_outline_rounded, color: colorAcento, size: 16)),
                            )),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!ultima)
          Container(
            margin: const EdgeInsets.only(left: 25),
            width: 3,
            height: 22,
            color: _turquesa.withOpacity(0.55),
          ),
      ],
    );
  }
}
