import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';

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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  IO.Socket socket = IO.io(
    // 'https://j99lbcr4-3000.use2.devtunnels.ms',
    'https://g3cd7r9p-3000.use2.devtunnels.ms',
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/firmasign/socket.io')
        .disableAutoConnect()
        .build(),
  );

  socket.connect();

  socket.onConnect((_) {
    log('🟢 Socket conectado desde background');
  });

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


   // ✅ Usamos stream de ubicación en vez de Timer.periodic
  final locationStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // más preciso para background
      distanceFilter: 5, // cada 10 metros
    ),
  ).listen((Position position) {
    socket.emit('ubicacion', {
      'lat': position.latitude,
      'lng': position.longitude,
    });

    log("📍 Ubicación enviada automáticamente: ${position.latitude}, ${position.longitude}");
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
