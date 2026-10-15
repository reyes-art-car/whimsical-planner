import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'sub_crecer.dart' show Bullet;

// =====================================================================
//  Vertedero mental
// =====================================================================

class VertederoScreen extends StatefulWidget {
  const VertederoScreen({super.key});

  @override
  State<VertederoScreen> createState() => _VertederoScreenState();
}

class _VertederoScreenState extends State<VertederoScreen> {
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final inbox = app.d.inbox;
      return SubPage('Vertedero mental', [
        AppCard(
          child: Column(
            children: [
              TextField(
                controller: _c,
                minLines: 4,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: inputDeco(context,
                    'Escribe todo lo que tengas en la cabeza. Una cosa por línea.'),
              ),
              const SizedBox(height: 10),
              Btn('Sacarlo de la cabeza', () {
                app.dump(_c.text);
                _c.clear();
              }, kind: 'teal', block: true),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (inbox.isEmpty) const Muted('Vacío. Tu cabeza, más ligera.'),
              for (final i in inbox)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.t, style: const TextStyle(fontSize: 15.5)),
                            Muted(dateTimeShort(DateTime.fromMillisecondsSinceEpoch(i.at)),
                                small: true),
                          ],
                        ),
                      ),
                      Btn('→ Tarea', () => app.inboxToTask(i.id), small: true),
                      IconButton(
                        tooltip: 'Borrar',
                        onPressed: () => app.inboxDelete(i.id),
                        icon: Icon(Icons.close, color: p.muted),
                      ),
                    ],
                  ),
                ),
              if (inbox.length > 1)
                Btn('Vaciar todo', () {
                  askConfirm(context, '¿Vaciar el vertedero entero?', app.inboxClear);
                }, kind: 'ghost', block: true),
            ],
          ),
        ),
      ]);
    });
  }
}

// =====================================================================
//  Hábitos
// =====================================================================

class HabitosScreen extends StatelessWidget {
  const HabitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final days = lastDays(7);
      final today = dkey();
      return SubPage('Hábitos', [
        for (final h in app.d.habits)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Muted(() {
                      final s = app.streakOf(h.log);
                      return 'racha de $s ${s == 1 ? 'día' : 'días'}';
                    }(), small: true),
                    IconButton(
                      tooltip: 'Borrar hábito',
                      onPressed: () {
                        askConfirm(context, '¿Borrar este hábito y su historial?',
                            () => app.habitDelete(h.id));
                      },
                      icon: Icon(Icons.close, color: p.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final d in days)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _DayButton(
                            letter: dowLetters[jsDay(d)],
                            number: d.day,
                            on: h.log[dkey(d)] != null,
                            today: dkey(d) == today,
                            onTap: () => app.habitToggle(h.id, dkey(d)),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        AppCard(
          child: QuickAdd(
            hint: 'Nuevo hábito (pequeño y concreto)',
            button: '+',
            onSubmit: app.addHabit,
          ),
        ),
        const Muted(
          'Si fallas un día, no pasa nada: la regla es no fallar dos seguidos.',
          small: true,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
      ]);
    });
  }
}

class _DayButton extends StatelessWidget {
  final String letter;
  final int number;
  final bool on;
  final bool today;
  final VoidCallback onTap;
  const _DayButton({
    required this.letter,
    required this.number,
    required this.on,
    required this.today,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Material(
      color: on ? p.ok : p.surface2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: today ? p.accent : Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(letter,
                  style: TextStyle(fontSize: 12, color: on ? Colors.white : p.muted)),
              Text('$number',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : p.text)),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
//  Recordatorios
// =====================================================================

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final TextEditingController _c = TextEditingController();
  TimeOfDay? _time;
  bool _daily = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool _hasText() {
    if (_c.text.trim().isEmpty) {
      app.toast('Escribe primero qué quieres recordar');
      return false;
    }
    return true;
  }

  void _in(int min) {
    if (!_hasText()) return;
    app.addReminder(_c.text.trim(), DateTime.now().add(Duration(minutes: min)), false);
    _c.clear();
  }

  void _add() {
    if (!_hasText()) return;
    final t = _time;
    if (t == null) {
      app.toast('Elige una hora o usa los botones rápidos');
      return;
    }
    final n = DateTime.now();
    var w = DateTime(n.year, n.month, n.day, t.hour, t.minute);
    if (!_daily && !w.isAfter(n)) w = w.add(const Duration(days: 1));
    app.addReminder(_c.text.trim(), w, _daily);
    _c.clear();
    setState(() => _time = null);
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final k = dkey();
      final list = List<Reminder>.from(app.d.reminders)
        ..sort((a, b) {
          final o = (a.off ? 1 : 0) - (b.off ? 1 : 0);
          return o != 0 ? o : a.time.compareTo(b.time);
        });
      return SubPage('Recordatorios', [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('¿Qué tengo que recordar?'),
              TextField(
                controller: _c,
                textCapitalization: TextCapitalization.sentences,
                decoration: inputDeco(context, 'Ej.: sacar la ropa de la lavadora'),
              ),
              const FieldLabel('Rápido'),
              ChipWrap([
                ChipOpt('En 10 min', false, () => _in(10)),
                ChipOpt('En 30 min', false, () => _in(30)),
                ChipOpt('En 1 hora', false, () => _in(60)),
              ]),
              const FieldLabel('O a una hora'),
              Row(
                children: [
                  Btn(_time == null ? 'Elegir hora' : _time!.format(context), () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _time ?? TimeOfDay.now(),
                    );
                    if (t != null) setState(() => _time = t);
                  }),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchRow('Cada día', _daily, (v) => setState(() => _daily = v)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Btn('Añadir recordatorio', _add, kind: 'primary', block: true),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (list.isEmpty) const Muted('Sin recordatorios.'),
              for (final r in list)
                Opacity(
                  opacity: r.off ? 0.6 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Muted(
                                  '⏰ ${r.time} · ${r.daily ? 'cada día' : (r.off ? 'ya avisado' : (r.date == k ? 'hoy' : 'mañana'))}',
                                  small: true),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Borrar recordatorio',
                          onPressed: () => app.deleteReminder(r.id),
                          icon: Icon(Icons.close, color: p.muted),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Muted(
          'Los avisos suenan con la app abierta. Para algo importante, ponlo también como alarma en el reloj del móvil.',
          small: true,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
      ]);
    });
  }
}

// =====================================================================
//  Progreso
// =====================================================================

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  double? _estRatio() {
    final l = app.d.tasks.where((t) => t.done && t.est > 0 && t.spent > 0).toList();
    if (l.length < 2) return null;
    return l.fold<double>(0, (a, t) => a + t.spent / t.est) / l.length;
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final d = app.d;
      final lvl = d.points ~/ 100 + 1;
      final into = d.points % 100;
      final d7 = lastDays(7);
      final r = _estRatio();
      final totalDone = d.tasks.where((t) => t.done).length;
      final totalFocus = d.focus.values.fold<int>(0, (a, b) => a + b);
      final best = d.habits.fold<int>(0, (a, h) => math.max(a, app.streakOf(h.log)));
      final labels = [for (final x in d7) dowLetters[jsDay(x)]];
      return SubPage('Progreso', [
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: context.pal.accent),
                  const SizedBox(width: 8),
                  Text('${d.points}',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
                ],
              ),
              Text('Nivel $lvl', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ProgressBar(into / 100),
              Muted('${100 - into} puntos para el nivel ${lvl + 1}',
                  small: true, padding: const EdgeInsets.only(top: 6)),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tareas hechas · 7 días'),
              BarChart([for (final x in d7) d.doneLog[dkey(x)] ?? 0], labels),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Minutos de foco · 7 días'),
              BarChart([for (final x in d7) d.focus[dkey(x)] ?? 0], labels),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tu reloj interno'),
              if (r != null) ...[
                Text.rich(TextSpan(children: [
                  const TextSpan(text: 'De media, tus tareas te llevan '),
                  TextSpan(
                      text: '${r.toStringAsFixed(1).replaceAll('.', ',')}×',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: ' el tiempo que estimas.'),
                ])),
                Muted(
                  r > 1.2
                      ? 'Truco: multiplica tus estimaciones por esa cifra al planificar.'
                      : (r < 0.8
                          ? 'Sueles sobreestimar. ¡Puedes ser más optimista!'
                          : 'Tus estimaciones son bastante precisas. ¡Bien!'),
                  small: true,
                  padding: const EdgeInsets.only(top: 6),
                ),
              ] else
                const Muted(
                  'Cuando completes tareas usando el temporizador, verás aquí si sueles calcular bien el tiempo. La “ceguera temporal” es muy habitual con TDAH.',
                  small: true,
                ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            children: [
              StatsRow([
                ['$totalDone', 'tareas en total'],
                [minsLabel(totalFocus), 'de foco'],
                ['$best', 'mejor racha'],
              ]),
              const SizedBox(height: 16),
              StatsRow([
                ['${d.forest.where((x) => !x.dead).length}', 'árboles'],
                [minsLabel(d.med.values.fold<int>(0, (a, b) => a + b)), 'meditando'],
                ['${d.food}', 'bayas'],
              ]),
            ],
          ),
        ),
      ]);
    });
  }
}

// =====================================================================
//  Ajustes
// =====================================================================

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  Widget _num(String label, int value, int mi, int ma, void Function(int v) set,
      {int step = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          NumStepper(value, mi, ma, set, step: step),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final st = app.d.settings;
      return SubPage('Ajustes', [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tú'),
              const Muted('Tu nombre', small: true, padding: EdgeInsets.only(bottom: 6)),
              SaveField(
                initial: st.name,
                onSave: (v) {
                  if (v.trim() != st.name) app.setSetting((s) => s.name = v.trim());
                },
              ),
              const SizedBox(height: 8),
              _num('Empieza tu día (hora)', st.dayStart, 0, 23,
                  (v) => app.setSetting((s) => s.dayStart = v)),
              _num('Termina tu día (hora)', st.dayEnd, 1, 24,
                  (v) => app.setSetting((s) => s.dayEnd = v)),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Temporizador'),
              _num('Bloque de foco (min)', st.focus, 1, 120,
                  (v) => app.setSetting((s) => s.focus = v)),
              _num('Descanso corto (min)', st.short, 1, 30,
                  (v) => app.setSetting((s) => s.short = v)),
              _num('Descanso largo (min)', st.long, 1, 60,
                  (v) => app.setSetting((s) => s.long = v)),
              _num('Bloques antes del descanso largo', st.cycles, 2, 8,
                  (v) => app.setSetting((s) => s.cycles = v)),
              _num('Aviso antes de terminar (min, 0 = no)', st.warn, 0, 10,
                  (v) => app.setSetting((s) => s.warn = v)),
              _num('Margen del modo bosque (segundos)', st.grace, 0, 60,
                  (v) => app.setSetting((s) => s.grace = v),
                  step: 5),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Avisos'),
              SwitchRow('Sonido', st.sound, (v) => app.setSetting((s) => s.sound = v)),
              SwitchRow('Vibración', st.vibe, (v) => app.setSetting((s) => s.vibe = v)),
              const Muted(
                'Los avisos aparecen dentro de la app (y suenan o vibran). No se envían notificaciones del sistema.',
                small: true,
                padding: EdgeInsets.only(top: 4),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tema'),
              ChipWrap([
                for (final e in const [
                  ['auto', 'Automático'],
                  ['light', 'Claro'],
                  ['dark', 'Oscuro'],
                ])
                  ChipOpt(e[1], st.theme == e[0], () => app.setSetting((s) => s.theme = e[0])),
              ]),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Tus datos'),
              const Muted(
                'Todo se guarda solo en este móvil, nada sale a internet. Haz una copia de vez en cuando.',
                small: true,
                padding: EdgeInsets.only(bottom: 12),
              ),
              Btn('Copia de seguridad', () => showBackupSheet(context), block: true),
              const SizedBox(height: 8),
              Btn('Borrar todo y empezar de cero', () {
                askConfirm(
                  context,
                  '¿Seguro? Se borrarán todas tus tareas, rutinas y registros de este móvil.',
                  app.wipe,
                );
              }, kind: 'ghost', block: true),
            ],
          ),
        ),
      ]);
    });
  }
}

void showBackupSheet(BuildContext context) {
  showSheet<void>(context, (c) => const _BackupSheet());
}

class _BackupSheet extends StatefulWidget {
  const _BackupSheet();

  @override
  State<_BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<_BackupSheet> {
  late final TextEditingController _c = TextEditingController(text: app.exportJson());

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Copia de seguridad',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            ),
            Btn('Cerrar', () => Navigator.of(context).pop(), kind: 'ghost', small: true),
          ],
        ),
        const Muted(
          'Copia este texto y guárdalo en una nota o envíatelo. Para restaurar, pega una copia aquí (también sirve la de la versión web) y pulsa «Restaurar».',
          small: true,
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        TextField(
          controller: _c,
          minLines: 6,
          maxLines: 10,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: inputDeco(context, 'Pega aquí una copia'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Btn('Copiar', () async {
                await Clipboard.setData(ClipboardData(text: _c.text));
                app.toast('Copiado');
              }, kind: 'primary'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Btn('Restaurar', () {
                final txt = _c.text;
                askConfirm(
                  context,
                  'Esto sustituirá tus datos actuales por los de la copia. ¿Seguir?',
                  () {
                    if (app.restore(txt)) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    } else {
                      app.toast('Ese texto no es una copia válida de Enfoque');
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================================
//  Acerca de / ideas que ayudan
// =====================================================================

class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage('Ideas que ayudan', const [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            H2('Ideas que ayudan'),
            Bullet('Si algo lleva menos de dos minutos, hazlo ahora.'),
            Bullet(
                'Cuando una tarea te da pereza, normalmente el primer paso es demasiado grande. Trocéala.'),
            Bullet('Elige qué hacer según tu energía, además de la urgencia.'),
            Bullet('Apunta las cosas y déjalas a la vista. Lo que no ves, se olvida.'),
            Bullet(
                'El aviso antes de que acabe el temporizador te ayuda a cambiar de tarea sin brusquedad.'),
            Bullet('Un día malo no borra lo que has avanzado.'),
          ],
        ),
      ),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            H2('Sobre Enfoque'),
            Muted(
              'Es tu app personal: funciona sin conexión y guarda todo en este dispositivo. No es un tratamiento ni sustituye a un profesional; es una ayuda para organizarte.',
              small: true,
            ),
          ],
        ),
      ),
    ]);
  }
}
