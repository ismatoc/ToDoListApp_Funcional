import 'dart:io';

import 'package:dio/dio.dart';

import '../1-entities/login.dart';
import '../1-entities/multimedia.dart';

abstract class ConsutlasRepository {
  Future<Login> getLogin(Map<String, dynamic> info);
  Future<Login> getActividades(Map<String, dynamic> info);
  Future<Login> getEstadosTareas(Map<String, dynamic> info);
  Future<Login> getTarea(Map<String, dynamic> info);
  Future<Login> getAvance(Map<String, dynamic> info);

  Future<UploadResult> subirMedios({
    required Map<String, dynamic> info,
    required List<File> fotos,
    required List<File> videos,
  });

  Future<Login> getMedia(Map<String, dynamic> info);
  Future<Login> dashboard(Map<String, dynamic> info);

  Future<Login> restablecer(Map<String, dynamic> info);
  Future<Login> validarestablecer(Map<String, dynamic> info);

}