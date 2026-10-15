import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'audio.dart';
import 'data.dart';
import 'util.dart';

const String storageKey = 'enfoque.v1';

enum UiKind { toast, celebrate, planted, confetti }

class UiEvent {
  final UiKind kind;
  final String title;
  final String text;
  final int n;
  final String id;
  const UiEvent(this.kind, {this.title = '', this.text = '', this.n = 0, this.id = ''});
}

/// Sesión de meditación en curso.
class MedSession {
  final String type;
  final int min;
  final int bell;
  final int dur;
  int end;
  int bells = 0;
  MedSession(this.type, this.min, this.bell, this.dur, this.end);
}

/// Actividad guiada en curso.
class ActSession {
  final String id;
  int idx;
  int end;
  ActSession(this.id, this.idx, this.end);
}

class AppState extends ChangeNotifier {
  AppData d = AppData.defaults();
  SharedPreferences? _prefs;
  bool loaded = false;

  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> msgKey = GlobalKey<ScaffoldMessengerState>();
  final StreamController<UiEvent> _events = StreamController<UiEvent>.broadcast();
  Stream<UiEvent> get events => _events.stream;

  // ---- estado de interfaz compartido ----
  int tab = 0;
  int skip = 0;
  int hopN = 0;
  String noiseType = 'off';
  String? pickedId;

  // rutina en curso (pantalla "run")
  String? runRoutineId;
  String? runStepId;
  int runEnd = 0;
  int? runPausedLeft;
  bool runAlerted = false;

  MedSession? med;
  String medType = 'resp';
  int medMin = 5;
  int medBell = 0;
  ActSession? act;

  Timer? _ticker;
  int _lastMin = -1;
  int _lastPetTick = 0;
  bool _disposed = false;

  // =====================================================================
  //  Arranque, guardado
  // =====================================================================

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(storageKey);
      if (raw != null && raw.isNotEmpty) {
        final j = jsonDecode(raw);
        if (j is Map) d = AppData.fromJson(Map<String, dynamic>.from(j));
      }
    } catch (_) {
      d = AppData.defaults();
    }
    if (d.timer != null) tab = 2;
    medMin = 5;
    petTick();
    loaded = true;
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) => tick());
    if (d.timer != null && d.timer!.end != null && d.timer!.tree && d.timer!.kind == 'focus') {
      _wakeOn();
    }
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void save() {
    try {
      _prefs?.setString(storageKey, jsonEncode(d.toJson()));
    } catch (_) {}
  }

  /// Guarda y avisa a la interfaz.
  void commit() {
    save();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _events.close();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  // =====================================================================
  //  Avisos al usuario
  // =====================================================================

  void _emit(UiEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  void toast(String msg) => _emit(UiEvent(UiKind.toast, text: msg));
  void confetti([int n = 70]) => _emit(UiEvent(UiKind.confetti, n: n));
  void celebrate(String title, String text, int streakN) =>
      _emit(UiEvent(UiKind.celebrate, title: title, text: text, n: streakN));
  void showPlanted(String id) => _emit(UiEvent(UiKind.planted, id: id));

  void chime() => Sfx.chime(d.settings.sound);
  void bowl() => Sfx.bowl(d.settings.sound);
  void buzz([int kind = 1]) {
    if (!d.settings.vibe) return;
    try {
      if (kind >= 2) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {}
  }

  void alertDone(String title, String body) {
    toast('$title $body');
    chime();
    buzz(2);
  }

  Future<void> _wakeOn() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  Future<void> _wakeOff() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  // =====================================================================
  //  Consultas
  // =====================================================================

  Task? getTask(String? id) {
    if (id == null) return null;
    for (final t in d.tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Routine? getRoutine(String? id) {
    if (id == null) return null;
    for (final r in d.routines) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<Task> pending() => d.tasks.where((t) => !t.done).toList();

  String? todayEnergy() {
    final m = d.moods[dkey()];
    if (m == null || m.e.isEmpty) return null;
    return m.e;
  }

  int fit(Task t, String? e) {
    if (e == null) return 0;
    if (t.energy == e) return 2;
    return (energyOrd[t.energy] ?? 1) < (energyOrd[e] ?? 1) ? 1 : 0;
  }

  List<Task> rankedTasks() {
    final e = todayEnergy();
    final l = pending();
    l.sort((a, b) {
      final s = (b.star ? 1 : 0) - (a.star ? 1 : 0);
      if (s != 0) return s;
      final f = fit(b, e) - fit(a, e);
      if (f != 0) return f;
      final m = (a.est == 0 ? 99 : a.est) - (b.est == 0 ? 99 : b.est);
      if (m != 0) return m;
      return a.created - b.created;
    });
    return l;
  }

  Task? nowTask() {
    final l = rankedTasks();
    if (l.isEmpty) return null;
    return l[skip % l.length];
  }

  int streakOf(Map<String, int> log) {
    var day = DateTime.now();
    if (log[dkey(day)] == null) day = DateTime(day.year, day.month, day.day - 1);
    var n = 0;
    while (log[dkey(day)] != null) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  int habitsToday() => d.habits.where((h) => h.log[dkey()] != null).length;

  String speciesFor(int min) {
    final s = d.settings.tree;
    if (s != 'auto' && trees.containsKey(s)) return s;
    return treeKindFor(min);
  }

  // =====================================================================
  //  Puntos y mascota
  // =====================================================================

  void gain(int n) {
    if (n <= 0) return;
    d.points += n;
    d.foodProg += n;
    while (d.foodProg >= 10) {
      d.foodProg -= 10;
      d.food += 1;
    }
    final p = d.pet;
    if (p != null) {
      final s0 = petStage(p);
      p.xp += n;
      p.joy = math.min(100.0, p.joy + n * 0.6);
      final s1 = petStage(p);
      if (s1 > s0) {
        final name = p.name;
        Timer(const Duration(milliseconds: 900), () {
          final extra = stageUnlock[s1] != null ? ' y lleva ${stageUnlock[s1]}' : '';
          toast(s0 == 0
              ? '¡$name ha nacido!'
              : '¡$name ha crecido! Ahora es ${stageName[s1].toLowerCase()}$extra');
          chime();
          confetti(90);
          notifyListeners();
        });
      }
    }
  }

  void petTick() {
    final p = d.pet;
    if (p == null) return;
    final hr = (nowMs() - p.last) / 3600000.0;
    if (hr < 0.02) return;
    p.hunger = math.max(0.0, p.hunger - hr * 3);
    p.joy = math.max(0.0, p.joy - hr * 2.2);
    p.last = nowMs();
    save();
  }

  String petSay(Pet p) {
    final mood = petMood(p);
    final t = nowTask();
    if (petStage(p) == 0) {
      return 'Dentro del huevo algo se mueve… Cada cosa que hagas lo ayuda a nacer (${p.xp} de 30 puntos).';
    }
    if (mood == 'sleep') return 'Zzz… Descansar también es productivo.';
    if (p.hunger < 30) {
      return d.food > 0
          ? '¡Tengo hambre! ¿Me das una baya?'
          : 'Tengo hambre… Si hacemos algo juntos, ganamos bayas.';
    }
    if (d.timer != null && d.timer!.end != null) {
      return 'Shhh, estamos en un bloque de foco. ¡Tú puedes!';
    }
    if (p.joy < 35) return 'Te echaba de menos. ¿Hacemos algo pequeñito juntos?';
    final now = DateTime.now();
    if (t != null && now.minute % 2 == 0) {
      return '¿Y si empezamos con «${t.title}»? Solo un ratito.';
    }
    return petPhrases[(now.day * 24 + now.hour) % petPhrases.length];
  }

  void adoptPet(String name, String kind, String color) {
    final nm = name.trim().isEmpty ? 'Mochi' : name.trim();
    d.pet = Pet(name: nm, kind: kind, color: color);
    commit();
    toast('Ya tienes a $nm. Su huevo crece con lo que hagas.');
    confetti();
  }

  void petFeed() {
    final p = d.pet;
    if (p == null) return;
    if (d.food <= 0) {
      toast('No quedan bayas. Ganas una cada 10 puntos');
      return;
    }
    if (p.hunger >= 98) {
      toast('${p.name} ya no tiene hambre');
      return;
    }
    d.food--;
    p.hunger = math.min(100.0, p.hunger + 25);
    p.joy = math.min(100.0, p.joy + 3);
    hopN++;
    commit();
    toast('¡Ñam!');
  }

  void petPat() {
    final p = d.pet;
    if (p == null) return;
    if (nowMs() - p.lastPet > 10 * 60000) {
      p.joy = math.min(100.0, p.joy + 8);
      p.lastPet = nowMs();
    }
    hopN++;
    commit();
    toast(petStage(p) == 0 ? 'El huevo se mueve un poquito' : 'A ${p.name} le encanta');
  }

  void petLeave() {
    d.pet = null;
    commit();
  }

  // =====================================================================
  //  Tareas
  // =====================================================================

  Task addTask(String title, {String energy = 'media', int est = 15}) {
    final t = Task(title: title, energy: energy, est: est);
    d.tasks.add(t);
    commit();
    return t;
  }

  void completeTask(String id) {
    final t = getTask(id);
    if (t == null || t.done) return;
    t.done = true;
    t.doneAt = nowMs();
    final k = dkey();
    d.doneLog[k] = (d.doneLog[k] ?? 0) + 1;
    gain(10);
    skip = 0;
    commit();
    toast('¡Hecho! +10 puntos');
    chime();
    buzz();
    confetti();
  }

  void undoTask(String id) {
    final t = getTask(id);
    if (t == null || !t.done) return;
    t.done = false;
    if (t.doneAt != null && dkey(DateTime.fromMillisecondsSinceEpoch(t.doneAt!)) == dkey()) {
      final k = dkey();
      d.doneLog[k] = math.max(0, (d.doneLog[k] ?? 0) - 1);
    }
    d.points = math.max(0, d.points - 10);
    t.doneAt = null;
    commit();
  }

  void toggleSub(String id, String sid) {
    final t = getTask(id);
    if (t == null) return;
    SubTask? s;
    for (final x in t.subs) {
      if (x.id == sid) s = x;
    }
    if (s == null) return;
    s.done = !s.done;
    if (s.done) {
      gain(2);
      if (!t.done && t.subs.every((x) => x.done)) {
        toast('¡Todos los pasos listos! ¿Marcas la tarea como hecha?');
      } else {
        toast('Paso hecho. +2 puntos');
      }
      buzz();
    } else {
      d.points = math.max(0, d.points - 2);
    }
    commit();
  }

  void deleteTask(String id) {
    d.tasks.removeWhere((t) => t.id == id);
    if (d.timer != null && d.timer!.taskId == id) d.timer!.taskId = null;
    commit();
  }

  void toggleStar(String id) {
    final t = getTask(id);
    if (t == null) return;
    t.star = !t.star;
    commit();
  }

  void clearDone() {
    d.tasks.removeWhere((t) => t.done);
    commit();
  }

  // =====================================================================
  //  Vertedero mental
  // =====================================================================

  void capture(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    d.inbox.insert(0, InboxItem(t: t));
    commit();
    toast('Apuntado. Ya no tienes que acordarte.');
  }

  void dump(String text) {
    final ls = text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (ls.isEmpty) return;
    for (final t in ls.reversed) {
      d.inbox.insert(0, InboxItem(t: t));
    }
    commit();
    toast('${ls.length} ${ls.length == 1 ? 'cosa apuntada' : 'cosas apuntadas'}. Ya no tienes que acordarte.');
  }

  void inboxToTask(String id) {
    final i = d.inbox.where((x) => x.id == id).toList();
    if (i.isEmpty) return;
    d.inbox.removeWhere((x) => x.id == id);
    d.tasks.add(Task(title: i.first.t));
    commit();
    toast('Ahora es una tarea');
  }

  void inboxDelete(String id) {
    d.inbox.removeWhere((x) => x.id == id);
    commit();
  }

  void inboxClear() {
    d.inbox.clear();
    commit();
  }

  // =====================================================================
  //  Temporizador de foco
  // =====================================================================

  int rem(FocusTimer t) => t.end != null ? math.max(0, t.end! - nowMs()) : t.left;

  void startTimer(String? taskId, int min, bool pomo) {
    final dur = math.max(1, min) * 60000;
    final s = d.settings;
    d.timer = FocusTimer(
      kind: 'focus',
      dur: dur,
      end: nowMs() + dur,
      left: dur,
      taskId: taskId,
      pomo: pomo,
      fmin: math.max(1, min),
      tree: s.forest,
      species: speciesFor(math.max(1, min)),
    );
    if (d.timer!.tree) _wakeOn();
    tab = 2;
    commit();
  }

  int logFocus(int min, String? taskId) {
    if (min < 1) return 0;
    final k = dkey();
    d.focus[k] = (d.focus[k] ?? 0) + min;
    final task = getTask(taskId);
    if (task != null) task.spent += min;
    final pts = math.max(1, (min / 5).round());
    gain(pts);
    return pts;
  }

  TreeRec plantTree(int min, bool dead, Task? task, String? sp) {
    final tr = TreeRec(
      min: min,
      kind: sp ?? treeKindFor(min),
      dead: dead,
      task: task?.title ?? '',
    );
    d.forest.add(tr);
    return tr;
  }

  FocusTimer _next(FocusTimer t, String kind, int dur, int cycle) {
    final n = t.copy();
    n.kind = kind;
    n.dur = dur;
    n.end = null;
    n.left = dur;
    n.cycle = cycle;
    n.warned = false;
    n.lastCheck = 0;
    n.fresh = true;
    n.dead = false;
    n.hiddenAt = null;
    return n;
  }

  String treeArt(String kind) => (trees[kind]?.fem ?? false) ? 'una' : 'un';

  void _finish() {
    final t = d.timer;
    if (t == null) return;
    final s = d.settings;
    if (t.kind == 'focus') {
      final min = (t.dur / 60000).round();
      final pts = logFocus(min, t.taskId);
      final task = getTask(t.taskId);
      final TreeRec? tr = t.tree ? plantTree(min, t.dead, task, t.species) : null;
      var body = '';
      if (tr != null && !tr.dead) {
        body += 'Has plantado ${treeArt(tr.kind)} ${(trees[tr.kind]?.name ?? '').toLowerCase()}. ';
      } else if (tr != null) {
        body += 'Tu árbol se marchitó, pero tus minutos cuentan. ';
      }
      if (task != null) {
        body += 'Buen trabajo con «${task.title}». +$pts puntos';
      } else {
        body += '+$pts puntos. Tómate un respiro.';
      }
      alertDone('¡Bloque terminado!', body);
      if (t.pomo) {
        final cycle = t.cycle + 1;
        final isLong = cycle % math.max(1, s.cycles) == 0;
        final dur = (isLong ? s.long : s.short) * 60000;
        d.timer = _next(t, isLong ? 'long' : 'short', dur, cycle);
      } else {
        d.timer = null;
      }
      _wakeOff();
      confetti(40);
      save();
      notifyListeners();
      if (tr != null && !tr.dead) showPlanted(tr.id);
    } else {
      alertDone('Descanso terminado.', '¿Vamos con otro bloque?');
      if (t.pomo) {
        d.timer = _next(t, 'focus', t.fmin * 60000, t.cycle);
      } else {
        d.timer = null;
      }
      _wakeOff();
      commit();
    }
  }

  void pauseT() {
    final t = d.timer;
    if (t == null || t.end == null) return;
    t.left = rem(t);
    t.end = null;
    _wakeOff();
    commit();
  }

  void resumeT() {
    final t = d.timer;
    if (t == null || t.end != null) return;
    t.end = nowMs() + t.left;
    t.fresh = false;
    if (t.tree && t.kind == 'focus') _wakeOn();
    commit();
  }

  void add5() {
    final t = d.timer;
    if (t == null) return;
    if (t.end != null) {
      t.end = t.end! + 300000;
    } else {
      t.left += 300000;
    }
    t.dur += 300000;
    t.warned = false;
    commit();
    toast('+5 minutos');
  }

  void stopT() {
    final t = d.timer;
    if (t == null) return;
    if (t.kind == 'focus') {
      final min = ((t.dur - rem(t)) / 60000).round();
      if (min >= 1) {
        logFocus(min, t.taskId);
        if (t.tree) plantTree(min, true, getTask(t.taskId), t.species);
        toast('Guardados $min min de foco.${t.tree ? ' Al terminar antes, el árbol se marchita.' : ' ¡Cuenta todo!'}');
      }
      d.timer = null;
    } else if (t.pomo) {
      d.timer = _next(t, 'focus', t.fmin * 60000, t.cycle);
    } else {
      d.timer = null;
    }
    _wakeOff();
    commit();
  }

  void endAll() {
    d.timer = null;
    _wakeOff();
    commit();
  }

  // =====================================================================
  //  Ruido de fondo
  // =====================================================================

  void setNoise(String type) {
    noiseType = type;
    Sfx.setNoise(type, d.settings.noiseVol);
    notifyListeners();
  }

  void setNoiseVol(double v) {
    d.settings.noiseVol = v;
    Sfx.setNoiseVolume(v);
    save();
    notifyListeners();
  }

  // =====================================================================
  //  Rutinas
  // =====================================================================

  List<String> rDone(Routine r) {
    final x = r.done;
    if (x != null && x.date == dkey()) return x.ids;
    return <String>[];
  }

  bool routineToday(Routine r) => r.at.isNotEmpty && r.days.contains(jsDay(DateTime.now()));

  bool routineNow(Routine r) {
    if (!routineToday(r)) return false;
    final hm = parseHm(r.at);
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, now.day, hm[0], hm[1]);
    final tot = r.steps.fold<int>(0, (a, x) => a + x.min);
    return !now.isBefore(s) &&
        now.difference(s).inMinutes < tot + 30 &&
        rDone(r).length < r.steps.length;
  }

  int rStreak(Routine r) {
    var day = DateTime.now();
    if (r.hist[dkey(day)] == null) day = DateTime(day.year, day.month, day.day - 1);
    var n = 0;
    while (r.hist[dkey(day)] != null) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  void _routineSet(Routine r, List<String> ids, int pts) {
    final prevAw = r.done != null && r.done!.date == dkey() && r.done!.aw;
    r.done = RDone(date: dkey(), ids: ids, aw: prevAw);
    if (pts > 0) gain(pts);
    if (r.steps.isNotEmpty && r.steps.every((s) => ids.contains(s.id)) && !r.done!.aw) {
      r.done!.aw = true;
      r.hist[dkey()] = 1;
      gain(15);
      chime();
      buzz();
      confetti();
      celebrate('¡Rutina completada!', '${r.name}. +15 puntos.', rStreak(r));
    }
    commit();
  }

  void routineMark(String rid, String sid, bool award) {
    final r = getRoutine(rid);
    if (r == null) return;
    final ids = List<String>.from(rDone(r));
    if (!ids.contains(sid)) ids.add(sid);
    _routineSet(r, ids, award ? 2 : 0);
  }

  void routineToggle(String rid, String sid) {
    final r = getRoutine(rid);
    if (r == null) return;
    var ids = List<String>.from(rDone(r));
    if (ids.contains(sid)) {
      ids.remove(sid);
    } else {
      ids.add(sid);
    }
    _routineSet(r, ids, 0);
  }

  void routineReset(String rid) {
    final r = getRoutine(rid);
    if (r == null) return;
    r.done = null;
    runStepId = null;
    commit();
  }

  Routine newRoutine() {
    final r = Routine(name: 'Nueva rutina', icon: 'estrella');
    d.routines.add(r);
    commit();
    return r;
  }

  void deleteRoutine(String id) {
    d.routines.removeWhere((r) => r.id == id);
    commit();
  }

  // --- rutina en marcha ---
  int runLeft() => runPausedLeft ?? (runEnd - nowMs());

  /// Sincroniza el paso actual. No notifica (se llama desde build).
  RStep? syncRun(Routine r) {
    runRoutineId = r.id;
    final done = rDone(r);
    RStep? cur;
    for (final s in r.steps) {
      if (!done.contains(s.id)) {
        cur = s;
        break;
      }
    }
    if (cur != null && runStepId != cur.id) {
      runStepId = cur.id;
      runEnd = nowMs() + cur.min * 60000;
      runPausedLeft = null;
      runAlerted = false;
    }
    return cur;
  }

  /// Se llama al cerrar la pantalla de rutina. No notifica.
  void closeRun() {
    runRoutineId = null;
    runStepId = null;
    runPausedLeft = null;
    runAlerted = false;
  }

  void runPlus() {
    if (runPausedLeft != null) {
      runPausedLeft = runPausedLeft! + 60000;
    } else {
      runEnd += 60000;
    }
    runAlerted = false;
    notifyListeners();
  }

  void runPauseToggle() {
    if (runPausedLeft != null) {
      runEnd = nowMs() + runPausedLeft!;
      runPausedLeft = null;
    } else {
      runPausedLeft = runEnd - nowMs();
    }
    notifyListeners();
  }

  int routineRemaining(Routine r) {
    final done = rDone(r);
    var ms = 0;
    for (final s in r.steps) {
      if (done.contains(s.id)) continue;
      if (s.id == runStepId && s.min > 0) {
        ms += math.max(0, runLeft());
      } else {
        ms += s.min * 60000;
      }
    }
    return ms;
  }

  void _runTick() {
    final rid = runRoutineId;
    if (rid == null || runStepId == null) return;
    final r = getRoutine(rid);
    if (r == null) return;
    RStep? cur;
    for (final s in r.steps) {
      if (s.id == runStepId) cur = s;
    }
    if (cur == null || cur.min <= 0) return;
    if (runLeft() <= 0 && !runAlerted && runPausedLeft == null) {
      runAlerted = true;
      chime();
      buzz(2);
      if (r.auto) {
        toast('¡Siguiente paso!');
        routineMark(r.id, cur.id, true);
      } else {
        toast('¡Tiempo! Cuando acabes, pulsa Hecho');
      }
    }
  }

  // =====================================================================
  //  Hábitos
  // =====================================================================

  Habit addHabit(String name) {
    final h = Habit(name: name.trim());
    d.habits.add(h);
    commit();
    return h;
  }

  void habitToggle(String id, String key) {
    Habit? h;
    for (final x in d.habits) {
      if (x.id == id) h = x;
    }
    if (h == null) return;
    if (h.log[key] != null) {
      h.log.remove(key);
      if (key == dkey()) d.points = math.max(0, d.points - 3);
    } else {
      h.log[key] = 1;
      if (key == dkey()) {
        gain(3);
        toast('${h.name}: hecho hoy. +3 puntos');
        buzz();
      }
    }
    commit();
  }

  void habitDelete(String id) {
    d.habits.removeWhere((h) => h.id == id);
    commit();
  }

  // =====================================================================
  //  Ánimo
  // =====================================================================

  Mood _mood() => d.moods[dkey()] ?? Mood();

  void setEnergy(String e) {
    final m = _mood();
    m.e = e;
    if (!m.aw) {
      m.aw = true;
      gain(2);
    }
    d.moods[dkey()] = m;
    skip = 0;
    commit();
  }

  void setMood(int v) {
    final m = _mood();
    m.m = v;
    if (!m.aw) {
      m.aw = true;
      gain(2);
    }
    d.moods[dkey()] = m;
    commit();
  }

  void setMoodNote(String s) {
    final m = _mood();
    m.note = s.trim();
    d.moods[dkey()] = m;
    save();
  }

  // =====================================================================
  //  Recordatorios
  // =====================================================================

  void addReminder(String text, DateTime when, bool daily) {
    final time = '${pad(when.hour)}:${pad(when.minute)}';
    final r = Reminder(text: text, time: time, daily: daily, date: dkey(when));
    if (daily && !when.isAfter(DateTime.now())) r.last = dkey();
    d.reminders.add(r);
    commit();
    toast('Te aviso a las $time');
  }

  void deleteReminder(String id) {
    d.reminders.removeWhere((r) => r.id == id);
    commit();
  }

  void _checkReminders() {
    final now = DateTime.now();
    final k = dkey(now);
    var changed = false;
    for (final r in d.reminders) {
      if (r.off || r.last == k) continue;
      if (!r.daily && r.date != k) continue;
      final hm = parseHm(r.time);
      final tg = DateTime(now.year, now.month, now.day, hm[0], hm[1]);
      if (!now.isBefore(tg) && now.difference(tg).inMinutes < 20) {
        r.last = k;
        if (!r.daily) r.off = true;
        changed = true;
        toast('⏰ ${r.text}');
        chime();
        buzz(2);
      }
    }
    for (final r in d.routines) {
      if (!routineToday(r) || r.alerted == k) continue;
      final hm = parseHm(r.at);
      final tg = DateTime(now.year, now.month, now.day, hm[0], hm[1]);
      if (!now.isBefore(tg) &&
          now.difference(tg).inMinutes < 20 &&
          rDone(r).length < r.steps.length) {
        r.alerted = k;
        changed = true;
        toast('Hora de: ${r.name}');
        chime();
        buzz(2);
      }
    }
    if (changed) commit();
  }

  // =====================================================================
  //  Viajes y retos
  // =====================================================================

  Habit? jHabit() {
    final a = d.journey.active;
    if (a == null) return null;
    final pr = d.journey.prog[a];
    final J = journeys[a];
    if (pr == null || J == null || pr.step >= J.steps.length) return null;
    final name = J.steps[pr.step].h;
    for (final h in d.habits) {
      if (h.name == name) return h;
    }
    return null;
  }

  void _jEnsureHabit(String a) {
    final pr = d.journey.prog[a];
    final J = journeys[a];
    if (pr == null || J == null || pr.step >= J.steps.length) return;
    final name = J.steps[pr.step].h;
    if (!d.habits.any((h) => h.name == name)) d.habits.add(Habit(name: name));
  }

  int jCount() {
    final a = d.journey.active;
    if (a == null) return 0;
    final pr = d.journey.prog[a];
    final h = jHabit();
    if (pr == null || h == null) return 0;
    return h.log.keys.where((k) => k.compareTo(pr.since) >= 0).length;
  }

  void jStart(String id) {
    d.journey.active = id;
    d.journey.prog.putIfAbsent(id, () => JProg(since: dkey()));
    _jEnsureHabit(id);
    commit();
  }

  void jQuit() {
    d.journey.active = null;
    commit();
  }

  void jToday() {
    final h = jHabit();
    if (h == null) return;
    habitToggle(h.id, dkey());
  }

  void jNext() {
    final a = d.journey.active;
    if (a == null) return;
    final J = journeys[a];
    final pr = d.journey.prog[a];
    if (J == null || pr == null || pr.step >= J.steps.length) return;
    if (jCount() < J.steps[pr.step].days) return;
    pr.step++;
    pr.since = dkey();
    gain(20);
    if (pr.step >= J.steps.length) {
      if (!d.journey.done.contains(a)) d.journey.done.add(a);
      d.journey.active = null;
      commit();
      confetti(120);
      celebrate('¡Viaje completado!',
          '${J.name}. Ya tienes ${J.steps.length} hábitos nuevos. +20 puntos.', 0);
      return;
    }
    _jEnsureHabit(a);
    commit();
    confetti(70);
    celebrate('Paso completado', 'Nuevo hábito: ${J.steps[pr.step].h}. Lee tu carta. +20 puntos.', 0);
  }

  List<String> cDays(Challenge c) {
    final s = parseKey(c.start);
    return List<String>.generate(7, (i) => dkey(DateTime(s.year, s.month, s.day + i)));
  }

  void cStart(String id) {
    d.challenges[id] = Challenge(start: dkey());
    commit();
    toast('Reto empezado. Marca cada día que lo cumplas.');
  }

  void cToggle(String id) {
    final c = d.challenges[id];
    if (c == null) return;
    final k = dkey();
    if (c.log[k] != null) {
      c.log.remove(k);
    } else {
      c.log[k] = 1;
      gain(3);
      if (!c.done && c.log.length >= 7) {
        c.done = true;
        gain(30);
        confetti(90);
        celebrate('¡Reto completado!', '${retos[id]?.name ?? 'Reto'}: siete días. +30 puntos.', 0);
      }
    }
    commit();
  }

  void cQuit(String id) {
    d.challenges.remove(id);
    commit();
  }

  // =====================================================================
  //  Diario
  // =====================================================================

  void journalSet(int idx, String value, int promptOffset) {
    final k = dkey();
    final v = value.trim();
    final prev = d.journal[k];
    final before = prev == null ? '' : (idx < 0 ? prev.t : prev.g[idx]);
    if (before == v) return;
    final e = prev ?? JournalEntry();
    if (idx < 0) {
      e.t = v;
    } else {
      e.g[idx] = v;
    }
    e.p = journalPrompts[(DateTime.now().day + promptOffset) % journalPrompts.length];
    final had = d.journal[k] != null && d.journal[k]!.aw;
    d.journal[k] = e;
    if (!had && (e.t.isNotEmpty || e.g.any((x) => x.isNotEmpty))) {
      e.aw = true;
      gain(3);
      toast('Guardado en tu diario. +3 puntos');
    }
    commit();
  }

  void setWhy(String s) {
    d.why = s.trim();
    commit();
  }

  // =====================================================================
  //  Meditación
  // =====================================================================

  void medStart() {
    final dur = medMin * 60000;
    med = MedSession(medType, medMin, medBell, dur, nowMs() + dur);
    bowl();
    _wakeOn();
    notifyListeners();
  }

  void _medLog(int min) {
    if (min < 1) return;
    final k = dkey();
    d.med[k] = (d.med[k] ?? 0) + min;
    gain(min);
    if (d.pet != null) d.pet!.joy = math.min(100.0, d.pet!.joy + 10);
    save();
  }

  void medStop() {
    final m = med;
    if (m == null) return;
    final min = ((m.dur - (m.end - nowMs())) / 60000).round();
    med = null;
    _wakeOff();
    if (min >= 1) {
      _medLog(min);
      toast('Guardados $min min de meditación');
    }
    notifyListeners();
  }

  void _medTick() {
    final m = med;
    if (m == null) return;
    final left = m.end - nowMs();
    if (left <= 0) {
      med = null;
      _wakeOff();
      bowl();
      Timer(const Duration(milliseconds: 1600), bowl);
      _medLog(m.min);
      buzz(2);
      toast('Meditación completada. +${m.min} puntos');
      notifyListeners();
      return;
    }
    if (m.bell > 0) {
      final el = m.dur - left;
      final n = el ~/ (m.bell * 60000);
      if (n > m.bells) {
        m.bells = n;
        bowl();
      }
    }
  }

  // =====================================================================
  //  Actividades guiadas
  // =====================================================================

  void actStart(String id) {
    final A = activities[id];
    if (A == null) return;
    act = ActSession(id, 0, nowMs() + A.steps[0].secs * 1000);
    bowl();
    _wakeOn();
    notifyListeners();
  }

  void actNextStep() {
    final a = act;
    if (a == null) return;
    final A = activities[a.id]!;
    a.idx++;
    if (a.idx >= A.steps.length) {
      _actDone();
      return;
    }
    a.end = nowMs() + A.steps[a.idx].secs * 1000;
    chime();
    buzz();
    notifyListeners();
  }

  void _actDone() {
    final a = act;
    if (a == null) return;
    act = null;
    _wakeOff();
    bowl();
    Timer(const Duration(milliseconds: 1500), bowl);
    final k = dkey();
    d.acts[k] = (d.acts[k] ?? 0) + 1;
    final A = activities[a.id]!;
    final total = A.steps.fold<int>(0, (s, x) => s + x.secs);
    final min = math.max(1, (total / 60).round());
    gain(min);
    commit();
    celebrate('${A.name}: hecho', '+$min puntos. Tu cuerpo te lo agradece.', 0);
  }

  void actStop() {
    act = null;
    _wakeOff();
    notifyListeners();
  }

  // =====================================================================
  //  Ajustes y datos
  // =====================================================================

  void setSetting(void Function(Settings s) f) {
    f(d.settings);
    commit();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(d.toJson());

  /// Devuelve false si el texto no es una copia válida.
  bool restore(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is! Map || j['tasks'] is! List) return false;
      d = AppData.fromJson(Map<String, dynamic>.from(j));
      tab = 0;
      closeRun();
      commit();
      toast('Copia restaurada ✓');
      return true;
    } catch (_) {
      return false;
    }
  }

  void wipe() {
    d = AppData.defaults();
    tab = 0;
    med = null;
    act = null;
    closeRun();
    _wakeOff();
    commit();
    toast('Todo borrado. Empezamos de cero.');
  }

  // =====================================================================
  //  Bucle y ciclo de vida
  // =====================================================================

  void tick() {
    if (!loaded) return;
    var dirty = false;
    final t = d.timer;
    if (t != null && t.end != null) {
      final r = t.end! - nowMs();
      if (r <= 0) {
        _finish();
        return;
      }
      final s = d.settings;
      final warnMs = s.warn * 60000;
      if (warnMs > 0 && !t.warned && r <= warnMs && t.dur > warnMs * 2) {
        t.warned = true;
        save();
        toast(t.kind == 'focus'
            ? 'Quedan ${s.warn} min: ve cerrando poco a poco'
            : 'El descanso acaba en ${s.warn} min');
        buzz();
      }
      if (t.kind == 'focus' && s.checkin > 0) {
        final n = (t.dur - r) ~/ (s.checkin * 60000);
        if (n > t.lastCheck) {
          t.lastCheck = n;
          save();
          final task = getTask(t.taskId);
          toast(task != null
              ? '¿Sigues con «${task.title}»? Vas bien.'
              : '¿Sigues en ello? Vas bien.');
          buzz();
        }
      }
      dirty = true;
    }
    if (t != null && t.end == null) dirty = true;
    if (runRoutineId != null) {
      _runTick();
      dirty = true;
    }
    if (med != null) {
      _medTick();
      dirty = true;
    }
    if (act != null) {
      final a = act!;
      if (a.end - nowMs() <= 0) actNextStep();
      dirty = true;
    }
    _checkReminders();
    final nowT = nowMs();
    if (nowT - _lastPetTick > 60000) {
      _lastPetTick = nowT;
      petTick();
    }
    final m = DateTime.now().minute;
    if (m != _lastMin) {
      _lastMin = m;
      dirty = true;
    }
    if (dirty) notifyListeners();
  }

  /// Llamado cuando la app pasa a segundo plano.
  void onBackground() {
    final t = d.timer;
    if (t != null && t.end != null && t.tree && t.kind == 'focus' && !t.dead) {
      t.hiddenAt = nowMs();
      save();
    }
  }

  /// Llamado cuando la app vuelve a primer plano.
  void onForeground() {
    checkWither();
    final t = d.timer;
    if (t != null && t.end != null && t.tree && t.kind == 'focus') _wakeOn();
    if (med != null || act != null) _wakeOn();
    tick();
  }

  void checkWither() {
    final t = d.timer;
    if (t != null && t.hiddenAt != null) {
      if (t.end != null && !t.dead && nowMs() - t.hiddenAt! > d.settings.grace * 1000) {
        t.dead = true;
        toast('Has salido de la app y tu árbol se ha marchitado. Tus minutos siguen contando.');
        buzz(2);
      }
      t.hiddenAt = null;
      commit();
    }
  }
}

/// Estado único de la aplicación.
final AppState app = AppState();
