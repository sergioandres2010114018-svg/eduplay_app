import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/models.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final content = await Content.load();
  if (!DefaultFirebaseOptions.isConfigured) {
    runApp(const ConfigMissingApp());
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(ChangeNotifierProvider(
    create: (_) => AppState(content),
    child: const EduPlayApp(),
  ));
}

class EduPlayApp extends StatelessWidget {
  const EduPlayApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'EduPlay',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(next: AuthGate()),
      );
}

class ConfigMissingApp extends StatelessWidget {
  const ConfigMissingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/images/logo.png', height: 180),
              const SizedBox(height: 16),
              const Text('Falta configurar Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Edita lib/firebase_options.dart con los datos de tu proyecto Firebase y vuelve a compilar.',
                  textAlign: TextAlign.center),
            ]),
          )),
        ),
      );
}
