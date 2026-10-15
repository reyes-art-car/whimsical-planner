import 'package:flutter/painting.dart' show Color;
import 'util.dart';

Color hexColor(String h) {
  var s = h.replaceAll('#', '');
  if (s.length == 6) s = 'FF$s';
  final v = int.tryParse(s, radix: 16);
  return Color(v ?? 0xFFE9A15B);
}

// =====================================================================
//  MODELOS (el JSON es compatible con la copia de seguridad de la web)
// =====================================================================

class SubTask {
  String id;
  String t;
  bool done;
  SubTask({String? id, required this.t, this.done = false}) : id = id ?? uid();
  factory SubTask.fromJson(Map<String, dynamic> j) => SubTask(
      id: jStr(j['id'], uid()), t: jStr(j['t']), done: jBool(j['done']));
  Map<String, dynamic> toJson() => {'id': id, 't': t, 'done': done};
}

class Task {
  String id;
  String title;
  String energy;
  int est;
  List<SubTask> subs;
  bool done;
  bool star;
  int created;
  int spent;
  int? doneAt;
  String? homeChoreId;

  Task({
    String? id,
    required this.title,
    this.energy = 'media',
    this.est = 15,
    List<SubTask>? subs,
    this.done = false,
    this.star = false,
    int? created,
    this.spent = 0,
    this.doneAt,
    this.homeChoreId,
  })  : id = id ?? uid(),
        subs = subs ?? <SubTask>[],
        created = created ?? nowMs();

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: jStr(j['id'], uid()),
        title: jStr(j['title']),
        homeChoreId:
            j['homeChoreId'] is String ? j['homeChoreId'] as String : null,
        energy: jStr(j['energy'], 'media'),
        est: jInt(j['est']),
        subs: jList(j['subs']).map((e) => SubTask.fromJson(jMap(e))).toList(),
        done: jBool(j['done']),
        star: jBool(j['star']),
        created: jInt(j['created'], nowMs()),
        spent: jInt(j['spent']),
        doneAt: j['doneAt'] is num ? (j['doneAt'] as num).toInt() : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'energy': energy,
        'est': est,
        'subs': subs.map((e) => e.toJson()).toList(),
        'done': done,
        'star': star,
        'created': created,
        'spent': spent,
        'doneAt': doneAt,
        'homeChoreId': homeChoreId,
      };
}

class InboxItem {
  String id;
  String t;
  int at;
  InboxItem({String? id, required this.t, int? at})
      : id = id ?? uid(),
        at = at ?? nowMs();
  factory InboxItem.fromJson(Map<String, dynamic> j) => InboxItem(
      id: jStr(j['id'], uid()), t: jStr(j['t']), at: jInt(j['at'], nowMs()));
  Map<String, dynamic> toJson() => {'id': id, 't': t, 'at': at};
}

class RStep {
  String id;
  String t;
  int min;
  RStep({String? id, required this.t, this.min = 0}) : id = id ?? uid();
  factory RStep.fromJson(Map<String, dynamic> j) =>
      RStep(id: jStr(j['id'], uid()), t: jStr(j['t']), min: jInt(j['min']));
  Map<String, dynamic> toJson() => {'id': id, 't': t, 'min': min};
}

class RDone {
  String date;
  List<String> ids;
  bool aw;
  RDone({required this.date, required this.ids, this.aw = false});
  factory RDone.fromJson(Map<String, dynamic> j) =>
      RDone(date: jStr(j['date']), ids: jStrList(j['ids']), aw: jBool(j['aw']));
  Map<String, dynamic> toJson() => {'date': date, 'ids': ids, 'aw': aw};
}

const Map<String, String> legacyIcons = {
  '☀️': 'sol',
  '☀': 'sol',
  '🌙': 'luna',
  '🚪': 'puerta',
  '✨': 'estrella',
};

class Routine {
  String id;
  String icon;
  String name;
  RDone? done;
  String at;
  List<int> days;
  bool auto;
  List<RStep> steps;
  Map<String, int> hist;
  String? alerted;

  Routine({
    String? id,
    this.icon = 'estrella',
    required this.name,
    this.done,
    this.at = '',
    List<int>? days,
    this.auto = false,
    List<RStep>? steps,
    Map<String, int>? hist,
    this.alerted,
  })  : id = id ?? uid(),
        days = days ?? <int>[],
        steps = steps ?? <RStep>[],
        hist = hist ?? <String, int>{};

  factory Routine.fromJson(Map<String, dynamic> j) {
    var icon = jStr(j['icon']);
    if (icon.isEmpty) {
      icon = legacyIcons[jStr(j['emoji'])] ?? 'estrella';
    }
    final d = j['done'];
    return Routine(
      id: jStr(j['id'], uid()),
      icon: icon,
      name: jStr(j['name'], 'Rutina'),
      done: d is Map ? RDone.fromJson(jMap(d)) : null,
      at: jStr(j['at']),
      days: jList(j['days']).whereType<num>().map((e) => e.toInt()).toList(),
      auto: jBool(j['auto']),
      steps: jList(j['steps']).map((e) => RStep.fromJson(jMap(e))).toList(),
      hist: jIntMap(j['hist']),
      alerted: j['alerted'] is String ? j['alerted'] as String : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'icon': icon,
        'name': name,
        'done': done?.toJson(),
        'at': at,
        'days': days,
        'auto': auto,
        'steps': steps.map((e) => e.toJson()).toList(),
        'hist': hist,
        'alerted': alerted,
      };
}

class Habit {
  String id;
  String name;
  Map<String, int> log;
  Habit({String? id, required this.name, Map<String, int>? log})
      : id = id ?? uid(),
        log = log ?? <String, int>{};
  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
      id: jStr(j['id'], uid()), name: jStr(j['name']), log: jIntMap(j['log']));
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'log': log};
}

class Mood {
  int m;
  String e;
  String note;
  bool aw;
  Mood({this.m = 0, this.e = '', this.note = '', this.aw = false});
  factory Mood.fromJson(Map<String, dynamic> j) => Mood(
      m: jInt(j['m']),
      e: jStr(j['e']),
      note: jStr(j['note']),
      aw: j['aw'] == true || j['aw'] == 1);
  Map<String, dynamic> toJson() => {'m': m, 'e': e, 'note': note, 'aw': aw};
}

class Reminder {
  String id;
  String text;
  String time;
  bool daily;
  String date;
  String? last;
  bool off;
  Reminder({
    String? id,
    required this.text,
    required this.time,
    this.daily = false,
    required this.date,
    this.last,
    this.off = false,
  }) : id = id ?? uid();
  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
      id: jStr(j['id'], uid()),
      text: jStr(j['text']),
      time: jStr(j['time'], '09:00'),
      daily: jBool(j['daily']),
      date: jStr(j['date'], dkey()),
      last: j['last'] is String ? j['last'] as String : null,
      off: jBool(j['off']));
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'time': time,
        'daily': daily,
        'date': date,
        'last': last,
        'off': off,
      };
}

class Pet {
  String name;
  String kind;
  String color;
  double hunger;
  double joy;
  int xp;
  int last;
  int lastPet;
  int born;
  Pet({
    required this.name,
    required this.kind,
    required this.color,
    this.hunger = 80,
    this.joy = 80,
    this.xp = 0,
    int? last,
    this.lastPet = 0,
    int? born,
  })  : last = last ?? nowMs(),
        born = born ?? nowMs();
  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
      name: jStr(j['name'], 'Mochi'),
      kind: jStr(j['kind'], 'gato'),
      color: jStr(j['color'], '#E9A15B'),
      hunger: jDbl(j['hunger'], 80),
      joy: jDbl(j['joy'], 80),
      xp: jInt(j['xp']),
      last: jInt(j['last'], nowMs()),
      lastPet: jInt(j['lastPet']),
      born: jInt(j['born'], nowMs()));
  Map<String, dynamic> toJson() => {
        'name': name,
        'kind': kind,
        'color': color,
        'hunger': hunger,
        'joy': joy,
        'xp': xp,
        'last': last,
        'lastPet': lastPet,
        'born': born,
      };
}

class TreeRec {
  String id;
  String d;
  int min;
  String kind;
  bool dead;
  int at;
  String task;
  TreeRec({
    String? id,
    String? d,
    required this.min,
    required this.kind,
    this.dead = false,
    int? at,
    this.task = '',
  })  : id = id ?? uid(),
        d = d ?? dkey(),
        at = at ?? nowMs();
  factory TreeRec.fromJson(Map<String, dynamic> j) => TreeRec(
      id: jStr(j['id'], uid()),
      d: jStr(j['d'], dkey()),
      min: jInt(j['min']),
      kind: jStr(j['kind'], 'brote'),
      dead: jBool(j['dead']),
      at: jInt(j['at'], nowMs()),
      task: jStr(j['task']));
  Map<String, dynamic> toJson() => {
        'id': id,
        'd': d,
        'min': min,
        'kind': kind,
        'dead': dead,
        'at': at,
        'task': task,
      };
}

class FocusTimer {
  String kind; // focus | short | long
  int dur;
  int? end;
  int left;
  String? taskId;
  bool pomo;
  int fmin;
  int cycle;
  bool warned;
  int lastCheck;
  bool fresh;
  bool tree;
  String species;
  bool dead;
  int? hiddenAt;

  FocusTimer({
    this.kind = 'focus',
    required this.dur,
    this.end,
    required this.left,
    this.taskId,
    this.pomo = false,
    required this.fmin,
    this.cycle = 0,
    this.warned = false,
    this.lastCheck = 0,
    this.fresh = false,
    this.tree = false,
    this.species = 'brote',
    this.dead = false,
    this.hiddenAt,
  });

  FocusTimer copy() => FocusTimer(
        kind: kind,
        dur: dur,
        end: end,
        left: left,
        taskId: taskId,
        pomo: pomo,
        fmin: fmin,
        cycle: cycle,
        warned: warned,
        lastCheck: lastCheck,
        fresh: fresh,
        tree: tree,
        species: species,
        dead: dead,
        hiddenAt: hiddenAt,
      );

  factory FocusTimer.fromJson(Map<String, dynamic> j) => FocusTimer(
        kind: jStr(j['kind'], 'focus'),
        dur: jInt(j['dur'], 25 * 60000),
        end: j['end'] is num ? (j['end'] as num).toInt() : null,
        left: jInt(j['left'], 25 * 60000),
        taskId: j['taskId'] is String ? j['taskId'] as String : null,
        pomo: jBool(j['pomo']),
        fmin: jInt(j['fmin'], 25),
        cycle: jInt(j['cycle']),
        warned: jBool(j['warned']),
        lastCheck: jInt(j['lastCheck']),
        fresh: jBool(j['fresh']),
        tree: jBool(j['tree']),
        species: jStr(j['species'], 'brote'),
        dead: jBool(j['dead']),
        hiddenAt: j['hiddenAt'] is num ? (j['hiddenAt'] as num).toInt() : null,
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'dur': dur,
        'end': end,
        'left': left,
        'taskId': taskId,
        'pomo': pomo,
        'fmin': fmin,
        'cycle': cycle,
        'warned': warned,
        'lastCheck': lastCheck,
        'fresh': fresh,
        'tree': tree,
        'species': species,
        'dead': dead,
        'hiddenAt': hiddenAt,
      };
}

class JProg {
  int step;
  String since;
  JProg({this.step = 0, required this.since});
  factory JProg.fromJson(Map<String, dynamic> j) =>
      JProg(step: jInt(j['step']), since: jStr(j['since'], dkey()));
  Map<String, dynamic> toJson() => {'step': step, 'since': since};
}

class JourneyState {
  String? active;
  Map<String, JProg> prog;
  List<String> done;
  JourneyState({this.active, Map<String, JProg>? prog, List<String>? done})
      : prog = prog ?? <String, JProg>{},
        done = done ?? <String>[];
  factory JourneyState.fromJson(Map<String, dynamic> j) {
    final p = <String, JProg>{};
    jMap(j['prog']).forEach((k, v) => p[k] = JProg.fromJson(jMap(v)));
    return JourneyState(
      active: j['active'] is String ? j['active'] as String : null,
      prog: p,
      done: jStrList(j['done']),
    );
  }
  Map<String, dynamic> toJson() => {
        'active': active,
        'prog': prog.map((k, v) => MapEntry(k, v.toJson())),
        'done': done,
      };
}

class Challenge {
  String start;
  Map<String, int> log;
  bool done;
  Challenge({required this.start, Map<String, int>? log, this.done = false})
      : log = log ?? <String, int>{};
  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
      start: jStr(j['start'], dkey()),
      log: jIntMap(j['log']),
      done: jBool(j['done']));
  Map<String, dynamic> toJson() => {'start': start, 'log': log, 'done': done};
}

class JournalEntry {
  List<String> g;
  String t;
  String p;
  bool aw;
  JournalEntry({List<String>? g, this.t = '', this.p = '', this.aw = false})
      : g = g ?? <String>['', '', ''];
  factory JournalEntry.fromJson(Map<String, dynamic> j) {
    final g = jStrList(j['g']);
    while (g.length < 3) {
      g.add('');
    }
    return JournalEntry(
        g: g,
        t: jStr(j['t']),
        p: jStr(j['p']),
        aw: j['aw'] == true || j['aw'] == 1);
  }
  Map<String, dynamic> toJson() => {'g': g, 't': t, 'p': p, 'aw': aw};
}

class Settings {
  String name;
  int focus;
  int short;
  int long;
  int cycles;
  int warn;
  int checkin;
  bool sound;
  bool vibe;
  String theme; // auto | light | dark
  double noiseVol;
  int dayStart;
  int dayEnd;
  bool forest;
  int grace;
  String tree;

  Settings({
    this.name = 'Reyes',
    this.focus = 25,
    this.short = 5,
    this.long = 15,
    this.cycles = 4,
    this.warn = 2,
    this.checkin = 10,
    this.sound = true,
    this.vibe = true,
    this.theme = 'auto',
    this.noiseVol = 0.4,
    this.dayStart = 7,
    this.dayEnd = 23,
    this.forest = true,
    this.grace = 10,
    this.tree = 'auto',
  });

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
        name: jStr(j['name'], 'Reyes'),
        focus: jInt(j['focus'], 25),
        short: jInt(j['short'], 5),
        long: jInt(j['long'], 15),
        cycles: jInt(j['cycles'], 4),
        warn: jInt(j['warn'], 2),
        checkin: jInt(j['checkin'], 10),
        sound: jBool(j['sound'], true),
        vibe: jBool(j['vibe'], true),
        theme: jStr(j['theme'], 'auto'),
        noiseVol: jDbl(j['noiseVol'], 0.4),
        dayStart: jInt(j['dayStart'], 7),
        dayEnd: jInt(j['dayEnd'], 23),
        forest: jBool(j['forest'], true),
        grace: jInt(j['grace'], 10),
        tree: jStr(j['tree'], 'auto'),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'focus': focus,
        'short': short,
        'long': long,
        'cycles': cycles,
        'warn': warn,
        'checkin': checkin,
        'sound': sound,
        'vibe': vibe,
        'theme': theme,
        'noiseVol': noiseVol,
        'dayStart': dayStart,
        'dayEnd': dayEnd,
        'forest': forest,
        'grace': grace,
        'tree': tree,
      };
}

class AppData {
  int mig;
  int points;
  List<Task> tasks;
  List<InboxItem> inbox;
  List<Routine> routines;
  List<Habit> habits;
  Map<String, Mood> moods;
  Map<String, int> focus;
  Map<String, int> doneLog;
  List<Reminder> reminders;
  FocusTimer? timer;
  Pet? pet;
  int food;
  int foodProg;
  List<TreeRec> forest; // Copias antiguas.
  Map<String, String> homeDone;
  Map<String, int> med;
  JourneyState journey;
  Map<String, Challenge> challenges;
  Map<String, JournalEntry> journal;
  String why;
  Map<String, int> acts;
  Settings settings;

  AppData({
    this.mig = 1,
    this.points = 0,
    List<Task>? tasks,
    List<InboxItem>? inbox,
    List<Routine>? routines,
    List<Habit>? habits,
    Map<String, Mood>? moods,
    Map<String, int>? focus,
    Map<String, int>? doneLog,
    List<Reminder>? reminders,
    this.timer,
    this.pet,
    this.food = 3,
    this.foodProg = 0,
    List<TreeRec>? forest,
    Map<String, String>? homeDone,
    Map<String, int>? med,
    JourneyState? journey,
    Map<String, Challenge>? challenges,
    Map<String, JournalEntry>? journal,
    this.why = '',
    Map<String, int>? acts,
    Settings? settings,
  })  : tasks = tasks ?? <Task>[],
        inbox = inbox ?? <InboxItem>[],
        routines = routines ?? <Routine>[],
        habits = habits ?? <Habit>[],
        moods = moods ?? <String, Mood>{},
        focus = focus ?? <String, int>{},
        doneLog = doneLog ?? <String, int>{},
        reminders = reminders ?? <Reminder>[],
        forest = forest ?? <TreeRec>[],
        homeDone = homeDone ?? <String, String>{},
        med = med ?? <String, int>{},
        journey = journey ?? JourneyState(),
        challenges = challenges ?? <String, Challenge>{},
        journal = journal ?? <String, JournalEntry>{},
        acts = acts ?? <String, int>{},
        settings = settings ?? Settings();

  factory AppData.defaults() {
    final t2 = Task(
        title: 'Trocea una tarea grande en pasos pequeños',
        energy: 'media',
        est: 10,
        subs: [SubTask(t: 'Escribe el primer paso de 2 minutos')]);
    return AppData(
      tasks: [
        Task(
            title: 'Toca el círculo para completar una tarea',
            energy: 'baja',
            est: 2),
        t2,
      ],
      routines: [
        Routine(
          icon: 'sol',
          name: 'Rutina de mañana',
          at: '08:00',
          days: [1, 2, 3, 4, 5],
          steps: [
            RStep(t: 'Beber un vaso de agua', min: 1),
            RStep(t: 'Lavarme la cara y los dientes', min: 5),
            RStep(t: 'Vestirme', min: 10),
            RStep(t: 'Desayunar', min: 15),
            RStep(t: 'Salir a andar', min: 30),
            RStep(t: 'Mirar mi plan del día en Enfoque', min: 2),
          ],
        ),
        Routine(
          icon: 'luna',
          name: 'Rutina de noche',
          at: '22:30',
          days: [0, 1, 2, 3, 4, 5, 6],
          steps: [
            RStep(t: 'Preparar la ropa de mañana', min: 5),
            RStep(t: 'Dejar llaves y cartera en su sitio', min: 1),
            RStep(t: 'Cargar el móvil fuera de la cama', min: 1),
            RStep(t: 'Lavarme los dientes', min: 3),
            RStep(t: 'Escribir', min: 10),
            RStep(t: 'Leer', min: 20),
            RStep(t: 'Vaciar la cabeza en el vertedero mental', min: 3),
          ],
        ),
        Routine(
          icon: 'puerta',
          name: 'Antes de salir de casa',
          steps: [
            RStep(t: 'Llaves'),
            RStep(t: 'Móvil'),
            RStep(t: 'Cartera'),
            RStep(t: 'Cargador / auriculares'),
            RStep(t: 'Luces y fuegos apagados'),
          ],
        ),
      ],
      habits: [
        Habit(name: 'Beber agua'),
        Habit(name: 'Moverme 10 minutos'),
        Habit(name: 'Acostarme a mi hora'),
      ],
    );
  }

  factory AppData.fromJson(Map<String, dynamic> j) {
    final moods = <String, Mood>{};
    jMap(j['moods']).forEach((k, v) => moods[k] = Mood.fromJson(jMap(v)));
    final ch = <String, Challenge>{};
    jMap(j['challenges'])
        .forEach((k, v) => ch[k] = Challenge.fromJson(jMap(v)));
    final jr = <String, JournalEntry>{};
    jMap(j['journal'])
        .forEach((k, v) => jr[k] = JournalEntry.fromJson(jMap(v)));

    final d = AppData(
      mig: jInt(j['mig']),
      points: jInt(j['points']),
      tasks: jList(j['tasks']).map((e) => Task.fromJson(jMap(e))).toList(),
      inbox: jList(j['inbox']).map((e) => InboxItem.fromJson(jMap(e))).toList(),
      routines:
          jList(j['routines']).map((e) => Routine.fromJson(jMap(e))).toList(),
      habits: jList(j['habits']).map((e) => Habit.fromJson(jMap(e))).toList(),
      moods: moods,
      focus: jIntMap(j['focus']),
      doneLog: jIntMap(j['doneLog']),
      reminders:
          jList(j['reminders']).map((e) => Reminder.fromJson(jMap(e))).toList(),
      timer: j['timer'] is Map ? FocusTimer.fromJson(jMap(j['timer'])) : null,
      pet: j['pet'] is Map ? Pet.fromJson(jMap(j['pet'])) : null,
      food: jInt(j['food'], 3),
      foodProg: jInt(j['foodProg']),
      forest: jList(j['forest']).map((e) => TreeRec.fromJson(jMap(e))).toList(),
      homeDone: jMap(j['homeDone']).map((k, v) => MapEntry(k, jStr(v))),
      med: jIntMap(j['med']),
      journey: JourneyState.fromJson(jMap(j['journey'])),
      challenges: ch,
      journal: jr,
      why: jStr(j['why']),
      acts: jIntMap(j['acts']),
      settings: Settings.fromJson(jMap(j['settings'])),
    );
    d._migrate();
    return d;
  }

  /// Migración 1: pasos nuevos en las rutinas de mañana y noche.
  void _migrate() {
    if (mig >= 1) return;
    void add(Routine? r, String txt, int min, String after) {
      if (r == null) return;
      final exists =
          r.steps.any((x) => x.t.toLowerCase().startsWith(txt.toLowerCase()));
      if (exists) return;
      final i = r.steps.indexWhere((x) => x.t == after);
      final st = RStep(t: txt, min: min);
      if (i >= 0) {
        r.steps.insert(i + 1, st);
      } else {
        r.steps.add(st);
      }
    }

    Routine? find(String name, String icon) {
      for (final r in routines) {
        if (r.name == name) return r;
      }
      for (final r in routines) {
        if (r.icon == icon) return r;
      }
      return null;
    }

    final m = find('Rutina de mañana', 'sol');
    final n = find('Rutina de noche', 'luna');
    add(m, 'Salir a andar', 30, 'Desayunar');
    add(n, 'Escribir', 10, 'Lavarme los dientes');
    add(n, 'Leer', 20, 'Escribir');
    mig = 1;
  }

  Map<String, dynamic> toJson() => {
        'v': 1,
        'mig': mig,
        'points': points,
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'inbox': inbox.map((e) => e.toJson()).toList(),
        'routines': routines.map((e) => e.toJson()).toList(),
        'habits': habits.map((e) => e.toJson()).toList(),
        'moods': moods.map((k, v) => MapEntry(k, v.toJson())),
        'focus': focus,
        'doneLog': doneLog,
        'reminders': reminders.map((e) => e.toJson()).toList(),
        'timer': timer?.toJson(),
        'pet': pet?.toJson(),
        'food': food,
        'foodProg': foodProg,
        'forest': forest.map((e) => e.toJson()).toList(),
        'homeDone': homeDone,
        'med': med,
        'journey': journey.toJson(),
        'challenges': challenges.map((k, v) => MapEntry(k, v.toJson())),
        'journal': journal.map((k, v) => MapEntry(k, v.toJson())),
        'why': why,
        'acts': acts,
        'settings': settings.toJson(),
      };
}

// =====================================================================
//  CONTENIDO FIJO
// =====================================================================

const List<String> energyKeys = ['baja', 'media', 'alta'];
const Map<String, String> energyName = {
  'baja': 'Baja',
  'media': 'Media',
  'alta': 'Alta',
};
const Map<String, int> energyOrd = {'baja': 0, 'media': 1, 'alta': 2};

// Mascota
const Map<String, String> petKinds = {
  'gato': 'Gato',
  'conejo': 'Conejo',
  'osito': 'Osito',
  'pollito': 'Pollito',
};
const List<String> petColors = [
  '#E9A15B',
  '#8FB4D9',
  '#A9D18E',
  '#EFA3B8',
  '#C3AEE6',
  '#F0CE5E',
];
const List<int> stageXp = [0, 30, 150, 500, 1200, 3000];
const List<String> stageName = [
  'Huevo',
  'Bebé',
  'Pequeño',
  'Joven',
  'Adulto',
  'Leyenda',
];
const Map<int, String> stageUnlock = {
  3: 'bufanda',
  4: 'brote en la cabeza',
  5: 'corona',
};
const List<String> petPhrases = [
  'Me gusta pasar el día contigo.',
  'Un paso pequeño también es avanzar.',
  '¿Has bebido agua hoy?',
  'No hace falta hacerlo perfecto, solo empezarlo.',
  'Hoy cuenta todo lo que hagas, aunque sea poco.',
  'Si te atascas, troceamos la tarea juntos.',
  'Respira hondo. Vamos de una en una.',
];

// Árboles
class TreeSpec {
  final String name;
  final bool fem;
  final int? autoMin;
  final Color color;
  const TreeSpec(this.name, this.fem, this.autoMin, this.color);
}

const Map<String, TreeSpec> trees = {
  'brote': TreeSpec('Brote', false, 0, Color(0xFF7BC47F)),
  'arbusto': TreeSpec('Arbusto', false, 10, Color(0xFF5FAE6A)),
  'pino': TreeSpec('Pino', false, 25, Color(0xFF2F8F5B)),
  'roble': TreeSpec('Roble', false, 45, Color(0xFF4E9F3D)),
  'cerezo': TreeSpec('Cerezo', false, 60, Color(0xFFF2A7C3)),
  'jacaranda': TreeSpec('Jacarandá', false, null, Color(0xFF9B6FD6)),
  'lavanda': TreeSpec('Lavanda', true, null, Color(0xFFA88BE0)),
  'glicinia': TreeSpec('Glicinia', true, null, Color(0xFF8C7BE6)),
  'abeto': TreeSpec('Abeto nevado', false, null, Color(0xFF2E7D6B)),
  'cactus': TreeSpec('Cactus', false, null, Color(0xFF5DAA6E)),
  'palmera': TreeSpec('Palmera', true, null, Color(0xFF4FA65A)),
};

String treeKindFor(int min) {
  if (min >= 60) return 'cerezo';
  if (min >= 45) return 'roble';
  if (min >= 25) return 'pino';
  if (min >= 10) return 'arbusto';
  return 'brote';
}

// Retos opcionales
class RetoDef {
  final String name;
  final String desc;
  const RetoDef(this.name, this.desc);
}

const Map<String, RetoDef> retos = {
  'paseo': RetoDef('Paseo de 10 minutos',
      'Sal a caminar cada día, aunque sea a por el pan.'),
  'cama':
      RetoDef('Sin móvil en la cama', 'El móvil duerme fuera del dormitorio.'),
  'agua': RetoDef(
      'Agua con cada comida', 'Un vaso en el desayuno, la comida y la cena.'),
  'orden': RetoDef('Ordenar 5 minutos',
      'Temporizador de cinco minutos y a recoger una zona.'),
  'lectura':
      RetoDef('Leer 10 minutos', 'En papel o libro electrónico, sin redes.'),
  'gracias': RetoDef(
      'Tres cosas buenas', 'Apunta en el diario tres cosas buenas del día.'),
  'sol': RetoDef('Luz natural por la mañana',
      'Cinco minutos al aire libre antes de las once.'),
};

// Diario
const List<String> journalPrompts = [
  '¿Qué ha salido bien hoy, aunque sea pequeño?',
  '¿Qué te ha costado y cómo lo has sacado adelante?',
  '¿Qué necesitas mañana para que el día vaya mejor?',
  '¿Qué has hecho hoy por ti?',
  '¿Qué te ha hecho reír o sonreír?',
  '¿Qué puedes soltar hoy?',
  '¿Quién te ha ayudado últimamente?',
  '¿Qué harías distinto si repitieras el día?',
];

// Actividades guiadas
class ActStep {
  final String text;
  final int secs;
  const ActStep(this.text, this.secs);
}

class ActDef {
  final String name;
  final String desc;
  final String icon;
  final List<ActStep> steps;
  const ActDef(this.name, this.desc, this.icon, this.steps);
}

const Map<String, ActDef> activities = {
  'estirar': ActDef(
      'Estiramientos', '5 minutos para soltar el cuerpo', 'actividades', [
    ActStep('Gira el cuello despacio hacia la derecha', 30),
    ActStep('Ahora hacia la izquierda', 30),
    ActStep('Sube los hombros hacia las orejas y suéltalos', 30),
    ActStep('Brazos arriba, estírate hacia el techo', 30),
    ActStep('Inclínate hacia la derecha', 30),
    ActStep('Inclínate hacia la izquierda', 30),
    ActStep('Dobla el tronco hacia delante, sin forzar', 40),
    ActStep('Gira la cintura a un lado y al otro', 40),
    ActStep('Sacude las manos y los pies', 20),
    ActStep('Respira hondo tres veces', 20),
  ]),
  'activar': ActDef('Activarte', '3 minutos para despejarte', 'actividades', [
    ActStep('Marcha en el sitio subiendo las rodillas', 45),
    ActStep('Círculos grandes con los brazos', 30),
    ActStep('Sentadillas suaves, a tu ritmo', 45),
    ActStep('Estírate de puntillas', 30),
    ActStep('Respira hondo y suelta el aire despacio', 30),
  ]),
  'ojos': ActDef('Descanso de pantalla', '1 minuto para tus ojos', 'animo', [
    ActStep('Mira algo lejano, por la ventana si puedes', 20),
    ActStep('Parpadea despacio diez veces', 15),
    ActStep('Cierra los ojos y respira', 25),
  ]),
  'siesta':
      ActDef('Siesta corta', '20 minutos y te despierto con suavidad', 'luna', [
    ActStep(
        'Túmbate o apoya la cabeza. Cierra los ojos. No hace falta dormirse: descansar ya cuenta.',
        1200),
  ]),
};

// Meditaciones
class MedDef {
  final String name;
  final String desc;
  final List<String> prompts;
  const MedDef(this.name, this.desc, this.prompts);
}

const Map<String, MedDef> meditations = {
  'resp': MedDef('Respiración consciente', 'Para calmar la mente acelerada.', [
    'Siéntate cómodo y cierra los ojos si te apetece.',
    'Nota el aire entrando por la nariz…',
    '…y saliendo despacio.',
    'Si tu mente se va a otra parte, no pasa nada. Vuelve a la respiración.',
    'Cuenta cada exhalación del 1 al 10 y vuelve a empezar.',
    'Suelta los hombros y la mandíbula.',
    'Sigue respirando a tu ritmo.',
    'Distraerte y volver es la práctica. Lo estás haciendo bien.',
    'Unas respiraciones más…',
    'Poco a poco, vuelve a la habitación.',
  ]),
  'cuerpo':
      MedDef('Escaneo corporal', 'Para soltar tensión y bajar al cuerpo.', [
    'Ponte cómodo. Respira hondo tres veces.',
    'Lleva la atención a los pies. ¿Qué notas?',
    'Sube por las piernas: rodillas, muslos.',
    'Nota el peso de tu cuerpo apoyado.',
    'Barriga y pecho: cómo suben y bajan.',
    'Manos y brazos. Deja que pesen.',
    'Hombros: suéltalos un poco más.',
    'Cuello, mandíbula y frente. Relaja la cara.',
    'Siente el cuerpo entero a la vez.',
    'Mueve suavemente los dedos y abre los ojos.',
  ]),
  'nubes': MedDef('Pensamientos como nubes', 'Para cuando la cabeza no para.', [
    'Imagina un cielo amplio y tranquilo.',
    'Cada pensamiento que llegue es una nube.',
    'No la persigas ni la empujes: solo mírala pasar.',
    'Si te enganchas a una, dile «pensamiento» y vuelve al cielo.',
    'Los sonidos también son nubes. Llegan y se van.',
    'Tú eres el cielo, no las nubes.',
    'Sigue observando con curiosidad.',
    'Respira y deja pasar lo que venga.',
    'Vuelve despacio, trayendo esta calma contigo.',
  ]),
  'pausa': MedDef('Pausa de 3 pasos', 'Un reinicio rápido entre tareas.', [
    'Para. ¿Qué está pasando ahora mismo dentro de ti?',
    'Nota pensamientos, emociones y sensaciones, sin cambiarlas.',
    'Lleva toda la atención a la respiración.',
    'Respira con el abdomen, despacio.',
    'Ahora amplía la atención a todo el cuerpo.',
    '¿Qué es lo siguiente pequeño que quieres hacer?',
  ]),
  'silencio': MedDef('Silencio con campana', 'Sin voz guía, solo campanas.', [
    'Silencio. Quédate aquí, sin hacer nada más.',
  ]),
};

// Respiración guiada
class BreathPhase {
  final String label;
  final int secs;
  final bool big;
  const BreathPhase(this.label, this.secs, this.big);
}

class BreathDef {
  final String name;
  final List<BreathPhase> seq;
  const BreathDef(this.name, this.seq);
}

const Map<String, BreathDef> breathPatterns = {
  'caja': BreathDef('Caja 4-4-4-4', [
    BreathPhase('Inhala', 4, true),
    BreathPhase('Mantén', 4, true),
    BreathPhase('Exhala', 4, false),
    BreathPhase('Mantén', 4, false),
  ]),
  '478': BreathDef('4-7-8', [
    BreathPhase('Inhala', 4, true),
    BreathPhase('Mantén', 7, true),
    BreathPhase('Exhala', 8, false),
  ]),
  'coh': BreathDef('Coherente 5-5', [
    BreathPhase('Inhala', 5, true),
    BreathPhase('Exhala', 5, false),
  ]),
};

// =====================================================================
//  AYUDAS DE MASCOTA
// =====================================================================

int petStage(Pet p) {
  var i = 0;
  for (var j = 0; j < stageXp.length; j++) {
    if (p.xp >= stageXp[j]) i = j;
  }
  return i;
}

/// sleep | happy | ok | sad
String petMood(Pet p) {
  final h = DateTime.now().hour;
  if (h >= 23 || h < 7) return 'sleep';
  final a = (p.hunger + p.joy) / 2;
  if (a >= 65) return 'happy';
  if (a >= 35) return 'ok';
  return 'sad';
}
