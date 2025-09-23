import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todolistapp/3-presentation/providers/avance_provider.dart';
import 'package:todolistapp/3-presentation/providers/multimedia_provider.dart';
import 'package:todolistapp/3-presentation/screens/tareas/crear_avance.dart';
import 'package:path/path.dart' as p;

import '../../../1-domain/1-entities/avance.dart'; // para tipos en el sheet
import '../screens.dart';

bool cargandoMedia = false;

Future<List<File>> decodeFotosToFiles(
  dynamic raw, {
  required String scope, // <- usa un id único del mensaje (p.ej. id_tarea_detalle + fecha + hora)
  bool clearScopeDir = true,        // limpia la carpeta antes de escribir
}) async {
  final List items = (raw as List?) ?? [];
  final tmp = await getTemporaryDirectory();

  final scopeDir = Directory(p.join(tmp.path, 'msg_cache', scope, 'fotos'));
  if (clearScopeDir && await scopeDir.exists()) {
    try { await scopeDir.delete(recursive: true); } catch (_) {}
  }
  await scopeDir.create(recursive: true);

  final files = <File>[];

  int i = 0;
  for (final it in items) {
    String? b64;
    String? mime;
    String filename;

    if (it is Map) {
      b64  = (it['base64'] as String?) ?? (it['data'] as String?);
      mime = it['mime'] as String?;
      // Prefijo con scope para evitar colisiones entre mensajes
      final base = _safeBaseName((it['filename'] as String?) ?? 'img_$i');
      filename = '$base.${_extFromMime(mime)}';
    } else if (it is String) {
      b64 = it;
      filename = 'img_$i.jpg';
    } else {
      i++;
      continue;
    }

    b64 = b64?.replaceFirst(RegExp(r'^data:[^;]+;base64,'), '');
    if (b64 == null) { i++; continue; }

    final bytes = base64Decode(b64);

    // Truco anticolisión extra: añade un sufijo microseconds
    final uniqueName = '${p.basenameWithoutExtension(filename)}_${DateTime.now().microsecondsSinceEpoch}${p.extension(filename)}';

    final f = File(p.join(scopeDir.path, uniqueName));
    await f.writeAsBytes(bytes, flush: true);
    files.add(f);
    i++;
  }

  return files;
}

String _extFromMime(String? mime) {
  switch (mime) {
    case 'image/jpeg': return 'jpg';
    case 'image/png':  return 'png';
    case 'image/webp': return 'webp';
    default:           return 'jpg';
  }
}

String _safeBaseName(String name) {
  final n = name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
  return n.isEmpty ? 'img' : n;
}





  Future<List<File>> decodeVideosToFiles(dynamic raw) async {
  final List items = (raw as List?) ?? [];
  final dir = await getTemporaryDirectory();
  final files = <File>[];

  int i = 0;
  for (final it in items) {
    String? b64;
    String? mime;
    String filename;

    if (it is Map) {
      b64   = (it['base64'] as String?) ?? (it['data'] as String?);
      mime  = it['mime'] as String?;
      filename = (it['filename'] as String?) ?? 'vid_${i++}.${_extFromVideoMime(mime)}';
    } else if (it is String) {
      b64 = it; // lista de strings base64
      filename = 'vid_${i++}.mp4';
    } else {
      continue;
    }

    // quita prefijo data URL si viene así
    b64 = b64?.replaceFirst(RegExp(r'^data:[^;]+;base64,'), '');
    if (b64 == null) continue;

    final bytes = base64Decode(b64);
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    files.add(file);
  }
  return files;
}

String _extFromVideoMime(String? mime) {
  switch (mime) {
    case 'video/mp4':        return 'mp4';
    case 'video/webm':       return 'webm';
    case 'video/quicktime':  return 'mov';
    case 'video/x-msvideo':  return 'avi';
    case 'video/x-matroska': return 'mkv';
    default:                 return 'mp4';
  }
}



class ChatCrud extends ConsumerStatefulWidget {
  final String tareaId;
  final String currentUserId;
  const ChatCrud({super.key, required this.tareaId, required this.currentUserId});

  @override
 _ChatCrudState createState() => _ChatCrudState();
}

class _ChatCrudState extends ConsumerState<ChatCrud> {
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _items = [];
  var info;


  

  

  @override
  void initState() {
    super.initState();
    Future.microtask(() async{
      print(int.parse(widget.tareaId));
      await ref.read( nowAvanceProvider.notifier ).loadAllData({
        "tipo_consulta": "R",
        "id_tarea": int.parse(widget.tareaId)
      });

      

    });
    
  }


  Future<void> _onRefresh() async {

    
      await ref.read(nowAvanceProvider.notifier).loadAllData({
        'tipo_consulta': 'R',
        'id_tarea': int.parse(widget.tareaId),
      });
    
    // Nada de setState + watch aquí.
  }

 

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _crearNuevo() async {
    final nuevo = await showModalBottomSheet<ChatMessage>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => NuevoAvanceSheet(currentUserId: widget.currentUserId),
    );

    await _onRefresh();

    if (nuevo != null) {
      // Aquí harías POST a tu API y reemplazarías archivos por URLs si aplica
      setState(() => _items.add(nuevo));
      _jumpToBottom();
    }
  }

  Future<void> _editar(dynamic m) async {
    final editado = await showModalBottomSheet<ChatMessage>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => NuevoAvanceSheet(
        currentUserId: widget.currentUserId,
        inicial: m,
      ),
    );

    if (editado != null) {
      setState(() {
        final i = _items.indexWhere((x) => x.id == m.id);
        if (i != -1) _items[i] = editado;
      });
    }
  }

  Future<void> _borrar(dynamic m) async {
    // DELETE a tu API si aplica
    setState(() => _items.removeWhere((x) => x.id == m.id));
  }

  @override
  Widget build(BuildContext context) {

    var data = ref.watch( nowAvanceProvider );

    

    print(data.respuesta.length != 0);
    List<Map<String, dynamic>> lista = [];

if(data.respuesta.length != 0){

    // 1) Si data o data.respuesta viene null -> loading (o lo que tú quieras)
  if (data?.estado == false) {
    return const Center(child: CircularProgressIndicator());
  }

  // 2) Asegúrate que sea una lista y que NO esté vacía
  final resp = data!.respuesta;
  if (resp is! List || resp.isEmpty) {
    // Puedes mostrar "sin datos" o un loader, según tu caso
    return const Center(child: Text('Sin datos para mostrar'));
  }

  // 3) Ya es seguro usar [0]
  final item0 = resp[0];

  // 4) Lee 'detalles' de forma segura
  final detalles = item0 is Map<String, dynamic> ? item0['detalles'] : null;

  // 5) Construye tu lista de Map<String,dynamic> (vacía si no hay detalles)
   lista = (detalles is List)
      ? detalles.whereType<Map<String, dynamic>>().toList()
      : <Map<String, dynamic>>[];

  // 6) Si también quieres tratar el caso de 'detalles' vacío:
}else{
  //  lista = [];
  return const Center(child: CircularProgressIndicator());
   


  //  return const LoadingOverlay();


}




    return 
   
    RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Lista con scroll
          lista.length > 0 ?
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final m = lista[index];
                logger.d(m);
                final isMine = m["id_tarea_detalle"] == widget.currentUserId;
      
                return Dismissible(
                  key: ValueKey(m["id_tarea_detalle"]),
                  direction: isMine ? DismissDirection.endToStart : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red.withOpacity(0.15),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  onDismissed: (_) => _borrar(m),
                  child: GestureDetector(
                    onLongPress: isMine ? () => _editar(m) : null,
                    child: Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: _MessageBubble(message: m, isMine: isMine),
                    ),
                  ),
                );
              },
            ),
          )
          :
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No tiene avances, ingrese uno nuevo.', style: TextStyle(fontWeight: FontWeight.bold)),
      
                Image.asset('assets/abajo.gif', fit: BoxFit.contain, width: 140)
      
              ],
            )
          ),
      
          // Botón único para no saturar la UI
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _crearNuevo,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar avance'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


 

class _MessageBubble extends ConsumerStatefulWidget {
  final dynamic message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<_MessageBubble> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant;
    final fg = widget.isMine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
              
    final List fotosRaw = (widget.message["fotos"] as List?) ?? [];
    final List videosRaw = (widget.message["videos"] as List?) ?? [];
    
    print(widget.message);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(6),
          ),
          boxShadow: [BoxShadow(blurRadius: 6, offset: const Offset(0, 2), color: Colors.black.withOpacity(0.06))],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(widget.message["fecha_detalle"] + ' ' + widget.message["hora_detalle"],//DateFormat('dd/MM/yyyy HH:mm').format(message["fecha_detalle"]),
                        style: TextStyle(color: fg.withOpacity(0.9), fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: fg.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Text('${widget.message["avance_detalle"]}%',
                          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 6),
              
                  if (widget.message["descripcion_detalle"].isNotEmpty) 
                    Text(widget.message["descripcion_detalle"], style: TextStyle(color: fg)),
              
                  
              
                  // if (widget.message["fotos"].isNotEmpty) ...[
                  //   const SizedBox(height: 10),
                   
              
                      // if (widget.message["tiene_multimedia"] == "1") ...[
                      //   const SizedBox(height: 10),
                      //   FutureBuilder<List<File>>(
                      //     future: decodeFotosToFiles(
                      //       fotosRaw,
                      //       scope: '${widget.message["id_tarea_detalle"]}_${widget.message["fecha_detalle"]}_${widget.message["hora_detalle"]}',
                      //       clearScopeDir: true, // borra caché del mensaje antes de escribir
                      //     ),
                      //     builder: (context, snap) {
                      //       if (snap.connectionState != ConnectionState.done) {
                      //         return const SizedBox(height: 96, child: Center(child: CircularProgressIndicator()));
                      //       }
                      //       final files = snap.data ?? const <File>[];
                      //       if (files.isEmpty) return const SizedBox.shrink();
                      //       // Opcional: clave única para el grid por mensaje, refuerza cache-busting del subtree
                      //       return KeyedSubtree(
                      //         key: ValueKey('grid_fotos_${widget.message["id_tarea_detalle"]}_${widget.message["fecha_detalle"]}_${widget.message["hora_detalle"]}'),
                      //         child: ImagesGridCompact(urls: widget.message["fotos"]),
                      //       );
                      //     },
                      //   ),
                      // ],
              
                  
              
                
              
              
                  // if (videosRaw.isNotEmpty) ...[
                  //   const SizedBox(height: 8),
                  //   FutureBuilder<List<File>>(
                  //     future: decodeVideosToFiles(videosRaw),
                  //     builder: (context, snap) {
                  //       if (snap.connectionState != ConnectionState.done) {
                  //         return const SizedBox(
                  //           height: 80,
                  //           child: Center(child: CircularProgressIndicator()),
                  //         );
                  //       }
                  //       final files = snap.data ?? const <File>[];
                  //       if (files.isEmpty) return const SizedBox.shrink();
                  //       return VideosGridCompact(files: files); // tu widget existente
                  //     },
                  //   ),
                  // ]
              
                 
                ],
              ),
            ),

            
            widget.message["tiene_multimedia"] == "1" ?
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text('MULTIMEDIA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),),
                  // Icon(Icons.photo_album,size: 30),

                  SizedBox(
                    width: 45,   // ancho más pequeño
                    height: 45,  // alto más pequeño
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue[300],
                      onPressed:() async {

                        print(widget.message["fotos"]);
                        print(widget.message["videos"]);

                       
                        abrirModalMultimedia(context, widget.message);

                        // abrirModalMultimedia(context, ref, widget.message["id_tarea_detalle"]);
                      },
                      child: const Icon(Icons.perm_media, color: Colors.white) // ícono más chico
                    ),
                  ),
                ],
              )
            )
            :
            SizedBox()
          ],
        ),
      ),
    );
  }
}

class _VideoTilePlaceholder extends StatelessWidget {
  final bool isMine;
  final String label;
  const _VideoTilePlaceholder({required this.isMine, required this.label});
  @override
  Widget build(BuildContext context) {
    final c = isMine ? Colors.white : Colors.black87;
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.videocam_rounded, color: c.withOpacity(0.9)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: c.withOpacity(0.9))),
          const Spacer(),
          Icon(Icons.play_arrow_rounded, color: c.withOpacity(0.9)),
        ],
      ),
    );
  }
}



Future<void> abrirModalMultimedia(BuildContext context, Map<String, dynamic> message) {
  final fotos = List<String>.from(message["fotos"] ?? []);
  final videos = List<String>.from(message["videos"] ?? []);

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Multimedia",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (fotos.isNotEmpty) ...[
                    Text('Fotos: ${fotos.length}'),
                    const SizedBox(height: 10),
                    ImagesGridCompact(urls: fotos),
                    // ImagesGridCompact(files: fotos, thumb: 88, spacing: 6),
                    const SizedBox(height: 12),
                  ],

                  if (videos.isNotEmpty) ...[
                    Text('Videos: ${videos.length}'),
                    const SizedBox(height: 10),
                    // VideosGridCompact(files: videos),
                    VideosGridCompact(urls: videos),
                    const SizedBox(height: 12),
                  ],

                  if (fotos.isEmpty && videos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No hay multimedia para mostrar')),
                    ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cerrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}




// Future<void> abrirModalMultimedia(BuildContext context, WidgetRef ref, int idTareaDetalle) {
//   return showDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierColor: Colors.black54,
//     builder: (context) {
//       // 👉 Arranca el futuro DENTRO del builder
//       final future = _loadYDecodificar(ref, idTareaDetalle);

//       return Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
//           child: FutureBuilder<MediaFiles>(
//             future: future,
//             builder: (context, snap) {
//               final cargando = snap.connectionState != ConnectionState.done;

//               // Contenido base (lista o mensaje vacío)
//               Widget contenido;
//               if (snap.hasData) {
//                 final data = snap.data!;
//                 contenido = Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text(
//                           "Multimedia",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                         ),
//                         const SizedBox(height: 16),

//                         if (data.fotos.isNotEmpty) ...[
//                           Text('Fotos: ${data.fotos.length}'),
//                           const SizedBox(height: 10),
//                           ImagesGridCompact(files: data.fotos, thumb: 88, spacing: 6),
//                           const SizedBox(height: 12),
//                         ],

//                         if (data.videos.isNotEmpty) ...[
//                           Text('Videos: ${data.videos.length}'),
//                           const SizedBox(height: 10),
//                           VideosGridCompact(files: data.videos),
//                           const SizedBox(height: 12),
//                         ],

//                         if (data.fotos.isEmpty && data.videos.isEmpty)
//                           const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 24),
//                             child: Center(child: Text('No hay multimedia para mostrar')),
//                           ),

//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                           ),
//                           child: const Text("Cerrar"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               } else {
//                 // estructura mínima mientras no hay data (igual habrá overlay)
//                 contenido = const SizedBox(height: 240, width: 320);
//               }

//               return Stack(
//                 children: [
//                   contenido,

//                   // Overlay de carga dentro del modal
//                   if (cargando)
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.45),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Center(child: CircularProgressIndicator()),
//                       ),
//                     ),

//                   // Overlay de error
//                   if (snap.hasError && !cargando)
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.45),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(24.0),
//                             child: Text(
//                               'Error cargando multimedia:\n${snap.error}',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// -------- helpers --------

// class MediaFiles {
//   final List<File> fotos;
//   final List<File> videos;
//   MediaFiles(this.fotos, this.videos);
// }

// Future<MediaFiles> _loadYDecodificar(WidgetRef ref, int idTareaDetalle) async {
//   // 👇 ahora cargamos aquí (no afuera del dialog)
//   final media = await ref.read(nowMediaProvider.notifier).loadAllData({
//     "tipo_consulta": "R",
//     "id_tarea_detalle": idTareaDetalle,
//   });

//   final fotosB64  = <String>[];
//   final videosB64 = <String>[];

//   for (final item in media.respuesta) {
//     final mime = (item["mime"] ?? "").toString();
//     if (mime == "image/jpeg")      fotosB64.add(item["base64"]);
//     if (mime == "application/mp4") videosB64.add(item["base64"]);
//   }

//   // Decodifica en paralelo
//   final results = await Future.wait([
//     decodeFotosToFiles(fotosB64, scope: 'media_$idTareaDetalle', clearScopeDir: true),
//     decodeVideosToFiles(videosB64),
//   ]);

//   return MediaFiles(results[0] as List<File>, results[1] as List<File>);
// }







