import 'package:go_router/go_router.dart';
import '../../presentation/screens/screens.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: Inicio.name,
      builder: (context, state) => Inicio(),
      routes: [
        GoRoute(
          path: 'principal',
          name: Principal.name,
          builder: (context, state) => Principal(),
          routes: [
            
          ]
        )
      ]
    )
  ]
);