import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:todolistapp/0-config/constants/environment.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      initialNotificationTitle : 'Ubicación activa',
      initialNotificationContent : 'Enviando ubicación en segundo plano',
      // foregroundServiceTypes: AndroidForegroundServiceType.location, // 👈 OBLIGATORIO
      // foregroundServiceTypes: const [
      //   AndroidForegroundServiceType.location,
      // ],
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
      autoStart: true
    ),
  );

  await service.startService();
}

int? _userId;
Position? _lastPos;
Timer? _heartbeat;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  _userId = prefs.getInt('id_usuario');

  IO.Socket socket = IO.io(
    // Environment.apiUrl,
    'https://j99lbcr4-3000.use2.devtunnels.ms',
    // 'https://g3cd7r9p-3000.use2.devtunnels.ms',
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/firmasign/socket.io')
        // .setQuery(_userId != null ? {'id_usuario': '${_userId!}'} : {})
        .setQuery(_userId != null ? {'id_usuario': '$_userId'} : {'id_usuario':null})
        .disableAutoConnect()
        .build(),
  );

  // socket.connect();

  socket.onConnect((_) {
    log('🟢 Socket conectado (bg)');
    if (_userId != null) socket.emit('set_user', {'id_usuario': _userId});
  });
  socket.onDisconnect((r) => log('🔴 Socket desconectado: $r'));
  socket.onError((e) => log('⚠️ Socket error: $e'));
  socket.onConnectError((e) => log('⚠️ Connect error: $e'));
  socket.connect();

  // // 🕒 Enviar ubicación cada 15 segundos
  // final timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     socket.emit('ubicacion', {
  //       'lat': position.latitude,
  //       'lng': position.longitude,
  //     });

  //     log("📍 Ubicación enviada automáticamente: ${position.latitude}, ${position.longitude}");
  //   } catch (e) {
  //     log('❌ Error al obtener ubicación: $e');
  //   }
  // });

service.on('set_user').listen((event) async {
    final dynamic raw = event?['id_usuario'];
    final int? newId = (raw is int) ? raw : null;
    _userId = newId;
    if (newId != null) {
      await prefs.setInt('id_usuario', newId);
      if (socket.connected) socket.emit('set_user', {'id_usuario': newId});
    } else {
      await prefs.remove('id_usuario');
      // No enviamos null al backend para no romper nada
    }
  });

  // 1) Stream: envía cuando hay movimiento (con tus mismas claves)
  final locationStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // envía solo si te mueves ≥5m
    ),
  ).listen((pos) {
    _lastPos = pos;
    if (!socket.connected) return; // evita tirar errores si se cae


    String _getFecha() {
      final now = DateTime.now();
      return "${now.year.toString().padLeft(4, '0')}-"
            "${now.month.toString().padLeft(2, '0')}-"
            "${now.day.toString().padLeft(2, '0')}";
    }

    String _getHora() {
      final now = DateTime.now();
      return "${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}:"
            "${now.second.toString().padLeft(2, '0')}";
    }


    final payload = {
      'lat': pos.latitude,
      'lng': pos.longitude,
      'fecha': _getFecha(),
      'hora': _getHora(),
      if (_userId != null) 'id_usuario': _userId,
    };
    socket.emit('ubicacion', payload);
    log('📍 (stream) $payload');
  });

  // 2) Heartbeat: cada 15s manda aunque estés quieto
  _heartbeat = Timer.periodic(const Duration(seconds: 15), (_) async {
    if (!socket.connected) return;
    try {
      // intenta una lectura fresca (rápida); si no, reutiliza la última
      final fresh = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      ).catchError((_) => null);

      final use = fresh ?? _lastPos;
      if (use == null) return;

       String _getFecha() {
          final now = DateTime.now();
          return "${now.year.toString().padLeft(4, '0')}-"
                "${now.month.toString().padLeft(2, '0')}-"
                "${now.day.toString().padLeft(2, '0')}";
        }

        String _getHora() {
          final now = DateTime.now();
          return "${now.hour.toString().padLeft(2, '0')}:"
                "${now.minute.toString().padLeft(2, '0')}:"
                "${now.second.toString().padLeft(2, '0')}";
        }

      final payload = {
        'lat': use.latitude,
        'lng': use.longitude,
        'fecha': _getFecha(),
        'hora': _getHora(),
        if (_userId != null) 'id_usuario': _userId,
      };
      socket.emit('ubicacion', payload);
      log('📍 (heartbeat) $payload');
    } catch (e) {
      log('❌ Heartbeat error: $e');
    }
  });



   // Escuchar eventos para detener el servicio (opcional)
  service.on('stopService').listen((event) {
    log("🛑 Servicio detenido manualmente.");
    locationStream.cancel();
    socket.disconnect();
    service.stopSelf();
  });
  
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}
