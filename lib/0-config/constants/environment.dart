import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  //PRODUCCIÓN
  static String apiUrl = dotenv.env['API_URL'] ?? 'No esta configurado el API_URL';
  static String apikey = dotenv.env['API_KEY'] ?? 'no existe';
  
}

