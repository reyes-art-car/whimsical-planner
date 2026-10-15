import 'package:flutter/material.dart';

/// Jardín de papel: crema, lavanda y salvia, también en modo nocturno.
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
    bg: Color(0xFFFAF6ED),
    surface: Color(0xFFFFFDF8),
    surface2: Color(0xFFF0EBDD),
    text: Color(0xFF3C3546),
    muted: Color(0xFF726879),
    line: Color(0xFFE5DDCF),
    accent: Color(0xFF75539D),
    accentSoft: Color(0xFFECE3F5),
    teal: Color(0xFF456B57),
    tealSoft: Color(0xFFE4EDDC),
    ok: Color(0xFF52765C),
    gold: Color(0xFFAD791C),
    ground: Color(0xFFECE6D4),
    sky1: Color(0xFFE7DCF5),
    sky2: Color(0xFFFFF6E6),
    hill1: Color(0xFFC9D9B5),
    hill2: Color(0xFFA7C39A),
    onAccent: Color(0xFFFFFFFF),
  );

  static const Pal dark = Pal(
    bg: Color(0xFF211E29),
    surface: Color(0xFF2B2633),
    surface2: Color(0xFF36303F),
    text: Color(0xFFEEEAF7),
    muted: Color(0xFFA9A1BD),
    line: Color(0xFF372F4A),
    accent: Color(0xFFB592FF),
    accentSoft: Color(0xFF2F2448),
    teal: Color(0xFFB5D2A4),
    tealSoft: Color(0xFF293B30),
    ok: Color(0xFFB5D2A4),
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
    appBarTheme: AppBarTheme(elevation: 0, scrolledUnderElevation: 0, foregroundColor: p.text),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 76,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
        fontFamily: 'Lexend', fontSize: 12, fontWeight: FontWeight.w500, color: p.text,
      )),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.accent, width: 2),
      ),
    ),
  );
}
