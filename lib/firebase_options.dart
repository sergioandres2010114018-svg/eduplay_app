// ============================================================
//  CONFIGURACIÓN DE FIREBASE  (rellena estos 5 datos una sola vez)
//  Consola Firebase > Configuración del proyecto > Tus apps > Android
//  (nombre de paquete: com.senatic.eduplay)
// ============================================================
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PEGA_AQUI_TU_API_KEY',
    appId: 'PEGA_AQUI_TU_APP_ID', // formato 1:123456789:android:abc123
    messagingSenderId: 'PEGA_AQUI_TU_SENDER_ID',
    projectId: 'PEGA_AQUI_TU_PROJECT_ID',
    storageBucket: 'PEGA_AQUI_TU_PROJECT_ID.firebasestorage.app',
  );

  static bool get isConfigured => !android.apiKey.startsWith('PEGA_');
}
