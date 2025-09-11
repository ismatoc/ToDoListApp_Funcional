class Tarea {
  final int id_tarea;
  final int id_usuario;
  final String nombres;
  final String apellidos;
  final int id_area;
  final String area;
  final int id_estado_tarea;
  final String estado_tarea;
  final int id_actividad;
  final String actividad;
  final String estado;
  final int avance;
  final String descripcion;
  final String detalle_proyecto;
  final dynamic fecha_inicio;
  final dynamic fecha_fin;


  Tarea({required this.id_tarea, 
         required this.id_usuario,
         required this.nombres,
         required this.apellidos,
         required this.id_area,
         required this.area,
         required this.id_estado_tarea,
         required this.estado_tarea,
         required this.id_actividad,
         required this.actividad,
         required this.estado,
         required this.avance,
         required this.descripcion,
         required this.detalle_proyecto,
         required this.fecha_inicio,
         required this.fecha_fin
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id_tarea: map['id_tarea'] as int,
      id_usuario: map['id_usuario'] as int,
      nombres: map['nombres'] as String,
      apellidos: map['apellidos'] as String,
      id_area: map['id_area'] as int,
      area: map['area'] as String,
      id_estado_tarea: map['id_estado_tarea'] as int,
      estado_tarea: map['estado_tarea'] as String,
      id_actividad: map['id_actividad'] as int,
      actividad: map['actividad'] as String,
      estado: map['estado'] as String,
      avance: map['avance'] as int,
      descripcion: map['descripcion'] as String,
      detalle_proyecto: map['detalle_proyecto'] as String,
      fecha_inicio: map['fecha_inicio'] as dynamic,
      fecha_fin: map['fecha_fin'] as dynamic,
    );
  }
}
