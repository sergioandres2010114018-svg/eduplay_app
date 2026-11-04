# EduPlay – Aprende jugando, supera cada reto

Aplicación móvil educativa (Android) para estudiantes de los grados 9°, 10° y 11°.
Proyecto productivo **SenaTic** – I.E.T.D. Pijiño del Carmen (Magdalena) – SENA Centro Acuícola y Agroindustrial de Gaira.

> **App móvil creada por: Ana Lia Tovar, IE Pijiño y proyecto SenaTic**

## Funciones (según el documento del proyecto)
- Registro e inicio de sesión (Firebase Authentication); los usuarios quedan guardados en Firebase.
- Selección de grado (9°, 10°, 11°) y de área: Matemáticas, Física, Español/Lectura crítica y Ciencias Sociales.
- 24 lecciones con explicación, ejemplo, **video** e imágenes, y 72 preguntas con retroalimentación inmediata.
- Retos por lección, **simulacro tipo ICFES cronometrado** (20 min).
- Puntos, niveles, rachas, insignias, tabla de clasificación y panel de progreso.
- Acerca de: misión, visión, valores, organigrama y equipo.

## Estructura
```
lib/            código Dart (pantallas, servicios, modelos)
assets/         logo, imágenes, videos y banco de preguntas (data/content.json)
tools/          script que genera el contenido y los videos
scripts/        prepare_android.sh (crea la carpeta android/)
.github/        workflow que construye el APK automáticamente
firestore.rules reglas de seguridad de la base de datos
```

## Paso 1 – Crear el proyecto en Firebase (gratis)
1. Entra a https://console.firebase.google.com → **Agregar proyecto** → nombre `eduplay`.
2. **Authentication** → Comenzar → habilita **Correo electrónico/Contraseña**.
3. **Firestore Database** → Crear base de datos → modo producción → ubicación `southamerica-east1` (o la más cercana).
4. Pestaña **Reglas** → pega el contenido de `firestore.rules` → Publicar.
5. **Configuración del proyecto → Tus apps → Android** (ícono de Android):
   - Nombre del paquete: `com.senatic.eduplay`
   - Registra la app (puedes omitir el resto de pasos y no necesitas descargar `google-services.json`).
   - Copia los valores: `apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket` (en «Configuración del proyecto → General → Tus apps → SDK setup and configuration»).
6. Pega esos 5 datos en `lib/firebase_options.dart`.

## Paso 2 – Subir a GitHub
1. Crea un repositorio nuevo en https://github.com (ej. `eduplay-app`).
2. Sube **todo el contenido de esta carpeta** (en la web: *Add file → Upload files*, arrastra las carpetas; asegúrate de incluir `.github/`).
3. Ve a la pestaña **Actions**; el workflow **Construir APK de EduPlay** corre solo (≈10 min). Si no, entra a él y pulsa **Run workflow**.
4. Al terminar, abre la ejecución y descarga el artefacto **EduPlay-APK** (zip con `app-release.apk`).

## Paso 3 – Instalar
Pasa el `app-release.apk` al celular, permite «instalar apps desconocidas» y ábrelo.

## Ver los usuarios registrados
- Firebase Console → **Authentication → Users**: correo, fecha de registro y UID.
- Firebase Console → **Firestore → users**: nombre, grado, puntos, insignias y progreso de cada estudiante.

## Compilar en tu computador (opcional)
```bash
bash scripts/prepare_android.sh
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## Agregar o editar contenido
Edita `tools/build_content.py` (lecciones y preguntas) y ejecuta `python3 tools/build_content.py`
(requiere Pillow y ffmpeg). Regenera `assets/data/content.json` y los videos.

## Protección de datos
Se guardan nombre, correo, grado y progreso. El ranking público solo muestra el primer nombre, grado y puntos.
Para menores de edad se solicita autorización del acudiente (Ley 1581 de 2012).

Todos los contenidos académicos deben ser validados por los docentes de área antes de la versión final.
