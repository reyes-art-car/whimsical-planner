// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enfoque/main.dart';
import 'package:enfoque/data.dart';
import 'package:enfoque/guides.dart';
import 'package:enfoque/screens/mas.dart';
import 'package:enfoque/state.dart';
import 'package:enfoque/screens/casa.dart';
import 'package:enfoque/house.dart';
import 'package:enfoque/util.dart';

void main() {
  setUp(() {
    app.d = AppData.defaults();
    app.tab = 0;
    app.skip = 0;
    app.d.settings.sound = false;
    app.d.settings.vibe = false;
  });

  testWidgets('Inicio sencillo, ayuda y navegación a tareas', (tester) async {
    await tester.pumpWidget(const EnfoqueApp());
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Tu bosque'), findsNothing);
    expect(find.text('Hoy llevas'), findsNothing);
    await tester.tap(find.text('Cómo se usa'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1. Elige tu energía'), findsOneWidget);
    final tasks = find.text('Ver y añadir tareas');
    await tester.scrollUntilVisible(tasks, 200);
    await tester.pumpAndSettle();
    await tester.ensureVisible(tasks);
    await tester.pumpAndSettle();
    await tester.tap(tasks);
    await tester.pumpAndSettle();
    expect(find.text('Nueva tarea…'), findsOneWidget);
    expect(find.text('Cómo se usa'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foco'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo bloque'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mi espacio agrupa las herramientas opcionales', (tester) async {
    await tester.pumpWidget(const EnfoqueApp());
    await tester.tap(find.text('Mi espacio'));
    await tester.pumpAndSettle();
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Rutinas'), findsOneWidget);
    expect(find.text('Viajes'), findsNothing);
    expect(find.text('Mi mascota').hitTestable(), findsNothing);
    final more = find.text('Más herramientas');
    await tester.scrollUntilVisible(more, 200);
    await tester.pumpAndSettle();
    await tester.ensureVisible(more);
    await tester.pumpAndSettle();
    await tester.tap(more);
    await tester.pumpAndSettle();
    final pet = find.text('Mi mascota');
    await tester.scrollUntilVisible(pet, 150);
    await tester.pumpAndSettle();
    await tester.ensureVisible(pet);
    await tester.pumpAndSettle();
    await tester.tap(pet);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Cómo se usa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'la casa funciona en móvil y solo progresa al confirmar una acción',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const EnfoqueApp());
    await tester.tap(find.byType(HomeSummary));
    await tester.pumpAndSettle();
    expect(find.text('Cocina · 0 de ${homeRooms.first.chores.length}'),
        findsOneWidget);
    final confirm =
        find.byKey(ValueKey('complete-${homeRooms.first.chores.first.id}'));
    await tester.scrollUntilVisible(confirm, 150);
    await tester.pumpAndSettle();
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pump(const Duration(milliseconds: 500));
    expect(app.d.homeDone.length, 1);
    expect(find.text('Hecho en tu casa real'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  });

  for (final confirm in [false, true]) {
    testWidgets('el foco anima la casa y guarda solo al confirmar: $confirm',
        (tester) async {
      final room = homeRooms[1];
      final task = app.addHomeTask(room.chores.first.id)!;
      app.startTimer(task.id, 3, false);
      await tester.pumpWidget(const EnfoqueApp());
      expect(find.text('Ordenando: Dormitorio'), findsOneWidget);
      expect(tester.widget<RoomFocusScene>(find.byType(RoomFocusScene)).ordered,
          lessThan(0.1));
      app.d.timer!.end = nowMs() + 90000;
      app.commit();
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.widget<RoomFocusScene>(find.byType(RoomFocusScene)).ordered,
          closeTo(0.5, 0.02));
      app.pauseT();
      await tester.pump();
      final paused =
          tester.widget<RoomFocusScene>(find.byType(RoomFocusScene)).ordered;
      await tester.pump(const Duration(seconds: 2));
      expect(tester.widget<RoomFocusScene>(find.byType(RoomFocusScene)).ordered,
          paused);
      expect(app.d.homeDone, isEmpty);
      app.d.timer!.end = nowMs() - 1;
      app.loaded = true;
      app.tick();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('¿Has hecho esta tarea?'), findsOneWidget);
      expect(app.d.homeDone, isEmpty);
      await tester
          .tap(find.text(confirm ? 'Sí, ya lo he hecho' : 'Todavía no'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(task.done, confirm);
      expect(app.d.homeDone.containsKey(task.homeChoreId), confirm);
      if (confirm)
        expect(find.text('Dormitorio · 1 de ${room.chores.length}'),
            findsOneWidget);
      expect(tester.takeException(), isNull);
      app.loaded = false;
      app.d.timer = null;
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }

  test('todas las secciones del menú tienen una guía', () {
    for (final key in subTitle.keys) {
      expect(sectionGuides.containsKey(subTitle[key]), isTrue, reason: key);
    }
  });
}
