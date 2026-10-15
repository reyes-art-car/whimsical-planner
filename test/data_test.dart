import 'dart:convert';

import 'package:enfoque/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los datos por defecto sobreviven a un guardado y una carga', () {
    final a = AppData.defaults();
    final txt = jsonEncode(a.toJson());
    final b = AppData.fromJson(jsonDecode(txt) as Map<String, dynamic>);
    expect(b.routines.length, 3);
    expect(b.tasks.length, a.tasks.length);
    expect(b.habits.length, 3);
  });

  test('la rutina de mañana incluye salir a andar y la de noche leer y escribir', () {
    final a = AppData.defaults();
    final m = a.routines.firstWhere((r) => r.icon == 'sol');
    final n = a.routines.firstWhere((r) => r.icon == 'luna');
    expect(m.steps.any((s) => s.t == 'Salir a andar' && s.min == 30), isTrue);
    expect(n.steps.any((s) => s.t == 'Leer'), isTrue);
    expect(n.steps.any((s) => s.t == 'Escribir'), isTrue);
  });

  test('una copia antigua de la web recibe los pasos nuevos', () {
    final old = <String, dynamic>{
      'tasks': <dynamic>[],
      'routines': [
        {
          'id': 'r1',
          'emoji': '☀️',
          'name': 'Rutina de mañana',
          'steps': [
            {'id': 's1', 't': 'Desayunar', 'min': 15},
          ],
        },
        {
          'id': 'r2',
          'emoji': '🌙',
          'name': 'Rutina de noche',
          'steps': [
            {'id': 's2', 't': 'Lavarme los dientes', 'min': 3},
          ],
        },
      ],
    };
    final d = AppData.fromJson(old);
    expect(d.routines[0].icon, 'sol');
    expect(d.routines[0].steps.map((s) => s.t), contains('Salir a andar'));
    expect(d.routines[1].steps.map((s) => s.t), containsAll(['Escribir', 'Leer']));
  });

  test('el árbol automático crece con los minutos', () {
    expect(treeKindFor(5), 'brote');
    expect(treeKindFor(25), 'pino');
    expect(treeKindFor(60), 'cerezo');
  });
}
