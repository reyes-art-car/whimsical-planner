import 'package:flutter/material.dart';

import 'data.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';
import 'screens/mas.dart';

/// Reparte los avisos de [AppState] (mensajes, celebraciones, confeti…).
void handleUiEvent(UiEvent e) {
  final ctx = app.navKey.currentState?.overlay?.context;
  switch (e.kind) {
    case UiKind.toast:
      final m = app.msgKey.currentState;
      if (m == null) return;
      m.hideCurrentSnackBar();
      m.showSnackBar(SnackBar(
        content: Text(e.text, style: const TextStyle(fontSize: 14.5, height: 1.3)),
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
    case UiKind.planted:
      if (ctx == null) return;
      showSheet<void>(ctx, (c) => _PlantedSheet(e.id));
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
        Muted(text, align: TextAlign.center, padding: const EdgeInsets.symmetric(vertical: 8)),
        if (streak > 1)
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '$streak días seguidos.', style: const TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: ' No rompas la cadena.'),
            ]),
          ),
        const SizedBox(height: 14),
        Btn('Seguir', () => Navigator.of(context).pop(), kind: 'primary', block: true),
      ],
    );
  }
}

class _PlantedSheet extends StatelessWidget {
  final String id;
  const _PlantedSheet(this.id);

  @override
  Widget build(BuildContext context) {
    TreeRec? tr;
    for (final x in app.d.forest) {
      if (x.id == id) tr = x;
    }
    if (tr == null) return const SizedBox.shrink();
    final t = tr;
    final spec = trees[t.kind];
    final name = (spec?.name ?? '').toLowerCase();
    final alive = app.d.forest.where((x) => !x.dead).length;
    final last = app.d.forest.length > 24
        ? app.d.forest.sublist(app.d.forest.length - 24)
        : app.d.forest;
    return Column(
      children: [
        TreeView(t.kind, size: 130),
        Text('¡${(spec?.fem ?? false) ? 'Nueva' : 'Nuevo'} $name en tu bosque!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
        Muted(
          '${t.min} min de foco${t.task.isNotEmpty ? ' en «${t.task}»' : ''}. Ya tienes $alive ${alive == 1 ? 'árbol' : 'árboles'}.',
          small: true,
          align: TextAlign.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        ForestScene(last, height: 170, per: 8, hl: t.id),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Btn('Ver mi bosque', () {
                Navigator.of(context).pop();
                app.navKey.currentState?.push(
                  MaterialPageRoute<void>(builder: (_) => subScreen('bosque')),
                );
              }, kind: 'primary'),
            ),
            const SizedBox(width: 8),
            Expanded(child: Btn('Seguir', () => Navigator.of(context).pop())),
          ],
        ),
      ],
    );
  }
}
