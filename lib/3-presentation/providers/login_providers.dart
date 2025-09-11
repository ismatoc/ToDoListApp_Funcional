

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/1-domain/3-repositories/consultas_repository.dart';
import 'package:todolistapp/3-presentation/providers/consultas_repository_providers.dart';

import '../../1-domain/1-entities/login.dart';

// Provider Para Consultar
final nowLoginProvider = StateNotifierProvider<LoginNotifier, Login>((ref) {
  final fetchAllLogins = ref.watch( consultasRepositoryProvider );
  return LoginNotifier(fetchAllLogin: fetchAllLogins);
});




class LoginNotifier extends StateNotifier<Login>{
  final ConsutlasRepository fetchAllLogin;

  LoginNotifier({
    required this.fetchAllLogin
  }): super (Login.empty());

  Future<Login> loadAllData(Map<String, dynamic> info) async {
    final Login allData = await fetchAllLogin.getLogin(info);
    state = allData;
    await Future.delayed(const Duration(milliseconds: 300));
    return state;
  }
}


// Provider para obtener la informacion
final loginProvider = ChangeNotifierProvider((ref) => LoginProvider());

class LoginProvider extends ChangeNotifier {
  dynamic _info;
  dynamic get info => _info;

  void setInfo(dynamic newInfo){
    _info = newInfo;
    notifyListeners();
  }
}

