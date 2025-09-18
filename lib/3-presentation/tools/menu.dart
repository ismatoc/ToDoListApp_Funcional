// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:todolistapp/3-presentation/providers/login_providers.dart';

// class CustomDrawer extends ConsumerStatefulWidget {
//   final Function(String) onItemSelected;
//   const CustomDrawer({super.key, required this.onItemSelected});

//   @override
//   _CustomDrawerState createState() => _CustomDrawerState();
// }

// class _CustomDrawerState extends ConsumerState<CustomDrawer> {
//   @override
//   Widget build(BuildContext context) {

//     final loginInfo = ref.watch( loginProvider.notifier ).info;
//     print(loginInfo);

//     return Drawer(
//       child: Column(
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade800, Colors.blue.shade400],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [

//                 CircleAvatar(
//                   radius: 25, // tamaño del avatar
//                   backgroundColor: Colors.blue.shade100, // fondo suave
//                   child: Icon(
//                     Icons.person,       // 👤 ícono de usuario
//                     size: 45,
//                     color: Colors.blue, // color principal
//                   ),
//                 ),
                
//                 Text(loginInfo["nombres"] + ' ' + loginInfo["apellidos"], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
//                 Text(loginInfo["usuario"], style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),),
//                 Text(loginInfo["area"].toString(), style: TextStyle(color: Colors.white, fontSize: 14),)

//               ],
//             )
//           ),
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text("Inicio"),
//             onTap: () {
//               Navigator.pop(context); // 👈 Oculta el Drawer
//               widget.onItemSelected("inicio");
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.add),
//             title: const Text("Crear Tarea"),
//             onTap: () {
//               Navigator.pop(context);
//               widget.onItemSelected("tarea");
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.task),
//             title: const Text("Tareas"),
//             onTap: () {
//               Navigator.pop(context);
//               widget.onItemSelected("tareas");
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text("Cerrar Sesión"),
//             onTap: () {
//               context.push('/');
//               widget.onItemSelected("config");
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todolistapp/3-presentation/providers/login_providers.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final Function(String) onItemSelected;
  const CustomDrawer({super.key, required this.onItemSelected});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final loginInfo = ref.watch(loginProvider.notifier).info;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          // ---------- HEADER ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  // colorScheme.primary.withOpacity(.95),
                  Colors.blue.withOpacity(.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.15),
                        Colors.white.withOpacity(.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(.15),
                    child: Icon(
                      Icons.person,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Nombre y detalle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loginInfo["nombres"]} ${loginInfo["apellidos"]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${loginInfo["usuario"]}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${loginInfo["area"]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      
          // ---------- MENÚ ----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected('inicio');
                  },
                ),
                _DrawerItem(
                  icon: Icons.add_circle_rounded,
                  label: 'Crear Tarea',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected('tarea');
                  },
                ),
                _DrawerItem(
                  icon: Icons.task_alt_rounded,
                  label: 'Tareas',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected('tareas');
                  },
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 24,
                  color: Theme.of(context).dividerColor.withOpacity(.6),
                ),
                // Puedes agregar más secciones aquí si quieres
              ],
            ),
          ),
      
          // ---------- CERRAR SESIÓN (fijo abajo) ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar Sesión',
              isDestructive: true,
              onTap: () {
                // Navega al login y notifica si quieres
                context.push('/');
                widget.onItemSelected('logout');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(.05)
        : cs.surfaceVariant.withOpacity(.5);

    final fg = isDestructive ? Colors.red : cs.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(.35)
                  : cs.outlineVariant.withOpacity(.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.red : Colors.blue), //cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
