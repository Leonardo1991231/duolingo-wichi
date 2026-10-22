import 'package:flutter/material';
import 'package:audioplayers/audioplayers.dart';
import 'quiz_data.dart';

void main() => runApp(const WichiApp());

class WichiApp extends StatelessWidget {
  const WichiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSound(String path) async {
    if (path.isNotEmpty) {
      await _audioPlayer.play(AssetSource(path));
    }
  }

  void _checkAnswer(String selectedAnswer) {
    bool isCorrect = selectedAnswer == wichiQuestions[_currentIndex].correctAnswer;
    
    if (isCorrect) _score++;

    // Mostrar feedback visual rápido (Estilo Duolingo)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "¡Excelente! 🎉" : "Incorrecto 😢"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );

    // Pasar a la siguiente pregunta
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
        content: Text("Completaste el módulo de Wichí.\nPuntaje: $_score / ${wichiQuestions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _score = 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Reiniciar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = wichiQuestions[_currentIndex];
    double progress = (_currentIndex + 1) / wichiQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aprende Wichí (Dragones)"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de progreso superior
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 10,
            ),
            const SizedBox(height: 30),
            
            // Instrucción
            Text(
              currentQuestion.instruction,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              textAlign: Alignment.center,
            ),
            const SizedBox(height: 10),

            // Palabra o botón de audio central
            GestureDetector(
              onTap: () => _playSound(currentQuestion.audioPath),
              child: Card(
                elevation: 4,
                color: Colors.teal[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Text(
                    currentQuestion.questionText,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                    textAlign: Alignment.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Opciones de respuesta dinámicas
            Expanded(
              child: ListView(
                children: currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    onEdges: const EdgeInsets.only(), // Ajuste estético
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal[900],
                        side: const BorderSide(color: Colors.teal, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
