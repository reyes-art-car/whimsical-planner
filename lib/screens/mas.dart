import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';
import 'sub_calma.dart';
import 'sub_crecer.dart';
import 'sub_org.dart';

const Map<String, String> subTitle = {
  'viajes': 'Viajes',
  'retos': 'Retos de 7 días',
  'diario': 'Diario',
  'actividades': 'Actividades guiadas',
  'mascota': 'Mi mascota',
  'bosque': 'Mi bosque',
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
  'viajes': 'Hábitos nuevos, de uno en uno',
  'retos': 'Siete días seguidos',
  'diario': 'Gratitud y tu porqué',
  'actividades': 'Estirar, activarte, siesta',
  'mascota': 'Crece con lo que haces',
  'bosque': 'Árboles de tus bloques',
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
    case 'viajes':
      return const ViajesScreen();
    case 'retos':
      return const RetosScreen();
    case 'diario':
      return const DiarioScreen();
    case 'actividades':
      return const ActividadesScreen();
    case 'mascota':
      return const MascotaScreen();
    case 'bosque':
      return const BosqueScreen();
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
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => subScreen(key)));
}

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  static const List<List<Object>> groups = [
    [
      'Crecer',
      ['viajes', 'retos', 'mascota', 'bosque'],
    ],
    [
      'Calma',
      ['meditar', 'actividades', 'respirar', 'diario', 'animo'],
    ],
    [
      'Organizarte',
      ['vertedero', 'habitos', 'recordatorios'],
    ],
    [
      'Tú',
      ['progreso', 'ajustes', 'acerca'],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final kids = <Widget>[];
    for (var gi = 0; gi < groups.length; gi++) {
      final name = groups[gi][0] as String;
      final keys = groups[gi][1] as List<String>;
      kids.add(SectionLabel(name));
      kids.add(MenuList([
        for (final k in keys)
          MenuRow(
            leading: IcoBox(k, teal: gi.isOdd),
            title: subTitle[k] ?? k,
            subtitle: subDesc[k],
            trailing: Icon(Icons.chevron_right, color: p.muted),
            onTap: () => openSub(context, k),
          ),
      ]));
    }
    return ListView(padding: const EdgeInsets.all(16), children: kids);
  }
}
