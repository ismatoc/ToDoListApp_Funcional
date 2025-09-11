import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';


class Avances extends ConsumerStatefulWidget {
  static const name = 'avances';
  final dynamic? idTarea;
  final VoidCallback? onBack;
  const Avances({super.key, this.idTarea, this.onBack});

  @override
 _AvancesState createState() => _AvancesState();
}

class _AvancesState extends ConsumerState<Avances> {

  void _modal(Map<String, dynamic> item) async {
    final modal = await _abrirEditar(item:item);
  }

  Future<Map<String, dynamic>?> _abrirEditar({Map<String, dynamic>? item}) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.blue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      context: context, 
      builder: (context){
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Expanded(child: CrearAvance(items: item)),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    print(widget.idTarea);

    return Scaffold(
      appBar: AppBar(
        title: Text("Avances de tarea #" + widget.idTarea["id_tarea"].toString()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack, // 👈 dispara el callback
          
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: SizedBox(
        //       width: 45,   // ancho más pequeño
        //       height: 45,  // alto más pequeño
        //       child: FloatingActionButton(
        //         backgroundColor: Colors.green[200],
        //         onPressed:() => _modal(widget.idTarea),
        //         child: const Icon(Icons.add, size: 20), // ícono más chico
        //       ),
        //     ),
        //   ),
        // ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(),
            Text(widget.idTarea["descripcion"].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
            Text(widget.idTarea["detalle_proyecto"]),
            SizedBox(height: 10),
            Text("ACTIVIDAD: " + widget.idTarea["actividad"].toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),),

            Row(
              children: [
                Text(
                  widget.idTarea["fecha_inicio"].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_right_alt, size: 22, color: Colors.grey[600]),
                ),
            
                Text(
                  widget.idTarea["fecha_fin"].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            Divider(),

            Expanded(
              child: ChatCrud(
                tareaId: widget.idTarea["id_tarea"].toString(),
                // si quieres prefijar autor actual:
                currentUserId: "u123",
              ),
            ),
          ],
        ),
      )
    );
  }
}
