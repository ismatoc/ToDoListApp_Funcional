class Actividad {
  final int id_actividad;
  final String descripcion;

  Actividad({required this.id_actividad, required this.descripcion});

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id_actividad: map['id_actividad'] as int,
      descripcion: map['actividad'] as String,
    );
  }
}
