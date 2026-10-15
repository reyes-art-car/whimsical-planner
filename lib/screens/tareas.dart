import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Etiquetas de una tarea (energía, tiempo, pasos, foco).
Widget taskTags(BuildContext context, Task t) {
  final sd = t.subs.where((s) => s.done).length;
  return Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      Tag(energyLabel(context, t.energy)),
      if (t.est > 0) Tag(Text('⏱ ${t.est}′')),
      if (t.subs.isNotEmpty) Tag(Text('$sd/${t.subs.length} pasos')),
      if (t.spent > 0) Tag(Text('${t.spent}′ de foco')),
    ],
  );
}

/// Siguiente paso pendiente de una tarea, con casilla.
Widget nextSubRow(BuildContext context, Task t) {
  SubTask? s;
  for (final x in t.subs) {
    if (!x.done) {
      s = x;
      break;
    }
  }
  if (s == null) return const SizedBox.shrink();
  final step = s;
  final p = context.pal;
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: InkWell(
      onTap: () => app.toggleSub(t.id, step.id),
      child: Row(
        children: [
          CheckCircle(false, () => app.toggleSub(t.id, step.id), small: true),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Siguiente paso: ', style: TextStyle(color: p.muted)),
                  TextSpan(text: step.t),
                ],
              ),
              style: const TextStyle(fontSize: 14.5),
            ),
          ),
        ],
      ),
    ),
  );
}

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  String _filter = 'pend';
  String _energy = 'media';
  int _est = 15;
  final TextEditingController _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _add() {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    app.addTask(t, energy: _energy, est: _est);
    _title.clear();
    if (_filter == 'done') _filter = 'pend';
    setState(() {});
    app.toast('Tarea añadida');
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final f = _filter;
      final list = app.d.tasks.where((t) {
        if (f == 'done') return t.done;
        if (f == 'star') return !t.done && t.star;
        return !t.done;
      }).toList();
      if (f == 'done') {
        list.sort((a, b) => (b.doneAt ?? 0) - (a.doneAt ?? 0));
      } else {
        list.sort((a, b) {
          final s = (b.star ? 1 : 0) - (a.star ? 1 : 0);
          if (s != 0) return s;
          return a.created - b.created;
        });
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _title,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDeco(context, 'Nueva tarea…'),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Btn('Añadir', _add, kind: 'primary'),
                  ],
                ),
                const FieldLabel('Energía que pide'),
                ChipWrap([
                  for (final e in energyKeys)
                    ChipOpt(
                      energyName[e]!,
                      _energy == e,
                      () => setState(() => _energy = e),
                    ),
                ]),
                const FieldLabel('Tiempo aproximado'),
                ChipWrap([
                  for (final m in const [2, 5, 15, 30, 60])
                    ChipOpt('$m min', _est == m, () => setState(() => _est = m)),
                ]),
              ],
            ),
          ),
          ChipWrap([
            ChipOpt('Pendientes', f == 'pend', () => setState(() => _filter = 'pend')),
            ChipOpt('★ Prioridad', f == 'star', () => setState(() => _filter = 'star')),
            ChipOpt('Hechas', f == 'done', () => setState(() => _filter = 'done')),
          ]),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Muted(f == 'done'
                        ? 'Aún nada por aquí. ¡Ya llegará!'
                        : 'Nada pendiente aquí.'),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: p.line),
                        _TaskRow(list[i]),
                      ],
                    ],
                  ),
          ),
          if (f == 'done' && list.length > 3)
            Btn('Limpiar tareas hechas', () {
              askConfirm(
                context,
                '¿Quitar de la lista todas las tareas hechas? Tus estadísticas se mantienen.',
                app.clearDone,
              );
            }, kind: 'ghost', block: true),
          if (f != 'done')
            const Muted(
              'Toca una tarea para trocearla en pasos, cambiar su energía o empezar un bloque de foco.',
              small: true,
              padding: EdgeInsets.symmetric(horizontal: 4),
            ),
        ],
      );
    });
  }
}

class _TaskRow extends StatelessWidget {
  final Task t;
  const _TaskRow(this.t);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Opacity(
      opacity: t.done ? 0.65 : 1,
      child: Row(
        children: [
          CheckCircle(t.done, () => t.done ? app.undoTask(t.id) : app.completeTask(t.id)),
          Expanded(
            child: InkWell(
              onTap: () => showTaskSheet(context, t.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        decoration: t.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    taskTags(context, t),
                  ],
                ),
              ),
            ),
          ),
          if (!t.done)
            IconButton(
              onPressed: () => app.toggleStar(t.id),
              tooltip: 'Prioridad',
              icon: Icon(
                t.star ? Icons.star_rounded : Icons.star_border_rounded,
                color: t.star ? p.gold : p.muted,
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Hoja de edición de tarea
// =====================================================================

void showTaskSheet(BuildContext context, String id) {
  showSheet<void>(context, (sc) => Live((c) {
        final t = app.getTask(id);
        if (t == null) return const SizedBox.shrink();
        final p = c.pal;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Editar tarea',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                ),
                Btn('Cerrar', () => Navigator.of(sc).pop(), kind: 'ghost', small: true),
              ],
            ),
            const FieldLabel('Título'),
            SaveField(
              initial: t.title,
              onSave: (v) {
                if (v.trim().isNotEmpty) {
                  t.title = v.trim();
                  app.commit();
                }
              },
            ),
            const FieldLabel('Energía que pide'),
            ChipWrap([
              for (final e in energyKeys)
                ChipOpt(energyName[e]!, t.energy == e, () {
                  t.energy = e;
                  app.commit();
                }),
            ]),
            const FieldLabel('Tiempo estimado'),
            ChipWrap([
              for (final m in const [2, 5, 10, 15, 25, 45, 60, 90])
                ChipOpt('$m′', t.est == m, () {
                  t.est = m;
                  app.commit();
                }),
            ]),
            const FieldLabel('Pasos pequeños'),
            for (final s in t.subs)
              Row(
                children: [
                  CheckCircle(s.done, () => app.toggleSub(t.id, s.id), small: true),
                  Expanded(
                    child: Text(
                      s.t,
                      style: TextStyle(
                        fontSize: 15,
                        color: s.done ? p.muted : p.text,
                        decoration: s.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Borrar paso',
                    onPressed: () {
                      t.subs.removeWhere((x) => x.id == s.id);
                      app.commit();
                    },
                    icon: Icon(Icons.close, color: p.muted),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            QuickAdd(
              hint: '¿Cuál es el paso más pequeño posible?',
              button: '+',
              onSubmit: (v) {
                t.subs.add(SubTask(t: v));
                app.commit();
              },
            ),
            if (t.spent > 0)
              Muted(
                'Llevas ${t.spent} min de foco en esta tarea${t.est > 0 ? ' (estimaste ${t.est})' : ''}.',
                small: true,
                padding: const EdgeInsets.only(top: 10),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!t.done)
                  Expanded(
                    child: Btn('▶ Empezar foco', () {
                      final min = t.est > 0 ? math.min(t.est, app.d.settings.focus) : app.d.settings.focus;
                      app.startTimer(t.id, min, false);
                      Navigator.of(sc).popUntil((r) => r.isFirst);
                    }, kind: 'primary'),
                  ),
                if (!t.done) const SizedBox(width: 8),
                Btn('Borrar', () {
                  askConfirm(sc, '¿Borrar esta tarea?', () {
                    app.deleteTask(t.id);
                    Navigator.of(sc).pop();
                  });
                }),
              ],
            ),
          ],
        );
      }));
}

// =====================================================================
//  "Elige tú por mí"
// =====================================================================

void showPickSheet(BuildContext context) {
  showSheet<void>(context, (c) => const _PickSheet());
}

class _PickSheet extends StatefulWidget {
  const _PickSheet();

  @override
  State<_PickSheet> createState() => _PickSheetState();
}

class _PickSheetState extends State<_PickSheet> {
  String _text = '…';
  String? _picked;
  Timer? _iv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _roll());
  }

  @override
  void dispose() {
    _iv?.cancel();
    super.dispose();
  }

  void _roll() {
    _iv?.cancel();
    final e = app.todayEnergy();
    var c = app.pending();
    final f = c.where((t) => app.fit(t, e) >= 1).toList();
    if (e != null && f.isNotEmpty) c = f;
    if (c.isEmpty) return;
    var fin = c[math.Random().nextInt(c.length)];
    if (c.length > 1 && fin.id == _picked) {
      fin = c.firstWhere((t) => t.id != _picked);
    }
    _picked = fin.id;
    if (c.length < 2) {
      setState(() => _text = fin.title);
      return;
    }
    var i = 0;
    _iv = Timer.periodic(const Duration(milliseconds: 80), (tm) {
      i++;
      if (!mounted) {
        tm.cancel();
        return;
      }
      if (i > 14) {
        tm.cancel();
        setState(() => _text = fin.title);
        app.buzz();
      } else {
        setState(() => _text = c[i % c.length].title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Muted('Elijo por ti…'),
        Container(
          constraints: const BoxConstraints(minHeight: 90),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            _text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Btn('▶ ¡Vamos!', () {
              final t = app.getTask(_picked);
              if (t == null) return;
              final min = t.est > 0 ? math.min(t.est, app.d.settings.focus) : app.d.settings.focus;
              app.startTimer(t.id, min, false);
              Navigator.of(context).popUntil((r) => r.isFirst);
            }, kind: 'primary'),
            Btn('Otra', _roll),
            Btn('Cerrar', () => Navigator.of(context).pop(), kind: 'ghost'),
          ],
        ),
      ],
    );
  }
}
