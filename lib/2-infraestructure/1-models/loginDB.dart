class LoginDb {
    String mensaje;
    bool estado;
    dynamic respuesta;

    LoginDb({
        required this.mensaje,
        required this.estado,
        required this.respuesta,
    });

    factory LoginDb.fromJson(Map<String, dynamic> json) => LoginDb(
        mensaje: json["mensaje"],
        estado: json["estado"],
        respuesta: json["respuesta"],
    );

    Map<String, dynamic> toJson() => {
        "mensaje": mensaje,
        "estado": estado,
        "respuesta": respuesta,
    };
}