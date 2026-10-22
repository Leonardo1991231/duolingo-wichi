import 'package:flutter/material.dart'; // <--- ¡Esta línea faltaba!
import 'package:audioplayers/audioplayers.dart';

class PantallaEjercicio extends StatefulWidget {
  const PantallaEjercicio({super.key});

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
            const SnackBar(
              content: Text("Error al reproducir el sonido"),
            ), // <--- Corregido el const
          );
        }
      }
    }
  }

  void _checkAnswer(String selectedAnswer) {
    bool isCorrect =
        selectedAnswer == wichiQuestions[_currentIndex].correctAnswer;

    if (isCorrect) _score++;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "¡Excelente! 🎉" : "Incorrecto 😢"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );

    setState(() {
      if (_currentIndex < wichiQuestions.length - 1) {
        _currentIndex++;
      } else {
        _showFinalDialog();
      }
    });
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Lección Terminada! 👏"),
        content: Text(
          "Completaste el módulo de Wichí.\nPuntaje: $_score / ${wichiQuestions.length}",
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
    if (wichiQuestions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Cargando preguntas...")));
    }

    final currentQuestion = wichiQuestions[_currentIndex];
    double progress = (_currentIndex + 1) / wichiQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Módulo 1: Cuestionario"),
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

class Question {
  final String instruction;
  final String questionText;
  final String audioUrl;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.instruction,
    required this.questionText,
    this.audioUrl = '',
    required this.options,
    required this.correctAnswer,
  });
}

List<Question> wichiQuestions = [
  Question(
    instruction: "Selecciona la traducción correcta para:",
    questionText: "Wityan",
    audioUrl: "https://soundhelix.com",
    options: ["Hola / Buenos días", "Adiós", "Perro", "Agua"],
    correctAnswer: "Hola / Buenos días",
  ),
  Question(
    instruction: "¿El significado de esta palabra es correcto?",
    questionText: "Nhiyuwílh = Arcoíris",
    options: ["Verdadero", "Falso"],
    correctAnswer: "Verdadero",
  ),
  Question(
    instruction: "Escucha el audio y selecciona el animal correcto:",
    questionText: "🔊 Escuchar",
    audioUrl: "https://soundhelix.com",
    options: ["Zorro", "Burro", "Gato", "Yaguareté"],
    correctAnswer: "Burro",
  ),
];
