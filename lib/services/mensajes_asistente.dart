import '../models/estado_asistente.dart';
import '../quiz_data.dart';

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
      EventoZorro.sectionOpened => ReaccionZorro(
          id: id,
          estado: EstadoZorro.talking,
          mensaje: _mensajeDeSeccion(detalle),
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

  static String _mensajeDeSeccion(String seccion) {
    final saludos = PerfilUsuario.leccionCompletada('Módulo 1: Saludos');
    final animales = PerfilUsuario.leccionCompletada('Módulo 2: Animales del Monte');
    final completadas = [saludos, animales].where((completa) => completa).length;

    return switch (seccion) {
      'lecciones' => completadas == 0
          ? 'Empecemos por Saludos básicos. Si una consigna no queda clara, tocame y la revisamos juntos.'
          : completadas == 1
              ? 'Ya tenés una misión completa. La siguiente es Animales del monte; cuando quieras, la practicamos.'
              : 'Ya completaste las misiones disponibles. Podés repasarlas o seguir practicando en Jugar.',
      'juegos' => 'Elegí un juego corto para repasar. Si querés, te recomiendo uno según lo que ya practicaste.',
      'comunidad' => 'Acá encontrás videos y la radio. Cuando quieras volver a practicar palabras, te llevo a Aprender.',
      'progreso' => 'Vas $completadas de 2 misiones y tenés ${PerfilUsuario.estrellasTotales} estrellas. ${completadas < 2 ? 'Tu próximo paso es ${saludos ? 'Animales del monte' : 'Saludos básicos'}.' : '¡Ya completaste el camino disponible!'}',
      _ => 'Estoy acá para acompañarte. Tocame si necesitás una pista o querés revisar tu progreso.',
    };
  }
}
