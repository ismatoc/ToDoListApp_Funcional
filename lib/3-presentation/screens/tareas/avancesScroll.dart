import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:todolistapp/3-presentation/providers/avance_provider.dart';
import 'package:todolistapp/3-presentation/screens/tareas/crear_avance.dart';

import '../../../1-domain/1-entities/avance.dart'; // para tipos en el sheet
import '../screens.dart';


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
  if (data?.respuesta == null) {
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
   lista = [];
}




    return RefreshIndicator(
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

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant;
    final fg = isMine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

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
            bottomLeft: Radius.circular(isMine ? 14 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 14),
          ),
          boxShadow: [BoxShadow(blurRadius: 6, offset: const Offset(0, 2), color: Colors.black.withOpacity(0.06))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(message["fecha_detalle"] + ' ' + message["hora_detalle"],//DateFormat('dd/MM/yyyy HH:mm').format(message["fecha_detalle"]),
                  style: TextStyle(color: fg.withOpacity(0.9), fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: fg.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Text('${message["avance_detalle"]}%',
                    style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6),

            if (message["descripcion_detalle"].isNotEmpty) Text(message["descripcion_detalle"], style: TextStyle(color: fg)),

            if (message["fotos"].isNotEmpty) ...[
              const SizedBox(height: 10),
              // Wrap(
              //   spacing: 8, runSpacing: 8,
              //   children: message.fotos
              //       .map((f) => ClipRRect(
              //             borderRadius: BorderRadius.circular(10),
              //             child: Image.file(f, width: 100, height: 100, fit: BoxFit.cover),
              //           ))
              //       .toList(),
              // ),
              ImagesGridCompact(
                files: message.fotos,
              ),
            ],

            // if (message.videos.isNotEmpty) ...[
            //   const SizedBox(height: 8),
            //   Column(
            //     children: message.videos.asMap().entries.map((e) {
            //       final idx = e.key;
            //       return _VideoTilePlaceholder(isMine: isMine, label: 'Video ${idx + 1}');
            //     }).toList(),
            //   ),
            // ],

            // if (message.videos.isNotEmpty) ...[
            //   const SizedBox(height: 10),
            //   Column(
            //     children: message.videos.asMap().entries.map((e) {
            //       final i = e.key;
            //       final file = e.value;
            //       return Padding(
            //         padding: const EdgeInsets.only(bottom: 8),
            //         child: VideoThumbTileVP(
            //           file: file,
            //           label: 'Video ${i + 1}',
            //           size: 80,
            //         ),
            //       );
            //     }).toList(),
            //   ),
            // ],


            if (message["videos"].isNotEmpty) ...[
              const SizedBox(height: 8),
              VideosGridCompact(files: message.videos),
            ],
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


