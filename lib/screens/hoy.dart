import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'mas.dart';
import 'tareas.dart';
import 'casa.dart';

class HoyScreen extends StatelessWidget {
  const HoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final d = app.d;
      final st = d.settings;
      final e = app.todayEnergy();
      final t = app.nowTask();
      final focusMin =
          (t != null && t.est > 0) ? math.min(t.est, st.focus) : st.focus;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionGuide('Hoy'),
          const HomeSummary(),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('¿Cómo vas de energía?'),
                ChipWrap([
                  for (final x in energyKeys)
                    ChipOpt(energyName[x]!, e == x, () => app.setEnergy(x),
                        leading: EnergyBars(
                            (energyOrd[x] ?? 1) + 1, context.pal.muted)),
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
                const H2('Tu siguiente paso'),
                if (t != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(t.title,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600)),
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
                  const Muted(
                      'No tienes tareas pendientes. Puedes descansar o añadir una en Tareas.',
                      padding: EdgeInsets.only(top: 6)),
                LinkBtn(
                    'Ver y añadir tareas', () => openSub(context, 'tareas')),
                if (app.pending().length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Btn('No sé por dónde empezar, elige tú',
                        () => showPickSheet(context),
                        kind: 'ghost', block: true),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Suelta una idea'),
                QuickAdd(
                  hint: 'Suelta aquí lo que te ronde la cabeza',
                  onSubmit: app.capture,
                ),
                const SizedBox(height: 8),
                const Muted(
                    'Guárdala ahora y decide después si convertirla en tarea.',
                    small: true),
                LinkBtn('Ver ideas guardadas (${d.inbox.length})',
                    () => openSub(context, 'vertedero')),
              ],
            ),
          ),
        ],
      );
    });
  }
}
