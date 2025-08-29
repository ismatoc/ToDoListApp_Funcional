import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onItemSelected;
  const CustomDrawer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                "ToDoList Mixco",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // 👈 Oculta el Drawer
              onItemSelected("inicio");
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text("Tareas"),
            onTap: () {
              Navigator.pop(context);
              onItemSelected("tareas");
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Cerrar Sesión"),
            onTap: () {
              context.push('/');
              onItemSelected("config");
            },
          ),
        ],
      ),
    );
  }
}