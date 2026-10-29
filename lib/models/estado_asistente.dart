enum EstadoZorro { idle, greeting, talking, thinking, happy, sad, celebrating }

enum EventoZorro {
  appOpened,
  activityStarted,
  correctAnswer,
  incorrectAnswer,
  lessonCompleted,
}

class ReaccionZorro {
  const ReaccionZorro({
    required this.id,
    required this.estado,
    required this.mensaje,
  });

  final int id;
  final EstadoZorro estado;
  final String mensaje;
}
