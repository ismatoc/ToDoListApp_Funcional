import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';

import '../../../1-domain/1-entities/estados_tareas.dart';
import '../../providers/estados_tareas_provider.dart';
import '../../providers/login_providers.dart';
import '../../providers/tarea_provider.dart';


class Tareas extends ConsumerStatefulWidget {
  
  final ValueChanged<dynamic>? onAvance;
  Tareas({super.key, this.onAvance});

  @override
  _CardsDemoPageState createState() => _CardsDemoPageState();
}

class _CardsDemoPageState extends ConsumerState<Tareas> {
  /// Lista interna y autónoma del widget
  List<Map<String, dynamic>> _items = [];
  dynamic tarea;
  int? _estadoTarea; 


  final _formKey = GlobalKey<FormState>();
  final _fechaInicioCtrl = TextEditingController();
  final _fechaFinCtrl = TextEditingController();

    int? _estadoSeleccionado = 1;
    DateTime? _fechaInicio;
    DateTime? _fechaFin;


    

    
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

  /// Simula carga inicial
  @override
  void initState() {
    super.initState();
    

    DateTime fecha = DateTime.now();

    Future.microtask(() async {

        final idEstadoTarea = ref.read( estadosTareasProvider.notifier ).id_estado_tarea;

        print(idEstadoTarea);

      final loginInfo = ref.read( loginProvider.notifier ).info;

      await ref.read(nowEstadosTareasProvider.notifier).loadAllData({
        "tipo_consulta": "R",
      });


      if(idEstadoTarea != null && idEstadoTarea != 0){
        // final loginInfo = ref.read( loginProvider.notifier ).info;
        await ref.read( nowTareaProvider.notifier ).loadAllData({
          "tipo_consulta": "R",
          "id_usuario": loginInfo["id_usuario"],
          "id_estado_tarea": idEstadoTarea
        });

        // await ref.read(nowEstadosTareasProvider.notifier).loadAllData({
        //   "tipo_consulta": "R",
        // });
        
      }else{
        
        await ref.read( nowTareaProvider.notifier ).loadAllData({
          "tipo_consulta": "R",
          "id_usuario": loginInfo["id_usuario"],
          'fecha1': _dateFmt.format(fecha!),
          'fecha2': _dateFmt.format(fecha!)
        });

        
        
      }

      
    });

    
      final formato = DateFormat('yyyy-MM-dd');
      _fechaInicio ??= fecha;
      _fechaFin ??= fecha;

      _fechaInicioCtrl.text = _dateFmt.format(_fechaInicio!);
      _fechaFinCtrl.text = _dateFmt.format(_fechaFin!);
  }

   @override
  void dispose() {
    _fechaInicioCtrl.dispose();
    _fechaFinCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    
    final idEstadoTarea = ref.watch( estadosTareasProvider );
    idEstadoTarea.setId(0);


    DateTime fecha = DateTime.now();

    final loginInfo = ref.read(loginProvider.notifier).info; // NO watch
    final userId = (loginInfo?['id_usuario'] as int?);
    if (userId != null) {
      await ref.read(nowTareaProvider.notifier).loadAllData({
        'tipo_consulta': 'R',
        'id_usuario': userId,
        'fecha1': _dateFmt.format(fecha!),
        'fecha2': _dateFmt.format(fecha!)
      });
    }
    // Nada de setState + watch aquí.
  }

  void _agregar() async {
    final nuevo = await _abrirEditor();

    if(nuevo?["data"]["tipo_consulta"] == "C"){
        Mensajes("Creada", 'Tarea Creada.!', DialogType.success, context);
    }
    await _onRefresh();
  }

  void _editar(Map<String, dynamic> item) async {
    print(item);
    final editado = await _abrirEditor(item: item);
    print(editado?["data"]["tipo_consulta"]);
    if(editado?["data"]["tipo_consulta"] == "U"){
      Mensajes("Actualizada", 'Tarea Actualizada.!', DialogType.success, context);
    }
  

    await _onRefresh();
  }

  void _eliminar(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Seguro que deseas eliminar "${item["titulo"]}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _items.removeWhere((e) => e["id"] == item["id"]));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _abrirEditor({Map<String, dynamic>? item}) async {

    return showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.blue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      context: context, 
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Expanded(child: CrearTarea(items: item, modal: true)),
            ],
          ),
        );
      }
    );

    

    
  }



  

  @override
  Widget build(BuildContext context) {
    

    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    tarea = ref.watch( nowTareaProvider );

    final List<Map<String, dynamic>> lista = (tarea?.respuesta is List)
    ? (tarea.respuesta as List).whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];

    if (tarea.estado == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // floatingActionButton: SizedBox(
      //   width: 45,   // ancho más pequeño
      //   height: 45,  // alto más pequeño
      //   child: FloatingActionButton(
      //     backgroundColor: Colors.green[200],
      //     onPressed: _agregar,
      //     child: const Icon(Icons.add, size: 20), // ícono más chico
      //   ),
      // ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          

          Padding(
            padding: EdgeInsets.only(bottom: 2, top: 2),
            child: Row(
              children: [

                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: ElevatedButton.icon(
                    onPressed:() async {

                      _fechaInicio = null;
                      _fechaFin = null;

                      _fechaInicioCtrl.clear();
                      _fechaFinCtrl.clear();
                      

                      // await ref.read(nowEstadosTareasProvider.notifier).loadAllData({
                      //   "tipo_consulta": "R",
                      // });

                      final infoestadosTareas = ref.watch(nowEstadosTareasProvider);

                      if (infoestadosTareas == null || infoestadosTareas.respuesta.isEmpty) {
                        Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final estadosTareas = (infoestadosTareas.respuesta as List)
                        .map((e) => Estados_Tareas.fromMap(e as Map<String, dynamic>))
                        .toList();

                      final valueIdEstadosTareas = (_estadoSeleccionado != null &&
                              estadosTareas.any((a) => a.id_estado_tarea == _estadoSeleccionado))
                              ? _estadoSeleccionado
                              : null;

                      DateTime fechita = DateTime.now();
                      final formato = DateFormat('yyyy-MM-dd');
                      _fechaInicio ??= fechita;
                      _fechaFin ??= fechita;

                      _fechaInicioCtrl.text = _dateFmt.format(_fechaInicio!);
                      _fechaFinCtrl.text = _dateFmt.format(_fechaFin!);

                      showDialog(
                        context: context, 
                        builder:(context) {
                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                                return AlertDialog(
                              title: const Text("Filtrar por: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              content: SizedBox(
                                width: 450,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // TextField(
                                    //   decoration: InputDecoration(
                                    //     labelText: "Buscar",
                                    //     border: OutlineInputBorder(),
                                    //   ),
                                    // ),
                                    // SizedBox(height: 10),
                                    // TextField(
                                    //   decoration: InputDecoration(
                                    //     labelText: "Estado",
                                    //     border: OutlineInputBorder(),
                                    //   ),
                                    // ),
                            
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
                                              value: a.id_estado_tarea,         
                                              child: Text(a.descripcion),    
                                            ))
                                        .toList(),
                                    onChanged: (id) => setState(() => _estadoSeleccionado = id),
                                    validator: (id) => id == null ? 'Seleccione un Estado' : null,
                                  ),
                            
                            
                                    SizedBox(height: 10),
                                    
                            
                            
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // TextFormField(
                                          //   readOnly: true,
                                          //   decoration: InputDecoration(
                                          //     labelText: 'Fecha inicio',
                                          //     border: border,
                                          //     suffixIcon: IconButton(
                                          //       icon: const Icon(Icons.date_range),
                                          //       onPressed: _pickFechaInicio,
                                          //     ),
                                          //   ),
                                          //   controller: TextEditingController(
                                          //     text: _fechaInicio == null ? '' : _dateFmt.format(_fechaInicio!),
                                          //   ),
                                          //   validator: (_) =>
                                          //       _fechaInicio == null ? 'Seleccione fecha de inicio' : null,
                                          // ),
                                          // const SizedBox(width: 12),

                                          TextFormField(
                                            controller: _fechaInicioCtrl,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Fecha inicio',
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))
                                              ),
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.date_range),
                                                onPressed: () async {
                                                  final picked = await showDatePicker(
                                                    context: context,
                                                    initialDate: _fechaInicio ?? DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (picked != null) {
                                                    _fechaInicio = picked;
                                                    _fechaInicioCtrl.text = _dateFmt.format(picked);
                                                    setStateDialog(() {}); // 🔁 refresca el modal
                                                  }
                                                },
                                              ),
                                            ),
                                            validator: (_) => _fechaInicio == null ? 'Seleccione fecha de inicio' : null,
                                          ),

                                          SizedBox(height: 10),

                                          TextFormField(
                                            controller: _fechaFinCtrl,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Fecha Fin',
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))
                                              ),
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.date_range),
                                                onPressed: () async {
                                                  final picked = await showDatePicker(
                                                    context: context,
                                                    initialDate: _fechaFin ?? DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (picked != null) {
                                                    _fechaFin = picked;
                                                    _fechaFinCtrl.text = _dateFmt.format(picked);
                                                    setStateDialog(() {}); // 🔁 refresca el modal
                                                  }
                                                },
                                              ),
                                            ),
                                            validator: (_) => _fechaFin == null ? 'Seleccione fecha de inicio' : null,
                                          ),

                                          
                                        ],
                                      ),
                                    ),
                            
                            
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cerrar"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Aquí iría lógica para aplicar filtros

                                    final loginInfo = ref.read(loginProvider.notifier).info; // NO watch
                                    final userId = (loginInfo?['id_usuario'] as int?);

                                    var data = {
                                      'tipo_consulta': 'R',
                                      'id_usuario': userId,
                                    };

                                    if( _estadoSeleccionado != null){
                                      data['id_estado_tarea'] = _estadoSeleccionado; 
                                    }

                                    if (_fechaInicio != null && _fechaFin != null){
                                      if (_fechaInicio!.isAfter(_fechaFin!)){
                                        Mensajes('Error', 'La fecha inicio no puede ser mayor que la fecha fin', DialogType.error, context);
                                      }else{
                                        if(_fechaFin!.isBefore(_fechaInicio!)){
                                          Mensajes('Error', 'La fecha fin no puede ser menor que la fecha inicio', DialogType.error, context);
                                        }else{
                                          
                                            data['fecha1'] = _fechaInicioCtrl.text;
                                            data['fecha2'] = _fechaFinCtrl.text;


                                          
                                        }
                                      }
                                    }
                            
                                    await ref.read(nowTareaProvider.notifier).loadAllData(data);
                            
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Aplicar"),
                                ),
                              ],
                            );
                            },
                          );
                        },
                      );
                    }, 
                    icon: const Icon(Icons.filter_alt), 
                    label: const Text('Filtro')
                  ),
                ),

                SizedBox(width: 70),

                const Text(
                  'Tareas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                Spacer(),

                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 5),
                  child: SizedBox(
                    width: 45,   // ancho más pequeño
                    height: 45,  // alto más pequeño
                    child: FloatingActionButton(
                      backgroundColor: Colors.green[200],
                      onPressed: _agregar,
                      child: const Icon(Icons.add, size: 20), // ícono más chico
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Scrollbar(
                child: lista.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 120),
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 10),
                          Center(child: Text('Sin tareas consultadas o registradas.')),
                          Center(child: Text('Cree una tarea.!')),
                          Center(child: Text("Fecha Actual: ${_fechaInicio != null ? _dateFmt.format(_fechaInicio!) : ''}")),
                          SizedBox(height: 400),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = lista[index];
                    
                          final String titulo = ((item["descripcion"] as String) ?? "").toString();
                          final String descripcion = (item["detalle_proyecto"] ?? "").toString();
                          final String estado = (item["estado_tarea"]).toString();
                          final String prioridad = (item["estado_tarea"]).toString();
                          final String? fecha_inicio = item["fecha_inicio"];
                          final String? fecha_fin = item["fecha_fin"];
            
                          // final IconData iconData = (item["icon"] is IconData) ? item["icon"] : Icons.folder_outlined;
            
                          return Card(
                            elevation: 9,
                            // surfaceTintColor: Colors.grey,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: _colorPorEstado(estado).withOpacity(0.35)),
                            ),
                            child: InkWell(
                              onTap: () => _editar(item),
                              onLongPress: () => _eliminar(item),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
            
                                    
            
                                    
                                   
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      
            
                                        
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
            
                                              Row(
                                                children: [
                                                  Chip(
                                                    
                                                    backgroundColor: item["id_estado_tarea"] == 1 ?Colors.blue.withOpacity(0.7) : item["id_estado_tarea"] == 2 ? Colors.orange.withOpacity(0.7) : Colors.green.withOpacity(0.7),
                                                    side: BorderSide(
                                                      color: Colors.white,
                                                      width: 2.2
                                                    ),
                                                    label: Text(item["estado_tarea"].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),), //Text('ID: ${item["id_tarea"]}'),
                                                    // avatar: item["id_estado_tarea"] == 1 ? Icon(Icons.circle, color: Colors.blue,) : item["id_estado_tarea"] == 2 ? Icon(Icons.circle, color: Colors.yellow,) : Icon(Icons.circle, color: Colors.green,),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 0,  
                                                    ),
                                                  ),

                                                  Spacer(),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            fecha_inicio.toString(),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                                          ),
                                                      
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                                            child: Icon(Icons.arrow_right_alt, size: 22, color: Colors.grey[600]),
                                                          ),
                                                      
                                                          Text(
                                                            fecha_fin.toString(),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                                          ),
                                                        ],
                                                      ),
                                                      Text('${item["actividad"]}')
                                                    ],
                                                  ),  
                                                  
                                                  Spacer(),
                                                ],
                                              ),
                                    
                                             
                                              
                                            ],
                                          ),
                                        ),
                                        // const SizedBox(width: 4),
                                        PopupMenuButton<String>(
                                          tooltip: 'Opciones',
                                          surfaceTintColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12), // bordes redondeados
                                          ),
                                          color: Colors.white, // fondo del popup
                                          elevation: 6, // sombra
                                          onSelected: (v) {
                                            print(item);
                                            if (v == 'editar') _editar(item);
                                            // if (v == 'eliminar') _eliminar(item);
                                          },
                                          itemBuilder: (ctx) => [
                                            PopupMenuItem(
                                              value: 'editar',
                                              child: ListTile(
                                                leading: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                                title: Text(
                                                  'Editar',
                                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent),
                                                ),
                                              ),
                                            ),
                                            const PopupMenuDivider(), // línea divisoria
                                            PopupMenuItem(
                                              value: 'eliminar',
                                              child: ListTile(
                                                leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                                                title: Text(
                                                  'Eliminar',
                                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
                                                ),
                                              ),
                                            ),
                                          ],
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10, right: 5),
                                            child: const Icon(
                                              Icons.more_vert, 
                                              color: Colors.black, 
                                              size: 24, // icono trigger
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              titulo,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          
                                          Expanded(
                                            child: Text(
                                              descripcion,
                                              maxLines: 2,                    
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.black)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
            
                                   
            
                                    SizedBox(height: 10),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text("Avance: " + item["avance"].toString() + '%', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.start,)),
                                              Text('Creado: ' + item["fecha_grabacion"].toString(), style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.start,),
                                            ],
                                          )
                                        ),
                                        Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)], // azul → azul claro
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: FilledButton.icon(
                                            onPressed: () {
                                              final dynamic idTarea = item;
                                              widget.onAvance?.call(idTarea);
                                              final idtarea = ref.watch( tareaProvider );
                                              idtarea.setIdTarea(idTarea["id_tarea"]);
                                            },
                                            icon: const Icon(Icons.add, color: Colors.white),
                                            label: const Text('Avances', style: TextStyle(color: Colors.white)),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.transparent, // 👈 deja ver el degradado
                                              shadowColor: Colors.transparent,
                                              surfaceTintColor: Colors.transparent,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ).copyWith(
                                              overlayColor: MaterialStateProperty.resolveWith((states) {
                                                if (states.contains(MaterialState.pressed)) return Colors.white24;
                                                if (states.contains(MaterialState.hovered)) return Colors.white12;
                                                return null;
                                              }),
                                            ),
                                          ),
                                        ),
            
                                       
                                        const SizedBox(width: 6),
                                        
                                      ],
                                    ),

                                    

                                    SizedBox(height: 10),
            
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// --------- Widgets y helpers internos ---------

class _DropdownCampo extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownCampo({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

Color _colorPorEstado(String estado) {
  switch (estado) {
    case 'completado':
      return Colors.green;
    case 'en_progreso':
      return Colors.orange;
    case 'pendiente':
    default:
      return Colors.blue;
  }
}

String _textoEstado(String estado) {
  switch (estado) {
    case 'completado':
      return 'Completado';
    case 'en_progreso':
      return 'En progreso';
    default:
      return 'Pendiente';
  }
}

String _formateaFechaHora(DateTime fecha) {
  final dd = fecha.day.toString().padLeft(2, '0');
  final mm = fecha.month.toString().padLeft(2, '0');
  final yyyy = fecha.year;
  final hh = fecha.hour.toString().padLeft(2, '0');
  final min = fecha.minute.toString().padLeft(2, '0');
  return "$dd/$mm/$yyyy $hh:$min";
}
