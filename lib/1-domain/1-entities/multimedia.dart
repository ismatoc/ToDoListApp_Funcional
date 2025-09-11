// 1-domain/1-entities/upload_result.dart
class UploadResult {
  final bool ok;
  final int totalFotos;
  final int totalVideos;

  UploadResult({required this.ok, required this.totalFotos, required this.totalVideos});

  factory UploadResult.fromJson(Map<String, dynamic> json) => UploadResult(
    ok: json['ok'] == true,
    totalFotos: (json['total_fotos'] ?? 0) as int,
    totalVideos: (json['total_videos'] ?? 0) as int,
  );

  static UploadResult empty() => UploadResult(ok: false, totalFotos: 0, totalVideos: 0);
}
