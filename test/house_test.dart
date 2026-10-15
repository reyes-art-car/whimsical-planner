import 'dart:convert';

import 'package:enfoque/data.dart';
import 'package:enfoque/house.dart';
import 'package:enfoque/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppState state;
  setUp(() {
    state = AppState();
    state.d.settings.sound = false;
    state.d.settings.vibe = false;
  });
  tearDown(() => state.dispose());

  test('una acción real crea una sola tarea y ordena al confirmarla', () {
    final id = homeRooms.first.chores.first.id;
    final task = state.addHomeTask(id)!;
    expect(state.addHomeTask(id), same(task));
    expect(state.d.homeDone, isEmpty);
    state.completeTask(task.id);
    expect(state.d.homeDone[id], task.id);
    final points = state.d.points;
    state.completeTask(task.id);
    expect(state.d.points, points);
    state.undoTask(task.id);
    expect(state.d.homeDone, isEmpty);
  });

  test('la casa y su vínculo con tareas sobreviven a una copia', () {
    final chore = homeRooms.first.chores.first;
    final task = state.addHomeTask(chore.id)!;
    state.completeTask(task.id);
    final restored = AppData.fromJson(jsonDecode(jsonEncode(state.d.toJson())));
    expect(restored.homeDone[chore.id], task.id);
    expect(restored.tasks.firstWhere((t) => t.id == task.id).homeChoreId,
        chore.id);
    state.clearDone();
    expect(state.d.homeDone[chore.id], task.id);
    expect(AppData.fromJson({'tasks': []}).homeDone, isEmpty);
  });

  test(
      'otra ronda conserva historial y deshacer una tarea antigua no afecta a la nueva',
      () {
    final room = homeRooms.first;
    final chore = room.chores.first;
    final old = state.addHomeTask(chore.id)!;
    state.completeTask(old.id);
    state.resetHomeRoom(room.id);
    expect(old.done, isTrue);
    expect(state.d.homeDone, isEmpty);
    final current = state.addHomeTask(chore.id)!;
    expect(current.id, isNot(old.id));
    state.completeTask(current.id);
    state.undoTask(old.id);
    expect(state.d.homeDone[chore.id], current.id);
  });

  test('hacer foco y salir de la app no completa ni penaliza la casa', () {
    final task = state.addHomeTask(homeRooms.first.chores.first.id)!;
    state.startTimer(task.id, 3, false);
    state.onBackground();
    state.onForeground();
    expect(state.d.timer!.tree, isFalse);
    expect(state.d.timer!.dead, isFalse);
    expect(state.d.homeDone, isEmpty);
    expect(task.done, isFalse);
    state.d.timer = null;
  });
}
