import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen(this.lesson, this.color, {super.key});
  final Lesson lesson;
  final Color color;

  Future<void> _youtube(BuildContext context) async {
    final uri = Uri.parse(
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(lesson.yt)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) snack(context, 'No se pudo abrir el enlace.');
    } catch (_) {
      if (context.mounted) snack(context, 'No se pudo abrir el enlace.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(lesson.title), backgroundColor: color),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          AssetVideo(lesson.video),
          const SectionTitle('Idea clave'),
          Text(lesson.summary, style: const TextStyle(fontSize: 16, height: 1.45)),
          const SectionTitle('Recuerda'),
          ...lesson.points.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 15.5, height: 1.4))),
                ]),
              )),
          const SectionTitle('Ejemplo'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: C.yellow.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.yellow)),
            child: Text(lesson.example, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
              onPressed: () => _youtube(context),
              icon: const Icon(Icons.smart_display, color: C.red),
              label: const Text('Ver más videos en YouTube')),
          const SizedBox(height: 10),
          FilledButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => QuizScreen(
                            title: lesson.title,
                            questions: [...lesson.questions]..shuffle(),
                            kind: 'reto',
                            lessonId: lesson.id,
                            areaId: lesson.areaId,
                          ))),
              icon: const Icon(Icons.sports_esports),
              label: const Text('¡Iniciar reto!')),
          const CreditFooter(),
        ]),
      );
}
