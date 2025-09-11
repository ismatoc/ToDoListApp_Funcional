class Login {
  final String? mensaje;
  final bool? estado;
  final dynamic? respuesta;

  Login({
    this.mensaje,
    this.estado,
    this.respuesta
  });

  factory Login.empty() => Login(mensaje: '', estado: false, respuesta: '');

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      mensaje: json['mensaje'] as String?,
      estado: json['estado'] as bool?,
      respuesta: json['respuesta'],
    );
  }


}