import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todolistapp/3-presentation/providers/login_providers.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final Function(String) onItemSelected;
  const CustomDrawer({super.key, required this.onItemSelected});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  @override
  Widget build(BuildContext context) {

    final loginInfo = ref.watch( loginProvider.notifier ).info;
    print(loginInfo);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Text(loginInfo["nombres"], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                ),

                 Text(loginInfo["apellidos"], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                 

              ],
            )
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // 👈 Oculta el Drawer
              widget.onItemSelected("inicio");
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Crear Tarea"),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected("tarea");
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text("Tareas"),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected("tareas");
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Cerrar Sesión"),
            onTap: () {
              context.push('/');
              widget.onItemSelected("config");
            },
          ),
        ],
      ),
    );
  }
}