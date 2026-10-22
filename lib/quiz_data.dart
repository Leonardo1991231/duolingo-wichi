class Question {
  final String instruction; // Ejemplo: "Selecciona la traducción"
  final String questionText; // Palabra en Wichí
  final String audioPath; // Nombre del archivo mp3
  final List<String> options; // Las opciones del botón
  final String correctAnswer; // Cuál es la correcta

  Question({
    required this.instruction,
    required this.questionText,
    this.audioPath = '',
    required this.options,
    required this.correctAnswer,
  });
}

// Esta es la lista que tu main.dart está buscando obligatoriamente
List<Question> wichiQuestions = [
  Question(
    instruction: "Selecciona la traducción correcta para:",
    questionText: "Wityan",
    audioPath: "audio/wityan.mp3",
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
    audioPath: "audio/asno.mp3",
    options: ["Zorro", "Burro", "Gato", "Yaguareté"],
    correctAnswer: "Burro",
  ),
];
