import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';
import 'sub_calma.dart';
import 'sub_crecer.dart';
import 'sub_org.dart';
import 'tareas.dart';
import 'rutinas.dart';
import 'casa.dart';

const Map<String, String> subTitle = {
  'tareas': 'Tareas',
  'rutinas': 'Rutinas',
  'retos': 'Retos de 7 días',
  'diario': 'Diario',
  'actividades': 'Actividades guiadas',
  'mascota': 'Mi mascota',
  'casa': 'Mi casa',
  'meditar': 'Meditar',
  'vertedero': 'Vertedero mental',
  'habitos': 'Hábitos',
  'animo': 'Ánimo y energía',
  'respirar': 'Respirar',
  'recordatorios': 'Recordatorios',
  'progreso': 'Progreso',
  'ajustes': 'Ajustes',
  'acerca': 'Ideas que ayudan',
};

const Map<String, String> subDesc = {
  'tareas': 'Añade, divide y completa tus pendientes',
  'rutinas': 'Sigue tus actividades paso a paso',
  'retos': 'Siete días seguidos',
  'diario': 'Gratitud y tu porqué',
  'actividades': 'Estirar, activarte, siesta',
  'mascota': 'Crece con lo que haces',
  'casa': 'Ordena por rincones, también en la vida real',
  'meditar': 'Meditaciones guiadas',
  'vertedero': 'Saca ideas de la cabeza',
  'habitos': 'Rachas de 7 días',
  'animo': 'Cómo estás hoy',
  'respirar': 'Calma en 1 minuto',
  'recordatorios': 'Avisos a una hora',
  'progreso': 'Puntos y estadísticas',
  'ajustes': 'Tiempos, sonido, datos',
  'acerca': 'Consejos y sobre la app',
};

Widget subScreen(String key) {
  switch (key) {
    case 'tareas':
      return const _ToolPage('Tareas', TareasScreen());
    case 'rutinas':
      return const _ToolPage('Rutinas', RutinasScreen());
    case 'retos':
      return const RetosScreen();
    case 'diario':
      return const DiarioScreen();
    case 'actividades':
      return const ActividadesScreen();
    case 'mascota':
      return const MascotaScreen();
    case 'casa':
      return const CasaScreen();
    case 'meditar':
      return const MeditarScreen();
    case 'vertedero':
      return const VertederoScreen();
    case 'habitos':
      return const HabitosScreen();
    case 'animo':
      return const AnimoScreen();
    case 'respirar':
      return const RespirarScreen();
    case 'recordatorios':
      return const RecordatoriosScreen();
    case 'progreso':
      return const ProgresoScreen();
    case 'ajustes':
      return const AjustesScreen();
    default:
      return const AcercaScreen();
  }
}

void openSub(BuildContext context, String key) {
  Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => subScreen(key)));
}

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  static const List<List<Object>> groups = [
    [
      'Para tu día',
      ['casa', 'tareas', 'rutinas', 'vertedero'],
    ],
    [
      'Una pausa',
      ['respirar', 'meditar'],
    ],
    [
      'A tu gusto · herramientas opcionales',
      [
        'mascota',
        'habitos',
        'diario',
        'animo',
        'actividades',
        'retos',
        'recordatorios'
      ],
    ],
    [
      'Tú',
      ['progreso', 'ajustes', 'acerca'],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final kids = <Widget>[const SectionGuide('Mi espacio')];
    for (var gi = 0; gi < groups.length; gi++) {
      final name = groups[gi][0] as String;
      final keys = groups[gi][1] as List<String>;
      final menu = MenuList([
        for (final k in keys)
          MenuRow(
            leading: IcoBox(k, teal: gi.isOdd),
            title: subTitle[k] ?? k,
            subtitle: subDesc[k],
            trailing: Icon(Icons.chevron_right, color: p.muted),
            onTap: () => openSub(context, k),
          ),
      ]);
      if (gi == 2) {
        kids.add(AppCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            title: const Text('Más herramientas'),
            subtitle: const Text('Opcionales, para cuando te apetezca'),
            children: [menu],
          ),
        ));
      } else {
        kids.add(SectionLabel(name));
        kids.add(menu);
      }
    }
    return ListView(padding: const EdgeInsets.all(16), children: kids);
  }
}

class _ToolPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _ToolPage(this.title, this.child);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: child,
      );
}
