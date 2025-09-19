import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:todolistapp/3-presentation/providers/dashboard_provider.dart';

import '../../providers/estados_tareas_provider.dart';
import '../../providers/login_providers.dart';

class Dashboard extends ConsumerStatefulWidget {
  static const name = 'dashboard';
  final void Function(int idEstadoTarea) onVerTareas;
  const Dashboard({super.key, required this.onVerTareas});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {

  dynamic dashboard;

  int totalTareas = 0;
  int totalInicio = 0;
  int totalProceso = 0;
  int totalFinalizado = 0;


  @override
  void initState(){
    super.initState();
    Future.microtask(() async{
      final loginInfo = ref.read( loginProvider.notifier ).info;
      dashboard = await ref.read( nowDashboardProvider.notifier ).loadAllData({
        "tipo_consulta": "R",
        "id_usuario": loginInfo["id_usuario"]
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    dashboard = ref.watch( nowDashboardProvider );

    print(dashboard);

    if (dashboard.estado == false) {
      return const Center(child: CircularProgressIndicator());
    }

    if(dashboard.respuesta["totales"].length > 0){

      for (var i = 0; i < dashboard.respuesta["totales"].length; i++) {
        if(dashboard.respuesta["totales"][i]["estado"] == "Total"){
          totalTareas = int.parse(dashboard.respuesta["totales"][i]["total"].toString());
        }

        if(dashboard.respuesta["totales"][i]["estado"] == "Inicio"){
          totalInicio = int.parse(dashboard.respuesta["totales"][i]["total"].toString());
        }

        if(dashboard.respuesta["totales"][i]["estado"] == "Proceso"){
          totalProceso = int.parse(dashboard.respuesta["totales"][i]["total"].toString());
        }

        if(dashboard.respuesta["totales"][i]["estado"] == "Finalizado"){
          totalFinalizado = int.parse(dashboard.respuesta["totales"][i]["total"].toString()); 
        }
      }

    }

    

    final dataMap = <String, double>{
      "Inicio": totalInicio.toDouble(),
      "Proceso": totalProceso.toDouble(),
      "Finalizado": totalFinalizado.toDouble(),
    };

    final colorList = <Color>[
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFF4CAF50),
    ];


    return SingleChildScrollView(
      child: Column(
        children: [
          // ---- Bloques de Totales ----
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _buildBlock("Total Tareas", totalTareas, Colors.indigo),
                GestureDetector(
                  onTap: () {
                    widget.onVerTareas(1);
                    final idEstadoTarea = ref.watch( estadosTareasProvider );
                    idEstadoTarea.setId(1);
                  },
                  child: _buildBlock("Inicio", totalInicio, Colors.blue)),
                GestureDetector(
                  onTap: () {
                    widget.onVerTareas(2);
                    final idEstadoTarea = ref.watch( estadosTareasProvider );
                    idEstadoTarea.setId(2);
                  },
                  child: _buildBlock("En Proceso", totalProceso, Colors.orange)),
                GestureDetector(
                  onTap: () {
                    widget.onVerTareas(3);
                    final idEstadoTarea = ref.watch( estadosTareasProvider );
                    idEstadoTarea.setId(3);
                  },
                  child: _buildBlock("Finalizados", totalFinalizado, Colors.green)),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // ---- Gráfica de dona a la mitad ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PieChart(
              dataMap: dataMap,
              chartType: ChartType.ring,
              baseChartColor: Colors.grey[200]!,
              colorList: colorList,
              chartRadius: MediaQuery.of(context).size.width / 2,
              chartLegendSpacing: 32,
              legendOptions: const LegendOptions(
                legendPosition: LegendPosition.bottom,
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValuesOutside: true,
              ),
              ringStrokeWidth: 32,
              // 👇 Ajuste para que parezca media dona
              totalValue: (totalInicio + totalProceso + totalFinalizado).toDouble(),
              initialAngleInDegree: 180,
            ),
          ),
        ],
      ),
    );
  }
}



Widget _buildBlock(String title, int value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$value",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
