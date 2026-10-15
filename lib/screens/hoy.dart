import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'mas.dart';
import 'rutinas.dart';
import 'sub_crecer.dart';
import 'tareas.dart';

class HoyScreen extends StatelessWidget {
  const HoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final now = DateTime.now();
      final d = app.d;
      final st = d.settings;
      final e = app.todayEnergy();
      final t = app.nowTask();
      final hNow = now.hour + now.minute / 60.0;
      final span = math.max(1, st.dayEnd - st.dayStart);
      final prog = clampD((hNow - st.dayStart) / span, 0.0, 1.0);
      final left = ((st.dayEnd - hNow) * 60).round();
      final k = dkey();
      final focusMin = (t != null && t.est > 0) ? math.min(t.est, st.focus) : st.focus;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PetCard(),
          const _TodayPlan(),
          const _ForestCard(),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(dateLong(now),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
                    ),
                    Muted('${pad(now.hour)}:${pad(now.minute)}', small: true),
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBar(prog),
                const SizedBox(height: 8),
                if (d.why.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      d.why,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: context.pal.accent,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                Muted(
                  hNow < st.dayStart
                      ? 'Tu día activo aún no ha empezado.'
                      : left > 0
                          ? 'Quedan ${minsLabel(left)} de día activo (hasta las ${st.dayEnd}:00)'
                          : 'Tu día activo ha terminado. Hora de desconectar.',
                  small: true,
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('¿Cómo vas de energía?'),
                ChipWrap([
                  for (final x in energyKeys)
                    ChipOpt(energyName[x]!, e == x, () => app.setEnergy(x),
                        leading: EnergyBars((energyOrd[x] ?? 1) + 1, context.pal.muted)),
                ]),
                if (e != null)
                  const Muted('Te propongo tareas que encajan con tu energía.',
                      small: true, padding: EdgeInsets.only(top: 8)),
              ],
            ),
          ),
          AppCard(
            color: context.pal.accentSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Muted('Haz esto ahora', small: true),
                if (t != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(t.title,
                        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
                  ),
                  taskTags(context, t),
                  nextSubRow(context, t),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Btn('▶ Empezar · $focusMin′', () {
                          app.startTimer(t.id, focusMin, false);
                        }, kind: 'primary'),
                      ),
                      const SizedBox(width: 8),
                      Btn('Hecho', () => app.completeTask(t.id)),
                      const SizedBox(width: 4),
                      Btn('Otra', () {
                        app.skip++;
                        app.commit();
                      }, kind: 'ghost'),
                    ],
                  ),
                ] else
                  const Muted('No tienes tareas pendientes. Descansa, o vacía la cabeza abajo.',
                      padding: EdgeInsets.only(top: 6)),
                if (app.pending().length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Btn('No sé por dónde empezar, elige tú', () => showPickSheet(context),
                        kind: 'ghost', block: true),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Vertedero mental'),
                QuickAdd(
                  hint: 'Suelta aquí lo que te ronde la cabeza',
                  onSubmit: app.capture,
                ),
                const SizedBox(height: 8),
                if (d.inbox.isEmpty)
                  const Muted('Lo ordenas luego, sin prisa.', small: true)
                else
                  Row(
                    children: [
                      Muted(
                          '${d.inbox.length} ${d.inbox.length == 1 ? 'cosa guardada' : 'cosas guardadas'} · ',
                          small: true),
                      InkWell(
                        onTap: () => openSub(context, 'vertedero'),
                        child: Text('ordenar',
                            style: TextStyle(
                                color: context.pal.accent,
                                fontSize: 13,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Hoy llevas'),
                StatsRow([
                  ['${d.doneLog[k] ?? 0}', 'tareas'],
                  ['${d.focus[k] ?? 0}', 'min de foco'],
                  ['${app.habitsToday()}/${d.habits.length}', 'hábitos'],
                ]),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Rutinas'),
                if (d.routines.isEmpty) const Muted('Sin rutinas todavía.'),
                for (final r in d.routines) _RoutineRow(r),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _RoutineRow extends StatelessWidget {
  final Routine r;
  const _RoutineRow(this.r);

  @override
  Widget build(BuildContext context) {
    final dn = app.rDone(r);
    final full = r.steps.isNotEmpty && dn.length >= r.steps.length;
    return MenuRow(
      leading: IcoBox(r.icon),
      title: r.name,
      badge: app.routineNow(r) ? const NowChip() : null,
      subtitle:
          '${app.routineToday(r) ? '${r.at} · ' : ''}${dn.length}/${r.steps.length} pasos${full ? ' · ✓ completada' : ''}',
      trailing: Icon(Icons.chevron_right, color: context.pal.muted),
      onTap: () => openRun(context, r.id),
    );
  }
}

// =====================================================================
//  Mascota en Hoy
// =====================================================================

class _PetCard extends StatelessWidget {
  const _PetCard();

  @override
  Widget build(BuildContext context) {
    final pet = app.d.pet;
    if (pet == null) {
      final demo = Pet(name: '', kind: 'gato', color: '#E9A15B');
      return AppCard(
        child: Row(
          children: [
            PetView(demo, 'ok', size: 92),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adopta a tu compañero',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const Muted(
                    'Una mascota que crece y es feliz cuando tú avanzas. Sin culpa: nunca se muere.',
                    small: true,
                    padding: EdgeInsets.symmetric(vertical: 6),
                  ),
                  Btn('Adoptar', () => showAdoptSheet(context), kind: 'primary', small: true),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final st = petStage(pet);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetView(pet, petMood(pet), size: 96, onTap: app.petPat),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bubble(app.petSay(pet)),
                if (st > 0) PetMeters(pet),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (st > 0) Btn('Dar baya · ${app.d.food}', app.petFeed, kind: 'teal', small: true),
                    Btn('${pet.name} · ${stageName[st]}', () => openSub(context, 'mascota'),
                        small: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Hoy toca (viaje y retos de hoy)
// =====================================================================

class _TodayPlan extends StatelessWidget {
  const _TodayPlan();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final k = dkey();
    final a = app.d.journey.active;
    final rows = <Widget>[];
    if (a != null) {
      final J = journeys[a];
      final pr = app.d.journey.prog[a];
      if (J != null && pr != null && pr.step < J.steps.length) {
        final st = J.steps[pr.step];
        final h = app.jHabit();
        final n = app.jCount();
        final on = h != null && h.log[k] != null;
        rows.add(Row(
          children: [
            CheckCircle(on, app.jToday, small: true),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st.h, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Muted('${J.name} · $n de ${st.days} días', small: true),
                ],
              ),
            ),
            if (n >= st.days)
              Btn('Siguiente carta', () => openSub(context, 'viajes'), kind: 'primary', small: true),
          ],
        ));
      }
    }
    app.d.challenges.forEach((id, c) {
      final R = retos[id];
      final ds = app.cDays(c);
      if (R == null || c.done || k.compareTo(ds[6]) > 0) return;
      final idx = ds.indexOf(k);
      rows.add(Row(
        children: [
          CheckCircle(c.log[k] != null, () => app.cToggle(id), small: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(R.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Muted('Reto · día ${idx + 1} de 7', small: true),
              ],
            ),
          ),
        ],
      ));
    });
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Hoy toca',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              InkWell(
                onTap: () => openSub(context, a != null ? 'viajes' : 'retos'),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text('ver',
                      style: TextStyle(
                          color: p.accent, decoration: TextDecoration.underline, fontSize: 14)),
                ),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
}

// =====================================================================
//  Bosque en Hoy
// =====================================================================

class _ForestCard extends StatelessWidget {
  const _ForestCard();

  @override
  Widget build(BuildContext context) {
    final all = app.d.forest;
    final alive = all.where((x) => !x.dead).length;
    final last = all.length > 24 ? all.sublist(all.length - 24) : all;
    return AppCard(
      onTap: () => openSub(context, 'bosque'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Tu bosque',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              Muted('$alive ${alive == 1 ? 'árbol' : 'árboles'} · ver ›', small: true),
            ],
          ),
          const SizedBox(height: 10),
          ForestScene(last, height: 170, per: 8),
          if (all.isEmpty)
            const Muted(
              'Haz un bloque de foco con el modo bosque y aquí crecerá tu primer árbol.',
              small: true,
              padding: EdgeInsets.only(top: 8),
            ),
        ],
      ),
    );
  }
}
