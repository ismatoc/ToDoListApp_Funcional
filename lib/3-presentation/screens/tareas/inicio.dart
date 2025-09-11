import 'package:flutter/material.dart';

import '../screens.dart';

class Principal extends StatefulWidget {
  static const name = 'principal';
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  String _selected = "inicio";
  dynamic? _avanceTareaId;

  Widget _getContent() {
    switch (_selected) {
      case "tarea":
        return CrearTarea();
      case "tareas":
        // return Tareas();
        return Tareas(
          onAvance: (dynamic idTarea) {
            setState(() {
              _avanceTareaId = idTarea;
              _selected = "avance";
            });
          },
        );
      case "avance":
        return Avances(
          idTarea: _avanceTareaId,
          onBack: () {
            setState(() => _selected = "tareas"); 
          },
        );
      case "config":
        return const Center(child: Text("⚙️ Configuración"));
      default:
        return const Center(child: Text("🏠 Bienvenido a ToDoList Mixco"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: const SizedBox.shrink(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("TareasMixco", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        centerTitle: true,
         flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
      ),
      drawer: CustomDrawer(
        onItemSelected: (value) {
          setState(() {
            _selected = value;
          });
        },
      ),
      body: _getContent(),
    );
  }
}