import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'foco.dart';

// =====================================================================
//  Viajes
// =====================================================================

class ViajesScreen extends StatelessWidget {
  const ViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final j = app.d.journey;
      final a = j.active;
      final kids = <Widget>[];

      if (a != null && journeys[a] != null && j.prog[a] != null) {
        final J = journeys[a]!;
        final pr = j.prog[a]!;
        if (pr.step < J.steps.length) {
          final st = J.steps[pr.step];
          final n = app.jCount();
          final h = app.jHabit();
          final today = h != null && h.log[dkey()] != null;
          kids.add(AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IcoBox(J.icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(J.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          Muted('Paso ${pr.step + 1} de ${J.steps.length}', small: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressBar(pr.step / J.steps.length),
                const SizedBox(height: 12),
                _Letter(st),
                const SizedBox(height: 12),
                DotsRow(st.days, math.min(n, st.days)),
                const SizedBox(height: 12),
                if (n >= st.days)
                  Btn(
                    pr.step + 1 < J.steps.length
                        ? 'Paso completado · leer la siguiente carta'
                        : 'Terminar el viaje',
                    app.jNext,
                    kind: 'primary',
                    block: true,
                  )
                else ...[
                  Btn(today ? 'Hecho hoy · desmarcar' : 'Lo he hecho hoy', app.jToday,
                      kind: today ? 'normal' : 'primary', block: true),
                  Muted('Lleva $n de ${st.days} días. El hábito también aparece en Hábitos.',
                      small: true, padding: const EdgeInsets.only(top: 8)),
                ],
                const SizedBox(height: 14),
                for (var i = 0; i < J.steps.length; i++)
                  Row(
                    children: [
                      CheckCircle(i < pr.step, null, small: true),
                      Expanded(
                        child: Text(J.steps[i].h,
                            style: TextStyle(color: i > pr.step ? p.muted : p.text)),
                      ),
                      Muted(i < pr.step ? 'hecho' : (i == pr.step ? 'ahora' : ''), small: true),
                    ],
                  ),
                LinkBtn('Pausar este viaje', () {
                  askConfirm(
                    context,
                    '¿Pausar este viaje? Podrás retomarlo donde lo dejaste.',
                    app.jQuit,
                  );
                }),
              ],
            ),
          ));
        }
      }

      kids.add(SectionLabel(a != null ? 'Otros viajes' : 'Elige un viaje'));
      kids.add(const Muted(
        'Cada viaje añade un hábito pequeño. Cuando lo repites varios días, se abre la siguiente carta y el siguiente hábito.',
        small: true,
        padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
      ));
      journeys.forEach((k, J) {
        if (k == a) return;
        final pr = j.prog[k];
        final done = j.done.contains(k);
        kids.add(AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IcoBox(J.icon, teal: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(J.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Muted(J.desc, small: true),
                      ],
                    ),
                  ),
                ],
              ),
              Muted(J.steps.map((s) => s.h).join(' · '),
                  small: true, padding: const EdgeInsets.symmetric(vertical: 10)),
              Btn(
                done
                    ? 'Completado · repetir'
                    : (pr != null ? 'Retomar (paso ${pr.step + 1})' : 'Empezar viaje'),
                () {
                  void go() => app.jStart(k);
                  if (a != null && a != k) {
                    askConfirm(
                      context,
                      'Ya tienes un viaje en marcha. ¿Cambiar a este? Tu progreso del otro se guarda.',
                      go,
                    );
                  } else {
                    go();
                  }
                },
                kind: done ? 'normal' : 'teal',
                block: true,
              ),
            ],
          ),
        ));
      });
      return SubPage('Viajes', kids);
    });
  }
}

class _Letter extends StatelessWidget {
  final JourneyStep st;
  const _Letter(this.st);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        color: p.surface2,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: p.accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in st.letter)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(line, style: const TextStyle(fontSize: 15, height: 1.45)),
                        ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(text: 'Tu próximo hábito: ', style: TextStyle(color: p.muted)),
                          TextSpan(text: st.h, style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' · ${st.days} días', style: TextStyle(color: p.muted)),
                        ]),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
//  Retos de 7 días
// =====================================================================

class RetosScreen extends StatelessWidget {
  const RetosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final k = dkey();
      final kids = <Widget>[];
      final act = app.d.challenges;
      if (act.isNotEmpty) kids.add(const SectionLabel('En marcha'));
      act.forEach((id, c) {
        final R = retos[id];
        if (R == null) return;
        final ds = app.cDays(c);
        final n = c.log.length;
        final over = k.compareTo(ds[6]) > 0;
        final idx = ds.indexOf(k);
        kids.add(AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IcoBox('retos'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Muted(
                            c.done
                                ? 'Completado'
                                : (over ? 'Terminado con $n de 7' : 'Día ${math.min(7, idx + 1)} de 7'),
                            small: true),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DotsMarks([for (final d in ds) c.log[d] != null], idx),
              const SizedBox(height: 12),
              if (!c.done && !over)
                Btn(c.log[k] != null ? 'Hecho hoy · desmarcar' : 'Lo he cumplido hoy',
                    () => app.cToggle(id),
                    kind: c.log[k] != null ? 'normal' : 'primary', block: true)
              else
                Btn('Empezar otra vez', () => app.cStart(id), block: true),
              LinkBtn('Quitar reto', () {
                askConfirm(
                  context,
                  '¿Abandonar este reto? Podrás empezarlo otra vez cuando quieras.',
                  () => app.cQuit(id),
                );
              }),
            ],
          ),
        ));
      });
      kids.add(SectionLabel(act.isNotEmpty ? 'Más retos' : 'Elige un reto'));
      final rest = retos.entries.where((e) => !act.containsKey(e.key)).toList();
      if (rest.isEmpty) {
        kids.add(const Muted('Tienes todos los retos en marcha.', padding: EdgeInsets.all(14)));
      } else {
        kids.add(MenuList([
          for (final e in rest)
            MenuRow(
              leading: const IcoBox('retos', teal: true),
              title: e.value.name,
              subtitle: e.value.desc,
              trailing: const Muted('Empezar', small: true),
              onTap: () => app.cStart(e.key),
            ),
        ]));
      }
      kids.add(const Muted(
        'Siete días seguidos de algo pequeño. Si fallas uno, sigue: lo que cuenta es volver.',
        small: true,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
      ));
      return SubPage('Retos de 7 días', kids);
    });
  }
}

// =====================================================================
//  Mascota
// =====================================================================

void showAdoptSheet(BuildContext context) {
  showSheet<void>(context, (c) => const _AdoptSheet());
}

class _AdoptSheet extends StatefulWidget {
  const _AdoptSheet();

  @override
  State<_AdoptSheet> createState() => _AdoptSheetState();
}

class _AdoptSheetState extends State<_AdoptSheet> {
  final TextEditingController _name = TextEditingController(text: 'Mochi');
  String _kind = 'gato';
  String _color = petColors.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pv = Pet(name: '', kind: _kind, color: _color, xp: 30, hunger: 90, joy: 90);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Adopta a tu compañero',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            ),
            Btn('Cerrar', () => Navigator.of(context).pop(), kind: 'ghost', small: true),
          ],
        ),
        Center(child: PetView(pv, 'happy', size: 150)),
        const Muted(
          'Empieza como un huevo. Crece y es feliz cuando tú haces cosas: tareas, foco, rutinas, hábitos y meditación.',
          small: true,
          align: TextAlign.center,
        ),
        const FieldLabel('Nombre'),
        TextField(
          controller: _name,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          decoration: inputDeco(context, 'Mochi').copyWith(counterText: ''),
        ),
        const FieldLabel('Especie'),
        ChipWrap([
          for (final e in petKinds.entries)
            ChipOpt(e.value, _kind == e.key, () => setState(() => _kind = e.key)),
        ]),
        const FieldLabel('Color'),
        ChipWrap([
          for (final c in petColors) Swatch(c, _color == c, () => setState(() => _color = c)),
        ]),
        const SizedBox(height: 18),
        Btn('Adoptar', () {
          app.adoptPet(_name.text, _kind, _color);
          Navigator.of(context).pop();
        }, kind: 'primary', block: true),
      ],
    );
  }
}

class MascotaScreen extends StatelessWidget {
  const MascotaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final pet = app.d.pet;
      if (pet == null) {
        return SubPage('Mi mascota', [
          AppCard(
            child: Column(
              children: [
                PetView(Pet(name: '', kind: 'gato', color: '#E9A15B'), 'ok', size: 150),
                const Muted('Aún no tienes mascota.', padding: EdgeInsets.symmetric(vertical: 8)),
                Btn('Adoptar', () => showAdoptSheet(context), kind: 'primary'),
              ],
            ),
          ),
        ]);
      }
      final st = petStage(pet);
      final hasNext = st + 1 < stageXp.length;
      final prev = stageXp[st];
      final pr = hasNext ? (pet.xp - prev) / (stageXp[st + 1] - prev) : 1.0;
      return SubPage('Mi mascota', [
        AppCard(
          child: Column(
            children: [
              PetView(pet, petMood(pet), size: 160, onTap: app.petPat),
              const SizedBox(height: 6),
              Bubble(app.petSay(pet)),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(pet.name,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
              ),
              Muted('${petKinds[pet.kind] ?? ''} · ${stageName[st]}', small: true),
              const SizedBox(height: 10),
              ProgressBar(pr),
              Muted(
                hasNext
                    ? '${pet.xp} de ${stageXp[st + 1]} puntos para ser ${stageName[st + 1].toLowerCase()}'
                    : '¡Etapa máxima alcanzada!',
                small: true,
                padding: const EdgeInsets.only(top: 4),
              ),
              if (st > 0) Padding(padding: const EdgeInsets.only(top: 10), child: PetMeters(pet)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (st > 0) Btn('Dar baya · ${app.d.food}', app.petFeed, kind: 'teal'),
                  Btn('Mimar', app.petPat),
                ],
              ),
            ],
          ),
        ),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2('Cómo cuidarla'),
              _Bullet('Cada cosa que haces suma puntos. Cada 10 puntos ganas una baya.'),
              _Bullet('Las bayas le llenan la barriga. Su alegría sube cuando tú avanzas.'),
              _Bullet(
                  'Si pasan días sin cuidarla se pone tristona, pero nunca se muere. En cuanto vuelves, se recupera.'),
              _Bullet('De noche duerme. Tú también deberías.'),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Etapas'),
              for (var i = 0; i < stageXp.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CheckCircle(pet.xp >= stageXp[i], null, small: true),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: stageName[i]),
                          if (stageUnlock[i] != null)
                            TextSpan(
                                text: ' · ${stageUnlock[i]}',
                                style: TextStyle(color: p.muted, fontSize: 13)),
                        ])),
                      ),
                      Muted('${stageXp[i]} pts', small: true),
                    ],
                  ),
                ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Personalizar'),
              const FieldLabel('Nombre'),
              SaveField(
                initial: pet.name,
                maxLength: 20,
                onSave: (v) {
                  if (v.trim().isNotEmpty) {
                    pet.name = v.trim();
                    app.commit();
                  }
                },
              ),
              const FieldLabel('Especie'),
              ChipWrap([
                for (final e in petKinds.entries)
                  ChipOpt(e.value, pet.kind == e.key, () {
                    pet.kind = e.key;
                    app.commit();
                  }),
              ]),
              const FieldLabel('Color'),
              ChipWrap([
                for (final c in petColors)
                  Swatch(c, pet.color == c, () {
                    pet.color = c;
                    app.commit();
                  }),
              ]),
              LinkBtn('Despedirme de ${pet.name}', () {
                askConfirm(
                  context,
                  '¿Seguro que quieres despedirte de tu mascota? Podrás adoptar otra después.',
                  () {
                    app.petLeave();
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ]);
    });
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: context.pal.accent, shape: BoxShape.circle),
            ),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.4))),
        ],
      ),
    );
  }
}

/// Lista de puntos con viñeta, reutilizable.
class Bullet extends StatelessWidget {
  final String text;
  const Bullet(this.text, {super.key});

  @override
  Widget build(BuildContext context) => _Bullet(text);
}

// =====================================================================
//  Bosque
// =====================================================================

class BosqueScreen extends StatefulWidget {
  const BosqueScreen({super.key});

  @override
  State<BosqueScreen> createState() => _BosqueScreenState();
}

class _BosqueScreenState extends State<BosqueScreen> {
  String _ff = 'semana';

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final st = app.d.settings;
      final days = _ff == 'hoy' ? 1 : (_ff == 'semana' ? 7 : 0);
      final since = days > 0 ? dkey(lastDays(days).first) : '';
      final list =
          app.d.forest.where((x) => days == 0 || x.d.compareTo(since) >= 0).toList();
      final alive = list.where((x) => !x.dead).length;
      final mins = list.fold<int>(0, (a, x) => a + x.min);
      final cur = st.tree;

      return SubPage('Mi bosque', [
        ChipWrap([
          ChipOpt('Hoy', _ff == 'hoy', () => setState(() => _ff = 'hoy')),
          ChipOpt('7 días', _ff == 'semana', () => setState(() => _ff = 'semana')),
          ChipOpt('Todo', _ff == 'todo', () => setState(() => _ff = 'todo')),
        ]),
        const SizedBox(height: 12),
        AppCard(
          child: StatsRow([
            ['$alive', 'árboles vivos'],
            ['${list.length - alive}', 'marchitos'],
            [minsLabel(mins), 'de foco'],
          ]),
        ),
        if (list.isNotEmpty)
          AppCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ForestScene(
                  list,
                  height: math.max(210.0, 110.0 + (list.length / 6).ceil() * 44),
                  per: 6,
                  hl: list.last.id,
                ),
                const Muted(
                  'Los árboles más recientes están delante.',
                  small: true,
                  align: TextAlign.center,
                  padding: EdgeInsets.only(top: 8),
                ),
              ],
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                const TreeView('pino', growth: 0.5, size: 90),
                const Muted(
                  'Aún no hay árboles aquí. Empieza un bloque de foco con el modo bosque para plantar el primero.',
                  align: TextAlign.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                Btn('Ir a Foco', () {
                  app.tab = 2;
                  app.commit();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }, kind: 'primary'),
              ],
            ),
          ),
        AppCard(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: H2('Elige tu árbol')),
              const Muted(
                'El que elijas se plantará en tus próximos bloques de foco.',
                small: true,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              MenuRow(
                leading: CheckCircle(cur == 'auto', null, small: true),
                title: 'Automático',
                subtitle: 'Brote, arbusto, pino, roble o cerezo según los minutos',
                onTap: () => app.setSetting((s) => s.tree = 'auto'),
              ),
              for (final e in trees.entries)
                MenuRow(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckCircle(cur == e.key, null, small: true),
                      TreeView(e.key, size: 44),
                    ],
                  ),
                  title: e.value.name,
                  subtitle: e.value.autoMin == null
                      ? null
                      : (e.value.autoMin! > 0
                          ? 'automático desde ${e.value.autoMin} min'
                          : 'automático con menos de 10 min'),
                  trailing: Muted(
                    () {
                      final n = app.d.forest.where((x) => x.kind == e.key && !x.dead).length;
                      return n > 0 ? '$n' : '';
                    }(),
                    small: true,
                  ),
                  onTap: () {
                    app.setSetting((s) => s.tree = e.key);
                    app.toast('Plantarás: ${e.value.name.toLowerCase()}');
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Text(
                  'Mientras crece tu árbol, la pantalla se mantiene encendida. Si cambias de app más de ${st.grace} s o terminas antes de tiempo, el árbol se marchita (tus minutos de foco cuentan igual).',
                  style: TextStyle(fontSize: 13, color: p.muted, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ]);
    });
  }
}
