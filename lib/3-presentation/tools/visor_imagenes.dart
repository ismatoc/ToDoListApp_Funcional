



// import 'dart:io';
// import 'package:flutter/material.dart';

// class ImagesGridCompact extends StatelessWidget {
//   final List<File> files;
//   final double thumb;    // tamaño del lado de cada miniatura
//   final double spacing;  // separación entre celdas
//   const ImagesGridCompact({
//     super.key,
//     required this.files,
//     this.thumb = 88,
//     this.spacing = 6,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (_, c) {
//         final maxW = c.maxWidth;

//         // ¿Cuántas columnas caben?
//         // Sumamos spacing una vez para que la división sea menos estricta y quepan más columnas.
//         int cols = ((maxW + spacing) / (thumb + spacing)).floor();
//         if (cols < 2) cols = 2; // al menos 2 columnas
//         if (cols > 5) cols = 5; // no más de 5 (opcional)

//         // Caso especial: 1 sola imagen => hazla más vistosa (relación 4:3)
//         // if (files.length == 1) {
//         //   return ClipRRect(
//         //     borderRadius: BorderRadius.circular(12),
//         //     child: AspectRatio(
//         //       aspectRatio: 4 / 3,
//         //       child: Image.file(files.first, fit: BoxFit.cover),
//         //     ),
//         //   );
//         // }

//         // Grid compacto, sin scroll propio (deja scrollear al ListView del chat)
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: files.length,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: cols,
//             crossAxisSpacing: spacing,
//             mainAxisSpacing: spacing,
//             childAspectRatio: 1, // cuadrado
//           ),
//           itemBuilder: (_, i) {
//             final f = files[i];
//             return ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: GestureDetector(
//                 onTap: () {
//                   // visor simple: si ya tienes tu viewer, llámalo aquí
//                   showDialog(
//                     context: context,
//                     barrierColor: Colors.black87,
//                     builder: (_) => _SimpleImageViewer(file: f),
//                   );
//                 },
//                 child: Image.file(f, fit: BoxFit.cover),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _SimpleImageViewer extends StatelessWidget {
//   final File file;
//   const _SimpleImageViewer({required this.file});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: Container(
//         color: Colors.black,
//         alignment: Alignment.center,
//         child: InteractiveViewer(
//           minScale: 0.6,
//           maxScale: 5,
//           child: Image.file(file, fit: BoxFit.contain),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class ImagesGridCompact extends StatelessWidget {
  final List<String> urls;
  final double thumb;
  final double spacing;

  const ImagesGridCompact({
    super.key,
    required this.urls,
    this.thumb = 88,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final maxW = c.maxWidth;
        int cols = ((maxW + spacing) / (thumb + spacing)).floor();
        if (cols < 2) cols = 2;
        if (cols > 5) cols = 5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: urls.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: (_, i) {
            final url = urls[i];
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black87,
                    builder: (_) => _SimpleImageViewer(url: url),
                  );
                },
                child: Image.network(url, fit: BoxFit.cover),
              ),
            );
          },
        );
      },
    );
  }
}

class _SimpleImageViewer extends StatelessWidget {
  final String url;
  const _SimpleImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 5,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
