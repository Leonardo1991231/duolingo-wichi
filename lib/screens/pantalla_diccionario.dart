import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import 'dart:typed_data';

import '../widgets/ilustracion_educativa.dart';

// Estructura para almacenar palabras con soporte de fotos y audios reales
class PalabraDiccionario {
  final String wichi;
  final String castellano;
  final String? audioPath; // Ruta temporal del audio grabado
  final Uint8List? imagenBytes; // Imagen guardada como memoria de bytes directa

  PalabraDiccionario({
    required this.wichi,
    required this.castellano,
    this.audioPath,
    this.imagenBytes,
  });
}

class PantallaDiccionario extends StatefulWidget {
  final bool sincronizarAlAbrir;

  const PantallaDiccionario({super.key, this.sincronizarAlAbrir = false});

  @override
  State<PantallaDiccionario> createState() => _PantallaDiccionarioState();
}

class _PantallaDiccionarioState extends State<PantallaDiccionario> {
  // Inicialización de los controladores de hardware nativos
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  // Variables de control de estado del formulario colaborativo
  bool _isRecording = false;
  String? _pathAudioGrabado;
  Uint8List? _imagenSeleccionadaBytes;

  // Estado de publicación y sincronización en tiempo real.
  bool _publicando = false;
  bool _sincronizando = false;

  final TextEditingController _wichiController = TextEditingController();
  final TextEditingController _castellanoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.sincronizarAlAbrir) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizarAhora());
    }
  }

  Future<void> _sincronizarAhora() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);
    try {
      final resultado = await FirebaseFirestore.instance
          .collection('diccionario')
          .orderBy('creadoEn', descending: true)
          .get(const GetOptions(source: Source.server));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diccionario actualizado: ${resultado.size} palabras.')) ,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo conectar. Revisá internet e intentá de nuevo.')) ,
        );
      }
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _wichiController.dispose();
    _castellanoController.dispose();
    super.dispose();
  }

  // REPRODUCTOR REAL: Lee las pistas de voz almacenadas localmente
  void _playSound(PalabraDiccionario item) async {
    if (item.audioPath != null && item.audioPath!.isNotEmpty) {
      try {
        await _audioPlayer.play(DeviceFileSource(item.audioPath!));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al reproducir el audio grabado"),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Esta palabra no cuenta con un audio registrado"),
        ),
      );
    }
  }

  // GRABADOR REAL: Se conecta con el micrófono del navegador o celular
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _pathAudioGrabado = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Grabación finalizada con éxito! 🎙️"),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    final tienePermiso = await _audioRecorder.hasPermission();
    if (!mounted) return;

    if (!tienePermiso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permiso de micrófono denegado")),
      );
      return;
    }

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: '',
    );
    if (!mounted) return;

    setState(() {
      _isRecording = true;
      _pathAudioGrabado = null;
    });
  }

  // SELECTOR REAL: Abre la galería de imágenes del dispositivo
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagen == null || !mounted) return;

    final bytes = await imagen.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imagenSeleccionadaBytes = bytes;
    });
  }

  Future<void> _publicarPalabra(BuildContext sheetContext, StateSetter setModalState) async {
    final wichi = _wichiController.text.trim();
    final castellano = _castellanoController.text.trim();
    if (wichi.isEmpty || castellano.isEmpty) {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        const SnackBar(content: Text('Completá la palabra y su traducción.')) ,
      );
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        const SnackBar(content: Text('Iniciá sesión desde Mi perfil para compartir una palabra.')) ,
      );
      return;
    }
    setModalState(() => _publicando = true);
    try {
      await FirebaseFirestore.instance.collection('diccionario').add(
        <String, Object>{
          'wichi': wichi,
          'castellano': castellano,
          'variante': 'Dragones',
          'creadoEn': FieldValue.serverTimestamp(),
          'verificado': false,
        },
      );
      _wichiController.clear();
      _castellanoController.clear();
      _pathAudioGrabado = null;
      _imagenSeleccionadaBytes = null;
      if (!mounted || !sheetContext.mounted) return;
      setModalState(() => _publicando = false);
      Navigator.pop(sheetContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palabra compartida con la comunidad.')) ,
      );
    } catch (_) {
      if (sheetContext.mounted) {
        ScaffoldMessenger.of(sheetContext).showSnackBar(
          const SnackBar(content: Text('No se pudo publicar. Revisá la conexión e intentá de nuevo.')) ,
        );
      }
    } finally {
      if (mounted) setState(() => _publicando = false);
      if (sheetContext.mounted) setModalState(() => _publicando = false);
    }
  }

  // VENTANA FLOTANTE: El formulario real para ingresar datos
  void _abrirFormularioAgregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Aporte Comunitario Real",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _wichiController,
                      decoration: const InputDecoration(
                        labelText: "Palabra en Wichí (Variante Dragones)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _castellanoController,
                      decoration: const InputDecoration(
                        labelText: "Traducción al Castellano",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _toggleRecording();
                              if (context.mounted) setModalState(() {});
                            },
                            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                            label: Text(
                              _isRecording ? "Detener" : "Grabar Voz",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRecording
                                  ? Colors.red
                                  : Colors.grey[200],
                              foregroundColor: _isRecording
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _seleccionarImagen();
                              if (context.mounted) setModalState(() {});
                            },
                            icon: Icon(
                              _imagenSeleccionadaBytes != null
                                  ? Icons.check_circle
                                  : Icons.image,
                            ),
                            label: Text(
                              _imagenSeleccionadaBytes != null
                                  ? "¡Foto Lista!"
                                  : "Subir Ilustración",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _imagenSeleccionadaBytes != null
                                  ? Colors.green
                                  : Colors.grey[200],
                              foregroundColor: _imagenSeleccionadaBytes != null
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Las palabras se comparten en línea. Las fotos y grabaciones no se sincronizan todavía.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _publicando ? null : () => _publicarPalabra(context, setModalState),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text(
                        "Publicar Palabra",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Diccionario Colaborativo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sincronizar ahora',
            onPressed: _sincronizando ? null : _sincronizarAhora,
            icon: _sincronizando
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('diccionario')
            .orderBy('creadoEn', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('No se pudo cargar el diccionario.')) ;
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()) ;
          }
          final documentos = snapshot.data?.docs ?? const [];
          if (documentos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IlustracionEducativa(
                      tipo: TipoIlustracion.diccionario,
                      width: 170,
                      height: 136,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'El diccionario comunitario está listo.\n¡Agregá la primera palabra!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final datos = documentos[index].data();
              final palabra = PalabraDiccionario(
                wichi: datos['wichi'] as String? ?? '',
                castellano: datos['castellano'] as String? ?? '',
              );
              final verificada = datos['verificado'] == true;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.menu_book, color: Colors.teal),
                  ),
                  title: Text(
                    palabra.wichi,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(palabra.castellano),
                      const SizedBox(height: 4),
                      Text(
                        verificada ? 'Verificada' : 'Aporte comunitario · no verificado',
                        style: TextStyle(color: verificada ? Colors.green : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioAgregar,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Añadir Palabra",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
