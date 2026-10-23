import 'package:flutter/material.dart';

import '../quiz_data.dart'; // Importa la clase PerfilUsuario para leer las estrellas

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Perfil de Aprendizaje",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar de usuario
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                PerfilUsuario.nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Comunidad Fortín Dragones, Salta",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Fila de Estadísticas Estilo Duolingo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    titulo: "Estrellas",
                    valor: "${PerfilUsuario.estrellasTotales}",
                    icono: Icons.star,
                    color: Colors.amber,
                  ),
                  _buildStatCard(
                    titulo: "Logros",
                    valor: "${PerfilUsuario.medallasGanadas}",
                    icono: Icons.emoji_events,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Sección de Medallas Obtenidas
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tus Medallas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),

              const ListTile(
                leading: Icon(Icons.verified, color: Colors.teal, size: 40),
                title: Text(
                  "Defensor Lingüístico",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Por iniciar el rescate de la variante Wichí local.",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Icon(icono, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(titulo, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
