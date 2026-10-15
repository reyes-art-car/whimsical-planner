import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

// Retos opcionales, mascota y bosque.

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
                        Text(R.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Muted(
                            c.done
                                ? 'Completado'
                                : (over
                                    ? 'Terminado con $n de 7'
                                    : 'Día ${math.min(7, idx + 1)} de 7'),
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
                Btn(
                    c.log[k] != null
                        ? 'Hecho hoy · desmarcar'
                        : 'Lo he cumplido hoy',
                    () => app.cToggle(id),
                    kind: c.log[k] != null ? 'normal' : 'primary',
                    block: true)
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
        kids.add(const Muted('Tienes todos los retos en marcha.',
            padding: EdgeInsets.all(14)));
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
    final pv =
        Pet(name: '', kind: _kind, color: _color, xp: 30, hunger: 90, joy: 90);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Adopta a tu compañero',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            ),
            Btn('Cerrar', () => Navigator.of(context).pop(),
                kind: 'ghost', small: true),
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
            ChipOpt(
                e.value, _kind == e.key, () => setState(() => _kind = e.key)),
        ]),
        const FieldLabel('Color'),
        ChipWrap([
          for (final c in petColors)
            Swatch(c, _color == c, () => setState(() => _color = c)),
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
                PetView(Pet(name: '', kind: 'gato', color: '#E9A15B'), 'ok',
                    size: 150),
                const Muted('Aún no tienes mascota.',
                    padding: EdgeInsets.symmetric(vertical: 8)),
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
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w600)),
              ),
              Muted('${petKinds[pet.kind] ?? ''} · ${stageName[st]}',
                  small: true),
              const SizedBox(height: 10),
              ProgressBar(pr),
              Muted(
                hasNext
                    ? '${pet.xp} de ${stageXp[st + 1]} puntos para ser ${stageName[st + 1].toLowerCase()}'
                    : '¡Etapa máxima alcanzada!',
                small: true,
                padding: const EdgeInsets.only(top: 4),
              ),
              if (st > 0)
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: PetMeters(pet)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (st > 0)
                    Btn('Dar baya · ${app.d.food}', app.petFeed, kind: 'teal'),
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
              _Bullet(
                  'Cada cosa que haces suma puntos. Cada 10 puntos ganas una baya.'),
              _Bullet(
                  'Las bayas le llenan la barriga. Su alegría sube cuando tú avanzas.'),
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
              decoration: BoxDecoration(
                  color: context.pal.accent, shape: BoxShape.circle),
            ),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14.5, height: 1.4))),
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
