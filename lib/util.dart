import 'dart:math';

final Random _rng = Random();

String uid() =>
    '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_rng.nextInt(1679616).toRadixString(36)}';

int nowMs() => DateTime.now().millisecondsSinceEpoch;

String pad(int n) => n.toString().padLeft(2, '0');

/// Clave de día "2026-10-13".
String dkey([DateTime? d]) {
  final x = d ?? DateTime.now();
  return '${x.year}-${pad(x.month)}-${pad(x.day)}';
}

DateTime parseKey(String k) {
  final p = k.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// Día de la semana como en JavaScript: 0 = domingo ... 6 = sábado.
int jsDay(DateTime d) => d.weekday % 7;

String fmt(int ms) {
  final s = ms <= 0 ? 0 : (ms / 1000).ceil();
  return '${pad(s ~/ 60)}:${pad(s % 60)}';
}

String minsLabel(num m) {
  final r = m.round();
  if (r == 0) return '0 min';
  if (r >= 60) {
    final rest = r % 60;
    final tail = rest > 0 ? ' $rest min' : '';
    return '${r ~/ 60} h$tail';
  }
  return '$r min';
}

List<DateTime> lastDays(int n) {
  final t = DateTime.now();
  return List<DateTime>.generate(
      n, (i) => DateTime(t.year, t.month, t.day - (n - 1 - i)));
}

const List<String> dowLetters = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];

String daysLabel(List<int> ds) {
  if (ds.length == 7) return 'cada día';
  if (ds.length == 5 && [1, 2, 3, 4, 5].every((x) => ds.contains(x))) {
    return 'L–V';
  }
  if (ds.isEmpty) return 'sin días';
  final order = [1, 2, 3, 4, 5, 6, 0];
  return order.where((x) => ds.contains(x)).map((x) => dowLetters[x]).join(' ');
}

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ---- lectura tolerante de JSON ----
int jInt(dynamic v, [int d = 0]) => v is num ? v.toInt() : d;
double jDbl(dynamic v, [double d = 0]) => v is num ? v.toDouble() : d;
String jStr(dynamic v, [String d = '']) => v is String ? v : d;
bool jBool(dynamic v, [bool d = false]) => v is bool ? v : d;
List<dynamic> jList(dynamic v) => v is List ? v : <dynamic>[];
Map<String, dynamic> jMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

Map<String, int> jIntMap(dynamic v) {
  final out = <String, int>{};
  jMap(v).forEach((k, val) {
    if (val is num) out[k] = val.toInt();
  });
  return out;
}

List<String> jStrList(dynamic v) =>
    jList(v).map((e) => e is String ? e : '').toList();

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

const List<String> _diasSemana = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const List<String> _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "Martes, 13 de octubre"
String dateLong(DateTime d) =>
    cap('${_diasSemana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]}');

/// "13 oct, 18:30"
String dateTimeShort(DateTime d) =>
    '${d.day} ${_meses[d.month - 1].substring(0, 3)}, ${pad(d.hour)}:${pad(d.minute)}';

/// "13/10" a partir de "2026-10-13"
String dmKey(String k) => k.length >= 10 ? '${k.substring(8, 10)}/${k.substring(5, 7)}' : k;

/// Hora "08:30" -> [8, 30]
List<int> parseHm(String s) {
  final p = s.split(':');
  if (p.length < 2) return [0, 0];
  return [int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0];
}
