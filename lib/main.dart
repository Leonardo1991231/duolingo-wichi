import 'package:flutter/material.dart';

import 'screens/pantalla_bienvenida.dart'; // Ahora importamos la bienvenida

void main() => runApp(const WichiFacilApp());

class WichiFacilApp extends StatelessWidget {
  const WichiFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wichí Fácil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PantallaBienvenida(), // <--- Arranca con la carátula institucional
    );
  }
}
