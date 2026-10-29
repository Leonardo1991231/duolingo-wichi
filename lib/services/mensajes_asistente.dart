import '../models/estado_asistente.dart';

class MensajesAsistente {
  const MensajesAsistente._();

  static ReaccionZorro paraEvento({
    required int id,
    required EventoZorro evento,
    String modulo = '',
    String respuestaCorrecta = '',
  }) {
    return switch (evento) {
      EventoZorro.appOpened => ReaccionZorro(
          id: id,
          estado: EstadoZorro.greeting,
          mensaje: '¡Hola! ¿Qué palabra en wichí vamos a aprender hoy?',
        ),
      EventoZorro.activityStarted => ReaccionZorro(
          id: id,
          estado: EstadoZorro.talking,
          mensaje: modulo.isEmpty
              ? '¡Vamos! Leé la consigna con calma y elegí tu respuesta.'
              : '¡Vamos con $modulo! Leé la consigna con calma y elegí tu respuesta.',
        ),
      EventoZorro.correctAnswer => ReaccionZorro(
          id: id,
          estado: EstadoZorro.happy,
          mensaje: '¡Muy bien! Acertaste. ¡Una palabra nueva en tu camino!',
        ),
      EventoZorro.incorrectAnswer => ReaccionZorro(
          id: id,
          estado: EstadoZorro.sad,
          mensaje: respuestaCorrecta.isEmpty
              ? 'Casi. No pasa nada: cada intento te ayuda a aprender. ¡Sigamos!'
              : 'Casi. La respuesta era «$respuestaCorrecta». Vamos a practicarla de nuevo.',
        ),
      EventoZorro.lessonCompleted => ReaccionZorro(
          id: id,
          estado: EstadoZorro.celebrating,
          mensaje: modulo.isEmpty
              ? '¡Misión cumplida! Cada paso cuenta. ¡Celebremos tu avance!'
              : '¡Misión cumplida! Completaste $modulo. ¡Celebremos tu avance!',
        ),
    };
  }
}
