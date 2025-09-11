import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/2-infraestructure/2-repository/consultas_repository_impl.dart';
import 'package:todolistapp/2-infraestructure/4-datasources/consultasdb_datasource.dart';

final consultasRepositoryProvider = Provider((ref) {
  return ConsultasRepositoryImpl( ConsultasDbDatasource());
});