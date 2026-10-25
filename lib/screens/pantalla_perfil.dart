import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../quiz_data.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  User? _usuario = FirebaseAuth.instance.currentUser;
  bool _ocupado = false;
  static Future<void>? _inicializacionGoogle;

  Future<void> _prepararGoogle() {
    return _inicializacionGoogle ??= GoogleSignIn.instance.initialize();
  }

  Future<void> _iniciarSesion() async {
    setState(() => _ocupado = true);
    try {
      UserCredential credencial;
      if (kIsWeb) {
        credencial = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        await _prepararGoogle();
        final cuentaGoogle = await GoogleSignIn.instance.authenticate();
        final idToken = cuentaGoogle.authentication.idToken;
        if (idToken == null) {
          throw StateError('Google no devolvió un token de inicio de sesión.');
        }
        final credencialGoogle = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        credencial = await FirebaseAuth.instance.signInWithCredential(
          credencialGoogle,
        );
      }

      final usuario = credencial.user;
      if (usuario == null) throw StateError('No se encontró la cuenta.');
      if (!mounted) return;
      setState(() => _usuario = usuario);
      await _sincronizar(usuario, importarInvitado: true);
    } catch (error) {
      debugPrint('Error al iniciar sesión o sincronizar: $error');
      if (mounted) {
        _mostrarMensaje(
          'No se pudo completar la acción (' + _codigoError(error) + ').',
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _sincronizar(User usuario, {bool importarInvitado = false}) async {
    try {
      await PerfilUsuario.sincronizarCuenta(
        usuario,
        importarProgresoInvitado: importarInvitado,
      );
      if (mounted) {
        setState(() {});
        _mostrarMensaje('Tu progreso quedó sincronizado con tu cuenta.');
      }
    } catch (error) {
      debugPrint('Error al sincronizar progreso con Firestore: $error');
      if (mounted) {
        _mostrarMensaje(
          'No se pudo sincronizar el progreso (' + _codigoError(error) + ').',
        );
      }
    }
  }

  Future<void> _cerrarSesion() async {
    setState(() => _ocupado = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        try {
          await _prepararGoogle();
          await GoogleSignIn.instance.signOut();
        } catch (_) {
          // Firebase ya cerró la sesión; se conserva ese cierre aunque Google falle.
        }
      }
      await PerfilUsuario.cerrarSesionLocal();
      if (mounted) setState(() => _usuario = null);
    } catch (_) {
      if (mounted) _mostrarMensaje('No se pudo cerrar la sesión. Intentá otra vez.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  String _codigoError(Object error) {
    if (error is FirebaseException) {
      return error.plugin + '/' + error.code;
    }
    return error.runtimeType.toString();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;
    final nombreMostrado = usuario?.displayName ?? PerfilUsuario.nombre;
    final colorTurquesa = const Color(0xFF29D6C1);

    return Scaffold(
      backgroundColor: const Color(0xFF071B30),
      appBar: AppBar(
        title: const Text('Mi perfil y progreso'),
        backgroundColor: const Color(0xFF0C2A43),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF0D766F),
                backgroundImage: usuario?.photoURL == null
                    ? null
                    : NetworkImage(usuario!.photoURL!),
                child: usuario?.photoURL != null
                    ? null
                    : const Icon(Icons.person, size: 52, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              nombreMostrado,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              usuario?.email ?? 'Comunidad Fortín Dragones, Salta',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            if (usuario == null)
              FilledButton.icon(
                onPressed: _ocupado ? null : _iniciarSesion,
                icon: _ocupado
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: const Text('Guardar mi progreso con Google'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorTurquesa,
                  foregroundColor: const Color(0xFF071B30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else ...[
              Card(
                color: const Color(0xFF102B45),
                child: ListTile(
                  leading: Icon(Icons.cloud_done_rounded, color: colorTurquesa),
                  title: const Text('Cuenta de Google conectada'),
                  subtitle: const Text('El avance se guarda en este dispositivo y en tu cuenta.'),
                  trailing: _ocupado
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ),
              TextButton.icon(
                onPressed: _ocupado
                    ? null
                    : () => _sincronizar(usuario, importarInvitado: true),
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Sincronizar mi progreso'),
              ),
              TextButton.icon(
                onPressed: _ocupado ? null : _cerrarSesion,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    titulo: 'Estrellas',
                    valor: PerfilUsuario.estrellasTotales.toString(),
                    icono: Icons.star_rounded,
                    color: const Color(0xFFFFD166),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    titulo: 'Logros',
                    valor: PerfilUsuario.medallasGanadas.toString(),
                    icono: Icons.emoji_events_rounded,
                    color: const Color(0xFFFFA94D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Tus medallas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.verified_rounded, color: Color(0xFF29D6C1), size: 38),
              title: Text('Defensor Lingüístico', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Por iniciar el rescate de la variante Wichí local.'),
            ),
          ],
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
      color: const Color(0xFF102B45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icono, color: color, size: 36),
            const SizedBox(height: 8),
            Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(titulo, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
