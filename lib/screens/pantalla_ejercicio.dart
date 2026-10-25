import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../quiz_data.dart';

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
  int _currentIndex = 0;
  int _score = 0;
  bool _guardandoResultado = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSound(String url) async {
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al reproducir el sonido")),
          );
        }
      }
    }
  }

  Future<void> _checkAnswer(String selectedAnswer) async {
    if (_guardandoResultado) return;

    final isCorrect =
        selectedAnswer == widget.preguntas[_currentIndex].correctAnswer;

    if (isCorrect) _score++;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "¡Excelente! 🎉" : "Incorrecto 😢"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );

    if (_currentIndex < widget.preguntas.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _guardandoResultado = true;
      await _showFinalDialog();
    }
  }

  Future<void> _showFinalDialog() async {
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
        title: const Text("¡Lección Terminada! 👏"),
        content: Text(
          'Completaste: ' +
              widget.nombreModulo +
              '\n' +
              'Preguntas correctas: ' +
              _score.toString() +
              ' / ' +
              widget.preguntas.length.toString() +
              '\n' +
              '¡Ganaste +' +
              recompensa.toString() +
              ' Estrellas! ⭐',
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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No hay preguntas en este módulo.")),
      );
    }

    final currentQuestion = widget.preguntas[_currentIndex];
    final progress = (_currentIndex + 1) / widget.preguntas.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreModulo),
        backgroundColor: const Color(0xFF0C2A43),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              color: const Color(0xFF29D6C1),
              minHeight: 10,
            ),
            const SizedBox(height: 30),
            Text(
              currentQuestion.instruction,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _playSound(currentQuestion.audioUrl),
              child: Card(
                elevation: 4,
                color: const Color(0xFF0D766F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: Text(
                    currentQuestion.questionText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: const Color(0xFF102B45),
                        foregroundColor: const Color(0xFF48E0CE),
                        side: const BorderSide(
                          color: Color(0xFF29D6C1),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _checkAnswer(option),
                      child: Text(option, style: const TextStyle(fontSize: 18)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
