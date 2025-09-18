import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/3-presentation/screens/tareas/dashboard.dart';

import '../../providers/avance_provider.dart';
import '../screens.dart';

class Principal extends ConsumerStatefulWidget {
  static const name = 'principal';
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends ConsumerState<Principal> {
  String _selected = "inicio";
  dynamic? _avanceTareaId;

  int? _idEstadoTareaFiltro;

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
            ref.invalidate(nowAvanceProvider);
            setState(() => _selected = "tareas"); 
          },
        );
      case "config":
        return const Center(child: Text("⚙️ Configuración"));
      default:
        return Dashboard(
          onVerTareas: (int idEstadoTarea) {
            setState(() {
              _idEstadoTareaFiltro = idEstadoTarea;
              _selected = "tareas";
            });
          },
        );
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