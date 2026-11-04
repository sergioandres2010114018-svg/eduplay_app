import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AttemptResult {
  final int points, correct, total;
  final List<BadgeInfo> newBadges;
  AttemptResult(this.points, this.correct, this.total, this.newBadges);
}

class AppState extends ChangeNotifier {
  AppState(this.content) {
    _auth.authStateChanges().listen(_onAuth);
  }

  final Content content;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  User? user;
  Profile? profile;
  bool ready = false; // ya se conoce si hay sesión o no

  void _onAuth(User? u) {
    user = u;
    _sub?.cancel();
    if (u == null) {
      profile = null;
      ready = true;
      notifyListeners();
      return;
    }
    _sub = _db.collection('users').doc(u.uid).snapshots().listen((snap) async {
      if (snap.exists) {
        profile = Profile.fromMap(u.uid, snap.data()!);
        ready = true;
        notifyListeners();
      } else {
        // Usuario autenticado sin documento (caso raro): se crea.
        await _createDoc(u, u.displayName ?? 'Estudiante', 9);
      }
    }, onError: (e) {
      ready = true;
      notifyListeners();
    });
  }

  Future<void> _createDoc(User u, String name, int grade) {
    return _db.collection('users').doc(u.uid).set({
      'name': name,
      'email': u.email,
      'grade': grade,
      'points': 0,
      'streak': 0,
      'lastActive': '',
      'badges': <String>[],
      'areas': <String>[],
      'completed': <String, dynamic>{},
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String authError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'El correo no es válido.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'email-already-in-use':
          return 'Ese correo ya está registrado. Inicia sesión.';
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres.';
        case 'network-request-failed':
          return 'Sin conexión a internet. Inténtalo de nuevo.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera un momento.';
        default:
          return 'Error: ${e.message ?? e.code}';
      }
    }
    return 'Ocurrió un error inesperado: $e';
  }

  Future<void> register(String name, String email, String pass, int grade) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: pass);
    await cred.user!.updateDisplayName(name.trim());
    await _createDoc(cred.user!, name.trim(), grade);
  }

  Future<void> login(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: pass);

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> logout() => _auth.signOut();

  Future<void> setGrade(int g) =>
      _db.collection('users').doc(user!.uid).update({'grade': g});

  Stream<QuerySnapshot<Map<String, dynamic>>> leaderboard() =>
      _db.collection('ranking').orderBy('points', descending: true).limit(20).snapshots();

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Guarda un reto o simulacro y calcula puntos, racha e insignias.
  Future<AttemptResult> saveAttempt({
    required String kind, // 'reto' | 'simulacro'
    String? lessonId,
    String? areaId,
    required int correct,
    required int total,
  }) async {
    final ref = _db.collection('users').doc(user!.uid);
    final earned = correct * 10 + (correct == total && total > 0 ? 20 : 0);
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final newBadges = <BadgeInfo>[];

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final m = snap.data() ?? <String, dynamic>{};
      final badges = List<String>.from(m['badges'] ?? const []);
      final areas = List<String>.from(m['areas'] ?? const []);
      final completed = Map<String, dynamic>.from(m['completed'] ?? const {});
      final attempts = ((m['attempts'] ?? 0) as int) + 1;
      final points = ((m['points'] ?? 0) as int) + earned;

      // racha
      final today = DateTime.now();
      final last = (m['lastActive'] ?? '') as String;
      var streak = (m['streak'] ?? 0) as int;
      if (last != _day(today)) {
        streak = last == _day(today.subtract(const Duration(days: 1))) ? streak + 1 : 1;
      }

      if (kind == 'reto' && lessonId != null) {
        final prev = (completed[lessonId] ?? 0) as int;
        if (pct > prev) completed[lessonId] = pct;
        if (areaId != null && !areas.contains(areaId)) areas.add(areaId);
      }

      void give(String id) {
        if (!badges.contains(id)) {
          badges.add(id);
          newBadges.add(allBadges.firstWhere((b) => b.id == id));
        }
      }

      if (attempts >= 1) give('primer_reto');
      if (correct == total && total > 0) give('perfecto');
      if (streak >= 3) give('racha3');
      if (areas.length >= 4) give('explorador');
      if (attempts >= 10) give('constante');
      if (kind == 'simulacro') give('simulacro');
      if (points ~/ 100 + 1 >= 5) give('nivel5');

      tx.set(_db.collection('ranking').doc(user!.uid), {
        'name': ((m['name'] ?? 'Estudiante') as String).split(' ').first,
        'grade': m['grade'] ?? 9,
        'points': points,
      });

      tx.set(ref, {
        'points': points,
        'streak': streak,
        'lastActive': _day(today),
        'badges': badges,
        'areas': areas,
        'completed': completed,
        'attempts': attempts,
      }, SetOptions(merge: true));
    });

    await ref.collection('attempts').add({
      'kind': kind,
      'lessonId': lessonId,
      'areaId': areaId,
      'correct': correct,
      'total': total,
      'points': earned,
      'at': FieldValue.serverTimestamp(),
    });
    return AttemptResult(earned, correct, total, newBadges);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
