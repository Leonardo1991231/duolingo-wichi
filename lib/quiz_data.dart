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

// BBDD de preguntas (Variante Dragones)
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
    instruction: "Escucha el audio de prueba y selecciona el animal correcto:",
    questionText: "🔊 Escuchar",
    audioUrl: "https://soundhelix.com",
    options: ["Zorro", "Burro", "Gato", "Yaguareté"],
    correctAnswer: "Burro",
  ),
];

// Clase Global corregida para almacenar el progreso del usuario Leo
class PerfilUsuario {
  static String nombre = "Leo Dragones";
  static int estrellasTotales =
      120; // Almacena tus estrellas como un número entero real
  static int medallasGanadas = 1;
}
