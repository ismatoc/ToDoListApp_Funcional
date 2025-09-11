import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Tile pequeño (120-140px) con thumbnail + botón ▶.
/// Al tocar, abre el diálogo con el reproductor y controles.
class VideoThumbTileVP extends StatefulWidget {
  final File file;
  final String label;
  final double size; // lado del tile cuadrado (default 120)
  const VideoThumbTileVP({
    super.key,
    required this.file,
    required this.label,
    this.size = 120,
  });

  @override
  State<VideoThumbTileVP> createState() => _VideoThumbTileVPState();
}

class _VideoThumbTileVPState extends State<VideoThumbTileVP> {
  Uint8List? _thumb;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _genThumb();
  }

  Future<void> _genThumb() async {
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.file.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 480,
        quality: 70,
        timeMs: 800, // fotograma temprano
      );
      setState(() {
        _thumb = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openPlayer() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => VideoPlayerDialogVP(file: widget.file, title: widget.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openPlayer,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: s, height: s,
              color: Colors.black12,
              child: _loading
                  ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
                  : (_thumb != null
                      ? Image.memory(_thumb!, width: s, height: s, fit: BoxFit.cover)
                      : const Icon(Icons.videocam_rounded, color: Colors.black45, size: 36)),
            ),
            // botón play
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo con video_player puro + overlay de controles (play/pause, progreso, replay).
class VideoPlayerDialogVP extends StatefulWidget {
  final File file;
  final String title;
  const VideoPlayerDialogVP({super.key, required this.file, required this.title});

  @override
  State<VideoPlayerDialogVP> createState() => _VideoPlayerDialogVPState();
}

class _VideoPlayerDialogVPState extends State<VideoPlayerDialogVP> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() => _ready = true);
      });
    _controller.addListener(_onTick);
  }

  void _onTick() {
    final v = _controller.value;
    if (v.isInitialized && v.position >= v.duration && !_controller.value.isPlaying && !_controller.value.isBuffering) {
      if (!_ended) setState(() => _ended = true); // terminó
    } else if (_ended && v.isPlaying) {
      setState(() => _ended = false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_ready) return;
    if (_ended) {
      _controller.seekTo(Duration.zero);
      _controller.play();
      setState(() => _ended = false);
    } else {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    }
    setState(() {});
  }

  void _replay() {
    _controller.seekTo(Duration.zero);
    _controller.play();
    setState(() => _ended = false);
  }

  String _fmt(Duration d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
    }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white))),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Player con aspecto real del video
              if (_ready)
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),

                      // Overlay central: Play/Pause/Replay
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _togglePlay,
                        child: AnimatedOpacity(
                          opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            color: Colors.black26,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(
                                  _ended ? Icons.replay : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 56,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Barra inferior de progreso con scrub + tiempos + botones
                      Positioned(
                        left: 0, right: 0, bottom: 0,
                        child: _BottomControls(
                          controller: _controller,
                          ended: _ended,
                          onToggle: _togglePlay,
                          onReplay: _replay,
                          fmt: _fmt,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool ended;
  final VoidCallback onToggle;
  final VoidCallback onReplay;
  final String Function(Duration) fmt;

  const _BottomControls({
    required this.controller,
    required this.ended,
    required this.onToggle,
    required this.onReplay,
    required this.fmt,
  });

  @override
  State<_BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<_BottomControls> {
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final v = widget.controller.value;
    final dur = v.duration.inMilliseconds
    .toDouble()
    .clamp(1.0, double.infinity) as double;

final pos = v.position.inMilliseconds
    .toDouble()
    .clamp(0.0, dur) as double;

    _dragValue = pos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Color(0xD0000000), Color(0x00000000)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.ended ? widget.onReplay : widget.onToggle,
            icon: Icon(
              widget.ended ? Icons.replay : (v.isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
            ),
          ),
          Text(widget.fmt(v.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _dragValue,
                min: 0.0,
                max: dur,
                onChanged: (val) => setState(() => _dragValue = val),
                onChangeEnd: (val) =>
                    widget.controller.seekTo(Duration(milliseconds: val.round())),
              ),
            ),
          ),
          Text(widget.fmt(v.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}







// Requiere tener definido en el mismo proyecto:
// import 'video_player_dialog_vp.dart'; // o donde tengas VideoPlayerDialogVP
// class VideoPlayerDialogVP extends StatefulWidget { ... }

class VideosGridCompact extends StatelessWidget {
  final List<File> files;
  final double baseThumb;   // tamaño “objetivo” por celda para calcular columnas
  final double spacing;
  const VideosGridCompact({
    super.key,
    required this.files,
    this.baseThumb = 88,     // igual que imágenes compactas
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final maxW = c.maxWidth;

      // Calcula columnas según ancho disponible
      int cols = ((maxW + spacing) / (baseThumb + spacing)).floor();
      if (cols < 2) cols = 2;
      if (cols > 5) cols = 5;

      // Tamaño real de cada celda (cuadrado)
      final cell = (maxW - spacing * (cols - 1)) / cols;

      // Caso 1 video: mostrar un rect 16:9 más vistoso
      if (files.length == 1) {
        return _VideoThumbRect(
          file: files.first,
          label: 'Video 1',
          onTap: () => _openDialog(context, files.first, 'Video 1'),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1, // cuadrado
        ),
        itemBuilder: (_, i) {
          final file = files[i];
          return SizedBox(
            width: cell, height: cell,
            child: _VideoThumbSquare(
              file: file,
              size: cell,
              label: 'Video ${i + 1}',
              onTap: () => _openDialog(context, file, 'Video ${i + 1}'),
            ),
          );
        },
      );
    });
  }

  void _openDialog(BuildContext context, File file, String label) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => VideoPlayerDialogVP(file: file, title: label),
    );
  }
}

/// Thumb cuadrado (como imagen) con overlay ▶
class _VideoThumbSquare extends StatefulWidget {
  final File file;
  final String label;
  final double size;
  final VoidCallback onTap;
  const _VideoThumbSquare({
    required this.file,
    required this.label,
    required this.size,
    required this.onTap,
  });

  @override
  State<_VideoThumbSquare> createState() => _VideoThumbSquareState();
}

class _VideoThumbSquareState extends State<_VideoThumbSquare> {
  Uint8List? _thumb;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _genThumb();
  }

  Future<void> _genThumb() async {
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.file.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 480,
        quality: 70,
        timeMs: 800,
      );
      setState(() { _thumb = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: s, height: s, color: Colors.black12,
              child: _loading
                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : (_thumb != null
                      ? Image.memory(_thumb!, width: s, height: s, fit: BoxFit.cover)
                      : const Icon(Icons.videocam_rounded, color: Colors.black45, size: 32)),
            ),
            // overlay play
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumb 16:9 para el caso de un solo video (se ve más “hero”)
class _VideoThumbRect extends StatefulWidget {
  final File file;
  final String label;
  final VoidCallback onTap;
  const _VideoThumbRect({required this.file, required this.label, required this.onTap});

  @override
  State<_VideoThumbRect> createState() => _VideoThumbRectState();
}

class _VideoThumbRectState extends State<_VideoThumbRect> {
  Uint8List? _thumb;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _genThumb();
  }

  Future<void> _genThumb() async {
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.file.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 800,
        quality: 70,
        timeMs: 800,
      );
      setState(() { _thumb = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black12,
                child: _loading
                    ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
                    : (_thumb != null
                        ? Image.memory(_thumb!, fit: BoxFit.cover)
                        : const Icon(Icons.videocam_rounded, color: Colors.black45, size: 36)),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(32)),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
