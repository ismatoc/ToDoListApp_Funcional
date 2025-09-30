import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todolistapp/1-domain/1-entities/estados_tareas.dart';
import 'package:todolistapp/3-presentation/providers/actividades_provider.dart';
import 'package:todolistapp/3-presentation/providers/estados_tareas_provider.dart';
import 'package:todolistapp/3-presentation/providers/tarea_provider.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';

import '../../../1-domain/1-entities/actividad.dart';
import '../../providers/login_providers.dart';
import 'package:intl/intl.dart';

class CrearTarea extends ConsumerStatefulWidget {

  final dynamic? items;
  final bool? modal;
  const CrearTarea({this.items, this.modal = false, super.key});

  @override
  _CrearTareaState createState() => _CrearTareaState();
}

class _CrearTareaState extends ConsumerState<CrearTarea> {


  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _descripcionCtrl = TextEditingController();
  final _detalleCtrl = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _estadoSeleccionado;
  int? _actividadSeleccionada;
  bool _guardando = false;

  String titulo = '';

  final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<void> _pickFechaInicio() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona fecha de inicio',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _fechaInicio = picked);
    }
  }

  Future<void> _pickFechaFin() async {
    final base = _fechaInicio ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? base,
      firstDate: DateTime(base.year - 5),
      lastDate: DateTime(base.year + 5),
      helpText: 'Selecciona fecha de fin',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _fechaFin = picked);
    }
  }

  Future<void> _guardar() async {
      if (!_formKey.currentState!.validate()) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
        useRootNavigator: true,
      );

      try {
        final loginInfo = ref.watch( loginProvider.notifier ).info;
      


        final payload = {
          "tipo_consulta": widget.items != null ? "U" : "C",
          "id_usuario": loginInfo["id_usuario"],
          "id_area": loginInfo["id_area"],
          "id_actividad": _actividadSeleccionada,
          "id_estado_tarea": _estadoSeleccionado,
          "descripcion": _descripcionCtrl.text.trim(),
          "detalle_proyecto": _detalleCtrl.text.trim(),
          "fecha_inicio": _dateFmt.format(_fechaInicio!),
          "fecha_fin": _dateFmt.format(_fechaFin!),
        };
        
        if(widget.items != null){
          payload["id_tarea"] = widget.items["id_tarea"];
          payload["usuario_modificacion_web"] = loginInfo["usuario"];
        }else{
          payload["usuario_creacion_web"] = loginInfo["usuario"];
        }

        final providerTarea = await ref.read( nowTareaProvider.notifier ).loadAllData(
          payload
        );

        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if ((widget.modal == true) && mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(<String, dynamic>{
            "ok": true,
            "data": payload,
          });
          return; // 👈 salimos: no muestres diálogos aquí
        }

        // Navigator.of(context).pop();

        
        _formKey.currentState!.reset();
        _descripcionCtrl.clear();
        _detalleCtrl.clear();
        setState(() {
          _actividadSeleccionada = null;
          _estadoSeleccionado = null;
          _fechaInicio = null;
          _fechaFin = null;
        });

        var mensajeTexto = widget.items != null ? 'Actualizada' : 'Creada';
        Mensajes(mensajeTexto, 'Tarea ${mensajeTexto}.!', DialogType.success, context);

        if(widget.modal == true){
          print('cierra modal');
          Navigator.pop(context, payload);
        }

      }catch (e) {
        Navigator.of(context).pop();
        Mensajes('Error', 'Error al Crear.!', DialogType.error, context);
        
    } finally {
      if (mounted) setState(() => _guardando = false);
    }

  }

  @override
  void initState(){
    super.initState();


    if(widget.items != null){
      titulo = 'Actualizar';
      var info = widget.items;
      _actividadSeleccionada = info["id_actividad"]; 
      _estadoSeleccionado = info["id_estado_tarea"];
      _descripcionCtrl.text = info["descripcion"];
      _detalleCtrl.text = info["detalle_proyecto"];
      final formato = DateFormat('dd-MM-yyyy');
      _fechaInicio = formato.parse(info["fecha_inicio"]); 
      _fechaFin = formato.parse(info["fecha_fin"]);
    }else{
      DateTime fecha = DateTime.now();
      titulo = 'Crear';
      final formato = DateFormat('yyyy-MM-dd');
      _fechaInicio = formato.parse(fecha.toString());
      _fechaFin = formato.parse(fecha.toString());

    }

    Future.microtask(() {
      ref.read(nowActividadProvider.notifier).loadAllData({
        "tipo_consulta": "R",
      });

      ref.read(nowEstadosTareasProvider.notifier).loadAllData({
        "tipo_consulta": "R",
      });
    });
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _detalleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    

    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    return Consumer(
      builder: (context, ref, child) {

        final infoactividades = ref.watch(nowActividadProvider);
        final infoestadosTareas = ref.watch(nowEstadosTareasProvider);


        if (infoactividades == null || infoactividades.respuesta.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (infoestadosTareas == null || infoestadosTareas.respuesta.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final actividades = (infoactividades.respuesta as List)
          .map((e) => Actividad.fromMap(e as Map<String, dynamic>))
          .toList();

        final valueId = (_actividadSeleccionada != null &&
                 actividades.any((a) => a.id_actividad == _actividadSeleccionada))
                ? _actividadSeleccionada
                : null;

        final estadosTareas = (infoestadosTareas.respuesta as List)
          .map((e) => Estados_Tareas.fromMap(e as Map<String, dynamic>))
          .toList();

        final valueIdEstadosTareas = (_estadoSeleccionado != null &&
                 estadosTareas.any((a) => a.id_estado_tarea == _estadoSeleccionado))
                ? _estadoSeleccionado
                : null;

        print(actividades);

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            Center(
                              child: Text(
                                '${titulo} Tarea',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
        
                            // Estado de la tarea
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Actividad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              value: valueId,
                              items: actividades
                                  .map((a) => DropdownMenuItem<int>(
                                        value: a.id_actividad,          // 👈 el id como value
                                        child: Text(a.descripcion),     // 👈 texto visible
                                      ))
                                  .toList(),
                              onChanged: (id) => setState(() => _actividadSeleccionada = id),
                              validator: (id) => id == null ? 'Seleccione una actividad' : null,
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              value: valueIdEstadosTareas,
                              items: estadosTareas
                                  .map((a) => DropdownMenuItem<int>(
                                        value: a.id_estado_tarea,          // 👈 el id como value
                                        child: Text(a.descripcion),     // 👈 texto visible
                                      ))
                                  .toList(),
                              onChanged: (id) => setState(() => _estadoSeleccionado = id),
                              validator: (id) => id == null ? 'Seleccione un Estado' : null,
                            ),

                            
                            const SizedBox(height: 12),

        
                            // Descripción
                            TextFormField(
                              controller: _descripcionCtrl,
                              maxLength: 120,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                hintText: 'Ej. Implementar módulo de reportes',
                                border: border,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'La descripción es requerida';
                                if (v.trim().length < 3) return 'Ingrese al menos 3 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
        
                            // Detalle del proyecto
                            TextFormField(
                              controller: _detalleCtrl,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Detalle del proyecto',
                                hintText: 'Notas, alcance, responsables, etc.',
                                border: border,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'El detalle es requerido' : null,
                            ),
                            const SizedBox(height: 12),
        
                            // Fecha inicio
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Fecha inicio',
                                      border: border,
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.date_range),
                                        onPressed: _pickFechaInicio,
                                      ),
                                    ),
                                    controller: TextEditingController(
                                      text: _fechaInicio == null ? '' : _dateFmt.format(_fechaInicio!),
                                    ),
                                    validator: (_) =>
                                        _fechaInicio == null ? 'Seleccione fecha de inicio' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Fecha fin',
                                      border: border,
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.event_available),
                                        onPressed: _pickFechaFin,
                                      ),
                                    ),
                                    controller: TextEditingController(
                                      text: _fechaFin == null ? '' : _dateFmt.format(_fechaFin!),
                                    ),
                                    validator: (_) {
                                      if (_fechaFin == null) return 'Seleccione fecha de fin';
                                      if (_fechaInicio != null && _fechaFin!.isBefore(_fechaInicio!)) {
                                        return 'La fecha fin debe ser posterior a la inicio';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
        
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save, color: Colors.white),
                                label: Text(
                                  widget.items != null ? 'Actualizar' : 'Guardar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,         
                                  foregroundColor: Colors.white,     
                                  padding: const EdgeInsets.symmetric(  
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(        
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,                        
                                  shadowColor: Colors.blueAccent,
                                ),
                                onPressed: _guardar,
                              ),
                            )
        
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ); 
      }
    );
  }
}