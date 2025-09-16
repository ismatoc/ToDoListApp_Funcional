import 'dart:io';

import 'package:dio/src/multipart_file.dart';
import 'package:todolistapp/1-domain/1-entities/login.dart';
import 'package:todolistapp/1-domain/1-entities/multimedia.dart';
import 'package:todolistapp/1-domain/2-datasources/consultas_datasource.dart';
import 'package:todolistapp/1-domain/3-repositories/consultas_repository.dart';

class ConsultasRepositoryImpl extends ConsutlasRepository {
  final ConsultasDatasource datasource;

  ConsultasRepositoryImpl(this.datasource);

  @override
  Future<Login> getLogin(Map<String, dynamic> info) {
    return datasource.getLogin(info);
  }
  
  @override
  Future<Login> getActividades(Map<String, dynamic> info) {
    return datasource.getActividades(info);
  }
  
  @override
  Future<Login> getEstadosTareas(Map<String, dynamic> info) {
    return datasource.getEstadosTareas(info);
  }
  
  @override
  Future<Login> getTarea(Map<String, dynamic> info) {
    return datasource.getTarea(info);
  }
  
  @override
  Future<Login> getAvance(Map<String, dynamic> info) {
    return datasource.getAvance(info);
  }

  @override
  Future<UploadResult> subirMedios({required Map<String, dynamic> info, required List<File> fotos, required List<File> videos}) {
    return datasource.subirMedios(info: info, fotos: fotos, videos: videos);
  }
  
  @override
  Future<Login> getMedia(Map<String, dynamic> info) {
    return datasource.getMedia(info);
  }
  
  @override
  Future<Login> dashboard(Map<String, dynamic> info) {
    return datasource.dashboard(info);
  }

  

  
}