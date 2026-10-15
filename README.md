# Enfoque (Flutter)

Versión Flutter de Enfoque, tu app de apoyo para el TDAH: tareas troceables, foco y casa por habitaciones,
rutinas, hábitos, mascota, meditación, respiración, diario y retos. Funciona sin conexión
y guarda todo en el propio dispositivo.

La versión actual cuenta con 14 pruebas automatizadas que comprueban los datos, la navegación,
las tareas de casa y la confirmación al terminar el temporizador, incluida la vista móvil.

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
  data.dart        modelos, contenido (retos, meditaciones…) y migraciones
  art.dart         dibujos SVG: mascota, 11 árboles y escena del bosque
  audio.dart       sonidos generados en código (campana, cuenco, ruido)
  widgets.dart     componentes comunes
  guides.dart      explicaciones dentro de cada sección
  house.dart       habitaciones y catálogo de tareas reales
  events.dart      mensajes, celebraciones y confeti
  screens/         una pantalla por archivo
test/data_test.dart
```

## Diferencias con la versión web

- Los avisos (temporizador, recordatorios, rutinas) salen dentro de la app con sonido y vibración.
  **No hay notificaciones del sistema**: para algo importante, ponlo también como alarma del móvil.
- Mi casa se ordena al confirmar tareas reales. Puedes salir de la app sin perder progreso.
- La importación de copias es pegando el texto (no hay selector de archivos).

## Dependencias

`shared_preferences` (guardado), `wakelock_plus` (pantalla encendida), `audioplayers` (sonidos),
`flutter_svg` (dibujos). La fuente Lexend va incluida en `assets/fonts` (licencia OFL).

## Navegación simplificada

- **Hoy:** energía, siguiente tarea y captura de ideas.
- **Foco:** temporizador y descansos para tus tareas, incluidas las de casa.
- **Mi espacio:** tareas, rutinas y pausas; el resto se despliega en Más herramientas.
- Cada sección incluye una explicación y un desplegable «Cómo se usa».
- Viajes se ha retirado de las pantallas y de la lógica de uso. Su formato de datos antiguo
  se conserva únicamente para poder leer y exportar copias previas sin perder información.

## Mi casa

Cocina, dormitorio, salón, baño y lavadero proponen acciones reales para ordenar, cocinar,
limpiar, poner lavadoras, tender, doblar y planchar. Puedes añadirlas
sin duplicados a Tareas, iniciar un bloque de foco o marcarlas después de hacerlas.
La ilustración se ordena con las acciones confirmadas; el temporizador no las completa.
Durante el bloque se muestra una vista previa animada del plano cenital de la habitación.
Al terminar se pregunta si has hecho la tarea: solo la confirmación guarda el cambio.
Cada habitación permite iniciar otra ronda sin borrar el historial. El progreso se guarda
en las copias de seguridad. Los datos antiguos del bosque se conservan por compatibilidad.
