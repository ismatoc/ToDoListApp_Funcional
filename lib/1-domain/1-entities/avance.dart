import 'dart:io';

class ChatMessage {
  final String id;
  final String userId;
  String text;
  dynamic fecha;   
  dynamic hora;
  int progreso;         // 0..100
  List<File> fotos;     // locales (tú luego las subes y reemplazas por URLs)
  List<File> videos;          // opcional

  ChatMessage({
    required this.id,
    required this.userId,
    required this.text,
    required this.fecha,
    required this.hora,
    required this.progreso,
    this.fotos = const [],
    this.videos = const [],
  });
}
