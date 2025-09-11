import 'package:todolistapp/1-domain/1-entities/login.dart';
import '../1-models/loginDB.dart';

class LoginMapper {
  static Login loginDbToEntity(LoginDb respuestaDB) => Login(
    mensaje: respuestaDB.mensaje,
    estado: respuestaDB.estado,
    respuesta: respuestaDB.respuesta
  );
}