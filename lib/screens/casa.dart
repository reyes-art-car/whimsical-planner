import 'package:flutter/material.dart';

import '../art.dart';
import '../house.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class HomeSummary extends StatelessWidget {
  const HomeSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final total = homeRooms.expand((r) => r.chores).length;
    final done = homeRooms
        .expand((r) => r.chores)
        .where((c) => app.d.homeDone.containsKey(c.id))
        .length;
    return AppCard(
      color: context.pal.accentSoft,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const CasaScreen(),
      )),
      child: Row(children: [
        Icon(Icons.cottage_outlined, size: 40, color: context.pal.accent),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const H2('Tu casa, poco a poco'),
          Muted('$done de $total pequeños pasos. Elige un rincón para hoy.',
              small: true),
        ])),
        Icon(Icons.chevron_right, color: context.pal.accent),
      ]),
    );
  }
}

class CasaScreen extends StatefulWidget {
  final String initialRoom;
  const CasaScreen({this.initialRoom = 'cocina', super.key});
  @override
  State<CasaScreen> createState() => _CasaScreenState();
}

class _CasaScreenState extends State<CasaScreen> {
  late String _room;

  @override
  void initState() {
    super.initState();
    _room = homeRooms.any((r) => r.id == widget.initialRoom)
        ? widget.initialRoom
        : homeRooms.first.id;
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final p = context.pal;
        final room = homeRooms.firstWhere((r) => r.id == _room);
        final done =
            room.chores.where((c) => app.d.homeDone.containsKey(c.id)).length;
        return SubPage('Mi casa', [
          const H2('Cada rincón cuenta'),
          const Muted(
              'No hace falta ordenar toda la casa. Una acción pequeña ya cambia tu espacio.',
              padding: EdgeInsets.only(bottom: 16)),
          ChipWrap([
            for (final r in homeRooms)
              ChipOpt(
                  r.name, r.id == _room, () => setState(() => _room = r.id)),
          ]),
          const SizedBox(height: 16),
          AppCard(
            color: p.accentSoft,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              H2('${room.name} · $done de ${room.chores.length}'),
              Semantics(
                label:
                    '${room.name}: $done de ${room.chores.length} acciones realizadas',
                image: true,
                child: ExcludeSemantics(
                    child: AspectRatio(
                  aspectRatio: 1.6,
                  child: SvgBox(_roomSvg(room.id, done.toDouble(), p)),
                )),
              ),
              const SizedBox(height: 12),
              ProgressBar(done / room.chores.length),
              const SizedBox(height: 10),
              Muted(
                  done == room.chores.length
                      ? '¡Este rincón está listo! Disfruta de lo que has hecho.'
                      : 'La habitación se ordena al completar acciones reales.',
                  small: true),
              if (done > 0)
                LinkBtn('Volver a ordenar esta habitación', () {
                  askConfirm(
                      context,
                      '¿Empezar otra ronda en ${room.name.toLowerCase()}? Tu historial de tareas se conserva.',
                      () => app.resetHomeRoom(room.id));
                }),
            ]),
          ),
          for (final chore in room.chores) _ChoreCard(chore),
        ]);
      });
}

class _ChoreCard extends StatelessWidget {
  final HomeChore chore;
  const _ChoreCard(this.chore);

  @override
  Widget build(BuildContext context) {
    final done = app.d.homeDone.containsKey(chore.id);
    final pending =
        app.d.tasks.any((t) => t.homeChoreId == chore.id && !t.done);
    return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? context.pal.teal : context.pal.muted),
        const SizedBox(width: 10),
        Expanded(
            child: Text(chore.title,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 8),
      Muted(chore.detail, small: true),
      const SizedBox(height: 8),
      Muted(
          done
              ? 'Hecho en tu casa real'
              : 'Unos ${chore.minutes} minutos · a tu ritmo',
          small: true),
      if (!done) ...[
        const SizedBox(height: 12),
        Btn('Ya lo he hecho', () {
          final task = app.addHomeTask(chore.id);
          if (task != null) app.completeTask(task.id);
        }, key: ValueKey('complete-${chore.id}'), kind: 'primary', block: true),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Btn('Empezar ${chore.minutes} min', () {
            final task = app.addHomeTask(chore.id);
            if (task == null) return;
            app.startTimer(task.id, chore.minutes, false);
            Navigator.of(context).popUntil((r) => r.isFirst);
          }, small: true)),
          const SizedBox(width: 8),
          Expanded(
              child: Btn(
                  pending ? 'En tus tareas' : 'Añadir a tareas',
                  pending
                      ? null
                      : () {
                          app.addHomeTask(chore.id);
                          app.toast(
                              'Guardada en Tareas. Puedes hacerla cuando quieras.');
                        },
                  small: true)),
        ]),
      ],
    ]));
  }
}

/// Plano cenital ortogonal. Los objetos fuera de sitio desaparecen
/// de uno en uno con cada tarea confirmada; el mobiliario permanece.
String _roomSvg(String room, double done, Pal p) {
  final total = homeRooms.firstWhere((r) => r.id == room).chores.length;
  final visualProgress = (done / total * 3).clamp(0.0, 3.0);
  final ink = hexOf(p.text);
  final wall = hexOf(p.surface);
  final floor = hexOf(p.surface2);
  final accent = hexOf(p.accent);
  final soft = hexOf(p.accentSoft);
  final green = hexOf(p.tealSoft);
  final gold = hexOf(p.gold);
  String moving(int step, String svg) {
    final progress = (visualProgress - step).clamp(0.0, 1.0);
    final opacity = (1 - progress).toStringAsFixed(3);
    final x = (progress * 22).toStringAsFixed(2);
    final y = (-progress * 25).toStringAsFixed(2);
    return '<g opacity="$opacity" transform="translate($x $y)">$svg</g>';
  }

  final furniture = switch (room) {
    'cocina' => '<path d="M24 25h250v39H66v70H24Z" fill="$green"/>'
        '<rect x="85" y="31" width="48" height="27" rx="5" fill="$wall"/>'
        '<path d="M109 31v27M129 43h10"/>'
        '<rect x="207" y="30" width="51" height="29" rx="4" fill="$wall"/>'
        '<g fill="$soft"><circle cx="220" cy="39" r="5"/><circle cx="244" cy="39" r="5"/>'
        '<circle cx="220" cy="51" r="5"/><circle cx="244" cy="51" r="5"/></g>'
        '<rect x="155" y="95" width="83" height="50" rx="12" fill="$soft"/>'
        '<rect x="176" y="82" width="36" height="10" rx="4" fill="$green"/>'
        '<rect x="176" y="148" width="36" height="10" rx="4" fill="$green"/>',
    'dormitorio' =>
      '<rect x="74" y="25" width="119" height="131" rx="8" fill="$green"/>'
          '<rect x="80" y="32" width="107" height="118" rx="6" fill="$soft"/>'
          '<rect x="87" y="39" width="41" height="24" rx="7" fill="$wall"/>'
          '<rect x="139" y="39" width="41" height="24" rx="7" fill="$wall"/>'
          '<path d="M81 76h105M91 86v52M176 86v52"/>'
          '<rect x="31" y="30" width="29" height="33" rx="5" fill="$green"/>'
          '<circle cx="45" cy="46" r="8" fill="$gold"/>'
          '<rect x="239" y="25" width="34" height="114" rx="4" fill="$green"/>'
          '<path d="M256 26v112M251 73v13M262 73v13"/>',
    'salon' =>
      '<rect x="87" y="55" width="141" height="102" rx="21" fill="$green" stroke="none"/>'
          '<rect x="30" y="29" width="166" height="45" rx="9" fill="$soft"/>'
          '<path d="M40 30v34h146V30M86 39v24M139 39v24"/>'
          '<rect x="27" y="32" width="15" height="44" rx="5" fill="$green"/>'
          '<rect x="185" y="32" width="15" height="44" rx="5" fill="$green"/>'
          '<rect x="108" y="100" width="89" height="39" rx="16" fill="$wall"/>'
          '<rect x="245" y="40" width="25" height="91" rx="5" fill="$soft"/>'
          '<rect x="253" y="50" width="9" height="69" rx="3" fill="$accent"/>',
    'lavadero' =>
      '<rect x="29" y="27" width="63" height="58" rx="6" fill="$green"/>'
          '<rect x="36" y="35" width="49" height="42" rx="4" fill="$wall"/>'
          '<path d="M40 40h41"/>'
          '<rect x="99" y="27" width="68" height="36" rx="5" fill="$green"/>'
          '<rect x="201" y="43" width="58" height="86" rx="7" fill="$soft"/>'
          '<path d="M210 48v76M222 48v76M234 48v76M246 48v76"/>'
          '<rect x="37" y="111" width="79" height="37" rx="17" fill="$soft"/>'
          '<path d="M49 122h54M49 136h54"/>',
    _ => '<rect x="29" y="28" width="100" height="42" rx="5" fill="$green"/>'
        '<ellipse cx="79" cy="49" rx="27" ry="13" fill="$wall"/>'
        '<path d="M79 29v10"/>'
        '<rect x="185" y="26" width="84" height="84" rx="6" fill="$soft"/>'
        '<path d="M185 26l84 84M269 26l-84 84" stroke="$wall"/>'
        '<circle cx="254" cy="96" r="3" fill="$accent"/>'
        '<rect x="38" y="104" width="31" height="19" rx="4" fill="$green"/>'
        '<ellipse cx="54" cy="138" rx="18" ry="23" fill="$wall"/>'
        '<ellipse cx="54" cy="136" rx="11" ry="15" fill="$soft"/>'
        '<rect x="184" y="125" width="78" height="34" rx="10" fill="$green"/>',
  };
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 195">'
      '<g stroke="$ink" stroke-width="2" stroke-linejoin="round" stroke-linecap="round">'
      '<rect x="15" y="15" width="270" height="165" rx="5" fill="$floor" stroke="none"/>'
      '<path d="M16 55h268M16 95h268M16 135h268M75 16v39M180 55v40M95 95v40M210 135v44" stroke="$ink" opacity=".07"/>'
      '$furniture'
      '<path d="M111 180H15V15h270v165h-96" fill="none" stroke="$accent" stroke-width="8"/>'
      '<path d="M111 180v-39m0 0q39 0 39 39" fill="none" stroke="$accent" stroke-width="1.5"/>'
      '<path d="M140 12h64v6h-64Z" fill="$wall" stroke="$accent" stroke-width="1"/>'
      '${moving(0, '<path d="M32 171l12-13 12 6 14-5 8 15-26 5Z" fill="#E8B7B9"/>')}'
      '${moving(1, '<path d="M149 160l18 3-2 16-18-3Z" fill="#E9D093"/><path d="M149 167l16 3"/>')}'
      '${moving(2, '<path d="M263 170l-8-8-8 9 8 7Z" fill="#BCA5D4"/>')}'
      '${done >= total ? '<path d="M158 58v-8m-4 4h8M238 42v-8m-4 4h8" stroke="$gold"/>' : ''}'
      '</g></svg>';
}

/// Vista previa temporal: anima un paso sin escribir progreso en los datos.
class RoomFocusScene extends StatelessWidget {
  final HomeRoom room;
  final double ordered;
  const RoomFocusScene({required this.room, required this.ordered, super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      label: '${room.name}: vista previa del orden durante el bloque de foco',
      image: true,
      child: ExcludeSemantics(
          child: TweenAnimationBuilder<double>(
        tween: Tween(begin: ordered, end: ordered),
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 500),
        builder: (context, value, _) => AspectRatio(
          aspectRatio: 1.6,
          child: SvgBox(_roomSvg(room.id, value, p)),
        ),
      )),
    );
  }
}
