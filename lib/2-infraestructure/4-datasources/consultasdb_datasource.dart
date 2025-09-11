import 'dart:io';

import 'package:dio/dio.dart';
import 'package:todolistapp/1-domain/1-entities/login.dart';
import 'package:todolistapp/1-domain/2-datasources/consultas_datasource.dart';
import 'package:todolistapp/0-config/constants/environment.dart';

import '../../1-domain/1-entities/multimedia.dart';

class ConsultasDbDatasource extends ConsultasDatasource {

  late final Dio dio;

  ConsultasDbDatasource(){
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl
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
    // final form = FormData.fromMap({
    //   'fotos': await _toMultipart(fotos),
    //   'videos': await _toMultipart(videos),
    //   ...info, // campos extra (id_usuario, etc.)
    // });

    // final resp = await dio.post('/multimedia', data: form,
    //   options: Options(contentType: 'multipart/form-data'),
    // );

    // if (resp.statusCode == 201) {
    //   return UploadResult.fromJson(resp.data as Map<String, dynamic>);
    // }
    // throw Exception('Error ${resp.statusCode}: ${resp.data}');

     final form = FormData(); // no uses fromMap aquí para controlar el orden

    // 1) Primero los campos de texto
    info.forEach((k, v) {
      form.fields.add(MapEntry(k, v.toString()));
    });

    // 2) Luego los archivos (fotos)
    for (final f in fotos) {
      final filename = f.path.split(Platform.pathSeparator).last;
      form.files.add(MapEntry(
        'fotos',
        await MultipartFile.fromFile(f.path, filename: filename),
      ));
    }

    // 3) Luego los archivos (videos)
    for (final v in videos) {
      final filename = v.path.split(Platform.pathSeparator).last;
      form.files.add(MapEntry(
        'videos',
        await MultipartFile.fromFile(v.path, filename: filename),
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

  


  



}