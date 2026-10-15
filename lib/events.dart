import 'package:flutter/material.dart';

import 'state.dart';
import 'theme.dart';
import 'widgets.dart';
import 'house.dart';
import 'screens/casa.dart';

/// Reparte los avisos de [AppState] (mensajes, celebraciones, confeti…).
void handleUiEvent(UiEvent e) {
  final ctx = app.navKey.currentState?.overlay?.context;
  switch (e.kind) {
    case UiKind.toast:
      final m = app.msgKey.currentState;
      if (m == null) return;
      m.hideCurrentSnackBar();
      m.showSnackBar(SnackBar(
        content:
            Text(e.text, style: const TextStyle(fontSize: 14.5, height: 1.3)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 3400),
      ));
      break;
    case UiKind.confetti:
      fireConfetti(e.n);
      break;
    case UiKind.celebrate:
      if (ctx == null) return;
      showSheet<void>(ctx, (c) => _CelebrateSheet(e.title, e.text, e.n));
      break;
    case UiKind.homeCheck:
      if (ctx == null) return;
      final task = app.getTask(e.id);
      if (task == null || task.done || homeChore(task.homeChoreId) == null) {
        return;
      }
      showSheet<void>(
          ctx,
          (c) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cottage_outlined,
                      size: 56, color: Theme.of(c).colorScheme.primary),
                  const H2('¿Has hecho esta tarea?'),
                  Text(task.title, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Muted(
                      'El bloque ha terminado. Confirma lo que has hecho en casa para guardar el cambio.',
                      align: TextAlign.center),
                  const SizedBox(height: 16),
                  Btn('Sí, ya lo he hecho', () {
                    app.completeTask(task.id);
                    Navigator.of(c).pop();
                    app.navKey.currentState?.push(MaterialPageRoute<void>(
                      builder: (_) => CasaScreen(
                          initialRoom: homeRooms
                              .firstWhere(
                                (r) => r.chores.any(
                                    (chore) => chore.id == task.homeChoreId),
                              )
                              .id),
                    ));
                  }, kind: 'primary', block: true),
                  const SizedBox(height: 8),
                  Btn('Todavía no', () => Navigator.of(c).pop(), block: true),
                  const Muted(
                      'Si necesitas más tiempo, la tarea seguirá pendiente.',
                      small: true,
                      padding: EdgeInsets.only(top: 10)),
                ],
              ));
      break;
  }
}

class _CelebrateSheet extends StatelessWidget {
  final String title;
  final String text;
  final int streak;
  const _CelebrateSheet(this.title, this.text, this.streak);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(
      children: [
        Icon(Icons.star_rounded, size: 110, color: p.gold),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        Muted(text,
            align: TextAlign.center,
            padding: const EdgeInsets.symmetric(vertical: 8)),
        if (streak > 1)
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '$streak días seguidos.',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: ' No rompas la cadena.'),
            ]),
          ),
        const SizedBox(height: 14),
        Btn('Seguir', () => Navigator.of(context).pop(),
            kind: 'primary', block: true),
      ],
    );
  }
}
