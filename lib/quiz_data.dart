import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuestionType { multipleChoice, trueFalse, wordBank, pictureChoice }

class Question {
  final String instruction;
  final String questionText;
  final String audioUrl;
  final List<String> options;
  final String correctAnswer;
  final QuestionType type;
  final List<String> wordBank;

  Question({
    required this.instruction,
    required this.questionText,
    this.audioUrl = '',
    required this.options,
    required this.correctAnswer,
    this.type = QuestionType.multipleChoice,
    this.wordBank = const <String>[],
  });
}

// Módulo 1: Saludos Básicos
List<Question> wichiQuestions = [
  Question(
    instruction: "Selecciona la traducción correcta para:",
    questionText: "Wityan",
    options: ["Hola / Buenos días", "Adiós", "Perro", "Agua"],
    correctAnswer: "Hola / Buenos días",
  ),
  Question(
    instruction: "Arma la traducción con las palabras disponibles:",
    questionText: "Wityan",
    correctAnswer: "Hola / Buenos días",
    type: QuestionType.wordBank,
    wordBank: ["Hola", "Buenos", "días", "Adiós", "Agua"],
    options: <String>[],
  ),
  Question(
    instruction: "¿El significado de esta palabra es correcto?",
    questionText: "Nhiyuwílh = Arcoíris",
    options: ["Verdadero", "Falso"],
    correctAnswer: "Verdadero",
    type: QuestionType.trueFalse,
  ),
];

// Módulo 2: Animales del Monte (NUEVO)
List<Question> animalesQuestions = [
  Question(
    instruction: "Selecciona el significado correcto para el animal:",
    questionText: "Asno",
    options: ["Zorro", "Burro", "Gato", "Yaguareté"],
    correctAnswer: "Burro",
    type: QuestionType.pictureChoice,
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

// El avance se conserva localmente y, cuando hay sesión, también en Firestore.
class PerfilUsuario {
  static const String _claveEstrellas = 'wichi.estrellas.v2';
  static const String _claveLecciones = 'wichi.lecciones_completadas.v2';
  static const String _claveMejoresPuntajes = 'wichi.mejores_puntajes.v2';
  static const String _claveMedallas = 'wichi.medallas.v1';
  static const String _claveRacha = 'wichi.racha.v1';
  static const String _claveUltimoDia = 'wichi.ultimo_dia.v1';
  static String? _userId;

  static String nombre = 'Aprendiz';
  static int estrellasTotales = 0;
  static int medallasGanadas = 0;
  static int rachaActual = 0;
  static String? ultimoDiaActividad;
  static Set<String> leccionesCompletadas = <String>{};
  static Map<String, int> mejoresPuntajes = <String, int>{};

  static int get rachaVigente {
    if (ultimoDiaActividad == null) return 0;
    final hoy = _fecha(DateTime.now());
    final ayer = _fecha(DateTime.now().subtract(const Duration(days: 1)));
    return ultimoDiaActividad == hoy || ultimoDiaActividad == ayer
        ? rachaActual
        : 0;
  }

  static String _fecha(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  static String _clave(String base) =>
      _userId == null ? base : base + '.' + _userId!;

  static Future<void> cargarProgreso({String? userId}) async {
    _userId = userId;
    await _cargarDesdePreferencias();
  }

  static Future<void> _cargarDesdePreferencias() async {
    final preferencias = await SharedPreferences.getInstance();
    estrellasTotales = preferencias.getInt(_clave(_claveEstrellas)) ?? 0;
    leccionesCompletadas =
        (preferencias.getStringList(_clave(_claveLecciones)) ?? <String>[])
            .toSet();
    medallasGanadas = preferencias.getInt(_clave(_claveMedallas)) ?? 0;
    rachaActual = preferencias.getInt(_clave(_claveRacha)) ?? 0;
    ultimoDiaActividad = preferencias.getString(_clave(_claveUltimoDia));
    mejoresPuntajes = <String, int>{};
    final puntajesGuardados =
        preferencias.getString(_clave(_claveMejoresPuntajes));
    if (puntajesGuardados == null) return;
    try {
      final decodificado = jsonDecode(puntajesGuardados);
      if (decodificado is Map<String, dynamic>) {
        mejoresPuntajes = <String, int>{
          for (final entrada in decodificado.entries)
            if (entrada.value is int) entrada.key: entrada.value as int,
        };
      }
    } on FormatException {
      mejoresPuntajes = <String, int>{};
    }
  }

  static bool leccionCompletada(String nombreModulo) =>
      leccionesCompletadas.contains(nombreModulo);

  static int mejorPuntaje(String nombreModulo) =>
      mejoresPuntajes[nombreModulo] ?? 0;

  static Future<void> sincronizarCuenta(
    User usuario, {
    bool importarProgresoInvitado = false,
  }) async {
    final importarInvitado = importarProgresoInvitado;
    final preferencias = await SharedPreferences.getInstance();
    final estrellasInvitado = importarInvitado
        ? (_userId == null
            ? estrellasTotales
            : preferencias.getInt(_claveEstrellas) ?? 0)
        : 0;
    final medallasInvitado = importarInvitado
        ? (_userId == null
            ? medallasGanadas
            : preferencias.getInt(_claveMedallas) ?? 0)
        : 0;
    final rachaInvitada = importarInvitado
        ? (_userId == null ? rachaActual : preferencias.getInt(_claveRacha) ?? 0)
        : 0;
    final ultimoDiaInvitado = importarInvitado
        ? (_userId == null ? ultimoDiaActividad : preferencias.getString(_claveUltimoDia))
        : null;
    final leccionesInvitado = importarInvitado
        ? (_userId == null
            ? Set<String>.from(leccionesCompletadas)
            : (preferencias.getStringList(_claveLecciones) ?? <String>[]).toSet())
        : <String>{};
    final puntajesInvitado = <String, int>{};
    if (importarInvitado) {
      if (_userId == null) {
        puntajesInvitado.addAll(mejoresPuntajes);
      } else {
        final guardados = preferencias.getString(_claveMejoresPuntajes);
        if (guardados != null) {
          try {
            final decodificados = jsonDecode(guardados);
            if (decodificados is Map<String, dynamic>) {
              puntajesInvitado.addAll(<String, int>{
                for (final entrada in decodificados.entries)
                  if (entrada.value is int) entrada.key: entrada.value as int,
              });
            }
          } on FormatException {
            puntajesInvitado.clear();
          }
        }
      }
    }

    _userId = usuario.uid;
    nombre = usuario.displayName?.trim().isNotEmpty == true
        ? usuario.displayName!.trim()
        : 'Aprendiz';
    await _cargarDesdePreferencias();

    estrellasTotales = _maximo(estrellasTotales, estrellasInvitado);
    medallasGanadas = _maximo(medallasGanadas, medallasInvitado);
    if (ultimoDiaInvitado != null &&
        (ultimoDiaActividad == null ||
            ultimoDiaInvitado.compareTo(ultimoDiaActividad!) > 0)) {
      ultimoDiaActividad = ultimoDiaInvitado;
      rachaActual = rachaInvitada;
    } else if (ultimoDiaInvitado != null &&
        ultimoDiaInvitado == ultimoDiaActividad) {
      rachaActual = _maximo(rachaActual, rachaInvitada);
    }
    leccionesCompletadas.addAll(leccionesInvitado);
    for (final entrada in puntajesInvitado.entries) {
      if (entrada.value > mejorPuntaje(entrada.key)) {
        mejoresPuntajes[entrada.key] = entrada.value;
      }
    }

    final referencia =
        FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid);
    final documento = await referencia.get();
    final datos = documento.data();
    if (datos != null) {
      estrellasTotales =
          _maximo(estrellasTotales, _entero(datos['estrellas']));
      medallasGanadas =
          _maximo(medallasGanadas, _entero(datos['medallas']));
      final ultimaRachaRemota = datos['ultimoDiaActividad'];
      if (ultimaRachaRemota is String &&
          (ultimoDiaActividad == null ||
              ultimaRachaRemota.compareTo(ultimoDiaActividad!) > 0)) {
        ultimoDiaActividad = ultimaRachaRemota;
        rachaActual = _entero(datos['rachaActual']);
      } else if (ultimaRachaRemota is String &&
          ultimaRachaRemota == ultimoDiaActividad) {
        rachaActual = _maximo(rachaActual, _entero(datos['rachaActual']));
      }
      final leccionesRemotas = datos['leccionesCompletadas'];
      if (leccionesRemotas is List) {
        leccionesCompletadas.addAll(leccionesRemotas.whereType<String>());
      }
      final puntajesRemotos = datos['mejoresPuntajes'];
      if (puntajesRemotos is Map) {
        for (final entrada in puntajesRemotos.entries) {
          if (entrada.key is String) {
            final modulo = entrada.key as String;
            final puntaje = _entero(entrada.value);
            if (puntaje > mejorPuntaje(modulo)) {
              mejoresPuntajes[modulo] = puntaje;
            }
          }
        }
      }
    }

    await _guardarLocal();
    if (importarInvitado) await _limpiarProgresoInvitado();
    await _guardarEnLaNube(referencia);
  }

  static int _entero(Object? valor) => valor is num ? valor.toInt() : 0;

  static int _maximo(int a, int b) => a > b ? a : b;

  static Future<void> _guardarLocal() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt(_clave(_claveEstrellas), estrellasTotales);
    await preferencias.setInt(_clave(_claveMedallas), medallasGanadas);
    await preferencias.setInt(_clave(_claveRacha), rachaActual);
    if (ultimoDiaActividad != null) {
      await preferencias.setString(_clave(_claveUltimoDia), ultimoDiaActividad!);
    }
    await preferencias.setStringList(
      _clave(_claveLecciones),
      leccionesCompletadas.toList(),
    );
    await preferencias.setString(
      _clave(_claveMejoresPuntajes),
      jsonEncode(mejoresPuntajes),
    );
  }

  static Future<void> _guardarEnLaNube(
    DocumentReference<Map<String, dynamic>> referencia,
  ) async {
    await referencia.set(<String, Object>{
      'nombre': nombre,
      'estrellas': estrellasTotales,
      'medallas': medallasGanadas,
      'rachaActual': rachaActual,
      if (ultimoDiaActividad != null)
        'ultimoDiaActividad': ultimoDiaActividad!,
      'leccionesCompletadas': leccionesCompletadas.toList(),
      'mejoresPuntajes': mejoresPuntajes,
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _limpiarProgresoInvitado() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt(_claveEstrellas, 0);
    await preferencias.setInt(_claveMedallas, 0);
    await preferencias.setInt(_claveRacha, 0);
    await preferencias.remove(_claveUltimoDia);
    await preferencias.setStringList(_claveLecciones, <String>[]);
    await preferencias.setString(_claveMejoresPuntajes, '{}');
  }

  static Future<void> cerrarSesionLocal() async {
    _userId = null;
    nombre = 'Aprendiz';
    await _cargarDesdePreferencias();
  }

  static Future<void> registrarResultado({
    required String nombreModulo,
    required int estrellasGanadas,
    required int respuestasCorrectas,
  }) async {
    estrellasTotales += estrellasGanadas;
    final hoy = _fecha(DateTime.now());
    if (ultimoDiaActividad != hoy) {
      final ayer = _fecha(DateTime.now().subtract(const Duration(days: 1)));
      rachaActual = ultimoDiaActividad == ayer ? rachaActual + 1 : 1;
      ultimoDiaActividad = hoy;
    }
    leccionesCompletadas.add(nombreModulo);
    if (respuestasCorrectas > mejorPuntaje(nombreModulo)) {
      mejoresPuntajes[nombreModulo] = respuestasCorrectas;
    }

    await _guardarLocal();
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null && _userId == usuario.uid) {
      try {
        await _guardarEnLaNube(
          FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid),
        );
      } catch (_) {
        // Se conserva el resultado local si el dispositivo no tiene conexión.
      }
    }
  }
}
