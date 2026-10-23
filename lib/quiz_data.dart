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

// Módulo 1: Saludos Básicos
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
];

// Módulo 2: Animales del Monte (NUEVO)
List<Question> animalesQuestions = [
  Question(
    instruction: "Selecciona el significado correcto para el animal:",
    questionText: "Asno",
    audioUrl: "https://soundhelix.com",
    options: ["Zorro", "Burro", "Gato", "Yaguareté"],
    correctAnswer: "Burro",
  ),
];

// Estructura para el juego infantil de tarjetas
class TarjetaJuego {
  final String palabra;
  bool estaVolteada;
  bool estaEmparejada;

  TarjetaJuego({
    required this.palabra,
    this.estaVolteada = false,
    this.estaEmparejada = false,
  });
}

// Estado del perfil global de Leo
class PerfilUsuario {
  static String nombre = "Leo Dragones";
  static int estrellasTotales = 120;
  static int medallasGanadas = 1;
}
