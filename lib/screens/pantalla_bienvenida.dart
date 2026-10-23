import 'package:flutter/material.dart';

import 'pantalla_inicio.dart'; // Nos conectará con el menú principal

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF041E42,
      ), // Un color azul oscuro de fondo por si tarda en cargar la imagen
      body: Stack(
        children: [
          // 1. La imagen de fondo que cubre toda la pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/images/caratula.png',
              fit: BoxFit.cover, // Hace que se adapte perfectamente a cualquier pantalla
            ),
          ),

          // 2. El botón interactivo posicionado exactamente abajo sobre el texto de la imagen
          Positioned(
            bottom: 40, // Lo ubica cerca del borde inferior
            left: 20,
            right: 20,
            child: SizedBox(
              height: 80, // Le damos buena altura para que sea fácil de tocar
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparente para no tapar el hermoso diseño de tu botón original
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Navegación limpia: te lleva al menú y borra esta pantalla para que no puedas volver atrás al apretar "Atrás"
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaInicio(),
                    ),
                  );
                },
                child: const SizedBox.shrink(), // No le ponemos texto adentro porque la imagen ya lo tiene escrito
              ),
            ),
          ),
        ],
      ),
    );
  }
}
