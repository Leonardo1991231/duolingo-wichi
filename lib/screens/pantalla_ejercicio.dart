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

  void _checkAnswer(String selectedAnswer) {
    bool isCorrect =
        selectedAnswer == widget.preguntas[_currentIndex].correctAnswer;

    if (isCorrect) _score++;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "¡Excelente! 🎉" : "Incorrecto 😢"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );

    setState(() {
      if (_currentIndex < widget.preguntas.length - 1) {
        _currentIndex++;
      } else {
        _showFinalDialog();
      }
    });
  }

  void _showFinalDialog() {
    int recompensa = _score * 10;
    PerfilUsuario.estrellasTotales += recompensa;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Lección Terminada! 👏"),
        content: Text(
          "Completaste: ${widget.nombreModulo}\n"
          "Preguntas correctas: $_score / ${widget.preguntas.length}\n"
          "¡Ganaste +$recompensa Estrellas! ⭐",
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
    if (widget.preguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No hay preguntas en este módulo.")),
      );
    }

    final currentQuestion = widget.preguntas[_currentIndex];
    double progress = (_currentIndex + 1) / widget.preguntas.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreModulo),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 10,
            ),
            const SizedBox(height: 30),
            Text(
              currentQuestion.instruction,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _playSound(currentQuestion.audioUrl),
              child: Card(
                elevation: 4,
                color: Colors.teal,
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
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal, width: 2),
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
