import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todolistapp/3-presentation/providers/avance_provider.dart';
import 'package:todolistapp/3-presentation/providers/login_providers.dart';
import 'package:todolistapp/3-presentation/providers/multimedia_provider.dart';
import 'package:todolistapp/3-presentation/providers/tarea_provider.dart';
import '../../../1-domain/1-entities/avance.dart';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

import '../../tools/mensajes.dart';
var logger = Logger();
class NuevoAvanceSheet extends ConsumerStatefulWidget {
  final String currentUserId;
  final ChatMessage? inicial;
  const NuevoAvanceSheet({super.key, required this.currentUserId, this.inicial});

  @override
  _NuevoAvanceSheetState createState() => _NuevoAvanceSheetState();
}

class _NuevoAvanceSheetState extends ConsumerState<NuevoAvanceSheet> {
  final _txtCtrl = TextEditingController();
  final _picker = ImagePicker();
  var idTarea;
  var loginInfo;
  int activa = 0;
  bool loading = false;

  DateTime? _fecha;
  final _dateFmt = DateFormat('yyyy-MM-dd');
  TimeOfDay? _hora;
  final TextEditingController _horaCtrl = TextEditingController();

  int _progreso = 0;
  final TextEditingController _avanceCtrl = TextEditingController();


  final List<File> _fotos = [];
  final List<File> _videos = [];


   Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona fecha',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  String _formatHora24(TimeOfDay? h) {
    if (h == null) return '';
    final hh = h.hour.toString().padLeft(2, '0');
    final mm = h.minute.toString().padLeft(2, '0');
    return '$hh:$mm'; // ej. 08:05
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
      helpText: 'Selecciona hora',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (picked != null) {
      setState(() {
        _hora = picked;
        _horaCtrl.text = _formatHora24(_hora);
      });
    }
  }

  

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      idTarea = ref.read( tareaProvider.notifier ).id_tarea;
      loginInfo = ref.read( loginProvider.notifier ).info;
    });

    if (widget.inicial != null) {
      final m = widget.inicial!;
      _txtCtrl.text = m.text;
      // _fechaHora = m.fechaHora;
      _progreso = m.progreso;
      _fotos.addAll(m.fotos);
      _videos.addAll(m.videos);
    } else {
      // _fechaHora = DateTime.now();
       DateTime fecha = DateTime.now();
       final formato = DateFormat('yyyy-MM-dd');
       _fecha = formato.parse(fecha.toString());
       TimeOfDay hora = TimeOfDay.fromDateTime(fecha);
       _horaCtrl.text = _formatHora24(hora);
       _avanceCtrl.text = '$_progreso';
    }
  }

  @override
  void dispose() {
    _horaCtrl.dispose();
    _avanceCtrl.dispose();
    super.dispose();
  }



  // ---------- Fotos (multi galería + una por cámara) ----------
  Future<ImageSource?> _elegirSource({required String titulo}) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text('$titulo desde galería'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text('$titulo con cámara'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancelar'),
            onTap: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickFotos() async {
    final src = await _elegirSource(titulo: 'Agregar fotos');
    if (src == null) return;

    if (src == ImageSource.gallery) {
      final imgs = await _picker.pickMultiImage(imageQuality: 82, maxWidth: 1920);
      if (imgs.isNotEmpty) {
        setState(() => _fotos.addAll(imgs.map((x) => File(x.path))));
      }
    } else {
      final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 82, maxWidth: 1920);
      if (shot != null) setState(() => _fotos.add(File(shot.path)));
    }
  }

  // ---------- Videos (multi galería con file_picker + cámara uno a uno) ----------



  
String _fmtMB(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(2);

Future<void> logVideoInfo(File f, {String tag = ''}) async {
  final name = p.basename(f.path);
  final ext  = p.extension(f.path).toLowerCase();
  final len  = await f.length(); // bytes

  // Duración (opcional, requiere video_player)
  Duration? dur;
  try {
    final ctrl = VideoPlayerController.file(f);
    await ctrl.initialize();
    dur = ctrl.value.duration;
    await ctrl.dispose();
  } catch (_) {}

  // Log
  // ignore: avoid_print
  print([
    if (tag.isNotEmpty) '[$tag]',
    'path=${f.path}',
    'name="$name" (len=${name.length})',
    'ext=$ext',
    'size=${len}B (${_fmtMB(len)} MB)',
    if (dur != null) 'duration=${dur.inMilliseconds}ms (~${dur.inSeconds}s)',
  ].join('  |  '));
}




  Future<void> _pickVideos() async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(children: [
        ListTile(
          leading: const Icon(Icons.video_library_outlined),
          title: const Text('Agregar videos desde galería (múltiples)'),
          onTap: () => Navigator.pop(context, 'gallery'),
        ),
        ListTile(
          leading: const Icon(Icons.videocam_outlined),
          title: const Text('Grabar con cámara (uno por vez)'),
          onTap: () => Navigator.pop(context, 'camera'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.close),
          title: const Text('Cancelar'),
          onTap: () => Navigator.pop(context),
        ),
      ]),
    ),
  );

  if (choice == 'gallery') {
    // TIP: con FilePicker puedes obtener el tamaño sin abrir File
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
      withData: false, // true también te trae bytes, pero no es necesario
    );
    if (res != null && res.files.isNotEmpty) {
      final files = <File>[];
      for (final pf in res.files) {
        if (pf.path == null) continue;
        final f = File(pf.path!);
        // Log de tamaño/nombre/duración
        await logVideoInfo(f, tag: 'GALLERY');
        files.add(f);
      }
      setState(() => _videos.addAll(files));
    }
  } else if (choice == 'camera') {
    final v = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (v != null) {
      final f = File(v.path);
      // Log de tamaño/nombre/duración
      await logVideoInfo(f, tag: 'CAMERA');
      setState(() => _videos.add(f));
    }
  }
}


  void _removeFotoAt(int i) => setState(() => _fotos.removeAt(i));
  void _removeVideoAt(int i) => setState(() => _videos.removeAt(i));

  Future<void> _guardar() async {

    setState(() => loading = true);


    try {
      activa = activa + 1;
      if(activa == 1){
        final txt = _txtCtrl.text.trim();
        if (txt.isEmpty) {
          return Mensajes('error', 'descripcion es requerido.!', DialogType.error, context);
        }

        final msg = ChatMessage(
          id: widget.inicial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          userId: widget.currentUserId,
          text: txt,
          fecha: '',//_fechaHora,
          hora: '',
          progreso: _progreso.round(),
          fotos: List<File>.from(_fotos),
          videos: List<File>.from(_videos),
        );
        
        final formato = DateFormat('yyyy-MM-dd');

        final ubicacion = await  Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        var info = {
          "tipo_consulta": "C",
          "id_tarea": idTarea,
          "descripcion": txt,
          "fecha": formato.format(_fecha!),
          "hora": '1970-01-01 ' + _horaCtrl.text + ':00',
          "latitud": ubicacion.latitude,
          "longitud": ubicacion.longitude,
          "avance":  int.parse(_avanceCtrl.text),
          "usuario_creacion_web": loginInfo["usuario"],
        };


        final providerAvance = await ref.read( nowAvanceProvider.notifier ).loadAllData(
          info
        );

        

        var infoMultimedia = {
          "tipo_consulta": "C",
          "id_tarea_detalle": providerAvance.respuesta["id_tarea_detalle"],
          "id_usuario": loginInfo["id_usuario"],
          "fecha": formato.format(_fecha!),
          "hora": '1970-01-01 ' + _horaCtrl.text + ':00',
          "latitud": ubicacion.latitude,
          "longitud": ubicacion.longitude,
          "usuario_creacion_web": loginInfo["usuario"]
        };

        final resultMultimedia = await ref.read( multimediaNotifierProvider.notifier ).subir(
          info: infoMultimedia, 
          fotos: List<File>.from(_fotos), 
          videos: List<File>.from(_videos)
        );

        await Future.delayed(Duration(seconds: 1));
        setState(() {
          activa = 0;
        });

        Navigator.pop(context, msg);

        final rootContext = Navigator.of(context, rootNavigator: true).context;
        Mensajes('correcto', 'avance guardado con éxito.!', DialogType.success, rootContext);
        
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }

    

    


  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom + 12.0;

    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: pad),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(widget.inicial == null ? 'Nuevo avance' : 'Editar avance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
        
               
        
        
                  TextFormField(
                    controller: _txtCtrl,
                    maxLines: null,
                    // maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      // hintText: 'Ej. Implementar módulo de reportes',
                      border: border,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'La descripción es requerida';
                      if (v.trim().length < 3) return 'Ingrese al menos 3 caracteres';
                      return null;
                    },
                  ),
        
        
                  const SizedBox(height: 12),
        
                
        
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            border: border,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: _pickFecha,
                            ),
                          ),
                          controller: TextEditingController(
                            text: _fecha == null ? '' : _dateFmt.format(_fecha!),
                          ),
                          validator: (_) =>
                              _fecha == null ? 'Seleccione fecha' : null,
                        ),
                      ),
        
                      SizedBox(width: 15),
        
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: _horaCtrl,
                          decoration: InputDecoration(
                            labelText: 'Hora',
                            border: border,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time), // mejor ícono para hora
                              onPressed: _pickHora,
                            ),
                          ),
                          validator: (_) => _hora == null ? 'Seleccione hora' : null,
                          onTap: _pickHora, // opcional: abrir al tocar el campo
                        ),
                      )
                    ],
                  ),
        
                  const SizedBox(height: 12),
        
                
        
                  Row(
                    children: [
                      
                      Expanded(
                        child: 
        
                        TextFormField(
                          controller: _avanceCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,   // solo dígitos
                            LengthLimitingTextInputFormatter(3),      // máx. 3 cifras
                          ],
                          decoration: InputDecoration(
                            labelText: 'Avance (%)',
                            border: border,
                            suffixText: '%',
                          ),
                          onChanged: (v) {
                            final n = int.tryParse(v) ?? 0;
                            setState(() => _progreso = n);
                          },
                          onFieldSubmitted: (_) {
                            // Opcional: al terminar de editar, “clampa” y refleja en el texto
                            if (_progreso > 100) {
                              setState(() {
                                _progreso = 100;
                                _avanceCtrl.text = '100';
                              });
                            }
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El avance es requerido';
                            final n = int.tryParse(v);
                            if (n == null) return 'Ingrese solo números enteros';
                            if (n < 0 || n > 100) return 'Debe estar entre 0 y 100';
                            return null;
                          },
                        )
        
                        ),
                      
                   
                    ],
                  ),
        
                  const SizedBox(height: 8),
        
                  // Botones Adjuntar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFotos,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Fotos'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickVideos,
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Videos'),
                        ),
                      ),
                    ],
                  ),
        
                  // Previews fotos
                  if (_fotos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: List.generate(_fotos.length, (i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_fotos[i], width: 80, height: 80, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 2, top: 2,
                                child: InkWell(
                                  onTap: () => _removeFotoAt(i),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
        
                  // Previews videos
                  if (_videos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_videos.length, (i) {
                        return Container(
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.videocam_rounded),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _videos[i].path.split(Platform.pathSeparator).last,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeVideoAt(i),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Quitar video',
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
        
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _guardar,
                      child: Text(widget.inicial == null ? 'Guardar' : 'Actualizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


        if (loading == true)
          Positioned.fill(
            child: Container(
              color: Colors.black45, // fondo oscuro
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
