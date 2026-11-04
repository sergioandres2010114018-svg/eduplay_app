import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'area_screen.dart';
import 'quiz_screen.dart';
import 'ranking_tab.dart';
import 'video_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    const titles = ['EduPlay', 'Aprender', 'Simulacro ICFES', 'Ranking', 'Mi perfil'];
    final pages = [
      HomeTab(goTo: (i) => setState(() => _i = i)),
      const LearnTab(),
      const SimulacroTab(),
      const RankingTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_i]),
        actions: [
          IconButton(
              tooltip: 'Acerca de',
              icon: const Icon(Icons.info_outline),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())))
        ],
      ),
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (i) => setState(() => _i = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Aprender'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Simulacro'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.goTo});
  final void Function(int) goTo;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.profile!;
    final done = p.completed.length;
    final total = s.content.totalLessons;
    return ListView(padding: const EdgeInsets.all(16), children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Image.asset('assets/images/banner.jpg', width: double.infinity, height: 170, fit: BoxFit.cover),
          Positioned(
              left: 18, bottom: 14, right: 18,
              child: Text('¡Hola, ${p.name.split(' ').first}!',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        _stat('Nivel', '${p.level}', Icons.military_tech, C.yellow),
        _stat('Puntos', '${p.points}', Icons.stars, C.blue),
        _stat('Racha', '${p.streak} d', Icons.local_fire_department, C.red),
      ]),
      const SizedBox(height: 10),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Siguiente nivel: ${100 - p.levelProgress} puntos',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: p.levelProgress / 100, minHeight: 10, color: C.green,
                borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 12),
            Text('Lecciones completadas: $done de $total'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
                value: total == 0 ? 0 : done / total, minHeight: 10, color: C.blue,
                borderRadius: BorderRadius.circular(8)),
          ]),
        ),
      ),
      const SectionTitle('Video de bienvenida'),
      GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VideoScreen('assets/videos/intro_eduplay.mp4', 'Bienvenido a EduPlay'))),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Image.asset('assets/images/logo.png', width: 56),
            title: const Text('Conoce EduPlay', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Aprende jugando, supera cada reto'),
            trailing: const Icon(Icons.play_circle_fill, size: 40, color: C.green),
          ),
        ),
      ),
      const SectionTitle('Empieza a jugar'),
      Row(children: [
        Expanded(child: _action('Aprender', Icons.menu_book, C.blue, () => goTo(1))),
        const SizedBox(width: 10),
        Expanded(child: _action('Simulacro', Icons.timer, C.red, () => goTo(2))),
      ]),
      const SizedBox(height: 10),
      const Card(
        child: ListTile(
          leading: Icon(Icons.lightbulb, color: C.yellow, size: 34),
          title: Text('Consejo del día'),
          subtitle: Text('Estudiar 15 a 20 minutos, de 3 a 5 veces por semana, rinde más que estudiar todo el día antes del examen.'),
        ),
      ),
      const CreditFooter(),
    ]);
  }

  Widget _stat(String l, String v, IconData i, Color c) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Icon(i, color: c, size: 30),
              Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(l, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      );

  Widget _action(String t, IconData i, Color c, VoidCallback f) => InkWell(
        onTap: f,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Icon(i, color: Colors.white, size: 34),
            const SizedBox(height: 6),
            Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        ),
      );
}

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.profile!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Grado ${p.grade}° · elige un área',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.navy)),
      const SizedBox(height: 10),
      ...s.content.areas.map((a) {
        final lessons = a.forGrade(p.grade);
        final done = lessons.where((l) => p.completed.containsKey(l.id)).length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AreaScreen(a))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(children: [
                Image.asset(a.image, width: double.infinity, height: 130, fit: BoxFit.cover),
                Container(
                    height: 130,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent
                    ]))),
                Positioned(
                  left: 16, top: 16, bottom: 16,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Icon(areaIcon(a.icon), color: Colors.white, size: 28),
                    Text(a.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('$done de ${lessons.length} lecciones', style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ]),
            ),
          ),
        );
      }),
      const CreditFooter(),
    ]);
  }
}

class SimulacroTab extends StatelessWidget {
  const SimulacroTab({super.key});

  void _start(BuildContext context, AppState s) {
    final p = s.profile!;
    final qs = <Question>[];
    for (final a in s.content.areas) {
      for (final l in a.forGrade(p.grade)) {
        qs.addAll(l.questions);
      }
    }
    qs.shuffle();
    final picked = qs.take(20).toList();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => QuizScreen(
                title: 'Simulacro tipo ICFES · Grado ${p.grade}°',
                questions: picked,
                kind: 'simulacro',
                timeLimit: 20 * 60)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: Image.asset('assets/images/logo.png', height: 150)),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Simulacro cronometrado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 8),
            Text('Preguntas de las 4 áreas para tu grado (${s.profile!.grade}°).'),
            const SizedBox(height: 6),
            const Text('• Hasta 20 preguntas de selección múltiple'),
            const Text('• Tiempo máximo: 20 minutos'),
            const Text('• Retroalimentación inmediata en cada pregunta'),
            const Text('• Ganas 10 puntos por respuesta correcta'),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: () => _start(context, s),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Comenzar simulacro')),
          ]),
        ),
      ),
      const CreditFooter(),
    ]);
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.profile!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
                radius: 32, backgroundColor: C.navy,
                child: Text(p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: Colors.white))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(p.email, style: const TextStyle(fontSize: 12)),
              Text('Nivel ${p.level} · ${p.points} puntos'),
            ])),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        const Text('Mi grado:', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 9, label: Text('9°')),
            ButtonSegment(value: 10, label: Text('10°')),
            ButtonSegment(value: 11, label: Text('11°')),
          ],
          selected: {p.grade},
          onSelectionChanged: (v) => s.setGrade(v.first),
        ),
      ]),
      const SectionTitle('Mi progreso por área'),
      ...s.content.areas.map((a) {
        final ls = a.lessons;
        final done = ls.where((l) => p.completed.containsKey(l.id)).toList();
        final avg = done.isEmpty
            ? 0
            : (done.map((l) => p.completed[l.id]!).reduce((x, y) => x + y) / done.length).round();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(areaIcon(a.icon), color: hexColor(a.color)),
                const SizedBox(width: 8),
                Expanded(child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                Text('${done.length}/${ls.length} · prom. $avg%'),
              ]),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                  value: ls.isEmpty ? 0 : done.length / ls.length,
                  color: hexColor(a.color), minHeight: 8, borderRadius: BorderRadius.circular(8)),
            ]),
          ),
        );
      }),
      const SectionTitle('Mis insignias'),
      Wrap(
        spacing: 10, runSpacing: 10,
        children: allBadges.map((b) {
          final has = p.badges.contains(b.id);
          return Tooltip(
            message: b.desc,
            child: Container(
              width: 100, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: has ? Colors.white : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: has ? C.yellow : Colors.transparent, width: 2)),
              child: Column(children: [
                Opacity(opacity: has ? 1 : 0.3, child: Text(b.emoji, style: const TextStyle(fontSize: 30))),
                Text(b.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
          onPressed: () async {
            await s.logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión')),
      const CreditFooter(),
    ]);
  }
}
