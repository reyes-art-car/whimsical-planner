import 'package:flutter/material.dart';

/// Paleta de lilas, morados y añil (misma que la versión web).
class Pal {
  final Color bg, surface, surface2, text, muted, line;
  final Color accent, accentSoft, teal, tealSoft, ok, gold;
  final Color ground, sky1, sky2, hill1, hill2, onAccent;

  const Pal({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.teal,
    required this.tealSoft,
    required this.ok,
    required this.gold,
    required this.ground,
    required this.sky1,
    required this.sky2,
    required this.hill1,
    required this.hill2,
    required this.onAccent,
  });

  static const Pal light = Pal(
    bg: Color(0xFFF5F2FA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFECE6F5),
    text: Color(0xFF221B33),
    muted: Color(0xFF615977),
    line: Color(0xFFDDD4EA),
    accent: Color(0xFF6A3EC2),
    accentSoft: Color(0xFFEBE1FB),
    teal: Color(0xFF3F4BB0),
    tealSoft: Color(0xFFE1E4F8),
    ok: Color(0xFF5B47C9),
    gold: Color(0xFFC98F12),
    ground: Color(0xFFE5DFF1),
    sky1: Color(0xFFD8CBF6),
    sky2: Color(0xFFF4EFFC),
    hill1: Color(0xFFC3DBB7),
    hill2: Color(0xFFA8CC9B),
    onAccent: Color(0xFFFFFFFF),
  );

  static const Pal dark = Pal(
    bg: Color(0xFF15121E),
    surface: Color(0xFF1E1A2A),
    surface2: Color(0xFF29233A),
    text: Color(0xFFEEEAF7),
    muted: Color(0xFFA9A1BD),
    line: Color(0xFF372F4A),
    accent: Color(0xFFB592FF),
    accentSoft: Color(0xFF2F2448),
    teal: Color(0xFF939DFF),
    tealSoft: Color(0xFF22264B),
    ok: Color(0xFFA08FFF),
    gold: Color(0xFFE8B53A),
    ground: Color(0xFF241E35),
    sky1: Color(0xFF100C20),
    sky2: Color(0xFF2B2247),
    hill1: Color(0xFF283C2D),
    hill2: Color(0xFF1E3024),
    onAccent: Color(0xFF15121E),
  );

  static Pal of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension PalContext on BuildContext {
  Pal get pal => Pal.of(this);
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  final text = ThemeData(brightness: b, fontFamily: 'Lexend')
      .textTheme
      .apply(bodyColor: p.text, displayColor: p.text, fontFamily: 'Lexend');
  final scheme = ColorScheme.fromSeed(seedColor: p.accent, brightness: b).copyWith(
    primary: p.accent,
    onPrimary: p.onAccent,
    secondary: p.teal,
    surface: p.surface,
    onSurface: p.text,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'Lexend',
    scaffoldBackgroundColor: p.bg,
    colorScheme: scheme,
    textTheme: text,
    dividerColor: p.line,
    canvasColor: p.bg,
  );
}
