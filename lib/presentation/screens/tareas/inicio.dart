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

  Widget _getContent() {
    switch (_selected) {
      case "tareas":
        return const Center(child: Text("📋 Tareas"));
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
        title: const Text("ToDoList Mixco"),
        centerTitle: true,
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