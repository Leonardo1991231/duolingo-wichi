import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// El avance se conserva localmente y, cuando hay sesión, también en Firestore.
class PerfilUsuario {
  static const String _claveEstrellas = 'wichi.estrellas.v2';
  static const String _claveLecciones = 'wichi.lecciones_completadas.v2';
  static const String _claveMejoresPuntajes = 'wichi.mejores_puntajes.v2';
  static const String _claveMedallas = 'wichi.medallas.v1';
  static String? _userId;

  static String nombre = 'Aprendiz';
  static int estrellasTotales = 0;
  static int medallasGanadas = 0;
  static Set<String> leccionesCompletadas = <String>{};
  static Map<String, int> mejoresPuntajes = <String, int>{};

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
      'leccionesCompletadas': leccionesCompletadas.toList(),
      'mejoresPuntajes': mejoresPuntajes,
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _limpiarProgresoInvitado() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt(_claveEstrellas, 0);
    await preferencias.setInt(_claveMedallas, 0);
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
