// 3-presentation/providers/multimedia_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/1-domain/3-repositories/consultas_repository.dart';
import 'package:todolistapp/3-presentation/providers/consultas_repository_providers.dart';
import '../../1-domain/1-entities/login.dart';
import '../../1-domain/1-entities/multimedia.dart';


final multimediaNotifierProvider =
    StateNotifierProvider<MultimediaNotifier, UploadResult>((ref) {
  final repo = ref.watch(consultasRepositoryProvider);
  return MultimediaNotifier(repo: repo);
});

class MultimediaNotifier extends StateNotifier<UploadResult> {
  final ConsutlasRepository repo;
  MultimediaNotifier({required this.repo}) : super(UploadResult.empty());

  Future<UploadResult> subir({
    required Map<String, dynamic> info,
    required List<File> fotos,
    required List<File> videos,
  }) async {
    final r = await repo.subirMedios(info: info, fotos: fotos, videos: videos);
    state = r;
    await Future.delayed(const Duration(milliseconds: 150));
    return r;
  }
}



final nowMediaProvider = StateNotifierProvider<LoginNotifier, Login>((ref) {
  final fetchAllLogins = ref.watch( consultasRepositoryProvider );
  return LoginNotifier(fetchAllLogin: fetchAllLogins);
});


class LoginNotifier extends StateNotifier<Login>{
  final ConsutlasRepository fetchAllLogin;

  LoginNotifier({
    required this.fetchAllLogin
  }): super (Login.empty());

  Future<Login> loadAllData(Map<String, dynamic> info) async {
    final Login allData = await fetchAllLogin.getMedia(info);
    state = allData;
    await Future.delayed(const Duration(milliseconds: 300));
    return state;
  }
}