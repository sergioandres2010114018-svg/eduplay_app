import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RankingTab extends StatelessWidget {
  const RankingTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return StreamBuilder(
      stream: s.leaderboard(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('No se pudo cargar el ranking. Revisa tu conexión.'));
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Los 20 mejores jugadores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.navy)),
          const SizedBox(height: 8),
          ...List.generate(docs.length, (i) {
            final d = docs[i].data();
            final me = docs[i].id == s.user?.uid;
            final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}';
            return Card(
              color: me ? C.yellow.withValues(alpha: 0.25) : Colors.white,
              child: ListTile(
                leading: Text(medal, style: const TextStyle(fontSize: 22)),
                title: Text('${((d['name'] ?? 'Estudiante') as String).split(' ').first}${me ? ' (tú)' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Grado ${d['grade'] ?? '-'}° · Nivel ${((d['points'] ?? 0) as int) ~/ 100 + 1}'),
                trailing: Text('${d['points'] ?? 0} pts',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: C.blue)),
              ),
            );
          }),
          const CreditFooter(),
        ]);
      },
    );
  }
}
