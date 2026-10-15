# Enfoque (Flutter)

Versión Flutter de Enfoque, tu app de apoyo para el TDAH: tareas troceables, foco con bosque,
rutinas, hábitos, mascota, meditación, respiración, diario, viajes y retos. Funciona sin conexión
y guarda todo en el propio dispositivo.

> **Aviso importante.** Este proyecto se ha escrito sin poder compilarlo (en el entorno donde se
> generó no hay acceso a los servidores de Flutter). Se ha comprobado la sintaxis de todos los
> archivos y se ha revisado a mano, pero la primera vez que lo compiles puede aparecer algún error
> pequeño. Pégame el mensaje y lo corrijo.

## Requisitos

- Flutter 3.22 o superior (Dart 3.4+). <https://docs.flutter.dev/get-started/install>
- Para Android: Android Studio o solo las herramientas de línea de comandos del SDK.
- Para iPhone: un Mac con Xcode.

## Puesta en marcha

Desde esta carpeta:

```bash
# 1. Genera las carpetas de plataforma (android, ios, web) sin tocar lib/ ni pubspec.yaml
flutter create --platforms=android,ios,web --project-name enfoque .

# 2. Descarga las dependencias
flutter pub get

# 3. (opcional) Comprueba el código y los tests
flutter analyze
flutter test

# 4. Ejecuta en un móvil conectado o en un emulador
flutter run
```

Si `flutter create` te pregunta o reemplaza `lib/main.dart`, vuelve a copiar el de este proyecto.

## Instalarla en el móvil

- **Android (APK):** `flutter build apk --release`. El archivo queda en
  `build/app/outputs/flutter-apk/app-release.apk`; cópialo al móvil e instálalo
  (hay que permitir "instalar apps de origen desconocido").
  Con el móvil conectado también vale `flutter install`.
- **iPhone:** abre `ios/Runner.xcworkspace` en Xcode, firma con tu Apple ID y ejecútala en tu iPhone.
- **Como web instalable (PWA):** `flutter build web --release` y sirve la carpeta `build/web`
  por HTTPS; luego "Añadir a pantalla de inicio".

Para que el nombre en el móvil sea "Enfoque", edita `android:label` en
`android/app/src/main/AndroidManifest.xml` y `CFBundleDisplayName` en `ios/Runner/Info.plist`.

## Copia de seguridad compatible con la versión web

El formato de datos es el mismo que el de la versión web. En **Más → Ajustes → Copia de seguridad**
puedes copiar tus datos y, en la otra versión, pegarlos y pulsar «Restaurar» (y al revés).

## Qué hay y dónde

```
lib/
  main.dart        arranque, pestañas, tema, ciclo de vida
  state.dart       toda la lógica (puntos, mascota, temporizador, rutinas…)
  data.dart        modelos, contenido (viajes, retos, meditaciones…) y migraciones
  art.dart         dibujos SVG: mascota, 11 árboles y escena del bosque
  audio.dart       sonidos generados en código (campana, cuenco, ruido)
  widgets.dart     componentes comunes
  events.dart      mensajes, celebraciones y confeti
  screens/         una pantalla por archivo
test/data_test.dart
```

## Diferencias con la versión web

- Los avisos (temporizador, recordatorios, rutinas) salen dentro de la app con sonido y vibración.
  **No hay notificaciones del sistema**: para algo importante, ponlo también como alarma del móvil.
- El modo bosque marchita el árbol si la app pasa a segundo plano más de los segundos de margen
  que elijas en Ajustes (la pantalla se mantiene encendida mientras crece).
- La importación de copias es pegando el texto (no hay selector de archivos).

## Dependencias

`shared_preferences` (guardado), `wakelock_plus` (pantalla encendida), `audioplayers` (sonidos),
`flutter_svg` (dibujos). La fuente Lexend va incluida en `assets/fonts` (licencia OFL).
