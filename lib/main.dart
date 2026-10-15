import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'events.dart';
import 'screens/foco.dart';
import 'screens/hoy.dart';
import 'screens/mas.dart';
import 'screens/rutinas.dart';
import 'screens/tareas.dart';
import 'state.dart';
import 'theme.dart';
import 'util.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.load();
  runApp(const EnfoqueApp());
}

class EnfoqueApp extends StatefulWidget {
  const EnfoqueApp({super.key});

  @override
  State<EnfoqueApp> createState() => _EnfoqueAppState();
}

class _EnfoqueAppState extends State<EnfoqueApp> with WidgetsBindingObserver {
  StreamSubscription<UiEvent>? _sub;
  String _theme = app.d.settings.theme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sub = app.events.listen(handleUiEvent);
    app.addListener(_onApp);
  }

  void _onApp() {
    final t = app.d.settings.theme;
    if (t != _theme) setState(() => _theme = t);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    app.removeListener(_onApp);
    _sub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      app.onBackground();
    } else if (state == AppLifecycleState.resumed) {
      app.onForeground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _theme == 'light'
        ? ThemeMode.light
        : (_theme == 'dark' ? ThemeMode.dark : ThemeMode.system);
    return MaterialApp(
      title: 'Enfoque',
      debugShowCheckedModeBanner: false,
      navigatorKey: app.navKey,
      scaffoldMessengerKey: app.msgKey,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: mode,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const Shell(),
    );
  }
}

String greeting() {
  final h = DateTime.now().hour;
  final g = h < 6
      ? 'Buenas noches'
      : (h < 14 ? 'Buenos días' : (h < 21 ? 'Buenas tardes' : 'Buenas noches'));
  final n = app.d.settings.name;
  return n.isEmpty ? g : '$g, $n';
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  static const List<String> _titles = ['', 'Tareas', 'Foco', 'Rutinas', 'Más'];
  static const List<String> _keys = ['hoy', 'tareas', 'foco', 'rutinas', 'mas'];
  static const List<String> _labels = ['Hoy', 'Tareas', 'Foco', 'Rutinas', 'Más'];

  Widget _body(int tab) {
    switch (tab) {
      case 1:
        return const TareasScreen();
      case 2:
        return const FocoScreen();
      case 3:
        return const RutinasScreen();
      case 4:
        return const MasScreen();
      default:
        return const HoyScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Live((context) {
      final p = context.pal;
      final tab = app.tab;
      final t = app.d.timer;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: p.bg,
          surfaceTintColor: p.bg,
          titleSpacing: 16,
          title: Text(tab == 0 ? greeting() : _titles[tab],
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 21)),
          actions: [
            if (t != null && tab != 2)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => app.setTab(2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      child: Text(
                        '${t.kind == 'focus' ? 'Foco' : 'Pausa'} ${fmt(app.rem(t))}${t.end == null ? ' ‖' : ''}',
                        style: TextStyle(
                            color: p.onAccent, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            PointsChip(() => openSub(context, 'progreso')),
          ],
        ),
        body: _body(tab),
        bottomNavigationBar: NavigationBar(
          backgroundColor: p.surface,
          indicatorColor: p.accentSoft,
          selectedIndex: tab,
          onDestinationSelected: app.setTab,
          destinations: [
            for (var i = 0; i < _keys.length; i++)
              NavigationDestination(
                icon: Icon(iconFor(_keys[i])),
                selectedIcon: Icon(iconFor(_keys[i]), color: p.accent),
                label: _labels[i],
              ),
          ],
        ),
      );
    });
  }
}
