import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../3-presentation/screens/screens.dart';


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
          

            GoRoute(
              path: 'recuperar',
              name: Recuperar.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: Recuperar(), 
                transitionsBuilder:(context, animation, secondaryAnimation, child) {
                  var fadeAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  );

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            ),

          ]
        ),

        

        
      ]
    ),

    
  ]
);