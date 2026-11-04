#!/usr/bin/env bash
# Genera la carpeta android/ con Flutter y le aplica la configuración de EduPlay.
# Se ejecuta automáticamente en GitHub Actions; también puedes correrlo en tu PC.
set -euo pipefail

flutter create --platforms=android --org com.senatic --project-name eduplay .

MANIFEST=android/app/src/main/AndroidManifest.xml

# Permiso de internet (necesario para login y base de datos en la versión release)
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <application|' "$MANIFEST"
fi

# Nombre visible de la app
sed -i -E 's|android:label="[^"]*"|android:label="EduPlay"|' "$MANIFEST"

# minSdk 23 (requerido por Firebase)
for f in android/app/build.gradle android/app/build.gradle.kts; do
  if [ -f "$f" ]; then
    sed -i -E 's/minSdk(Version)?[[:space:]]*=?[[:space:]]*flutter\.minSdkVersion/minSdk = 23/' "$f"
  fi
done

echo "Android listo (applicationId: com.senatic.eduplay)"
