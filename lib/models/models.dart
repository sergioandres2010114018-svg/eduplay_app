import 'dart:convert';
import 'package:flutter/services.dart';

class Question {
  final String q, explanation, lessonId, areaId;
  final List<String> options;
  final int answer;
  Question(this.q, this.options, this.answer, this.explanation, this.lessonId, this.areaId);
}

class Lesson {
  final String id, title, summary, example, video, yt, areaId;
  final int grade;
  final List<String> points;
  final List<Question> questions;
  Lesson(this.id, this.title, this.summary, this.example, this.video, this.yt,
      this.areaId, this.grade, this.points, this.questions);
}

class Area {
  final String id, name, icon, color, image;
  final List<Lesson> lessons;
  Area(this.id, this.name, this.icon, this.color, this.image, this.lessons);
  List<Lesson> forGrade(int g) => lessons.where((l) => l.grade == g).toList();
}

class Content {
  final List<Area> areas;
  Content(this.areas);

  static Future<Content> load() async {
    final raw = await rootBundle.loadString('assets/data/content.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final areas = (j['areas'] as List).map((a) {
      final lessons = (a['lessons'] as List).map((l) {
        final qs = (l['questions'] as List)
            .map((q) => Question(q['q'], List<String>.from(q['o']), q['a'], q['e'], l['id'], a['id']))
            .toList();
        return Lesson(l['id'], l['title'], l['summary'], l['example'], l['video'],
            l['yt'], a['id'], l['grade'], List<String>.from(l['points']), qs);
      }).toList();
      return Area(a['id'], a['name'], a['icon'], a['color'], a['image'], lessons);
    }).toList();
    return Content(areas);
  }

  int get totalLessons => areas.fold(0, (s, a) => s + a.lessons.length);
  Lesson? lessonById(String id) {
    for (final a in areas) {
      for (final l in a.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }
}

class Profile {
  final String uid, name, email;
  final int grade, points, streak;
  final List<String> badges;
  final Map<String, int> completed; // lessonId -> mejor puntaje (%)
  final int attempts;
  Profile({
    required this.uid, required this.name, required this.email, required this.grade,
    required this.points, required this.streak, required this.badges,
    required this.completed, required this.attempts,
  });
  int get level => points ~/ 100 + 1;
  int get levelProgress => points % 100;

  factory Profile.fromMap(String uid, Map<String, dynamic> m) => Profile(
        uid: uid,
        name: (m['name'] ?? 'Estudiante') as String,
        email: (m['email'] ?? '') as String,
        grade: (m['grade'] ?? 9) as int,
        points: (m['points'] ?? 0) as int,
        streak: (m['streak'] ?? 0) as int,
        badges: List<String>.from(m['badges'] ?? const []),
        completed: Map<String, int>.from(
            (m['completed'] ?? const <String, dynamic>{}).map((k, v) => MapEntry(k as String, (v as num).toInt()))),
        attempts: (m['attempts'] ?? 0) as int,
      );
}

class BadgeInfo {
  final String id, name, desc;
  final String emoji;
  const BadgeInfo(this.id, this.name, this.desc, this.emoji);
}

const allBadges = [
  BadgeInfo('primer_reto', 'Primer reto', 'Completaste tu primer reto', '🚀'),
  BadgeInfo('perfecto', 'Puntaje perfecto', 'Respondiste todo bien en un reto', '🎯'),
  BadgeInfo('racha3', 'Racha de 3 días', 'Estudiaste 3 días seguidos', '🔥'),
  BadgeInfo('explorador', 'Explorador', 'Practicaste las 4 áreas', '🧭'),
  BadgeInfo('constante', 'Constante', 'Completaste 10 retos', '💪'),
  BadgeInfo('simulacro', 'Simulacro ICFES', 'Terminaste un simulacro', '📝'),
  BadgeInfo('nivel5', 'Nivel 5', 'Llegaste al nivel 5', '🏆'),
];
