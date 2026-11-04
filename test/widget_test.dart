import 'package:flutter_test/flutter_test.dart';
import 'package:eduplay/models/models.dart';

void main() {
  test('nivel y progreso se calculan por puntos', () {
    final p = Profile(
        uid: 'u', name: 'Ana', email: 'a@a.com', grade: 9, points: 250,
        streak: 1, badges: const [], completed: const {}, attempts: 1);
    expect(p.level, 3);
    expect(p.levelProgress, 50);
  });
}
