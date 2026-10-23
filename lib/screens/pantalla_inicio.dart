import 'package:flutter/material.dart';

import '../quiz_data.dart'; // <--- ¡Asegúrate de que tenga los dos puntos (../) antes de quiz_data.dart!
import 'pantalla_ejercicio.dart';
import 'pantalla_perfil.dart';
import 'pantalla_diccionario.dart';
import 'pantalla_juego_infantil.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  @override
  Widget build(BuildContext context) {
    // Sistema de Desbloqueo Automático (Basado en las estrellas de quiz_data)
    bool modulo2Habilitado = PerfilUsuario.estrellasTotales >= 140;
    bool modulo3Habilitado = PerfilUsuario.estrellasTotales >= 170;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wichí Lhamtés",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                "${PerfilUsuario.estrellasTotales}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white, size: 26),
            tooltip: "Diccionario Comunitario",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaDiccionario(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 26,
            ),
            tooltip: "Ver Mi Perfil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaPerfil()),
              ).then((_) {
                setState(() {});
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "¿Qué quieres practicar hoy?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Módulo 1: Saludos
              _buildModuloBoton(
                context: context,
                titulo: "Módulo 1: Saludos Básicos",
                descripcion: "Aprende a decir Hola, Adiós y presentarte.",
                color: Colors.teal,
                icono: Icons.chat_bubble,
                habilitado: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaEjercicio(
                      preguntas: wichiQuestions,
                      nombreModulo: "Módulo 1: Saludos",
                    ),
                  ),
                ),
              ),

              // Módulo 2: Animales (Dinámico)
              _buildModuloBoton(
                context: context,
                titulo: "Módulo 2: Animales del Monte",
                descripcion: "Vocabulario sobre la fauna del Chaco.",
                color: Colors.orange,
                icono: Icons.pets,
                habilitado: modulo2Habilitado,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaEjercicio(
                      preguntas: animalesQuestions,
                      nombreModulo: "Módulo 2: Animales del Monte",
                    ),
                  ),
                ),
              ),

              // Sección Especial: Rincón de Juegos Infantiles
              const SizedBox(height: 20),
              const Text(
                "Rincón Infantil",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Divider(),

              _buildModuloBoton(
                context: context,
                titulo: "Juego de Memoria",
                descripcion: "¡Encuentra las palabras iguales y gana!",
                color: Colors.deepPurple,
                icono: Icons.extension,
                habilitado: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaJuegoInfantil(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuloBoton({
    required BuildContext context,
    required String titulo,
    required String descripcion,
    required Color color,
    required IconData icono,
    required bool habilitado,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          if (habilitado) {
            onTap();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "¡Consigue más estrellas en el módulo anterior para desbloquear! 🔒",
                ),
              ),
            );
          }
        },
        child: Card(
          elevation: habilitado ? 4 : 1,
          color: habilitado ? Colors.white : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: habilitado ? color : Colors.grey, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: habilitado
                      ? color.withOpacity(0.2)
                      : Colors.grey[300],
                  radius: 28,
                  child: Icon(
                    icono,
                    color: habilitado ? color : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: habilitado ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descripcion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!habilitado) const Icon(Icons.lock, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
