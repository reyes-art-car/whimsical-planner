import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../art.dart';
import '../widgets.dart';

// =====================================================================
//  Meditar
// =====================================================================

class MeditarScreen extends StatelessWidget {
  const MeditarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final m = app.med;
      if (m != null) {
        final def = meditations[m.type]!;
        final P = def.prompts;
        final left = math.max(0, m.end - nowMs());
        final idx = math.max(0, math.min(P.length - 1, ((m.dur - left) / m.dur * P.length).floor()));
        return SubPage('Meditar', [
          AppCard(
            child: Column(
              children: [
                Muted('${def.name} · ${m.min} min', small: true),
                const SizedBox(height: 12),
                Ring(
                  value: left / m.dur,
                  color: p.teal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(fmt(left),
                          style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w700)),
                      const Muted('respira', small: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 84,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      P[idx],
                      key: ValueKey<int>(idx),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 19, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Btn('Terminar', app.medStop, kind: 'ghost'),
              ],
            ),
          ),
        ]);
      }

      final d7 = lastDays(7);
      final wk = d7.fold<int>(0, (a, d) => a + (app.d.med[dkey(d)] ?? 0));
      final st = app.streakOf(app.d.med);
      return SubPage('Meditar', [
        AppCard(
          child: StatsRow([
            ['$wk', 'min esta semana'],
            ['$st', st == 1 ? 'día seguido' : 'días seguidos'],
            ['${app.d.med.length}', 'días meditados'],
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: H2('Elige una meditación')),
              for (final e in meditations.entries)
                MenuRow(
                  leading: CheckCircle(app.medType == e.key, null, small: true),
                  title: e.value.name,
                  subtitle: e.value.desc,
                  onTap: () {
                    app.medType = e.key;
                    app.commit();
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Duración'),
                    ChipWrap([
                      for (final n in const [3, 5, 10, 15, 20])
                        ChipOpt('$n min', app.medMin == n, () {
                          app.medMin = n;
                          app.commit();
                        }),
                    ]),
                    const FieldLabel('Campana de intervalo'),
                    ChipWrap([
                      for (final e in const [
                        [0, 'No'],
                        [1, 'Cada min'],
                        [2, 'Cada 2 min'],
                        [5, 'Cada 5 min'],
                      ])
                        ChipOpt(e[1] as String, app.medBell == e[0], () {
                          app.medBell = e[0] as int;
                          app.commit();
                        }),
                    ]),
                    const FieldLabel('Sonido de fondo'),
                    ChipWrap([
                      for (final e in const [
                        ['off', 'Ninguno'],
                        ['pink', 'Lluvia suave'],
                        ['brown', 'Mar lejano'],
                      ])
                        ChipOpt(e[1], app.noiseType == e[0], () => app.setNoise(e[0])),
                    ]),
                    const SizedBox(height: 16),
                    Btn('▶ Empezar a meditar', app.medStart, kind: 'primary', block: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Muted(
          'Meditar con TDAH no es dejar la mente en blanco: es darte cuenta de que te has ido y volver. Cada vuelta cuenta.',
          small: true,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
      ]);
    });
  }
}

// =====================================================================
//  Actividades guiadas
// =====================================================================

class ActividadesScreen extends StatelessWidget {
  const ActividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final a = app.act;
      if (a != null) {
        final A = activities[a.id]!;
        final stp = A.steps[a.idx];
        final left = math.max(0, a.end - nowMs());
        return SubPage('Actividades guiadas', [
          AppCard(
            child: Column(
              children: [
                Muted('${A.name} · paso ${a.idx + 1} de ${A.steps.length}', small: true),
                const SizedBox(height: 12),
                Ring(
                  value: left / (stp.secs * 1000),
                  color: p.teal,
                  child: Text(fmt(left),
                      style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w700)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    stp.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 19, height: 1.4),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (A.steps.length > 1) Btn('Siguiente', app.actNextStep),
                    Btn('Terminar', app.actStop, kind: 'ghost'),
                  ],
                ),
              ],
            ),
          ),
        ]);
      }
      return SubPage('Actividades guiadas', [
        MenuList([
          for (final e in activities.entries)
            MenuRow(
              leading: IcoBox(e.value.icon, teal: true),
              title: e.value.name,
              subtitle: e.value.desc,
              trailing: const Muted('Empezar', small: true),
              onTap: () => app.actStart(e.key),
            ),
        ]),
        const Muted(
          'Sonará un cuenco al cambiar de paso. La pantalla se mantiene encendida mientras dura.',
          small: true,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
      ]);
    });
  }
}

// =====================================================================
//  Respirar
// =====================================================================

class RespirarScreen extends StatefulWidget {
  const RespirarScreen({super.key});

  @override
  State<RespirarScreen> createState() => _RespirarScreenState();
}

class _RespirarScreenState extends State<RespirarScreen> {
  String _pat = 'caja';
  bool _on = false;
  int _idx = 0;
  int _left = 0;
  int _rounds = 0;
  Timer? _iv;

  BreathDef get _def => breathPatterns[_pat]!;

  @override
  void dispose() {
    _iv?.cancel();
    super.dispose();
  }

  void _stop() {
    _iv?.cancel();
    _iv = null;
    _on = false;
  }

  void _start() {
    _iv?.cancel();
    setState(() {
      _on = true;
      _idx = 0;
      _rounds = 0;
      _left = _def.seq[0].secs;
    });
    _iv = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _left--;
        if (_left <= 0) {
          _idx++;
          if (_idx >= _def.seq.length) {
            _idx = 0;
            _rounds++;
          }
          _left = _def.seq[_idx].secs;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final ph = _def.seq[math.min(_idx, _def.seq.length - 1)];
    final big = _on && ph.big;
    final size = _on ? (big ? 230.0 : 150.0) : 180.0;
    return SubPage('Respirar', [
      AppCard(
        child: Column(
          children: [
            ChipWrap([
              for (final e in breathPatterns.entries)
                ChipOpt(e.value.name, _pat == e.key, () {
                  setState(() {
                    _stop();
                    _pat = e.key;
                    _idx = 0;
                  });
                }),
            ], alignment: WrapAlignment.center),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: _on ? ph.secs : 1),
                  curve: Curves.easeInOut,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.accentSoft,
                    border: Border.all(color: p.accent, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_on ? ph.label : 'Listo',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      if (_on)
                        Text('$_left',
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Btn(_on ? '■ Parar' : '▶ Empezar', () {
              if (_on) {
                setState(_stop);
              } else {
                _start();
              }
            }, kind: 'primary'),
            Muted(
              _on
                  ? '$_rounds ${_rounds == 1 ? 'ciclo' : 'ciclos'}'
                  : 'Unos 5–6 ciclos suelen bastar para notar el cambio.',
              small: true,
              padding: const EdgeInsets.only(top: 10),
            ),
          ],
        ),
      ),
    ]);
  }
}

// =====================================================================
//  Diario
// =====================================================================

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  int _jrP = 0;

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final k = dkey();
      final e = app.d.journal[k];
      final g = e?.g ?? <String>['', '', ''];
      final prompt = journalPrompts[(DateTime.now().day + _jrP) % journalPrompts.length];
      final past = app.d.journal.entries.where((x) => x.key != k).toList()
        ..sort((a, b) => b.key.compareTo(a.key));
      final shown = past.length > 10 ? past.sublist(0, 10) : past;
      const hints = [
        'Algo que ha salido bien',
        'Alguien o algo que agradeces',
        'Un momento que te ha gustado',
      ];
      return SubPage('Diario', [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tu porqué'),
              const Muted('¿Para qué quieres organizarte mejor? Guarda aquí tu motivo para volver a él.',
                  small: true, padding: EdgeInsets.only(bottom: 10)),
              SaveField(
                initial: app.d.why,
                hint: 'Por ejemplo: para tener tiempo de pintar sin sentirme culpable',
                maxLines: 4,
                minLines: 2,
                onSave: (v) {
                  if (v.trim() != app.d.why) app.setWhy(v);
                },
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tres cosas buenas de hoy'),
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SaveField(
                    key: ValueKey<String>('g$i-$k'),
                    initial: i < g.length ? g[i] : '',
                    hint: hints[i],
                    onSave: (v) => app.journalSet(i, v, _jrP),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(prompt,
                        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
                  ),
                  Btn('Otra pregunta', () => setState(() => _jrP++), kind: 'ghost', small: true),
                ],
              ),
              const SizedBox(height: 8),
              SaveField(
                key: ValueKey<String>('t-$k'),
                initial: e?.t ?? '',
                hint: 'Escribe sin pensarlo mucho…',
                maxLines: 8,
                minLines: 4,
                onSave: (v) => app.journalSet(-1, v, _jrP),
              ),
              const Muted('Se guarda solo al salir de cada campo.',
                  small: true, padding: EdgeInsets.only(top: 8)),
            ],
          ),
        ),
        if (shown.isNotEmpty) ...[
          const SectionLabel('Días anteriores'),
          MenuList([
            for (final x in shown)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(dmKey(x.key),
                          style: TextStyle(fontSize: 13, color: context.pal.muted)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(x.value.g.where((s) => s.isNotEmpty).join(' · '),
                              style: const TextStyle(fontSize: 14, height: 1.35)),
                          if (x.value.t.isNotEmpty)
                            Muted(
                              x.value.t.length > 140
                                  ? '${x.value.t.substring(0, 140)}…'
                                  : x.value.t,
                              small: true,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ],
      ]);
    });
  }
}

// =====================================================================
//  Ánimo y energía
// =====================================================================

class AnimoScreen extends StatelessWidget {
  const AnimoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final k = dkey();
      final m = app.d.moods[k];
      final d14 = lastDays(14);
      final notes = app.d.moods.entries.where((x) => x.value.note.isNotEmpty).toList()
        ..sort((a, b) => b.key.compareTo(a.key));
      final shown = notes.length > 5 ? notes.sublist(0, 5) : notes;
      return SubPage('Ánimo y energía', [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('¿Cómo te sientes hoy?'),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => app.setMood(i),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: m?.m == i ? p.accentSoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: m?.m == i ? p.accent : Colors.transparent, width: 1.5),
                            ),
                            child: SvgBox(
                              faceSvg(i, hexOf(m?.m == i ? p.accent : p.muted)),
                              height: 44,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const FieldLabel('Energía'),
              ChipWrap([
                for (final x in energyKeys)
                  ChipOpt(energyName[x]!, m?.e == x, () => app.setEnergy(x),
                      leading: EnergyBars((energyOrd[x] ?? 1) + 1, p.muted)),
              ]),
              const FieldLabel('Nota (opcional)'),
              SaveField(
                initial: m?.note ?? '',
                hint: '¿Algo que influya? Sueño, comida, estrés, ciclo…',
                maxLines: 5,
                minLines: 2,
                onSave: (v) {
                  if (v.trim() != (m?.note ?? '')) app.setMoodNote(v);
                },
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Ánimo, últimos 14 días'),
              BarChart(
                [for (final d in d14) app.d.moods[dkey(d)]?.m ?? 0],
                [for (final d in d14) dowLetters[jsDay(d)]],
                maxValue: 5,
                showNumbers: false,
              ),
            ],
          ),
        ),
        if (shown.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Notas recientes'),
                for (final x in shown)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(dmKey(x.key),
                              style: TextStyle(fontSize: 13, color: p.muted)),
                        ),
                        Expanded(child: Text(x.value.note, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ]);
    });
  }
}
