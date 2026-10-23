import 'package:flutter/material.dart';

import '../quiz_data.dart'; // Importa PerfilUsuario y las preguntas globales
import 'pantalla_ejercicio.dart';
import 'pantalla_perfil.dart';
import 'pantalla_diccionario.dart'; // Conecta el diccionario comunitario

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  @override
  Widget build(BuildContext context) {
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
          // Marcador dinámico que lee directamente de PerfilUsuario
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
          // Botón del Diccionario Comunitario
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
          // Botón para ir a ver el Perfil y las Medallas
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
                // Al regresar del perfil, refresca la pantalla de inicio por si cambiaron los puntos
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
              const SizedBox(height: 30),

              _buildModuloBoton(
                context: context,
                titulo: "Módulo 1: Saludos Básicos",
                descripcion: "Aprende a decir Hola, Adiós y presentarte.",
                color: Colors.teal,
                icono: Icons.chat_bubble,
                habilitado: true,
              ),

              _buildModuloBoton(
                context: context,
                titulo: "Módulo 2: Animales del Monte",
                descripcion: "Vocabulario sobre la fauna del Chaco.",
                color: Colors.orange,
                icono: Icons.pets,
                habilitado: false,
              ),

              _buildModuloBoton(
                context: context,
                titulo: "Módulo 3: La Familia",
                descripcion: "Nombres de parentescos locales.",
                color: Colors.purple,
                icono: Icons.people,
                habilitado: false,
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          if (habilitado) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaEjercicio(),
              ),
            ).then((_) {
              // Recarga el marcador superior automáticamente al regresar de jugar
              setState(() {});
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "¡Completa el módulo anterior para desbloquear! 🔒",
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
