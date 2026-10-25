import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../quiz_data.dart';
import '../widgets/ilustracion_educativa.dart';

class PantallaEjercicio extends StatefulWidget {
  final List<Question> preguntas;
  final String nombreModulo;

  const PantallaEjercicio({
    super.key,
    required this.preguntas,
    required this.nombreModulo,
  });

  @override
  State<PantallaEjercicio> createState() => _PantallaEjercicioState();
}

class _PantallaEjercicioState extends State<PantallaEjercicio> {
  static const Color _azul = Color(0xFF0B2C49);
  static const Color _panel = Color(0xFF102B45);
  static const Color _turquesa = Color(0xFF29D6C1);

  int _currentIndex = 0;
  int _score = 0;
  int _combo = 0;
  bool _respuestaComprobada = false;
  bool _respuestaCorrecta = false;
  bool _guardandoResultado = false;
  String? _opcionSeleccionada;
  final List<String> _palabrasSeleccionadas = <String>[];
  final AudioPlayer _audioPlayer = AudioPlayer();

  Question get _pregunta => widget.preguntas[_currentIndex];

  bool get _hayRespuesta {
    if (_pregunta.type == QuestionType.wordBank) {
      return _palabrasSeleccionadas.isNotEmpty;
    }
    return _opcionSeleccionada != null;
  }

  String _normalizar(String texto) => texto
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9áéíóúüñ]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  Future<void> _reproducirAudio(String url) async {
    if (url.isEmpty) return;
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo reproducir el audio.')),
        );
      }
    }
  }

  void _comprobarRespuesta() {
    if (!_hayRespuesta || _respuestaComprobada) return;

    final respuesta = _pregunta.type == QuestionType.wordBank
        ? _palabrasSeleccionadas.join(' ')
        : _opcionSeleccionada!;
    final correcta =
        _normalizar(respuesta) == _normalizar(_pregunta.correctAnswer);

    setState(() {
      _respuestaComprobada = true;
      _respuestaCorrecta = correcta;
      if (correcta) {
        _score++;
        _combo++;
      } else {
        _combo = 0;
      }
    });
  }

  Future<void> _continuar() async {
    if (!_respuestaComprobada || _guardandoResultado) return;

    if (_currentIndex < widget.preguntas.length - 1) {
      setState(() {
        _currentIndex++;
        _opcionSeleccionada = null;
        _palabrasSeleccionadas.clear();
        _respuestaComprobada = false;
        _respuestaCorrecta = false;
      });
      return;
    }

    _guardandoResultado = true;
    await _mostrarResultadoFinal();
  }

  Future<void> _mostrarResultadoFinal() async {
    final recompensa = _score * 10;
    await PerfilUsuario.registrarResultado(
      nombreModulo: widget.nombreModulo,
      estrellasGanadas: recompensa,
      respuestasCorrectas: _score,
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Lección terminada! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Respuestas correctas: $_score de ${widget.preguntas.length}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD166),
                ),
                const SizedBox(width: 6),
                Text('+$recompensa estrellas'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFF9B54),
                ),
                const SizedBox(width: 6),
                Text('${PerfilUsuario.rachaVigente} días de racha'),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Seguir aprendiendo'),
          ),
        ],
      ),
    );
  }

  Widget _construirOpcion(String opcion) {
    final seleccionada = _opcionSeleccionada == opcion;
    final correcta = _respuestaComprobada &&
        opcion == _pregunta.correctAnswer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _respuestaComprobada
              ? null
              : () => setState(() => _opcionSeleccionada = opcion),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            foregroundColor: correcta
                ? const Color(0xFF87E3A4)
                : Colors.white,
            backgroundColor: correcta
                ? const Color(0xFF174B3B)
                : seleccionada
                    ? const Color(0xFF123D57)
                    : _panel,
            side: BorderSide(
              color: correcta
                  ? const Color(0xFF6AD98B)
                  : seleccionada
                      ? _turquesa
                      : Colors.white24,
              width: seleccionada || correcta ? 2 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            opcion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  String _emojiPara(String opcion) {
    switch (opcion.toLowerCase()) {
      case 'burro':
        return '🫏';
      case 'zorro':
        return '🦊';
      case 'gato':
        return '🐈';
      case 'yaguareté':
        return '🐆';
      default:
        return '🌿';
    }
  }

  Widget _construirImagenes() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pregunta.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final opcion = _pregunta.options[index];
        final seleccionada = _opcionSeleccionada == opcion;
        return Material(
          color: seleccionada ? const Color(0xFF123D57) : _panel,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _respuestaComprobada
                ? null
                : () => setState(() => _opcionSeleccionada = opcion),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: seleccionada ? _turquesa : Colors.white24,
                  width: seleccionada ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_emojiPara(opcion), style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    opcion,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construirBancoPalabras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: _palabrasSeleccionadas.isEmpty
              ? const Center(
                  child: Text(
                    'Tocá las palabras para formar la respuesta',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _palabrasSeleccionadas.length; i++)
                      ActionChip(
                        label: Text(_palabrasSeleccionadas[i]),
                        onPressed: _respuestaComprobada
                            ? null
                            : () => setState(
                                  () => _palabrasSeleccionadas.removeAt(i),
                                ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final palabra in _pregunta.wordBank)
              if (_palabrasSeleccionadas
                      .where((seleccionada) => seleccionada == palabra)
                      .length <
                  _pregunta.wordBank.where((opcion) => opcion == palabra).length)
                ActionChip(
                  label: Text(palabra),
                  backgroundColor: const Color(0xFF1B4057),
                  side: const BorderSide(color: Colors.white30),
                  onPressed: _respuestaComprobada
                      ? null
                      : () => setState(() => _palabrasSeleccionadas.add(palabra)),
                ),
          ],
        ),
      ],
    );
  }

  Widget _construirRespuestas() {
    switch (_pregunta.type) {
      case QuestionType.wordBank:
        return _construirBancoPalabras();
      case QuestionType.pictureChoice:
        return _construirImagenes();
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return Column(
          children: _pregunta.options.map(_construirOpcion).toList(),
        );
    }
  }

  Widget _construirPie() {
    if (!_respuestaComprobada) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _hayRespuesta ? _comprobarRespuesta : null,
              style: FilledButton.styleFrom(
                backgroundColor: _turquesa,
                foregroundColor: _azul,
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'COMPROBAR',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final color = _respuestaCorrecta
        ? const Color(0xFF7BE09B)
        : const Color(0xFFFF9B86);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        color: _respuestaCorrecta
            ? const Color(0xFF173D32)
            : const Color(0xFF492C32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _respuestaCorrecta ? '¡Muy bien!' : 'Repasemos esta respuesta',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_respuestaCorrecta) ...[
              const SizedBox(height: 4),
              Text(
                'La respuesta correcta es: ${_pregunta.correctAnswer}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _continuar,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: _azul,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'CONTINUAR',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay preguntas en este módulo.')),
      );
    }

    final question = _pregunta;
    final progress = (_currentIndex + 1) / widget.preguntas.length;
    final ilustracion = widget.nombreModulo.toLowerCase().contains('animal')
        ? TipoIlustracion.animales
        : TipoIlustracion.saludos;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreModulo),
        backgroundColor: _azul,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: _turquesa,
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_currentIndex + 1}/${widget.preguntas.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_combo > 1) ...[
                  const SizedBox(width: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFF9B54),
                        size: 18,
                      ),
                      Text(
                        'x$_combo',
                        style: const TextStyle(color: Color(0xFFFFB36B)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    question.instruction,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: question.audioUrl.isEmpty
                        ? null
                        : () => _reproducirAudio(question.audioUrl),
                    child: Card(
                      elevation: 2,
                      color: const Color(0xFF0D675F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: _turquesa.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            IlustracionEducativa(
                              tipo: ilustracion,
                              width: 64,
                              height: 56,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.questionText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (question.audioUrl.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _construirRespuestas(),
                ],
              ),
            ),
          ),
          _construirPie(),
        ],
      ),
    );
  }
}
