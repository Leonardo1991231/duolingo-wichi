import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pantalla_perfil.dart';

class PantallaComunidad extends StatelessWidget {
  const PantallaComunidad({super.key, this.initialTab = 0});

  final int initialTab;

  static const _fondo = Color(0xFF071326);

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        initialIndex: initialTab,
        child: Scaffold(
          backgroundColor: _fondo,
          appBar: AppBar(
            title: const Text('Comunidad'),
            backgroundColor: _fondo,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.smart_display_rounded), text: 'Videos'),
                Tab(icon: Icon(Icons.radio_rounded), text: 'Radios'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [_VideosDocentes(), _RadiosLocales()],
          ),
        ),
      );
}

class _VideosDocentes extends StatefulWidget {
  const _VideosDocentes();

  @override
  State<_VideosDocentes> createState() => _VideosDocentesState();
}

class _VideosDocentesState extends State<_VideosDocentes> {
  static const _panel = Color(0xFF112541);
  bool _enviando = false;

  Uri? _youtubeUri(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'https') return null;
    final host = uri.host.toLowerCase();
    final hostsValidos = {'youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be', 'www.youtu.be'};
    if (!hostsValidos.contains(host)) return null;
    final esYoutube = host.contains('youtube.com');
    final tieneVideo = esYoutube
        ? ((uri.path == '/watch' && (uri.queryParameters['v'] ?? '').isNotEmpty) ||
            uri.pathSegments.length >= 2 && {'shorts', 'embed', 'live'}.contains(uri.pathSegments.first))
        : uri.pathSegments.isNotEmpty;
    return tieneVideo ? uri : null;
  }

  Future<void> _abrirPerfil() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const PantallaPerfil(),
    ));
  }

  Future<void> _mostrarFormulario() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      final irAlPerfil = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Ingresá para compartir'),
          content: const Text('Las propuestas se envían para revisión. Iniciá sesión con tu cuenta para identificar quién comparte el video.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Ahora no')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Ir a mi perfil')),
          ],
        ),
      );
      if (irAlPerfil == true && mounted) await _abrirPerfil();
      return;
    }

    final titulo = TextEditingController();
    final url = TextEditingController();
    final descripcion = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _panel,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Compartí un video para aprender', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Pegá un enlace público de YouTube. Primero lo revisamos y, cuando se apruebe, aparece en la comunidad.', style: TextStyle(color: Color(0xFFB7C7D8))),
              const SizedBox(height: 16),
              TextFormField(
                controller: titulo,
                maxLength: 90,
                decoration: const InputDecoration(labelText: 'Título del video', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Escribí un título.' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Enlace de YouTube', hintText: 'https://youtu.be/...', border: OutlineInputBorder()),
                validator: (value) => _youtubeUri(value ?? '') == null ? 'Pegá un enlace público válido de YouTube.' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descripcion,
                maxLength: 240,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '¿Qué aprenderemos?', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _enviando ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  final uri = _youtubeUri(url.text)!;
                  Navigator.pop(sheetContext);
                  await _enviarPropuesta(usuario: usuario, titulo: titulo.text.trim(), url: uri, descripcion: descripcion.text.trim());
                },
                icon: _enviando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
                label: const Text('Enviar para revisión'),
              ),
            ],
          ),
        ),
      ),
    );
    titulo.dispose();
    url.dispose();
    descripcion.dispose();
  }

  Future<void> _enviarPropuesta({required User usuario, required String titulo, required Uri url, required String descripcion}) async {
    setState(() => _enviando = true);
    String mensaje = 'Video enviado para revisión. ¡Gracias por compartir!';
    try {
      await FirebaseFirestore.instance.collection('videos_docentes').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'videoUrl': url.toString(),
        'docente': usuario.displayName?.trim().isNotEmpty == true ? (usuario.displayName!.trim().length > 120 ? usuario.displayName!.trim().substring(0, 120) : usuario.displayName!.trim()) : 'Docente',
        'autorUid': usuario.uid,
        'estado': 'pendiente',
        'creadoEn': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      mensaje = 'No se pudo enviar. Revisá tu conexión e intentá de nuevo.';
    }
    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String? _idVideo(Uri uri) {
    if (uri.host.contains('youtu.be')) return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    if (uri.path == '/watch') return uri.queryParameters['v'];
    if (uri.pathSegments.length >= 2 && {'shorts', 'embed', 'live'}.contains(uri.pathSegments.first)) return uri.pathSegments[1];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final videos = FirebaseFirestore.instance.collection('videos_docentes').where('estado', isEqualTo: 'publicado').snapshots();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF174C68), Color(0xFF6037A3)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(children: [
              const Icon(Icons.record_voice_over_rounded, size: 38, color: Colors.white),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aprendemos en comunidad', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Videos compartidos por docentes y referentes.', style: TextStyle(color: Colors.white70)),
              ])),
              IconButton(onPressed: _mostrarFormulario, tooltip: 'Compartir un video', icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 30)),
            ]),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: videos,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('No pudimos cargar los videos ahora.'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final docs = [...?snapshot.data?.docs]..sort((a, b) {
                final fa = a.data()['creadoEn'];
                final fb = b.data()['creadoEn'];
                if (fa is Timestamp && fb is Timestamp) return fb.compareTo(fa);
                return 0;
              });
              if (docs.isEmpty) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.movie_filter_rounded, size: 58, color: Color(0xFF48D9C5)),
                    const SizedBox(height: 12),
                    const Text('Este espacio espera a las maestras.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Compartí un enlace de YouTube para proponer una clase. Los videos aparecen después de revisión.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB7C7D8))),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _mostrarFormulario, icon: const Icon(Icons.add_rounded), label: const Text('Proponer un video')),
                  ]),
                ));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final uri = _youtubeUri(data['videoUrl'] as String? ?? '');
                  final id = uri == null ? null : _idVideo(uri);
                  return Card(
                    color: _panel,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (id != null)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(fit: StackFit.expand, children: [
                            Image.network('https://img.youtube.com/vi/' + id + '/hqdefault.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF173452), child: Icon(Icons.movie_rounded, size: 44))),
                            const Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white)),
                          ]),
                        ),
                      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 4), child: Text(data['titulo'] as String? ?? 'Video educativo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(data['descripcion'] as String? ?? '', style: const TextStyle(color: Color(0xFFB7C7D8)))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
                        child: Row(children: [
                          const Icon(Icons.school_rounded, size: 18, color: Color(0xFF48D9C5)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(data['docente'] as String? ?? 'Docente de la comunidad', style: const TextStyle(color: Color(0xFFB7C7D8)))),
                          FilledButton.tonalIcon(
                            onPressed: uri == null ? null : () async {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Ver'),
                          ),
                        ]),
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RadiosLocales extends StatelessWidget {
  const _RadiosLocales();

  static const _panel = Color(0xFF112541);

  Future<void> _abrir(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la emisora. Intentá de nuevo más tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF15515B), Color(0xFF0E756D)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.waves_rounded, size: 38, color: Color(0xFF9DF2E8)),
              SizedBox(height: 12),
              Text('Voces del norte', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Escuchá radios de la región desde sus espacios oficiales.', style: TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 18),
          _RadioCard(
            nombre: 'La Voz Indígena',
            frecuencia: '94.5 FM · Tartagal',
            descripcion: 'Radio comunitaria hecha por comunicadoras y comunicadores de pueblos indígenas. Su sitio oficial enlaza la transmisión en vivo.',
            icono: Icons.diversity_3_rounded,
            colores: const [Color(0xFF9A4FAD), Color(0xFF542D91)],
            boton: 'Abrir transmisión oficial',
            onTap: () => _abrir(context, 'https://radiolavozindigena.org/'),
          ),
          const SizedBox(height: 12),
          _RadioCard(
            nombre: 'Radio Nacional Tartagal',
            frecuencia: 'LRA 25 · AM 540 · FM 92.3',
            descripcion: 'Emisora pública regional. Consultá sus programas y contenidos locales en el sitio oficial.',
            icono: Icons.radio_rounded,
            colores: const [Color(0xFF14798A), Color(0xFF11506D)],
            boton: 'Abrir emisora',
            onTap: () => _abrir(context, 'https://www.radionacional.com.ar/category/lra-25-tartagal/'),
          ),
          const SizedBox(height: 14),
          const Text('La reproducción se abre en el sitio de cada emisora y necesita conexión a internet.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFADBDD0), fontSize: 12)),
        ],
      );
}

class _RadioCard extends StatelessWidget {
  static const _panel = Color(0xFF112541);
  const _RadioCard({required this.nombre, required this.frecuencia, required this.descripcion, required this.icono, required this.colores, required this.boton, required this.onTap});
  final String nombre;
  final String frecuencia;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String boton;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: _panel,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(gradient: LinearGradient(colors: colores), borderRadius: BorderRadius.circular(17)), child: Icon(icono, color: Colors.white, size: 28)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(frecuencia, style: const TextStyle(color: Color(0xFF48D9C5), fontWeight: FontWeight.w600)),
              ])),
            ]),
            const SizedBox(height: 12),
            Text(descripcion, style: const TextStyle(color: Color(0xFFB7C7D8))),
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: FilledButton.tonalIcon(onPressed: onTap, icon: const Icon(Icons.open_in_new_rounded), label: Text(boton))),
          ]),
        ),
      );
}
