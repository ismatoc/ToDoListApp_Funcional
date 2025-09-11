
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'environment.dart';


class AuthInterceptor extends Interceptor {
  final Dio _tokenDio = Dio();
  String? _token;

  AuthInterceptor() {
    // Ignorar certificado SSL solo para desarrollo (Android/iOS/emulador)
    // if (!kReleaseMode) {
    //   (_tokenDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (client) {
    //     client.badCertificateCallback =
    //         (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   };
    // }
  }

  Future<void> _getToken() async {
    // if (_token != null) return;

    // print('${Environment.apiUrl}act');
    // print('${Environment.apikey}');


   

    try {
      final response = await _tokenDio.post(
        '${Environment.apiUrl}act',
        data: {},
        options: Options(
          headers: {
            'apikey': Environment.apikey,
            'Content-Length': '0',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      // print('Respuesta token: ${response.data}');
      _token = response.data['tk']; // Ajusta según tu API
      // print('Token obtenido: $_token');
    } catch (e) {
      // print('Error al obtener token: $e');
      rethrow;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // print('Interceptor ejecutándose');
    await _getToken();

    if (_token != null) {
      options.headers['Authorization'] = 'Bearer $_token';
      // print('Header Authorization agregado: Bearer $_token');
    }

    handler.next(options);
  }
}



