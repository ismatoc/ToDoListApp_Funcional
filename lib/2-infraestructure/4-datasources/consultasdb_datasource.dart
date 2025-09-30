import 'dart:io';

import 'package:dio/dio.dart';
import 'package:todolistapp/1-domain/1-entities/login.dart';
import 'package:todolistapp/1-domain/2-datasources/consultas_datasource.dart';
import 'package:todolistapp/0-config/constants/environment.dart';


import 'package:path/path.dart' as p;

import '../../1-domain/1-entities/multimedia.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

class ConsultasDbDatasource extends ConsultasDatasource {

  late final Dio dio;

  ConsultasDbDatasource(){
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl,
         connectTimeout: const Duration(seconds: 30),
         sendTimeout: const Duration(minutes: 20),   // ↑↑
         receiveTimeout: const Duration(minutes: 20),// ↑↑
      )
    );
  }

  @override
  Future<Login> getLogin(Map<String, dynamic> info) async {

    print(info);

    try {
      final String method = 'POST';
      final String url = '/login';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);

    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> getActividades(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/actividades';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);

    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> getEstadosTareas(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/estados_tareas';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);

    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> getTarea(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/tarea';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);

    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> getAvance(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/tarea_detalle';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);
    } catch (e) {
      throw Exception();
    }
  }


  Future<List<MultipartFile>> _toMultipart(List<File> files) async {
    return Future.wait(files.map((f) async {
      final name = f.path.split(Platform.pathSeparator).last;
      return MultipartFile.fromFile(f.path, filename: name);
    }));
  }
  
  @override
  Future<UploadResult> subirMedios({required Map<String, dynamic> info, required List<File> fotos, required List<File> videos}) async {



    String _extOr(String def, String path) {
      final e = p.extension(path).toLowerCase();
      return e.isEmpty ? def : e;
    }

    String _safeImageFilename(String path) {
      final ext = _extOr('.jpg', path);
      return 'img_${DateTime.now().microsecondsSinceEpoch}$ext';
    }

    String _safeVideoFilename(String path) {
      final ext = _extOr('.mp4', path);
      return 'vid_${DateTime.now().microsecondsSinceEpoch}$ext';
    }

    String _guessVideoSubtype(String path) {
      print(path);
      switch (p.extension(path).toLowerCase()) {
        case '.mp4':
        case '.m4v': return 'mp4';
        case '.webm': return 'webm';
        case '.mov':  return 'quicktime';
        case '.mkv':  return 'x-matroska';
        case '.avi':  return 'x-msvideo';
        case '.3gp':  return '3gpp';
        default:      return 'mp4';
      }
    }


     final form = FormData(); 

    // 1) Primero los campos de texto
    info.forEach((k, v) {
      form.fields.add(MapEntry(k, v.toString()));
    });



      for (final f in fotos) {
        form.files.add(MapEntry(
          'fotos',
          await MultipartFile.fromFile(
            f.path,
            filename: _safeImageFilename(f.path), // << AQUI el nombre corto
            // contentType opcional si quieres: MediaType('image', 'jpeg'|'png'...)
          ),
        ));
      }

 

     for (final v in videos) {
        form.files.add(MapEntry(
          'videos',
          await MultipartFile.fromFile(
            v.path,
            filename: _safeVideoFilename(v.path), // << AQUI el nombre corto
            contentType: MediaType('video', _guessVideoSubtype(v.path)),
          ),
        ));
      }

    final resp = await dio.post(
      '/multimedia',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (resp.statusCode == 201) {
      return UploadResult.fromJson(resp.data as Map<String, dynamic>);
    }
    throw Exception('Error ${resp.statusCode}: ${resp.data}');

  }


  
  @override
  Future<Login> getMedia(Map<String, dynamic> info) async {
     try {
      final String method = 'POST';
      final String url = '/multimedia/consulta';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);
    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> dashboard(Map<String, dynamic> info) async {
     try {
      final String method = 'POST';
      final String url = '/dashboard';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);
    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> restablecer(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/usuarios';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);
    } catch (e) {
      throw Exception();
    }
  }
  
  @override
  Future<Login> validarestablecer(Map<String, dynamic> info) async {
    try {
      final String method = 'POST';
      final String url = '/restablecer';

      final response = await dio.request(
        url,
        data: info,
        options: Options(
          method: method
        )
      );

      final data = response.data;
      return Login.fromJson(data);
    } catch (e) {
      throw Exception();
    }
  }

  


  



}