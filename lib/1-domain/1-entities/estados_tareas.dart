class Estados_Tareas {
  final int id_estado_tarea;
  final String descripcion;

  Estados_Tareas({required this.id_estado_tarea, required this.descripcion});

  factory Estados_Tareas.fromMap(Map<String, dynamic> map) {
    return Estados_Tareas(
      id_estado_tarea: map['id_estado_tarea'] as int,
      descripcion: map['estado_tarea'] as String,
    );
  }
}
