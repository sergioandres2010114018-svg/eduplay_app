import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';

class AreaScreen extends StatefulWidget {
  const AreaScreen(this.area, {super.key});
  final Area area;
  @override
  State<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  int? _grade;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().profile!;
    final g = _grade ?? p.grade;
    final a = widget.area;
    final color = hexColor(a.color);
    final lessons = a.forGrade(g);
    return Scaffold(
      appBar: AppBar(title: Text(a.name), backgroundColor: color),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(a.image, height: 140, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 12),
        Center(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 9, label: Text('Grado 9°')),
              ButtonSegment(value: 10, label: Text('Grado 10°')),
              ButtonSegment(value: 11, label: Text('Grado 11°')),
            ],
            selected: {g},
            onSelectionChanged: (v) => setState(() => _grade = v.first),
          ),
        ),
        const SectionTitle('Lecciones y retos'),
        ...lessons.map((l) {
          final best = p.completed[l.id];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                  backgroundColor: best == null ? Colors.grey.shade300 : C.green,
                  child: Icon(best == null ? Icons.play_arrow : Icons.check, color: Colors.white)),
              title: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(best == null ? 'Sin completar · ${l.questions.length} preguntas' : 'Mejor resultado: $best%'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LessonScreen(l, color))),
            ),
          );
        }),
        const CreditFooter(),
      ]),
    );
  }
}
