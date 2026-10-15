import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'art.dart';
import 'data.dart';
import 'state.dart';
import 'theme.dart';
import 'util.dart';

// =====================================================================
//  Reconstrucción cuando cambia el estado
// =====================================================================

class Live extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const Live(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: app, builder: (c, _) => builder(c));
  }
}

// =====================================================================
//  Iconos
// =====================================================================

IconData iconFor(String key) {
  switch (key) {
    case 'hoy':
      return Icons.wb_sunny_outlined;
    case 'tareas':
      return Icons.check_circle_outline;
    case 'foco':
      return Icons.timer_outlined;
    case 'rutinas':
      return Icons.repeat;
    case 'mas':
      return Icons.grid_view_rounded;
    case 'mascota':
      return Icons.pets;
    case 'bosque':
      return Icons.park_outlined;
    case 'meditar':
      return Icons.self_improvement;
    case 'viajes':
      return Icons.route;
    case 'retos':
      return Icons.flag_outlined;
    case 'diario':
      return Icons.menu_book_outlined;
    case 'actividades':
      return Icons.directions_run;
    case 'vertedero':
      return Icons.inbox_outlined;
    case 'habitos':
      return Icons.eco_outlined;
    case 'animo':
      return Icons.sentiment_satisfied_alt;
    case 'respirar':
      return Icons.air;
    case 'recordatorios':
      return Icons.notifications_none;
    case 'progreso':
      return Icons.bar_chart;
    case 'ajustes':
      return Icons.tune;
    case 'acerca':
      return Icons.info_outline;
    case 'sol':
      return Icons.wb_sunny_outlined;
    case 'luna':
      return Icons.nightlight_outlined;
    case 'puerta':
      return Icons.door_front_door_outlined;
    case 'taza':
      return Icons.coffee_outlined;
    case 'libro':
      return Icons.menu_book_outlined;
    case 'pesa':
      return Icons.fitness_center;
    case 'corazon':
      return Icons.favorite_border;
    case 'check':
      return Icons.check;
    default:
      return Icons.star_border_rounded;
  }
}

const List<String> routineIcons = [
  'sol',
  'luna',
  'puerta',
  'taza',
  'libro',
  'pesa',
  'corazon',
  'estrella',
];

// =====================================================================
//  Dibujos SVG
// =====================================================================

class SvgBox extends StatelessWidget {
  final String svg;
  final double? width;
  final double? height;
  const SvgBox(this.svg, {this.width, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(svg, width: width, height: height);
  }
}

SceneColors sceneColors(Pal p) => SceneColors(
      hexOf(p.sky1),
      hexOf(p.sky2),
      hexOf(p.hill1),
      hexOf(p.hill2),
      hexOf(p.gold),
      hexOf(p.text),
    );

class TreeView extends StatelessWidget {
  final String kind;
  final double growth;
  final bool dead;
  final double size;
  const TreeView(this.kind, {this.growth = 1, this.dead = false, this.size = 44, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgBox(treeSvg(kind, growth, dead), width: size, height: size);
  }
}

class ForestScene extends StatelessWidget {
  final List<TreeRec> list;
  final double height;
  final int per;
  final bool showPet;
  final String? hl;
  const ForestScene(this.list,
      {this.height = 180, this.per = 8, this.showPet = true, this.hl, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final svg = forestSvg(
      list,
      sceneColors(p),
      h: height,
      per: per,
      pet: showPet ? app.d.pet : null,
      hl: hl,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 360 / height,
        child: SvgPicture.string(svg, fit: BoxFit.fill),
      ),
    );
  }
}

/// Mascota con balanceo suave y salto al tocarla.
class PetView extends StatefulWidget {
  final Pet pet;
  final String mood;
  final double size;
  final VoidCallback? onTap;
  const PetView(this.pet, this.mood, {this.size = 120, this.onTap, super.key});

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final int _initialHop = app.hopN;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final svg = petSvg(widget.pet, widget.mood, hexOf(p.text));
    final hop = app.hopN;
    final child = AnimatedBuilder(
      animation: _c,
      builder: (c, w) => Transform.translate(
        offset: Offset(0, -3 * Curves.easeInOut.transform(_c.value)),
        child: w,
      ),
      child: TweenAnimationBuilder<double>(
        key: ValueKey<int>(hop),
        tween: Tween<double>(begin: hop == _initialHop ? 1.0 : 0.0, end: 1.0),
        duration: const Duration(milliseconds: 550),
        builder: (c, v, w) => Transform.translate(
          offset: Offset(0, -math.sin(v * math.pi) * 18),
          child: w,
        ),
        child: SvgBox(svg, width: widget.size, height: widget.size),
      ),
    );
    if (widget.onTap == null) return child;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: child);
  }
}

String faceSvg(int n, String color) {
  const mouths = [
    'M8 16.5q4-3.5 8 0',
    'M8 16q4-1.8 8 0',
    'M8 15.2h8',
    'M8 14.2q4 2.8 8 0',
    'M7.5 13.5q4.5 5 9 0',
  ];
  final m = mouths[math.min(4, math.max(0, n - 1))];
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<circle cx="12" cy="12" r="9.5" fill="none" stroke="$color" stroke-width="1.8"/>'
      '<circle cx="9" cy="9.8" r="1.3" fill="$color"/><circle cx="15" cy="9.8" r="1.3" fill="$color"/>'
      '<path d="$m" fill="none" stroke="$color" stroke-width="1.8" stroke-linecap="round"/></svg>';
}

// =====================================================================
//  Bloques básicos
// =====================================================================

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets margin;
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.margin = const EdgeInsets.only(bottom: 12),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final r = BorderRadius.circular(18);
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: r,
        border: Border.all(color: p.line),
      ),
      child: child,
    );
    return Padding(
      padding: margin,
      child: onTap == null
          ? box
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: r, onTap: onTap, child: box),
            ),
    );
  }
}

class H2 extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const H2(this.text, {this.padding = const EdgeInsets.only(bottom: 10), super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
    );
  }
}

class Muted extends StatelessWidget {
  final String text;
  final bool small;
  final TextAlign? align;
  final EdgeInsets padding;
  const Muted(this.text,
      {this.small = false, this.align, this.padding = EdgeInsets.zero, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: context.pal.muted,
          fontSize: small ? 13 : 15,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Etiqueta de campo o de sección.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.pal.muted),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: context.pal.muted,
        ),
      ),
    );
  }
}

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String kind; // primary | teal | ghost | normal
  final bool small;
  final bool block;
  final IconData? icon;
  const Btn(
    this.label,
    this.onTap, {
    this.kind = 'normal',
    this.small = false,
    this.block = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Color bg;
    Color fg;
    switch (kind) {
      case 'primary':
        bg = p.accent;
        fg = p.onAccent;
        break;
      case 'teal':
        bg = p.teal;
        fg = p.onAccent;
        break;
      case 'ghost':
        bg = Colors.transparent;
        fg = p.muted;
        break;
      default:
        bg = p.surface2;
        fg = p.text;
    }
    final r = BorderRadius.circular(14);
    final content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: small ? 18 : 20, color: fg),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: small ? 14 : 15.5,
            ),
          ),
        ),
      ],
    );
    final btn = Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: bg,
        borderRadius: r,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: small ? 40 : 50),
            padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18, vertical: 8),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
    if (block) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}

class LinkBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const LinkBtn(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(
            color: context.pal.accent,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class ChipOpt extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  final Widget? leading;
  const ChipOpt(this.label, this.on, this.onTap, {this.leading, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final r = BorderRadius.circular(22);
    return Material(
      color: on ? p.accentSoft : p.surface2,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: on ? p.accent : Colors.transparent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  color: on ? p.accent : p.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChipWrap extends StatelessWidget {
  final List<Widget> children;
  final WrapAlignment alignment;
  const ChipWrap(this.children, {this.alignment = WrapAlignment.start, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, alignment: alignment, children: children);
  }
}

class Swatch extends StatelessWidget {
  final String hex;
  final bool on;
  final VoidCallback onTap;
  const Swatch(this.hex, this.on, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hexColor(hex),
          shape: BoxShape.circle,
          border: Border.all(color: on ? p.accent : p.line, width: on ? 3 : 1.5),
        ),
      ),
    );
  }
}

class IcoBox extends StatelessWidget {
  final String icon;
  final bool teal;
  final double size;
  const IcoBox(this.icon, {this.teal = false, this.size = 44, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: teal ? p.tealSoft : p.accentSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(iconFor(icon), color: teal ? p.teal : p.accent, size: size * 0.5),
    );
  }
}

class CheckCircle extends StatelessWidget {
  final bool on;
  final VoidCallback? onTap;
  final bool small;
  const CheckCircle(this.on, this.onTap, {this.small = false, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final s = small ? 26.0 : 32.0;
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Padding(
        padding: EdgeInsets.all(small ? 9 : 6),
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? p.ok : Colors.transparent,
            border: Border.all(color: on ? p.ok : p.muted, width: 2),
          ),
          child: on ? Icon(Icons.check, size: s * 0.62, color: Colors.white) : null,
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final bool teal;
  final bool over;
  const ProgressBar(this.value, {this.teal = false, this.over = false, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final v = clampD(value, 0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 10,
        color: p.surface2,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(color: over ? p.gold : (teal ? p.teal : p.accent)),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final Widget child;
  const Tag(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(10)),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 12.5, color: p.muted, fontFamily: 'Lexend'),
        child: child,
      ),
    );
  }
}

class EnergyBars extends StatelessWidget {
  final int level; // 1..3
  final Color color;
  const EnergyBars(this.level, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 3.4,
            height: 4.0 + i * 4,
            margin: const EdgeInsets.only(right: 1.6),
            decoration: BoxDecoration(
              color: color.withOpacity(i < level ? 1.0 : 0.25),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

Widget energyLabel(BuildContext context, String e, {Color? color}) {
  final c = color ?? context.pal.muted;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EnergyBars((energyOrd[e] ?? 1) + 1, c),
      const SizedBox(width: 5),
      Text(energyName[e] ?? e),
    ],
  );
}

class StatsRow extends StatelessWidget {
  final List<List<String>> items; // [valor, etiqueta]
  const StatsRow(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      children: [
        for (final it in items)
          Expanded(
            child: Column(
              children: [
                Text(it[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  it[1],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class MenuRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool selected;
  final Widget? badge;
  const MenuRow({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: selected ? p.accentSoft : null,
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
                        ),
                      ),
                      if (badge != null) ...[const SizedBox(width: 8), badge!],
                    ],
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 13, color: p.muted, height: 1.3),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Lista con filas separadas dentro de una tarjeta.
class MenuList extends StatelessWidget {
  final List<Widget> rows;
  const MenuList(this.rows, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final kids = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) kids.add(Divider(height: 1, thickness: 1, color: p.line));
      kids.add(rows[i]);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(color: Colors.transparent, child: Column(children: kids)),
    );
  }
}

class DotsRow extends StatelessWidget {
  final int total;
  final int filled;
  final int? today;
  const DotsRow(this.total, this.filled, {this.today, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? p.ok : p.surface2,
              border: Border.all(color: today == i ? p.accent : Colors.transparent, width: 2),
            ),
            child: i < filled
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text('${i + 1}', style: TextStyle(fontSize: 13, color: p.muted)),
          ),
      ],
    );
  }
}

/// Puntos cuya posición no es consecutiva (retos).
class DotsMarks extends StatelessWidget {
  final List<bool> on;
  final int todayIdx;
  const DotsMarks(this.on, this.todayIdx, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < on.length; i++)
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on[i] ? p.ok : p.surface2,
              border: Border.all(color: todayIdx == i ? p.accent : Colors.transparent, width: 2),
            ),
            child: on[i]
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text('${i + 1}', style: TextStyle(fontSize: 13, color: p.muted)),
          ),
      ],
    );
  }
}

class BarChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final int? maxValue;
  final bool showNumbers;
  const BarChart(this.values, this.labels, {this.maxValue, this.showNumbers = true, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final mx = maxValue ?? math.max(1, values.fold<int>(0, (a, b) => math.max(a, b)));
    return Column(
      children: [
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final v in values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FractionallySizedBox(
                      heightFactor: math.max(0.03, v / mx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: v > 0 ? p.accent : p.accent.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (showNumbers)
          Row(
            children: [
              for (final v in values)
                Expanded(
                  child: Text(
                    v > 0 ? '$v' : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: p.muted),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: p.muted),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PointsChip extends StatelessWidget {
  final VoidCallback onTap;
  const PointsChip(this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Live((c) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 15, color: p.accent),
                    const SizedBox(width: 5),
                    Text(
                      '${app.d.points}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: p.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

// =====================================================================
//  Campos de texto
// =====================================================================

InputDecoration inputDeco(BuildContext context, String hint) {
  final p = context.pal;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: p.muted.withOpacity(0.8)),
    filled: true,
    fillColor: p.surface2,
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: p.accent, width: 2),
    ),
  );
}

/// Campo que guarda al salir de él o al pulsar intro.
class SaveField extends StatefulWidget {
  final String initial;
  final String hint;
  final void Function(String value) onSave;
  final int maxLines;
  final int minLines;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextAlign textAlign;
  const SaveField({
    required this.initial,
    required this.onSave,
    this.hint = '',
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType,
    this.maxLength,
    this.textAlign = TextAlign.start,
    super.key,
  });

  @override
  State<SaveField> createState() => _SaveFieldState();
}

class _SaveFieldState extends State<SaveField> {
  late final TextEditingController _c;
  late final FocusNode _f;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
    _f = FocusNode();
    _f.addListener(() {
      if (!_f.hasFocus) widget.onSave(_c.text);
    });
  }

  @override
  void didUpdateWidget(SaveField old) {
    super.didUpdateWidget(old);
    if (!_f.hasFocus && widget.initial != _c.text && widget.initial != old.initial) {
      _c.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      focusNode: _f,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType ??
          (widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      textAlign: widget.textAlign,
      maxLength: widget.maxLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: inputDeco(context, widget.hint).copyWith(counterText: ''),
      onSubmitted: (v) => widget.onSave(v),
      onTapOutside: (_) => _f.unfocus(),
    );
  }
}

/// Campo con botón que se vacía al enviar.
class QuickAdd extends StatefulWidget {
  final String hint;
  final String button;
  final void Function(String text) onSubmit;
  final String kind;
  const QuickAdd({
    required this.hint,
    required this.onSubmit,
    this.button = 'Guardar',
    this.kind = 'teal',
    super.key,
  });

  @override
  State<QuickAdd> createState() => _QuickAddState();
}

class _QuickAddState extends State<QuickAdd> {
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    widget.onSubmit(t);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            textCapitalization: TextCapitalization.sentences,
            decoration: inputDeco(context, widget.hint),
            onSubmitted: (_) => _go(),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
        const SizedBox(width: 8),
        Btn(widget.button, _go, kind: widget.kind),
      ],
    );
  }
}

/// Número con botones − / +.
class NumStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final void Function(int v) onChanged;
  final int step;
  const NumStepper(this.value, this.min, this.max, this.onChanged, {this.step = 1, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget b(IconData i, VoidCallback? f) => Material(
          color: p.surface2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: f,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(i, color: f == null ? p.muted.withOpacity(0.4) : p.text),
            ),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        b(Icons.remove, value > min ? () => onChanged(math.max(min, value - step)) : null),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        b(Icons.add, value < max ? () => onChanged(math.min(max, value + step)) : null),
      ],
    );
  }
}

class SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool v) onChanged;
  const SwitchRow(this.title, this.value, this.onChanged, {this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15.5)),
                  if (subtitle != null) Muted(subtitle!, small: true),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  Ventanas
// =====================================================================

Future<T?> showSheet<T>(BuildContext context, Widget Function(BuildContext c) builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.pal.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: builder(c),
      ),
    ),
  );
}

void askConfirm(BuildContext context, String msg, VoidCallback onYes) {
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: c.pal.surface,
      content: Text(msg, style: const TextStyle(fontSize: 16, height: 1.4)),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            Navigator.of(c).pop();
            onYes();
          },
          child: const Text('Sí, seguir'),
        ),
      ],
    ),
  );
}

// =====================================================================
//  Confeti
// =====================================================================

void fireConfetti(int n) {
  final ov = app.navKey.currentState?.overlay;
  if (ov == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(child: _ConfettiLayer(n, () => entry.remove())),
  );
  ov.insert(entry);
}

class _Piece {
  final double x, vx, vy, rot, spin, size;
  final Color color;
  _Piece(this.x, this.vx, this.vy, this.rot, this.spin, this.size, this.color);
}

class _ConfettiLayer extends StatefulWidget {
  final int n;
  final VoidCallback onDone;
  const _ConfettiLayer(this.n, this.onDone);

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Piece> _ps;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    const cols = [
      Color(0xFF9B6FD6),
      Color(0xFF6A3EC2),
      Color(0xFF3F4BB0),
      Color(0xFFB592FF),
      Color(0xFFF2C94C),
      Color(0xFFF2A7C3),
    ];
    _ps = List<_Piece>.generate(
      widget.n,
      (i) => _Piece(
        r.nextDouble(),
        (r.nextDouble() - 0.5) * 0.35,
        0.55 + r.nextDouble() * 0.5,
        r.nextDouble() * 6.28,
        (r.nextDouble() - 0.5) * 12,
        5 + r.nextDouble() * 6,
        cols[r.nextInt(cols.length)],
      ),
    );
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (c, _) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_ps, _c.value),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> ps;
  final double t;
  _ConfettiPainter(this.ps, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in ps) {
      final x = (p.x + p.vx * t) * size.width;
      final y = -20 + (p.vy * t + 0.9 * t * t) * size.height;
      final a = t < 0.75 ? 1.0 : (1 - t) / 0.25;
      final paint = Paint()..color = p.color.withOpacity(clampD(a, 0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + p.spin * t);
      canvas.drawRect(Rect.fromLTWH(-p.size / 2, -p.size / 3, p.size, p.size * 0.66), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

// =====================================================================
//  Reloj circular
// =====================================================================

class RingPainter extends CustomPainter {
  final double value; // 0..1 (lo que queda)
  final Color track;
  final Color color;
  final double stroke;
  RingPainter(this.value, this.track, this.color, {this.stroke = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(c, r, bg);
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    final v = clampD(value, 0.0, 1.0);
    if (v > 0) canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * v, false, fg);
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class Ring extends StatelessWidget {
  final double value;
  final Color? color;
  final double size;
  final Widget child;
  const Ring({required this.value, required this.child, this.color, this.size = 250, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RingPainter(value, p.surface2, color ?? p.accent),
        child: Center(child: child),
      ),
    );
  }
}


class NowChip extends StatelessWidget {
  const NowChip({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(10)),
      child: Text(
        'Ahora',
        style: TextStyle(color: p.onAccent, fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final String text;
  const Bubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.35)),
    );
  }
}

class PetMeters extends StatelessWidget {
  final Pet pet;
  const PetMeters(this.pet, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget row(String l, double v, Color c) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                child: Text(l, style: TextStyle(fontSize: 12.5, color: p.muted)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 10,
                    color: p.surface2,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clampD(v / 100, 0.0, 1.0),
                      child: Container(color: c),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        row('Barriga', pet.hunger, p.gold),
        row('Alegría', pet.joy, p.accent),
      ],
    );
  }
}

/// Pantalla secundaria con barra superior y lista.
class SubPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SubPage(this.title, this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: p.bg,
        surfaceTintColor: p.bg,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}
