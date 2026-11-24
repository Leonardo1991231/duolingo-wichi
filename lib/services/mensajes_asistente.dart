import '../models/estado_asistente.dart';

class MensajesAsistente {
  const MensajesAsistente._();

  static ReaccionZorro paraEvento({
    required int id,
    required EventoZorro evento,
    String modulo = '',
    String respuestaCorrecta = '',
    String detalle = '',
  }) {
    return switch (evento) {
      EventoZorro.appOpened => ReaccionZorro(
          id: id,
          estado: EstadoZorro.greeting,
          mensaje: '¡Hola! ¿Qué palabra en wichí vamos a aprender hoy?',
        ),
      EventoZorro.preparationStarted => ReaccionZorro(
          id: id,
          estado: EstadoZorro.greeting,
          mensaje: '¡Hola! Te acompaño a preparar un camino para aprender wichí.',
        ),
      EventoZorro.motivationSelected => ReaccionZorro(
          id: id,
          estado: EstadoZorro.happy,
          mensaje: detalle.isEmpty
              ? 'Qué bueno que tengas ganas de aprender. Vamos paso a paso.'
              : 'Ese es un gran motivo: $detalle. Vamos paso a paso.',
        ),
      EventoZorro.goalStepOpened => ReaccionZorro(
          id: id,
          estado: EstadoZorro.talking,
          mensaje: 'Ahora elegí una meta semanal que puedas sostener a tu ritmo.',
        ),
      EventoZorro.weeklyGoalSelected => ReaccionZorro(
          id: id,
          estado: EstadoZorro.happy,
          mensaje: detalle.isEmpty
              ? 'Perfecto. Una meta a tu ritmo vale mucho.'
              : 'Perfecto: $detalle. Una meta a tu ritmo vale mucho.',
        ),
      EventoZorro.preparationCompleted => ReaccionZorro(
          id: id,
          estado: EstadoZorro.celebrating,
          mensaje: '¡Listo! Ya elegiste tu objetivo. ¡Empecemos a aprender wichí!',
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
