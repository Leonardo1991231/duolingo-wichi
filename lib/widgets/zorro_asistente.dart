import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/estado_asistente.dart';
import '../quiz_data.dart';
import '../services/mensajes_asistente.dart';

final GlobalKey<NavigatorState> zorroNavigatorKey = GlobalKey<NavigatorState>();

/// Contexto y eventos locales del zorro. No envía datos fuera de la app.
class ContextoLocalZorro {
  static int seccionActual = 0;
  static void Function(int)? cambiarSeccion;
  static bool hayLeccion = false;
  static String nombreModulo = '';
  static String consigna = '';
  static String pregunta = '';
  static String respuestaCorrecta = '';
  static String respuestaElegida = '';
  static bool respuestaComprobada = false;
  static bool respuestaFueCorrecta = false;
  static final ValueNotifier<ReaccionZorro?> reacciones =
      ValueNotifier<ReaccionZorro?>(null);
  static int _secuencia = 0;

  static void emitirEvento(
    EventoZorro evento, {
    String modulo = '',
    String respuestaEsperada = '',
    String detalle = '',
  }) {
    reacciones.value = MensajesAsistente.paraEvento(
      id: ++_secuencia,
      evento: evento,
      modulo: modulo,
      respuestaCorrecta: respuestaEsperada,
      detalle: detalle,
    );
  }

  static void entrarInicio() {
    hayLeccion = false;
    nombreModulo = '';
    consigna = '';
    pregunta = '';
    respuestaCorrecta = '';
    respuestaElegida = '';
    respuestaComprobada = false;
    respuestaFueCorrecta = false;
  }

  static void actualizarLeccion({
    required String modulo,
    required String instruccion,
    required String textoPregunta,
    required String respuestaEsperada,
    required String respuestaActual,
    required bool comprobada,
    required bool correcta,
  }) {
    hayLeccion = true;
    nombreModulo = modulo;
    consigna = instruccion;
    pregunta = textoPregunta;
    respuestaCorrecta = comprobada ? respuestaEsperada : '';
    respuestaElegida = respuestaActual;
    respuestaComprobada = comprobada;
    respuestaFueCorrecta = correcta;
  }
}

class ZorroAsistente extends StatefulWidget {
  const ZorroAsistente({super.key});

  @override
  State<ZorroAsistente> createState() => _ZorroAsistenteState();
}

class _ZorroAsistenteState extends State<ZorroAsistente>
    with TickerProviderStateMixin {
  late final AnimationController _reposo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final AnimationController _salto = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _chatAbierto = false;
  ReaccionZorro? _reaccion;
  Timer? _temporizadorGlobo;

  @override
  void initState() {
    super.initState();
    _reaccion = ContextoLocalZorro.reacciones.value;
    ContextoLocalZorro.reacciones.addListener(_actualizarReaccion);
  }

  void _actualizarReaccion() {
    final reaccion = ContextoLocalZorro.reacciones.value;
    if (!mounted || reaccion == null) return;
    _temporizadorGlobo?.cancel();
    setState(() => _reaccion = reaccion);
    if (reaccion.estado == EstadoZorro.happy ||
        reaccion.estado == EstadoZorro.celebrating) {
      _salto.forward(from: 0);
    }
    _temporizadorGlobo = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _reaccion = null);
    });
  }

  @override
  void dispose() {
    ContextoLocalZorro.reacciones.removeListener(_actualizarReaccion);
    _temporizadorGlobo?.cancel();
    _reposo.dispose();
    _salto.dispose();
    super.dispose();
  }

  Future<void> _abrirChat() async {
    if (_chatAbierto) return;
    final navegador = zorroNavigatorKey.currentState;
    if (navegador == null) return;

    _temporizadorGlobo?.cancel();
    _salto.forward(from: 0);
    setState(() {
      _chatAbierto = true;
      _reaccion = null;
    });
    await navegador.push<void>(
      MaterialPageRoute<void>(builder: (_) => const _ChatZorro()),
    );
    if (mounted) setState(() => _chatAbierto = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_chatAbierto) return const SizedBox.shrink();
    return Semantics(
      button: true,
      label: 'Abrir conversación con el zorro',
      hint: 'El zorro te acompaña mientras aprendés.',
      child: GestureDetector(
        onTap: _abrirChat,
        child: AnimatedBuilder(
          animation: Listenable.merge([_reposo, _salto]),
          builder: (context, child) {
            final rebote = math.sin(_salto.value * math.pi) * 13;
            final estado = _reaccion?.estado ?? EstadoZorro.idle;
            return Transform.translate(
              offset: Offset(0, -2.5 * _reposo.value - rebote),
              child: Transform.rotate(
                angle: estado == EstadoZorro.sad ? -0.045 : 0,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      alignment: Alignment.bottomRight,
                      child: _reaccion == null
                          ? const SizedBox.shrink()
                          : Container(
                              key: ValueKey<int>(_reaccion!.id),
                              constraints: const BoxConstraints(maxWidth: 260),
                              margin: const EdgeInsets.only(bottom: 7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF173B55),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF29D6C1)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x55000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                _reaccion!.mensaje,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 3),
                    CustomPaint(
                      size: const Size(104, 116),
                      painter: _ZorroPintor(estado: estado),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MensajeLocal {
  const _MensajeLocal({required this.texto, required this.esEstudiante});

  final String texto;
  final bool esEstudiante;
}

class _ChatZorro extends StatefulWidget {
  const _ChatZorro();

  @override
  State<_ChatZorro> createState() => _ChatZorroState();
}

class _ChatZorroState extends State<_ChatZorro> {
  final _lista = ScrollController();
  final _entrada = TextEditingController();
  late final List<_MensajeLocal> _mensajes;
  late List<String> _opciones;

  @override
  void initState() {
    super.initState();
    _mensajes = [
      _MensajeLocal(texto: _saludoInicial(), esEstudiante: false),
    ];
    _opciones = _opcionesIniciales();
  }

  @override
  void dispose() {
    _lista.dispose();
    _entrada.dispose();
    super.dispose();
  }

  String _saludoInicial() {
    switch (ContextoLocalZorro.seccionActual) {
      case 1:
        if (ContextoLocalZorro.hayLeccion) {
          return 'Estás con ${ContextoLocalZorro.nombreModulo}. Puedo ayudarte a entender la consigna o darte una pista.';
        }
        return 'Estás en Aprender. Elegí una misión y te ayudo con la consigna, una pista o el resultado.';
      case 2:
        return 'Estás en Jugar. Los juegos sirven para repasar las palabras sin apuro. ¿Querés una recomendación?';
      case 3:
        return 'Estás en Comunidad. Acá podés explorar videos y la radio. También te puedo llevar a una lección.';
      case 4:
        final completadas = PerfilUsuario.leccionesCompletadas.length;
        return 'Tu avance: $completadas de 2 misiones y ${PerfilUsuario.estrellasTotales} estrellas. ¿Vemos cuál es el próximo paso?';
      default:
        return 'Estoy acá para ayudarte a estudiar, jugar o revisar tu progreso.';
    }
  }

  List<String> _opcionesIniciales() {
    switch (ContextoLocalZorro.seccionActual) {
      case 1:
        if (!ContextoLocalZorro.hayLeccion) {
          return const ['Empezar una misión', '¿Cómo voy?', 'Dame ánimo', 'Ver progreso'];
        }
        return ContextoLocalZorro.respuestaComprobada
            ? const ['Explicame mi resultado', 'Dame ánimo', '¿Qué me falta?', 'Ver progreso']
            : const ['Ayudame con esta misión', 'Dame una pista', '¿Cómo voy?', 'Ver progreso'];
      case 2:
        return const ['Recomendame un juego', '¿Cómo voy?', 'Llevame a estudiar', 'Ver progreso'];
      case 3:
        return const ['¿Qué puedo hacer acá?', 'Llevame a estudiar', 'Ver progreso', '¿Cómo voy?'];
      case 4:
        return const ['¿Qué me falta?', 'Llevame a estudiar', 'Dame ánimo', 'Volver a la app'];
      default:
        return const ['Llevame a estudiar', '¿Cómo voy?', 'Dame ánimo'];
    }
  }

  int? _destinoDeAccion(String opcion) => switch (opcion) {
    'Empezar una misión' || 'Llevame a estudiar' || 'Llevame a Aprender' => 1,
    'Llevame a Jugar' || 'Abrir el juego de memoria' => 2,
    'Ver progreso' || 'Abrir progreso' => 4,
    _ => null,
  };

  void _responder(String opcion) {
    if (opcion == 'Volver a la app') {
      Navigator.of(context).pop();
      return;
    }
    final destino = _destinoDeAccion(opcion);
    if (destino != null) {
      ContextoLocalZorro.cambiarSeccion?.call(destino);
      Navigator.of(context).pop();
      return;
    }
    _agregarIntercambio(
      opcion,
      _respuestaPara(opcion),
      opcion: opcion,
    );
  }

  void _enviarTexto() {
    final texto = _entrada.text.trim();
    if (texto.isEmpty) return;
    _entrada.clear();
    _agregarIntercambio(texto, _respuestaLibre(texto));
  }

  void _agregarIntercambio(
    String texto,
    String respuesta, {
    String? opcion,
  }) {
    setState(() {
      _mensajes.add(_MensajeLocal(texto: texto, esEstudiante: true));
      _mensajes.add(_MensajeLocal(texto: respuesta, esEstudiante: false));
      if (opcion != null) _opciones = _opcionesSiguientes(opcion);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lista.hasClients) {
        _lista.animateTo(
          _lista.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _respuestaLibre(String texto) {
    final pregunta = texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    if (pregunta.contains('hola') || pregunta.contains('buen dia')) {
      return '¡Hola! Me alegra que estés acá. ¿Seguimos con una misión o querés revisar tu avance?';
    }
    if (pregunta.contains('progreso') ||
        pregunta.contains('avance') ||
        pregunta.contains('racha') ||
        pregunta.contains('estrella') ||
        pregunta.contains('como voy')) {
      return _respuestaPara('¿Cómo voy?');
    }
    if (pregunta.contains('falta') || pregunta.contains('siguiente')) {
      return _respuestaPara('¿Qué me falta?');
    }
    if (pregunta.contains('pista') ||
        pregunta.contains('ayuda') ||
        pregunta.contains('entiendo') ||
        pregunta.contains('consigna')) {
      return _respuestaPara('Dame una pista');
    }
    if (pregunta.contains('juego') || pregunta.contains('jugar')) {
      return _respuestaPara('Recomendame un juego');
    }
    if (pregunta.contains('radio') ||
        pregunta.contains('video') ||
        pregunta.contains('comunidad')) {
      return _respuestaPara('¿Qué puedo hacer acá?');
    }
    if (pregunta.contains('gracias')) {
      return '¡De nada! Vamos paso a paso. Si querés, seguimos con otra misión.';
    }
    if (ContextoLocalZorro.seccionActual == 1 &&
        ContextoLocalZorro.hayLeccion &&
        ContextoLocalZorro.respuestaComprobada) {
      return _explicarResultado();
    }
    return 'Te puedo ayudar con una misión, darte una pista, recomendarte un juego o contarte cómo va tu progreso. ¿Qué necesitás ahora?';
  }

  String _respuestaPara(String opcion) {
    switch (opcion) {
      case 'Ayudame con esta misión':
        if (ContextoLocalZorro.seccionActual != 1 ||
            !ContextoLocalZorro.hayLeccion) {
          return 'Abrí una misión de la lista. Cuando empiece, voy a tener la consigna para darte una ayuda más precisa.';
        }
        if (ContextoLocalZorro.respuestaComprobada) {
          return _explicarResultado();
        }
        return '${ContextoLocalZorro.consigna} ${ContextoLocalZorro.pregunta}. Leé la consigna con calma y fijate qué te está pidiendo. Puedo darte una pista sin revelar la respuesta.';
      case 'Dame una pista':
        if (ContextoLocalZorro.seccionActual != 1 ||
            !ContextoLocalZorro.hayLeccion) {
          return 'En una misión, buscá las palabras clave de la consigna y comparalas con las opciones. Descartá primero las que no se relacionan.';
        }
        if (ContextoLocalZorro.respuestaComprobada) {
          return _explicarResultado();
        }
        final consigna = ContextoLocalZorro.consigna.trim();
        final pregunta = ContextoLocalZorro.pregunta.trim();
        return 'Pista para «$pregunta»: $consigna Pensá qué tipo de respuesta busca y descartá las opciones que no encajan. ¡Vamos paso a paso!';
      case '¿Qué me falta?':
        final completadas = PerfilUsuario.leccionesCompletadas.length;
        if (completadas >= 2) {
          return 'Ya completaste las dos misiones disponibles. ¡Buen trabajo! Podés repasarlas desde Aprender o practicar en Jugar.';
        }
        final siguiente = PerfilUsuario.leccionCompletada('Módulo 1: Saludos')
            ? 'Animales del monte'
            : 'Saludos básicos';
        return 'Completaste $completadas de 2 misiones. El próximo paso es «$siguiente». Si querés, te llevo a Aprender.';
      case 'Recomendame un juego':
        return 'Te recomiendo el juego de memoria para relacionar palabras con sus significados. Si preferís practicar preguntas, también está el desafío de saludos.';
      case '¿Qué puedo hacer acá?':
        return 'En Comunidad podés ver los videos compartidos y escuchar Radio Nacional Tartagal. Para practicar palabras, te llevo a Aprender.';
      case 'Explicame mi resultado':
        if (ContextoLocalZorro.seccionActual != 1 ||
            !ContextoLocalZorro.hayLeccion ||
            !ContextoLocalZorro.respuestaComprobada) {
          return 'Cuando elijas una respuesta y toques COMPROBAR, puedo ayudarte a repasar el resultado.';
        }
        return _explicarResultado();
      case '¿Cómo voy?':
        final lecciones = PerfilUsuario.leccionesCompletadas.length;
        final racha = PerfilUsuario.rachaVigente;
        return 'Tenés ${PerfilUsuario.estrellasTotales} estrellas y completaste $lecciones misiones. ${racha == 0 ? '¡Hoy podés empezar una racha!' : 'Llevás $racha ${racha == 1 ? 'día' : 'días'} de racha.'}';
      case 'Dame ánimo':
        return ContextoLocalZorro.seccionActual == 1 &&
                ContextoLocalZorro.hayLeccion &&
                ContextoLocalZorro.respuestaComprobada &&
                !ContextoLocalZorro.respuestaFueCorrecta
            ? 'Equivocarse también ayuda a aprender. Ya conocés la respuesta correcta; probemos la siguiente con calma.'
            : '¡Vas muy bien! Cada intento cuenta. Seguí a tu ritmo; yo te acompaño.';
      default:
        return 'Estoy acá para ayudarte con la misión, darte una pista o contarte cómo va tu progreso.';
    }
  }

  String _explicarResultado() {
    if (ContextoLocalZorro.respuestaFueCorrecta) {
      return '¡Muy bien! Elegiste "${ContextoLocalZorro.respuestaElegida}" y acertaste. ¡Una palabra más que ya conocés!';
    }
    return 'La respuesta correcta era "${ContextoLocalZorro.respuestaCorrecta}". Elegiste "${ContextoLocalZorro.respuestaElegida}". No pasa nada: ahora ya conocés la diferencia y podés seguir.';
  }

  List<String> _opcionesSiguientes(String opcion) {
    if (opcion == 'Recomendame un juego') {
      return const ['Abrir el juego de memoria', 'Llevame a Aprender', 'Volver a la app'];
    }
    if (opcion == '¿Qué me falta?') {
      return const ['Llevame a estudiar', 'Dame ánimo', '¿Cómo voy?', 'Volver a la app'];
    }
    if (opcion == '¿Qué puedo hacer acá?') {
      return const ['Llevame a Aprender', '¿Cómo voy?', 'Volver a la app'];
    }
    if (opcion == 'Ayudame con esta misión') {
      return const ['Dame una pista', 'Explicame mi resultado', '¿Cómo voy?', 'Volver a la app'];
    }
    if (opcion == 'Dame una pista') {
      return const ['Ayudame con esta misión', 'Explicame mi resultado', 'Dame ánimo', 'Volver a la app'];
    }
    if (opcion == '¿Cómo voy?') {
      return const ['¿Qué me falta?', 'Llevame a estudiar', 'Dame ánimo', 'Volver a la app'];
    }
    return const ['Dame una pista', '¿Cómo voy?', 'Dame ánimo', 'Volver a la app'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B30),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 48,
                    height: 54,
                    child: CustomPaint(painter: _ZorroPintor()),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wichi, tu compañero',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Aprendemos juntos',
                          style: TextStyle(color: Color(0xFFB8CAD8)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Volver a la app',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: ListView.builder(
                controller: _lista,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _mensajes.length + 1,
                itemBuilder: (context, index) {
                  if (index == _mensajes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Elegí cómo querés seguir',
                              style: TextStyle(color: Color(0xFFB8CAD8)),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _opciones
                                .map(
                                  (opcion) => ActionChip(
                                    label: Text(opcion),
                                    backgroundColor: const Color(0xFF126D69),
                                    labelStyle: const TextStyle(color: Colors.white),
                                    onPressed: () => _responder(opcion),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  }
                  final mensaje = _mensajes[index];
                  return mensaje.esEstudiante
                      ? _burbujaEstudiante(mensaje.texto)
                      : _burbujaZorro(mensaje.texto);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _entrada,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarTexto(),
                      decoration: InputDecoration(
                        hintText: 'Escribile al zorro...',
                        filled: true,
                        fillColor: const Color(0xFF112B45),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar mensaje',
                    onPressed: _enviarTexto,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _burbujaZorro(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 12, right: 34),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          width: 32,
          height: 36,
          child: CustomPaint(painter: _ZorroPintor()),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF173B55),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Text(texto, style: const TextStyle(color: Colors.white, height: 1.35)),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _burbujaEstudiante(String texto) => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 46),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF126D69),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Text(texto, style: const TextStyle(color: Colors.white, height: 1.35)),
        ),
      ),
    ),
  );
}

class _ZorroPintor extends CustomPainter {
  const _ZorroPintor({this.estado = EstadoZorro.idle});

  final EstadoZorro estado;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 104;
    final sy = size.height / 116;
    canvas.save();
    canvas.scale(sx, sy);

    final naranja = Paint()..color = const Color(0xFFE87938);
    final claro = Paint()..color = const Color(0xFFFFA34F);
    final oscuro = Paint()..color = const Color(0xFF833D31);
    final crema = Paint()..color = const Color(0xFFFFEBD0);
    final blanco = Paint()..color = Colors.white;
    final ojos = Paint()..color = const Color(0xFF253747);
    final sombra = Paint()..color = const Color(0x29000000);

    canvas.drawOval(const Rect.fromLTWH(18, 101, 69, 10), sombra);
    final cola = Path()
      ..moveTo(38, 83)
      ..cubicTo(10, 78, 10, 109, 30, 107)
      ..cubicTo(45, 106, 49, 91, 44, 87)
      ..close();
    canvas.drawPath(cola, oscuro);
    canvas.drawPath(cola, claro);
    canvas.drawCircle(const Offset(21, 103), 5, crema);

    canvas.drawOval(const Rect.fromLTWH(29, 66, 49, 40), naranja);
    canvas.drawOval(const Rect.fromLTWH(43, 74, 23, 31), crema);
    canvas.drawOval(const Rect.fromLTWH(31, 96, 18, 10), oscuro);
    canvas.drawOval(const Rect.fromLTWH(60, 96, 18, 10), oscuro);

    final orejas = Path()
      ..moveTo(20, 43)
      ..lineTo(24, 9)
      ..lineTo(44, 28)
      ..lineTo(58, 28)
      ..lineTo(79, 9)
      ..lineTo(84, 44)
      ..close();
    canvas.drawPath(orejas, naranja);
    final interior = Path()
      ..moveTo(27, 32)
      ..lineTo(28, 17)
      ..lineTo(39, 30)
      ..close()
      ..moveTo(65, 30)
      ..lineTo(77, 17)
      ..lineTo(78, 32)
      ..close();
    canvas.drawPath(interior, oscuro);
    canvas.drawOval(const Rect.fromLTWH(17, 25, 70, 58), naranja);
    canvas.drawOval(const Rect.fromLTWH(21, 56, 23, 13), claro);
    canvas.drawOval(const Rect.fromLTWH(61, 56, 23, 13), claro);
    canvas.drawOval(const Rect.fromLTWH(31, 40, 16, 21), blanco);
    canvas.drawOval(const Rect.fromLTWH(57, 40, 16, 21), blanco);
    final pupilaY = estado == EstadoZorro.thinking
        ? -2.0
        : estado == EstadoZorro.sad
            ? 2.0
            : 0.0;
    canvas.drawOval(Rect.fromLTWH(35, 44 + pupilaY, 9, 15), ojos);
    canvas.drawOval(Rect.fromLTWH(60, 44 + pupilaY, 9, 15), ojos);
    canvas.drawCircle(const Offset(38, 47), 2.8, blanco);
    canvas.drawCircle(const Offset(63, 47), 2.8, blanco);
    canvas.drawOval(const Rect.fromLTWH(38, 60, 29, 20), crema);
    canvas.drawCircle(const Offset(52.5, 62), 3, oscuro);
    final pincelBoca = Paint()
      ..color = oscuro.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    if (estado == EstadoZorro.talking) {
      canvas.drawOval(const Rect.fromLTWH(48, 64, 9, 10), oscuro);
    } else {
      final preocupado = estado == EstadoZorro.sad;
      canvas.drawArc(
        Rect.fromLTWH(45, preocupado ? 67 : 63, 15, 7),
        preocupado ? math.pi + 0.15 : 0.15,
        preocupado ? -(math.pi - 0.3) : math.pi - 0.3,
        false,
        pincelBoca,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ZorroPintor oldDelegate) =>
      oldDelegate.estado != estado;
}
