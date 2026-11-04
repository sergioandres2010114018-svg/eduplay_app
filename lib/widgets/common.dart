import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme.dart';

class CreditFooter extends StatelessWidget {
  const CreditFooter({super.key, this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Text(creditText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: light ? Colors.white70 : C.navy.withValues(alpha: 0.7))),
      );
}

/// Reproductor de video desde assets (con controles).
class AssetVideo extends StatefulWidget {
  const AssetVideo(this.asset, {super.key, this.autoPlay = false});
  final String asset;
  final bool autoPlay;
  @override
  State<AssetVideo> createState() => _AssetVideoState();
}

class _AssetVideoState extends State<AssetVideo> {
  late VideoPlayerController _vc;
  ChewieController? _cc;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _vc = VideoPlayerController.asset(widget.asset);
    _vc.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _cc = ChewieController(
          videoPlayerController: _vc,
          autoPlay: widget.autoPlay,
          looping: false,
          aspectRatio: _vc.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
              playedColor: C.green, handleColor: C.yellow, backgroundColor: Colors.black26),
        );
      });
    }).catchError((_) {
      if (mounted) setState(() => _error = true);
    });
  }

  @override
  void dispose() {
    _cc?.dispose();
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(child: Text('No se pudo cargar el video')));
    }
    if (_cc == null) {
      return const AspectRatio(
          aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(aspectRatio: _vc.value.aspectRatio, child: Chewie(controller: _cc!)));
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.navy)),
      );
}

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
