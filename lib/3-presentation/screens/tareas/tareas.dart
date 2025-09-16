// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:todolistapp/3-presentation/providers/tarea_provider.dart';

// import '../../providers/login_providers.dart';

// class Tareas extends ConsumerStatefulWidget {
//   const Tareas({super.key});

//   @override
//   _TareasState createState() => _TareasState();
// }

// class _TareasState extends ConsumerState<Tareas> {

//   @override
//   void initState(){
//     super.initState();

//     Future.microtask((){
//       final loginInfo = ref.watch( loginProvider.notifier ).info;
//       ref.read( nowTareaProvider.notifier ).loadAllData({
//         "tipo_consulta": "R",
//         "id_usuario": loginInfo["id_usuario"]
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {

    
//     final tareas = ref.watch( nowTareaProvider );

//     if (tareas == null || tareas.respuesta.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     print(tareas);
//     return const Placeholder();
//   }
// }


import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';

import '../../providers/login_providers.dart';
import '../../providers/tarea_provider.dart';


class Tareas extends ConsumerStatefulWidget {
  final ValueChanged<dynamic>? onAvance;
  const Tareas({super.key, this.onAvance});

  @override
  _CardsDemoPageState createState() => _CardsDemoPageState();
}

class _CardsDemoPageState extends ConsumerState<Tareas> {
  /// Lista interna y autónoma del widget
  List<Map<String, dynamic>> _items = [];
  dynamic tarea;

  /// Simula carga inicial
  @override
  void initState() {
    super.initState();
    _cargarDemo();
    Future.microtask(() async {
      final loginInfo = ref.read( loginProvider.notifier ).info;
      await ref.read( nowTareaProvider.notifier ).loadAllData({
        "tipo_consulta": "R",
        "id_usuario": loginInfo["id_usuario"]
      });
      
    });
  }

  Future<void> _cargarDemo() async {
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() {
      _items = [
        {
          "id": 1,
          "titulo": "Revisión de router zona 1",
          "descripcion": "Cambiar credenciales y revisar logs.",
          "estado": "pendiente", // pendiente | en_progreso | completado
          "prioridad": "alta",   // baja | media | alta
          "fecha": DateTime.now().subtract(const Duration(hours: 5)),
          "icon": Icons.router_outlined,
        },
        {
          "id": 2,
          "titulo": "Actualizar contenedores",
          "descripcion": "Reconstruir imágenes y limpiar cache.",
          "estado": "en_progreso",
          "prioridad": "media",
          "fecha": DateTime.now().add(const Duration(hours: 2)),
          "icon": Icons.settings_applications_outlined,
        },
        {
          "id": 3,
          "titulo": "Emitir reporte semanal",
          "descripcion": "Resumen de incidencias y uptime.",
          "estado": "completado",
          "prioridad": "baja",
          "fecha": DateTime.now().subtract(const Duration(days: 1)),
          "icon": Icons.assignment_outlined,
        },
      ];
    });
  }

  Future<void> _onRefresh() async {
    final loginInfo = ref.read(loginProvider.notifier).info; // NO watch
    final userId = (loginInfo?['id_usuario'] as int?);
    if (userId != null) {
      await ref.read(nowTareaProvider.notifier).loadAllData({
        'tipo_consulta': 'R',
        'id_usuario': userId,
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

    tarea = ref.watch( nowTareaProvider );

    final List<Map<String, dynamic>> lista = (tarea?.respuesta is List)
    ? (tarea.respuesta as List).whereType<Map<String, dynamic>>().toList()
    : <Map<String, dynamic>>[];

    if (tarea.estado == false) {
      return const Center(child: CircularProgressIndicator());
    }
    

    

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: SizedBox(
        width: 45,   // ancho más pequeño
        height: 45,  // alto más pequeño
        child: FloatingActionButton(
          backgroundColor: Colors.green[200],
          onPressed: _agregar,
          child: const Icon(Icons.add, size: 20), // ícono más chico
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 2, top: 2),
            child: Center(
              child: Text(
                'Tareas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
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
                        children: const [
                          SizedBox(height: 120),
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 10),
                          Center(child: Text('Sin elementos todavía')),
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
                          
                          print(item);
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
                                                    label: Text('ID: ${item["id_tarea"]}'),
                                                    avatar: item["estado"] == "A" ? Icon(Icons.circle, color: Colors.green,) :  Icon(Icons.circle, color: Colors.red,),
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
                                              style: TextStyle(color: Colors.grey)
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
                                          child: Text("Estado: " + item["estado_tarea"].toUpperCase()),
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
            
                                        // Spacer()
                                        const SizedBox(width: 6),
                                        // FilledButton.icon(
                                        //   onPressed: () => _eliminar(item),
                                        //   icon: const Icon(Icons.delete_outline),
                                        //   label: const Text('Eliminar'),
                                        // ),
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
