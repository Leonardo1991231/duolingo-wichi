import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'quiz_data.dart';
import 'screens/pantalla_bienvenida.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final usuario = FirebaseAuth.instance.currentUser;
  await PerfilUsuario.cargarProgreso(userId: usuario?.uid);
  if (usuario != null) {
    try {
      await PerfilUsuario.sincronizarCuenta(usuario);
    } catch (error) {
      debugPrint('No se pudo sincronizar el progreso con Firebase: $error');
    }
  }
  runApp(const WichiFacilApp());
}

class WichiFacilApp extends StatelessWidget {
  const WichiFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wichí Fácil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20C9B5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071B30),
        useMaterial3: true,
      ),
      home: const PantallaBienvenida(),
    );
  }
}
