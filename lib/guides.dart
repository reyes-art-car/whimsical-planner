/// Ayuda de uso, junto a los controles de cada sección.
const sectionGuides = <String, List<String>>{
  'Hoy': [
    'Un lugar para decidir tu siguiente paso, sin organizarlo todo de golpe.',
    '1. Elige tu energía; la propuesta se adapta a tus tareas pendientes.\n'
        '2. Pulsa Empezar para trabajar con el temporizador, Hecho para completar u Otra para cambiar la propuesta.\n'
        '3. Guarda las ideas que aparezcan en Suelta una idea. Puedes ordenarlas después.',
  ],
  'Foco': [
    'Dedica un rato a una sola cosa. Puedes empezar con cinco minutos.',
    '1. Elige una tarea o trabaja sin tarea concreta y ajusta los minutos.\n'
        '2. Activa Pomodoro si quieres alternar trabajo y descansos.\n'
        '3. Pulsa Empezar. Puedes pausar el contador o terminar el bloque.\n'
        'En las tareas de casa verás la habitación recogerse poco a poco. Es una vista previa: al terminar, confirma si has hecho la tarea para guardar el cambio. Puedes salir de la app sin perder progreso.',
  ],
  'Mi espacio': [
    'Aquí están tus tareas, rutinas y herramientas para hacer una pausa.',
    'Para tu día reúne lo esencial para organizarte. Una pausa ofrece respiración y meditación.\n'
        'Despliega Más herramientas solo si quieres explorar hábitos, diario, mascota u otras opciones.\n'
        'En Ajustes puedes cambiar tiempos, apariencia y guardar una copia de tus datos. No necesitas usarlo todo.',
  ],
  'Tareas': [
    'Apunta lo que quieres hacer y divídelo en pasos pequeños.',
    '1. Escribe una tarea, elige la energía que pide y su duración aproximada; pulsa Añadir.\n'
        '2. Toca una tarea para editarla, añadir pasos o empezar un bloque de foco.\n'
        '3. Marca el círculo al terminar. Usa la estrella para priorizar y los filtros para ver pendientes o completadas.',
  ],
  'Rutinas': [
    'Agrupa acciones que sueles repetir y síguelas de una en una.',
    '1. Pulsa Nueva rutina, ponle nombre y añade pasos con sus minutos.\n'
        '2. Puedes elegir días y una hora, o dejarla sin horario.\n'
        '3. Inicia la rutina y marca cada paso como Hecho; también puedes pausar o saltar.\n'
        'Las marcas se reinician cada día. En Editar puedes activar el avance automático.',
  ],
  'Vertedero mental': [
    'Un espacio para guardar ideas sin tener que resolverlas ahora.',
    'Escribe una idea por línea y pulsa Sacarlo de la cabeza.\n'
        'Cuando quieras ordenar, pulsa → Tarea para pasar una idea a tus pendientes o la cruz para borrarla.\n'
        'Las ideas de Suelta una idea en Hoy también aparecen aquí.',
  ],
  'Respirar': [
    'Sigue una pauta visual para hacer una pausa.',
    'Elige una pauta y pulsa Empezar. Sigue las instrucciones y el ritmo del círculo.\n'
        'Puedes detener el ejercicio cuando quieras; respira con comodidad, sin forzarte.',
  ],
  'Meditar': [
    'Reserva unos minutos para seguir una práctica guiada en pantalla.',
    'Elige una meditación y su duración. Iníciala y sigue las indicaciones que van apareciendo.\n'
        'Puedes terminar antes. No hace falta dejar la mente en blanco.',
  ],
  'Actividades guiadas': [
    'Pequeñas secuencias para estirar, activarte o descansar.',
    'Elige una actividad y sigue los pasos y sus tiempos.\n'
        'Usa los controles para avanzar, pausar o terminar cuando lo necesites.',
  ],
  'Mi mascota': [
    'Una compañía opcional que crece con tus avances.',
    'Adopta una mascota y personaliza su nombre y aspecto.\n'
        'Al avanzar en la app gana experiencia. Puedes tocarla y darle bayas cuando tengas comida.\n'
        'Consulta sus etapas y necesidades aquí. No se muere si dejas de entrar.',
  ],
  'Mi casa': [
    'Cuida una casa ilustrada con pequeñas acciones en tu casa real.',
    '1. Elige una habitación y una acción que encaje con tu espacio.\n'
        '2. Pulsa Añadir a tareas para hacerla después o Empezar para usar unos minutos de foco.\n'
        '3. Cuando la hayas hecho en la vida real, pulsa Ya lo he hecho. Esa parte de la ilustración se ordena.\n'
        'El tiempo por sí solo no completa la tarea. Puedes salir de la app sin penalización. Volver a ordenar inicia otra ronda de esa habitación sin borrar tu historial.',
  ],
  'Hábitos': [
    'Registra pequeñas acciones que quieres repetir.',
    'Añade un hábito y marca los días en los que lo haces.\n'
        'Puedes corregir una marca tocándola otra vez. El registro de la semana te ayuda a observar tu constancia.',
  ],
  'Diario': [
    'Guarda lo que te importa y algunos detalles de tu día.',
    'Escribe tu porqué y, si te apetece, tres cosas buenas del día.\n'
        'Las preguntas sirven de inspiración: no tienes que rellenarlo todo. Se guarda al salir de cada campo.',
  ],
  'Ánimo y energía': [
    'Observa cómo te sientes a lo largo de los días.',
    'Elige tu ánimo y tu energía de hoy. Puedes añadir una nota para recordar el contexto.\n'
        'Consulta el historial para reconocer cambios; puedes actualizar el registro del día.',
  ],
  'Retos de 7 días': [
    'Una propuesta opcional para practicar una acción durante una semana.',
    'Elige un reto y márcalo los días que lo hagas. Consulta las marcas para ver tu avance.\n'
        'Puedes dejarlo cuando quieras. No necesitas un reto para usar tareas, foco o rutinas.',
  ],
  'Recordatorios': [
    'Programa avisos que aparecen dentro de la app.',
    'Escribe qué quieres recordar y elige un intervalo rápido o una hora.\n'
        'Activa Cada día si quieres repetirlo y pulsa Añadir recordatorio.\n'
        'La app debe estar abierta para mostrar los avisos: para algo imprescindible usa también la alarma del móvil.',
  ],
  'Progreso': [
    'Consulta lo que ya has hecho, sin añadir nuevas obligaciones.',
    'Aquí se reúnen puntos, nivel, tareas completadas y minutos de foco.\n'
        'Los gráficos muestran tu actividad reciente. No tienes que alcanzar una cifra concreta.',
  ],
  'Ajustes': [
    'Adapta Enfoque a tus horarios y preferencias.',
    'Cambia tu nombre, tiempos de foco y descanso, sonidos y tema.\n'
        'En Copia de seguridad puedes copiar tus datos para guardarlos y restaurarlos después.\n'
        'Los datos se guardan en este dispositivo; Borrar todo elimina el contenido y pide confirmación.',
  ],
  'Ideas que ayudan': [
    'Consejos breves para usar la app con menos presión.',
    'Lee las ideas que te resulten útiles y vuelve a Hoy cuando quieras empezar.\n'
        'Puedes usar solo tareas y foco, y descubrir las demás herramientas cuando las necesites.',
  ],
};
