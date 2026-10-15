import 'package:flutter/painting.dart' show Color;

import 'data.dart';
import 'util.dart';

/// Dibujos en SVG (mascota, árboles, escena del bosque).
/// Se pintan con flutter_svg, así que no hace falta ningún archivo de imagen.

String hexOf(Color c) {
  // ignore: deprecated_member_use
  final v = c.value & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0')}';
}

const String _ink = '#3B2F2A';
const String _sw =
    'stroke="#3B2F2A" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"';
const String _ns = 'xmlns="http://www.w3.org/2000/svg"';

String _n(num v) => v.toStringAsFixed(1);

// =====================================================================
//  MASCOTA (lienzo 120 x 120)
// =====================================================================

String petInner(Pet p, String mood, String shadowColor) {
  final st = petStage(p);
  final c = p.color;
  const L = _ink;
  final b = StringBuffer();
  b.write('<ellipse cx="60" cy="112" rx="32" ry="5" fill="$shadowColor" opacity=".18"/>');

  if (st == 0) {
    final crack = p.xp >= 15;
    b.write('<path d="M60 18C85 18 95 58 95 78c0 20-15 32-35 32S25 98 25 78C25 58 35 18 60 18Z" fill="#FBF6EC" $_sw/>');
    b.write('<circle cx="47" cy="58" r="7" fill="$c"/>');
    b.write('<circle cx="73" cy="78" r="9" fill="$c"/>');
    b.write('<circle cx="50" cy="92" r="5" fill="$c"/>');
    b.write('<circle cx="74" cy="46" r="4" fill="$c"/>');
    if (crack) {
      b.write('<path d="M38 64l8 7 6-8 8 9 7-7 8 6" fill="none" stroke="$L" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>');
    }
    return b.toString();
  }

  final s = const [0.0, 0.74, 0.86, 0.94, 1.0, 1.0][st];
  var ears = '';
  var face = '';
  var acc = '';
  var top = '';

  if (p.kind == 'gato') {
    ears = '<path d="M30 54L33 18L56 40Z" fill="$c" $_sw/><path d="M90 54L87 18L64 40Z" fill="$c" $_sw/><path d="M36 42L37 28L47 38Z" fill="#F4B3B3"/><path d="M84 42L83 28L73 38Z" fill="#F4B3B3"/>';
  } else if (p.kind == 'conejo') {
    ears = '<g transform="rotate(-12 45 30)"><ellipse cx="45" cy="26" rx="9" ry="25" fill="$c" $_sw/><ellipse cx="45" cy="28" rx="4" ry="16" fill="#F4B3B3"/></g><g transform="rotate(12 75 30)"><ellipse cx="75" cy="26" rx="9" ry="25" fill="$c" $_sw/><ellipse cx="75" cy="28" rx="4" ry="16" fill="#F4B3B3"/></g>';
  } else if (p.kind == 'osito') {
    ears = '<circle cx="33" cy="44" r="13" fill="$c" $_sw/><circle cx="87" cy="44" r="13" fill="$c" $_sw/><circle cx="33" cy="44" r="6" fill="#000000" opacity=".13"/><circle cx="87" cy="44" r="6" fill="#000000" opacity=".13"/>';
  } else if (p.kind == 'pollito') {
    ears = '<path d="M58 40c-3-12 6-18 8-12M62 40c2-10 12-12 11-5" fill="none" $_sw/>';
  }

  const eyeO =
      '<circle cx="47" cy="65" r="5" fill="$L"/><circle cx="73" cy="65" r="5" fill="$L"/><circle cx="48.6" cy="63.4" r="1.7" fill="#ffffff"/><circle cx="74.6" cy="63.4" r="1.7" fill="#ffffff"/>';

  if (mood == 'happy') {
    face = '<path d="M41 67q6-8 12 0M67 67q6-8 12 0" fill="none" $_sw/>';
  } else if (mood == 'sleep') {
    face = '<path d="M41 66h12M67 66h12" fill="none" $_sw/>'
        '<path d="M91 30h8l-8 9h8" fill="none" stroke="$shadowColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>'
        '<path d="M102 18h6l-6 7h6" fill="none" stroke="$shadowColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>';
  } else if (mood == 'sad') {
    face = '$eyeO<path d="M40 56l11 4M80 56l-11 4" fill="none" $_sw/>';
  } else {
    face = eyeO;
  }
  face += '<ellipse cx="37" cy="77" rx="6.5" ry="4" fill="#F28B9B" opacity=".55"/><ellipse cx="83" cy="77" rx="6.5" ry="4" fill="#F28B9B" opacity=".55"/>';
  if (p.kind == 'pollito') {
    face += '<path d="M53 73L67 73L60 82Z" fill="#F29E38" stroke="$L" stroke-width="2.2" stroke-linejoin="round"/>';
  } else {
    face += '<ellipse cx="60" cy="73" rx="3.4" ry="2.4" fill="$L"/>';
    if (mood == 'happy') {
      face += '<path d="M53 78q7 7 14 0" fill="none" $_sw/>';
    } else if (mood == 'sad') {
      face += '<path d="M54 82q6-5 12 0" fill="none" $_sw/>';
    } else if (mood == 'sleep') {
      face += '<ellipse cx="60" cy="80" rx="3" ry="2.4" fill="$L"/>';
    } else {
      face += '<path d="M54 78q3 3 6 0q3 3 6 0" fill="none" $_sw/>';
    }
  }
  if (st >= 3) {
    acc = '<path d="M28 90q32 16 64 0l1 8q-33 17-66 0z" fill="#D9534F" $_sw/><path d="M74 96l4 14l8-3l-4-13z" fill="#D9534F" $_sw/>';
  }
  if (st >= 4) {
    top += '<path d="M60 40q-3-15 11-19q-2 13-11 19z" fill="#6DBE6A" $_sw/>';
  }
  if (st >= 5) {
    top += '<path d="M45 38l3-14 7 7 5-11 5 11 7-7 3 14z" fill="#F2C94C" $_sw/>';
  }
  b.write('<g transform="translate(60 110) scale($s) translate(-60 -110)">');
  b.write(ears);
  b.write('<ellipse cx="44" cy="104" rx="11" ry="6" fill="$c" $_sw/>');
  b.write('<ellipse cx="76" cy="104" rx="11" ry="6" fill="$c" $_sw/>');
  b.write('<ellipse cx="60" cy="72" rx="39" ry="35" fill="$c" $_sw/>');
  b.write('<ellipse cx="60" cy="86" rx="23" ry="15" fill="#ffffff" opacity=".32"/>');
  b.write(acc);
  b.write(face);
  b.write(top);
  b.write('</g>');
  return b.toString();
}

String petSvg(Pet p, String mood, String shadowColor) =>
    '<svg $_ns viewBox="0 0 120 120">${petInner(p, mood, shadowColor)}</svg>';

// =====================================================================
//  ÁRBOLES (lienzo 100 x 100)
// =====================================================================

String treeInner(String kind, double g, bool dead) {
  final gg = clampD(g, 0.0, 1.0);
  final T = trees[kind] ?? trees['brote']!;
  final leaf = dead ? '#A39274' : hexOf(T.color);
  final trunk = dead ? '#7D6E60' : '#8B5E3C';
  const L = _ink;
  const sw = 'stroke="$L" stroke-width="2.5" stroke-linejoin="round"';
  const ground = '<ellipse cx="50" cy="91" rx="30" ry="5" fill="#6B4F3A" opacity=".35"/>';

  if (gg < 0.12) {
    return '$ground<path d="M38 91q12-10 24 0z" fill="#8B6B4F"/>'
        '<path d="M50 84q-1-6 4-9" fill="none" stroke="${dead ? leaf : '#5FAE6A'}" stroke-width="3" stroke-linecap="round"/>';
  }

  final s = 0.38 + 0.62 * gg;
  final b = StringBuffer();
  if (kind == 'brote') {
    b.write('<path d="M50 90V60" stroke="${dead ? trunk : '#4C8F4F'}" stroke-width="4" stroke-linecap="round"/>');
    b.write('<ellipse cx="41" cy="62" rx="11" ry="6" transform="rotate(-28 41 62)" fill="$leaf" $sw/>');
    b.write('<ellipse cx="59" cy="56" rx="11" ry="6" transform="rotate(28 59 56)" fill="$leaf" $sw/>');
  } else if (kind == 'arbusto') {
    b.write('<rect x="46" y="74" width="8" height="17" fill="$trunk" $sw/>');
    b.write('<circle cx="36" cy="70" r="15" fill="$leaf" $sw/>');
    b.write('<circle cx="64" cy="70" r="15" fill="$leaf" $sw/>');
    b.write('<circle cx="50" cy="58" r="17" fill="$leaf" $sw/>');
  } else if (kind == 'pino') {
    b.write('<rect x="45" y="74" width="10" height="17" fill="$trunk" $sw/>');
    b.write('<path d="M50 40L24 78H76Z" fill="$leaf" $sw/>');
    b.write('<path d="M50 18L30 56H70Z" fill="$leaf" $sw/>');
  } else if (kind == 'lavanda') {
    const spikes = [
      [36, 62, -8],
      [44, 56, -3],
      [50, 52, 0],
      [56, 56, 3],
      [64, 62, 8],
    ];
    for (final sp in spikes) {
      final x = sp[0];
      final y = sp[1];
      final r = sp[2];
      b.write('<path d="M50 90Q${_n((50 + x) / 2)} 76 $x ${y + 8}" fill="none" stroke="${dead ? trunk : '#5E8F5A'}" stroke-width="2.5" stroke-linecap="round"/>');
      b.write('<ellipse cx="$x" cy="$y" rx="4.5" ry="11" transform="rotate($r $x $y)" fill="$leaf" $sw/>');
    }
  } else if (kind == 'cactus') {
    b.write('<rect x="43" y="36" width="14" height="55" rx="7" fill="$leaf" $sw/>');
    b.write('<path d="M43 66h-8a5 5 0 0 1-5-5V50a4 4 0 0 1 8 0v8h5" fill="$leaf" $sw/>');
    b.write('<path d="M57 58h8V44a4 4 0 0 1 8 0v14a6 6 0 0 1-6 6h-10" fill="$leaf" $sw/>');
    if (!dead) b.write('<circle cx="50" cy="35" r="5" fill="#E8A0D8" $sw/>');
  } else if (kind == 'palmera') {
    b.write('<path d="M48 91q-4-26 4-50h6q-8 24-4 50z" fill="$trunk" $sw/>');
    const fronds = [
      [-55, 30],
      [-20, 24],
      [20, 24],
      [55, 30],
      [0, 18],
    ];
    for (final f in fronds) {
      final r = f[0];
      final l = f[1];
      b.write('<ellipse cx="55" cy="${_n(40 - l / 2)}" rx="7" ry="$l" transform="rotate($r 55 40)" fill="$leaf" $sw/>');
    }
    if (!dead) {
      b.write('<circle cx="51" cy="44" r="4" fill="#8B5E3C"/><circle cx="59" cy="45" r="4" fill="#8B5E3C"/>');
    }
  } else if (kind == 'abeto') {
    b.write('<rect x="45" y="76" width="10" height="15" fill="$trunk" $sw/>');
    b.write('<path d="M50 52L22 80H78Z" fill="$leaf" $sw/>');
    b.write('<path d="M50 32L28 62H72Z" fill="$leaf" $sw/>');
    b.write('<path d="M50 12L34 42H66Z" fill="$leaf" $sw/>');
    if (!dead) {
      b.write('<path d="M50 12L42 27q4 3 8 0q4 3 8 0Z" fill="#ffffff"/>');
      b.write('<path d="M50 32L40 46q5 3 10 0q5 3 10 0Z" fill="#ffffff"/>');
      b.write('<path d="M50 52L38 65q6 3 12 0q6 3 12 0Z" fill="#ffffff"/>');
    }
  } else if (kind == 'glicinia') {
    b.write('<path d="M46 91V58q-10-6-14-2M54 91V58q10-6 14-2" fill="none" stroke="$trunk" stroke-width="5" stroke-linecap="round"/>');
    b.write('<ellipse cx="50" cy="40" rx="34" ry="16" fill="${dead ? leaf : '#7FB77E'}" $sw/>');
    if (!dead) {
      const pts = [
        [24, 52],
        [34, 58],
        [44, 62],
        [56, 62],
        [66, 58],
        [76, 52],
      ];
      for (final pt in pts) {
        final x = pt[0];
        final y = pt[1];
        b.write('<path d="M${x - 5} ${y - 12}q5 ${y - 40} 10 0q-5 18-5 18q0 0-5-18z" fill="$leaf" $sw/>');
      }
    }
  } else {
    b.write('<path d="M45 91V60h10v31z" fill="$trunk" $sw/>');
    b.write('<circle cx="34" cy="50" r="17" fill="$leaf" $sw/>');
    b.write('<circle cx="66" cy="50" r="17" fill="$leaf" $sw/>');
    b.write('<circle cx="50" cy="34" r="20" fill="$leaf" $sw/>');
    b.write('<circle cx="50" cy="58" r="15" fill="$leaf" $sw/>');
    if (kind == 'jacaranda' && !dead) {
      b.write('<circle cx="38" cy="40" r="3" fill="#D9C2FF"/><circle cx="58" cy="28" r="3" fill="#D9C2FF"/><circle cx="68" cy="52" r="3" fill="#D9C2FF"/><circle cx="44" cy="58" r="3" fill="#D9C2FF"/>');
    }
    if (kind == 'cerezo' && !dead) {
      b.write('<circle cx="40" cy="38" r="3" fill="#ffffff"/><circle cx="60" cy="30" r="3" fill="#ffffff"/><circle cx="66" cy="54" r="3" fill="#ffffff"/><circle cx="36" cy="56" r="3" fill="#ffffff"/>');
    }
  }
  return '$ground<g transform="translate(50 91) scale(${_n(s)}) translate(-50 -91)">${b.toString()}</g>';
}

String treeSvg(String kind, double g, bool dead) =>
    '<svg $_ns viewBox="0 0 100 100">${treeInner(kind, g, dead)}</svg>';

// =====================================================================
//  ESCENA DEL BOSQUE
// =====================================================================

/// Número estable entre 0 y 1 a partir de un texto.
double hash01(String s) {
  var x = 2166136261;
  for (final c in s.codeUnits) {
    x = x ^ c;
    x = (x * 403 + (x % 256) * 16777216) % 4294967296;
  }
  return x / 4294967295.0;
}

class SceneColors {
  final String sky1, sky2, hill1, hill2, gold, ink;
  const SceneColors(this.sky1, this.sky2, this.hill1, this.hill2, this.gold, this.ink);
}

String _star(double cx, double cy, String fill) {
  return '<path d="M$cx ${cy - 9}L${cx + 2.5} ${cy - 2.5}L${cx + 9} ${cy}L${cx + 2.5} ${cy + 2.5}L$cx ${cy + 9}L${cx - 2.5} ${cy + 2.5}L${cx - 9} ${cy}L${cx - 2.5} ${cy - 2.5}Z" fill="$fill"/>';
}

/// Escena con árboles. [pet] es opcional (se dibuja abajo a la derecha).
String forestSvg(
  List<TreeRec> list,
  SceneColors col, {
  double h = 180,
  int per = 8,
  Pet? pet,
  String? hl,
}) {
  const w = 360.0;
  final hr = DateTime.now().hour;
  final night = hr >= 21 || hr < 7;
  final n = list.length;
  final rows = n == 0 ? 1 : ((n + per - 1) ~/ per);
  final hz = h * 0.36;
  final gap = (h - hz - 10) / rows;
  final base = h < 200 ? 54.0 : 60.0;

  final b = StringBuffer();
  b.write('<svg $_ns viewBox="0 0 ${_n(w)} ${_n(h)}">');
  b.write('<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${col.sky1}"/><stop offset="1" stop-color="${col.sky2}"/></linearGradient></defs>');
  b.write('<rect width="${_n(w)}" height="${_n(h)}" fill="url(#sky)"/>');

  if (night) {
    b.write('<circle cx="${_n(w * .84)}" cy="${_n(h * .16)}" r="11" fill="#F1ECFF"/>');
    b.write('<circle cx="${_n(w * .84 + 5)}" cy="${_n(h * .16 - 3)}" r="10" fill="${col.sky1}"/>');
    const st = [
      [.12, .12],
      [.3, .22],
      [.55, .08],
      [.7, .25],
      [.42, .16],
    ];
    for (final s in st) {
      b.write('<circle cx="${_n(w * s[0])}" cy="${_n(h * s[1])}" r="1.4" fill="#ffffff" opacity=".8"/>');
    }
  } else {
    b.write('<circle cx="${_n(w * .84)}" cy="${_n(h * .17)}" r="13" fill="#FFE3A3" opacity=".9"/>');
    b.write('<g fill="#ffffff" opacity=".65">');
    b.write('<ellipse cx="${_n(w * .2)}" cy="${_n(h * .14)}" rx="22" ry="7"/>');
    b.write('<ellipse cx="${_n(w * .2 + 16)}" cy="${_n(h * .12)}" rx="14" ry="7"/>');
    b.write('<ellipse cx="${_n(w * .55)}" cy="${_n(h * .22)}" rx="18" ry="5"/>');
    b.write('</g>');
  }

  b.write('<path d="M0 ${_n(hz + 6)}Q${_n(w * .22)} ${_n(hz - 20)} ${_n(w * .48)} ${_n(hz + 2)}T${_n(w)} ${_n(hz - 8)}V${_n(h)}H0Z" fill="${col.hill1}"/>');
  b.write('<path d="M0 ${_n(hz + 20)}Q${_n(w * .3)} ${_n(hz + 4)} ${_n(w * .62)} ${_n(hz + 18)}T${_n(w)} ${_n(hz + 12)}V${_n(h)}H0Z" fill="${col.hill2}"/>');

  for (var i = 0; i < n; i++) {
    final t = list[i];
    final row = i ~/ per;
    final colN = i % per;
    final s = 0.6 + 0.4 * ((row + 1) / rows);
    final sz = base * s;
    var x = (colN + .5 + (row % 2 == 1 ? .4 : 0) + (hash01(t.id) - .5) * .55) / (per + .4) * w - sz / 2;
    x = clampD(x, 2.0, w - sz - 2);
    final y = hz + (row + 1) * gap - sz * .91 + (hash01('${t.id}y') - .5) * 5;
    b.write('<g transform="translate(${_n(x)} ${_n(y)}) scale(${(sz / 100).toStringAsFixed(3)})">${treeInner(t.kind, 1.0, t.dead)}</g>');
    if (hl == t.id) {
      b.write(_star(double.parse(_n(x + sz / 2)), double.parse(_n(y - 8)), col.gold));
    }
  }

  if (pet != null) {
    const ps = 46.0;
    b.write('<g transform="translate(${_n(w - ps - 10)} ${_n(h - ps - 6)}) scale(${(ps / 120).toStringAsFixed(3)})">${petInner(pet, petMood(pet), col.ink)}</g>');
  }
  b.write('</svg>');
  return b.toString();
}
