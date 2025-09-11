// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:todolistapp/config/constants/environment.dart';

// import 'config/router/app_router.dart';
// import 'services/background_location_service.dart';
// import 'package:showcaseview/showcaseview.dart';


// void main() async {

  

//   WidgetsFlutterBinding.ensureInitialized();

//   await Environment.initEnvironment();

//   // await Geolocator.requestPermission();
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     permission = await Geolocator.requestPermission();
//   }

//   await initializeService(); // 👈 Aquí lo inicializas

//   runApp(const MainApp());
// }

// class MainApp extends ConsumerWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//       ]);
//     });

//     // final AppTheme appTheme = ref.watch( themeNotifierProvider );

//     return ShowCaseWidget(
//       builder: (context) => MaterialApp.router(
//         routerConfig: appRouter,
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: true,
//           appBarTheme: const AppBarTheme(centerTitle: true),
//         ),
//         // theme: appTheme.getTheme(),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:showcaseview/showcaseview.dart';

import '0-config/router/app_router.dart';
import '0-config/constants/environment.dart';
import 'services/background_location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  runApp(const ProviderScope(child: RootApp()));
}

/// Arranque con pantalla de requisito de ubicación.
/// Si cumple (servicio + permisos), muestra tu MaterialApp.router.
class RootApp extends StatefulWidget {
  const RootApp({super.key});
  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> with WidgetsBindingObserver {
  bool _locationReady = false;
  bool _initializingService = false;
  String _statusText = 'Verificando ubicación…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Revisa servicio de ubicación y permisos.
  Future<void> _checkAll() async {
    setState(() => _statusText = 'Verificando servicio y permisos…');

    // 1) Servicio (GPS) encendido
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationReady = false;
        _statusText = 'El servicio de ubicación está desactivado.';
      });
      return;
    }

    // 2) Permisos
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      setState(() {
        _locationReady = false;
        _statusText = 'Permiso de ubicación denegado.';
      });
      return;
    }
    if (perm == LocationPermission.deniedForever) {
      setState(() {
        _locationReady = false;
        _statusText =
            'Permiso de ubicación bloqueado permanentemente. Actívalo en Configuración.';
      });
      return;
    }

    // OK: servicio + permisos listos
    if (!_initializingService) {
      _initializingService = true;
      await initializeService(); // tu servicio en segundo plano
    }
    setState(() {
      _locationReady = true;
      _statusText = 'Ubicación lista.';
    });
  }

  /// Revisa de nuevo al volver de ajustes/volver a primer plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAll();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    // Si NO está listo, muestra la pantalla de solicitud (no crashea la app).
    if (!_locationReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _LocationRequirementScreen(
          statusText: _statusText,
          onOpenLocationSettings: () async {
            await Geolocator.openLocationSettings();
          },
          onRequestPermission: () async {
            final p = await Geolocator.checkPermission();
            if (p == LocationPermission.denied) {
              await Geolocator.requestPermission();
            } else if (p == LocationPermission.deniedForever) {
              await Geolocator.openAppSettings();
            }
          },
          onRetry: _checkAll,
        ),
      );
    }

    // Listo: renderiza tu app normal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    });

    return ShowCaseWidget(
      builder: (_) => MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
      ),
    );
  }
}

/// UI simple para pedir GPS/permisos sin bloquear la app con errores.
class _LocationRequirementScreen extends StatelessWidget {
  final String statusText;
  final VoidCallback onOpenLocationSettings;
  final VoidCallback onRequestPermission;
  final VoidCallback onRetry;

  const _LocationRequirementScreen({
    required this.statusText,
    required this.onOpenLocationSettings,
    required this.onRequestPermission,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 72),
                  const SizedBox(height: 16),
                  const Text(
                    'Activar ubicación',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onOpenLocationSettings,
                    child: const Text('Activar GPS (Configuración)'),
                  ),
                  // const SizedBox(height: 8),
                  // OutlinedButton(
                  //   onPressed: onRequestPermission,
                  //   child: const Text('Otorgar permisos'),
                  // ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


