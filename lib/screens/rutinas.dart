import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

void openRun(BuildContext context, String id) {
  Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RoutineRunPage(id)));
}

void openRoutineEdit(BuildContext context, String id) {
  Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RoutineEditPage(id)));
}

class RutinasScreen extends StatelessWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionGuide('Rutinas'),
          for (final r in app.d.routines) _RoutineCard(r),
          Btn('+ Nueva rutina', () {
            final r = app.newRoutine();
            openRoutineEdit(context, r.id);
          }, kind: 'ghost', block: true),
          const Muted(
            'Las rutinas se reinician solas cada día.',
            small: true,
            padding: EdgeInsets.fromLTRB(4, 12, 4, 0),
          ),
        ],
      );
    });
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine r;
  const _RoutineCard(this.r);

  @override
  Widget build(BuildContext context) {
    final dn = app.rDone(r);
    final tot = r.steps.fold<int>(0, (a, s) => a + s.min);
    final full = r.steps.isNotEmpty && dn.length >= r.steps.length;
    final streak = app.rStreak(r);
    final info = StringBuffer();
    if (r.at.isNotEmpty) info.write('${r.at} · ${daysLabel(r.days)} · ');
    info.write('${r.steps.length} pasos');
    if (tot > 0) info.write(' · unos ${minsLabel(tot)}');
    if (r.auto) info.write(' · avanza sola');
    if (streak > 0) info.write(' · racha de $streak');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IcoBox(r.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    Muted(info.toString(), small: true),
                  ],
                ),
              ),
              if (app.routineNow(r)) const NowChip(),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(r.steps.isEmpty ? 0.0 : dn.length / r.steps.length,
              teal: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Btn(
                  full
                      ? '✓ Completada'
                      : (dn.isNotEmpty ? 'Continuar' : '▶ Empezar'),
                  () => openRun(context, r.id),
                  kind: 'primary',
                ),
              ),
              const SizedBox(width: 8),
              Btn('Editar', () => openRoutineEdit(context, r.id)),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Rutina en marcha
// =====================================================================

class RoutineRunPage extends StatefulWidget {
  final String id;
  const RoutineRunPage(this.id, {super.key});

  @override
  State<RoutineRunPage> createState() => _RoutineRunPageState();
}

class _RoutineRunPageState extends State<RoutineRunPage> {
  @override
  void dispose() {
    app.closeRun();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final r = app.getRoutine(widget.id);
      if (r == null) {
        return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
      }
      final p = context.pal;
      final cur = app.syncRun(r);
      final dn = app.rDone(r);
      final kids = <Widget>[];

      if (cur != null) {
        final left = app.runLeft();
        final over = left < 0;
        final paused = app.runPausedLeft != null;
        final lim = math.max(1, cur.min * 60000);
        final ms = app.routineRemaining(r);
        final end = DateTime.now().add(Duration(milliseconds: ms));
        kids.add(AppCard(
          color: p.accentSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Muted('Paso ${r.steps.indexOf(cur) + 1} de ${r.steps.length}',
                  small: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(cur.t,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.25)),
              ),
              if (cur.min > 0) ...[
                Text(
                  (over ? '+${fmt(-left)}' : fmt(left)) +
                      (paused
                          ? ' · en pausa'
                          : (over ? ' · sin prisa, termina tranquilo' : '')),
                  style: TextStyle(
                    fontSize: over ? 22 : 36,
                    fontWeight: FontWeight.w700,
                    color: over ? p.gold : p.text,
                  ),
                ),
                const SizedBox(height: 8),
                ProgressBar(1 - left / lim, teal: true, over: over),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Btn(
                        '✓ Hecho', () => app.routineMark(r.id, cur.id, true),
                        kind: 'primary'),
                  ),
                  if (cur.min > 0) ...[
                    const SizedBox(width: 8),
                    Btn('+1 min', app.runPlus),
                    const SizedBox(width: 8),
                    Btn(paused ? '▶' : '❚❚', app.runPauseToggle),
                  ],
                  const SizedBox(width: 4),
                  Btn('Saltar', () => app.routineMark(r.id, cur.id, false),
                      kind: 'ghost'),
                ],
              ),
              if (ms > 0)
                Muted(
                  'Te quedan ~${minsLabel((ms / 60000).ceil())} · terminas hacia las ${pad(end.hour)}:${pad(end.minute)}',
                  small: true,
                  padding: const EdgeInsets.only(top: 10),
                ),
            ],
          ),
        ));
      } else {
        final s = app.rStreak(r);
        kids.add(AppCard(
          child: Column(
            children: [
              Icon(Icons.star_rounded, size: 72, color: p.gold),
              const Text('¡Rutina completada!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              Muted('Racha: $s ${s == 1 ? 'día' : 'días'} seguidos',
                  small: true,
                  padding: const EdgeInsets.symmetric(vertical: 6)),
              Btn('Reiniciar', () => app.routineReset(r.id), kind: 'ghost'),
            ],
          ),
        ));
      }

      // lista de pasos con hora estimada
      var acc = 0;
      final base = r.at.isNotEmpty ? parseHm(r.at) : null;
      final rows = <Widget>[];
      for (final s in r.steps) {
        final on = dn.contains(s.id);
        String lbl = '';
        if (base != null) {
          final x = DateTime(2000, 1, 1, base[0], base[1] + acc);
          lbl = '${pad(x.hour)}:${pad(x.minute)}';
        }
        acc += s.min;
        rows.add(Row(
          children: [
            CheckCircle(on, () => app.routineToggle(r.id, s.id), small: true),
            if (lbl.isNotEmpty)
              SizedBox(
                width: 46,
                child:
                    Text(lbl, style: TextStyle(fontSize: 13, color: p.muted)),
              ),
            Expanded(
              child: Text(
                s.t,
                style: TextStyle(
                  fontSize: 15,
                  color: on ? p.muted : p.text,
                  decoration: on ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (s.min > 0) Muted('${s.min}′', small: true),
          ],
        ));
      }
      kids.add(AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(children: rows),
      ));

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(iconFor(r.icon), color: p.accent),
              const SizedBox(width: 10),
              Expanded(child: Text(r.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
          backgroundColor: p.bg,
          surfaceTintColor: p.bg,
          actions: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => openRoutineEdit(context, r.id),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: kids),
      );
    });
  }
}

// =====================================================================
//  Editar rutina
// =====================================================================

class RoutineEditPage extends StatelessWidget {
  final String id;
  const RoutineEditPage(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final r = app.getRoutine(id);
      final p = context.pal;
      if (r == null) {
        return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar rutina'),
          backgroundColor: p.bg,
          surfaceTintColor: p.bg,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Listo'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SaveField(
                    initial: r.name,
                    hint: 'Nombre de la rutina',
                    onSave: (v) {
                      if (v.trim().isNotEmpty) {
                        r.name = v.trim();
                        app.commit();
                      }
                    },
                  ),
                  const FieldLabel('Icono'),
                  ChipWrap([
                    for (final k in routineIcons)
                      ChipOpt('', r.icon == k, () {
                        r.icon = k;
                        app.commit();
                      },
                          leading: Icon(iconFor(k),
                              size: 22,
                              color: r.icon == k ? p.accent : p.text)),
                  ]),
                  const FieldLabel('Hora de inicio (opcional)'),
                  Row(
                    children: [
                      Btn(r.at.isEmpty ? 'Elegir hora' : r.at, () async {
                        final hm = parseHm(r.at.isEmpty ? '08:00' : r.at);
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: hm[0], minute: hm[1]),
                        );
                        if (t != null) {
                          r.at = '${pad(t.hour)}:${pad(t.minute)}';
                          if (r.days.isEmpty) r.days = [0, 1, 2, 3, 4, 5, 6];
                          app.commit();
                        }
                      }),
                      if (r.at.isNotEmpty)
                        LinkBtn('Quitar hora', () {
                          r.at = '';
                          app.commit();
                        }),
                    ],
                  ),
                  const FieldLabel('Días'),
                  ChipWrap([
                    for (final n in const [1, 2, 3, 4, 5, 6, 0])
                      ChipOpt(dowLetters[n], r.days.contains(n), () {
                        if (r.days.contains(n)) {
                          r.days.remove(n);
                        } else {
                          r.days.add(n);
                        }
                        app.commit();
                      }),
                  ]),
                  const SizedBox(height: 8),
                  SwitchRow(
                      'Avanzar sola al acabar el tiempo de cada paso', r.auto,
                      (v) {
                    r.auto = v;
                    app.commit();
                  }),
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const H2('Pasos'),
                  const Muted('Minutos de cada paso (0 = solo marcar)',
                      small: true, padding: EdgeInsets.only(bottom: 8)),
                  for (var i = 0; i < r.steps.length; i++) _StepEditor(r, i),
                  const SizedBox(height: 6),
                  _AddStep(r),
                ],
              ),
            ),
            Btn('Borrar rutina', () {
              askConfirm(context, '¿Borrar esta rutina?', () {
                app.deleteRoutine(r.id);
                Navigator.of(context).pop();
              });
            }, kind: 'ghost', block: true),
          ],
        ),
      );
    });
  }
}

class _StepEditor extends StatelessWidget {
  final Routine r;
  final int i;
  const _StepEditor(this.r, this.i);

  @override
  Widget build(BuildContext context) {
    final s = r.steps[i];
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SaveField(
            key: ValueKey<String>('st-${s.id}'),
            initial: s.t,
            hint: 'Paso',
            onSave: (v) {
              if (v.trim().isNotEmpty) {
                s.t = v.trim();
                app.commit();
              }
            },
          ),
          Row(
            children: [
              NumStepper(s.min, 0, 180, (v) {
                s.min = v;
                app.commit();
              }),
              const Muted(' min', small: true),
              const Spacer(),
              IconButton(
                tooltip: 'Subir paso',
                onPressed: i > 0
                    ? () {
                        final x = r.steps.removeAt(i);
                        r.steps.insert(i - 1, x);
                        app.commit();
                      }
                    : null,
                icon: Icon(Icons.arrow_upward, color: p.muted),
              ),
              IconButton(
                tooltip: 'Borrar paso',
                onPressed: () {
                  r.steps.removeAt(i);
                  app.commit();
                },
                icon: Icon(Icons.close, color: p.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddStep extends StatefulWidget {
  final Routine r;
  const _AddStep(this.r);

  @override
  State<_AddStep> createState() => _AddStepState();
}

class _AddStepState extends State<_AddStep> {
  final TextEditingController _c = TextEditingController();
  int _min = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    widget.r.steps.add(RStep(t: t, min: _min));
    _c.clear();
    app.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Nuevo paso'),
        TextField(
          controller: _c,
          textCapitalization: TextCapitalization.sentences,
          decoration: inputDeco(context, 'Escribe el paso'),
          onSubmitted: (_) => _add(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            NumStepper(_min, 0, 180, (v) => setState(() => _min = v)),
            const Muted(' min', small: true),
            const Spacer(),
            Btn('+ Añadir', _add, kind: 'teal', small: true),
          ],
        ),
      ],
    );
  }
}
