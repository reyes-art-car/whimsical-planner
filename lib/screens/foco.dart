import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'tareas.dart';
import '../house.dart';
import 'casa.dart';

class FocoScreen extends StatefulWidget {
  const FocoScreen({super.key});

  @override
  State<FocoScreen> createState() => _FocoScreenState();
}

class _FocoScreenState extends State<FocoScreen> {
  String _task = '';
  int _min = app.d.settings.focus;
  bool _pomo = false;

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final t = app.d.timer;
      final st = app.d.settings;
      final p = context.pal;
      final children = <Widget>[const SectionGuide('Foco')];

      if (t == null) {
        final pend = app.rankedTasks();
        final value = pend.any((x) => x.id == _task) ? _task : '';
        children.add(AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Nuevo bloque'),
              const FieldLabel('¿En qué vas a trabajar?'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: p.surface,
                  items: [
                    const DropdownMenuItem<String>(
                        value: '', child: Text('Sin tarea concreta')),
                    for (final x in pend)
                      DropdownMenuItem<String>(
                        value: x.id,
                        child: Text(x.title, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _task = v ?? ''),
                ),
              ),
              const FieldLabel('Duración'),
              ChipWrap([
                for (final m in const [5, 10, 15, 25, 45, 60])
                  ChipOpt('$m min', _min == m, () => setState(() => _min = m)),
              ]),
              const FieldLabel('Modo'),
              ChipWrap([
                ChipOpt(
                    'Un bloque', !_pomo, () => setState(() => _pomo = false)),
                ChipOpt('Pomodoro (con descansos)', _pomo,
                    () => setState(() => _pomo = true)),
              ]),
              const SizedBox(height: 16),
              Btn('▶ Empezar', () {
                app.startTimer(_task.isEmpty ? null : _task, _min, _pomo);
              }, kind: 'primary', block: true),
              const Muted(
                '¿Te cuesta arrancar? Prueba solo 5 minutos. Empezar es lo más difícil.',
                small: true,
                padding: EdgeInsets.only(top: 10),
              ),
            ],
          ),
        ));
      } else {
        final task = app.getTask(t.taskId);
        final label = {
              'focus': 'Foco',
              'short': 'Descanso corto',
              'long': 'Descanso largo'
            }[t.kind] ??
            'Foco';
        final left = app.rem(t);
        final frac = clampD(left / t.dur, 0.0, 1.0);
        final chore = homeChore(task?.homeChoreId);
        final room = chore == null
            ? null
            : homeRooms.firstWhere(
                (r) => r.chores.any((c) => c.id == chore.id),
              );
        children.add(AppCard(
          child: Column(
            children: [
              Muted(
                  '$label${t.pomo ? ' · bloque ${t.kind == 'focus' ? t.cycle + 1 : t.cycle}' : ''}',
                  small: true),
              const SizedBox(height: 10),
              if (room != null && t.kind == 'focus') ...[
                H2('Ordenando: ${room.name}'),
                RoomFocusScene(
                  key: ValueKey(t.taskId),
                  room: room,
                  ordered: room.chores
                          .where((c) => app.d.homeDone.containsKey(c.id))
                          .length +
                      (task!.done ? 0.0 : 1 - frac),
                ),
                const Muted(
                    'Vista previa · el cambio se guarda cuando confirmes la tarea.',
                    small: true,
                    align: TextAlign.center),
                const SizedBox(height: 12),
              ],
              Ring(
                value: frac,
                color: t.kind == 'focus' ? p.accent : p.teal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(fmt(left),
                        style: const TextStyle(
                            fontSize: 46, fontWeight: FontWeight.w700)),
                    Muted(
                        t.end != null
                            ? 'en marcha'
                            : (t.fresh ? 'preparado' : 'en pausa'),
                        small: true),
                  ],
                ),
              ),
              if (task != null && t.kind == 'focus') ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(task.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w600)),
                ),
                nextSubRow(context, task),
              ],
              if (t.kind != 'focus')
                const Muted(
                  'Levántate, bebe agua, mira por la ventana. Mejor sin pantalla.',
                  small: true,
                  align: TextAlign.center,
                  padding: EdgeInsets.only(top: 10),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (t.end != null)
                    Btn('Pausar', app.pauseT,
                        kind: 'primary', icon: Icons.pause)
                  else
                    Btn(t.fresh ? 'Empezar' : 'Reanudar', app.resumeT,
                        kind: 'primary', icon: Icons.play_arrow),
                  Btn('+5 min', app.add5),
                  Btn(t.kind == 'focus' ? 'Terminar' : 'Saltar descanso',
                      app.stopT,
                      kind: 'ghost'),
                ],
              ),
              if (t.pomo) LinkBtn('Cerrar la sesión pomodoro', app.endAll),
              if (task != null && t.kind == 'focus')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Btn('✓ He terminado la tarea',
                      () => app.completeTask(task.id),
                      kind: 'ghost', block: true),
                ),
            ],
          ),
        ));

        final pet = app.d.pet;
        if (pet != null && t.kind == 'focus') {
          children.add(AppCard(
            child: Row(
              children: [
                PetView(pet, t.end != null ? 'ok' : 'happy', size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: pet.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' se concentra contigo.\n'),
                      TextSpan(
                          text: 'Al terminar ganaréis bayas juntos.',
                          style: TextStyle(color: p.muted)),
                    ]),
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ));
        }
      }

      children.add(AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const H2('Ruido de fondo'),
            ChipWrap([
              for (final e in const [
                ['off', 'Apagado'],
                ['white', 'Blanco'],
                ['pink', 'Rosa'],
                ['brown', 'Marrón'],
              ])
                ChipOpt(e[1], app.noiseType == e[0], () => app.setNoise(e[0])),
            ]),
            const FieldLabel('Volumen'),
            Slider(
              value: clampD(st.noiseVol, 0.0, 1.0),
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: app.setNoiseVol,
            ),
            const Muted(
              'El ruido marrón es el favorito de mucha gente con TDAH. Funciona sin conexión.',
              small: true,
            ),
          ],
        ),
      ));

      children.add(AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const H2('Compañero de foco'),
            const Muted(
              'Como trabajar con alguien al lado (body doubling): te pregunto cada cierto tiempo si sigues en ello.',
              small: true,
              padding: EdgeInsets.only(bottom: 10),
            ),
            ChipWrap([
              for (final m in const [0, 5, 10, 15])
                ChipOpt(m > 0 ? 'Cada $m min' : 'Apagado', st.checkin == m,
                    () => app.setSetting((s) => s.checkin = m)),
            ]),
          ],
        ),
      ));

      return ListView(padding: const EdgeInsets.all(16), children: children);
    });
  }
}
