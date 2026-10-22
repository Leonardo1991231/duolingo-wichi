import 'package:flutter/material.dart'; // <--- ¡Esta línea faltaba!

import 'pantalla_ejercicio.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wichí Lhamtés - Dragones",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 24),
                SizedBox(width: 4),
                Text(
                  "5",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.star, color: Colors.amber, size: 24),
                SizedBox(width: 4),
                Text(
                  "120",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
            );
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
                      : Colors.grey[400],
                  radius: 28,
                  child: Icon(
                    icono,
                    color: habilitado ? color : Colors.white,
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
                          color: habilitado ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
