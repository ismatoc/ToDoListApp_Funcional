import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'config/router/app_router.dart';
import 'services/background_location_service.dart';
import 'package:showcaseview/showcaseview.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Geolocator.requestPermission();
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  await initializeService(); // 👈 Aquí lo inicializas

  runApp(const MainApp());
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });

    // final AppTheme appTheme = ref.watch( themeNotifierProvider );

    return ShowCaseWidget(
      builder: (context) => MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        // theme: appTheme.getTheme(),
      ),
    );
  }
}