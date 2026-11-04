import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.kind,
    this.lessonId,
    this.areaId,
    this.timeLimit,
  });
  final String title, kind;
  final String? lessonId, areaId;
  final List<Question> questions;
  final int? timeLimit; // segundos

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0, _correct = 0;
  int? _sel;
  bool _saving = false;
  Timer? _timer;
  late int _left = widget.timeLimit ?? 0;

  @override
  void initState() {
    super.initState();
    if (widget.timeLimit != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _left--);
        if (_left <= 0) _finish();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Question get _q => widget.questions[_i];

  void _answer(int o) {
    if (_sel != null) return;
    setState(() {
      _sel = o;
      if (o == _q.answer) _correct++;
    });
  }

  void _next() {
    if (_i + 1 >= widget.questions.length) {
      _finish();
    } else {
      setState(() {
        _i++;
        _sel = null;
      });
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    _saving = true;
    _timer?.cancel();
    final s = context.read<AppState>();
    AttemptResult? res;
    try {
      res = await s.saveAttempt(
          kind: widget.kind,
          lessonId: widget.lessonId,
          areaId: widget.areaId,
          correct: _correct,
          total: widget.questions.length);
    } catch (_) {
      if (mounted) snack(context, 'No se pudo guardar el resultado (¿sin conexión?).');
    }
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ResultScreen(
                title: widget.title,
                correct: _correct,
                total: widget.questions.length,
                result: res)));
  }

  Future<bool> _confirmExit() async {
    final r = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('¿Salir del reto?'),
              content: const Text('Perderás el avance de este intento.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Seguir')),
                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salir')),
              ],
            ));
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    final answered = _sel != null;
    final mm = (_left ~/ 60).toString().padLeft(2, '0');
    final ss = (_left % 60).toString().padLeft(2, '0');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 16)),
          actions: [
            if (widget.timeLimit != null)
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('$mm:$ss',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: _left < 60 ? C.yellow : Colors.white)),
              ))
          ],
        ),
        body: Column(children: [
          LinearProgressIndicator(
              value: (_i + (answered ? 1 : 0)) / widget.questions.length, color: C.green, minHeight: 6),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(18), children: [
              Text('Pregunta ${_i + 1} de ${widget.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: C.blue)),
              const SizedBox(height: 8),
              Text(q.q, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.navy, height: 1.3)),
              const SizedBox(height: 16),
              ...List.generate(q.options.length, (o) {
                Color bg = Colors.white, border = Colors.grey.shade300;
                IconData? icon;
                if (answered) {
                  if (o == q.answer) {
                    bg = C.green.withValues(alpha: 0.18);
                    border = C.green;
                    icon = Icons.check_circle;
                  } else if (o == _sel) {
                    bg = C.red.withValues(alpha: 0.15);
                    border = C.red;
                    icon = Icons.cancel;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _answer(o),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 2)),
                      child: Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: C.navy,
                            child: Text(String.fromCharCode(65 + o),
                                style: const TextStyle(color: Colors.white, fontSize: 13))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[o], style: const TextStyle(fontSize: 16))),
                        if (icon != null) Icon(icon, color: o == q.answer ? C.green : C.red),
                      ]),
                    ),
                  ),
                );
              }),
              if (answered)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: C.yellow.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                  child: Text(
                      '${_sel == q.answer ? '¡Correcto! 🎉' : 'Casi 💡'}\n${q.explanation}',
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: FilledButton(
                onPressed: answered ? _next : null,
                child: Text(_i + 1 >= widget.questions.length ? 'Terminar' : 'Siguiente')),
          ),
          const CreditFooter(),
        ]),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen(
      {super.key, required this.title, required this.correct, required this.total, this.result});
  final String title;
  final int correct, total;
  final AttemptResult? result;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final msg = pct >= 80 ? '¡Excelente trabajo!' : pct >= 50 ? '¡Vas muy bien, sigue practicando!' : 'No te rindas, repasa la lección e inténtalo de nuevo.';
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(24), children: [
              Center(child: Image.asset('assets/images/logo.png', height: 130)),
              Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))),
              const SizedBox(height: 14),
              Center(
                child: Text('$pct%',
                    style: TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w900,
                        color: pct >= 50 ? C.green : C.red)),
              ),
              Center(child: Text('$correct de $total respuestas correctas',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
              Center(child: Text(msg, textAlign: TextAlign.center)),
              const SizedBox(height: 16),
              if (result != null)
                Card(
                    child: ListTile(
                        leading: const Icon(Icons.stars, color: C.yellow, size: 36),
                        title: Text('+${result!.points} puntos',
                            style: const TextStyle(fontWeight: FontWeight.w800)))),
              ...?result?.newBadges.map((b) => Card(
                  color: C.yellow.withValues(alpha: 0.25),
                  child: ListTile(
                      leading: Text(b.emoji, style: const TextStyle(fontSize: 30)),
                      title: Text('Nueva insignia: ${b.name}'),
                      subtitle: Text(b.desc)))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Volver al inicio')),
          ),
          const CreditFooter(),
        ]),
      ),
    );
  }
}
