/// Acciones pequeñas que se pueden hacer fuera de la pantalla.
class HomeChore {
  final String id, title, detail;
  final int minutes;
  const HomeChore(this.id, this.title, this.detail, this.minutes);
}

class HomeRoom {
  final String id, name, icon;
  final List<HomeChore> chores;
  const HomeRoom(this.id, this.name, this.icon, this.chores);
}

const homeRooms = [
  HomeRoom('cocina', 'Cocina', 'kitchen', [
    HomeChore('cocina-mesa', 'Despejar una mesa o encimera',
        'Elige una sola superficie. Devuelve cada objeto a su sitio.', 5),
    HomeChore(
        'cocina-platos',
        'Lavar o guardar cinco piezas de vajilla',
        'Solo cinco piezas. Si tienes lavavajillas, puedes colocarlas dentro.',
        5),
    HomeChore('cocina-basura', 'Recoger los residuos de la cocina',
        'Separa los residuos y deja despejada la zona del cubo.', 3),
    HomeChore(
        'cocina-fregar',
        'Fregar los platos',
        'Reúne la vajilla, friega una tanda y déjala escurriendo. Puedes parar después de esa tanda.',
        10),
    HomeChore(
        'cocina-cocinar',
        'Cocinar una comida sencilla',
        'Elige algo que sepas preparar, reúne los ingredientes y empieza por el primer paso. Ajusta el tiempo a tu receta.',
        20),
    HomeChore(
        'cocina-encimera',
        'Limpiar la encimera',
        'Despeja una zona, pasa una bayeta y vuelve a colocar lo necesario.',
        5),
    HomeChore(
        'cocina-barrer',
        'Barrer la cocina',
        'Recoge lo que haya en el suelo y barre desde el fondo hacia la salida.',
        5),
    HomeChore(
        'cocina-suelo',
        'Fregar el suelo de la cocina',
        'Después de barrer, friega por zonas y deja que el suelo se seque.',
        10),
  ]),
  HomeRoom('dormitorio', 'Dormitorio', 'bed', [
    HomeChore(
        'dormitorio-cama',
        'Hacer la cama',
        'Estira la ropa de cama y coloca la almohada. No tiene que quedar perfecta.',
        3),
    HomeChore('dormitorio-ropa', 'Recoger cinco prendas',
        'Lleva la ropa sucia al cesto y guarda la que esté limpia.', 5),
    HomeChore('dormitorio-mesilla', 'Despejar la mesilla',
        'Retira lo que no necesites y deja a mano lo esencial.', 3),
    HomeChore('dormitorio-sabanas', 'Cambiar las sábanas',
        'Retira las usadas, colócalas en el cesto y pon un juego limpio.', 10),
    HomeChore(
        'dormitorio-armario',
        'Ordenar una balda del armario',
        'Elige una sola balda o cajón. Dobla y agrupa lo que quieras guardar ahí.',
        10),
  ]),
  HomeRoom('salon', 'Salón', 'sofa', [
    HomeChore('salon-mesa', 'Ordenar la mesa del salón',
        'Recoge tazas, papeles y objetos. Devuelve cada cosa a su sitio.', 5),
    HomeChore('salon-sofa', 'Colocar los cojines y la manta',
        'Despeja un asiento y dobla una manta si tienes.', 3),
    HomeChore('salon-suelo', 'Recoger cinco objetos del suelo',
        'Empieza por un rincón pequeño y deja libre el paso.', 5),
    HomeChore('salon-polvo', 'Quitar el polvo del salón',
        'Empieza por un mueble y pasa un paño por sus superficies.', 10),
    HomeChore(
        'salon-aspirar',
        'Aspirar o barrer el salón',
        'Despeja el paso y limpia el suelo por zonas, incluida la alfombra si tienes.',
        10),
    HomeChore(
        'salon-fregar',
        'Fregar el suelo del salón',
        'Friega el suelo que admita agua, por zonas, dejando libre una salida.',
        10),
  ]),
  HomeRoom('bano', 'Baño', 'bath', [
    HomeChore('bano-lavabo', 'Despejar el lavabo',
        'Guarda los productos que no estés usando.', 3),
    HomeChore('bano-toallas', 'Colgar o cambiar las toallas',
        'Coloca las que uses y lleva las sucias al cesto.', 3),
    HomeChore(
        'bano-productos',
        'Ordenar un estante del baño',
        'Agrupa los productos de una sola balda y recoge los envases vacíos.',
        5),
    HomeChore('bano-limpiar-lavabo', 'Limpiar el lavabo y los grifos',
        'Retira los objetos, limpia el lavabo y repasa los grifos.', 5),
    HomeChore(
        'bano-inodoro',
        'Limpiar el inodoro',
        'Limpia el interior y después el asiento y el exterior, con utensilios separados de los del lavabo.',
        10),
    HomeChore(
        'bano-ducha',
        'Limpiar la ducha o bañera',
        'Retira los envases, limpia una zona y aclárala antes de volver a colocarlos.',
        10),
    HomeChore('bano-espejo', 'Limpiar el espejo del baño',
        'Pasa un paño apropiado por el espejo y repasa las marcas.', 5),
    HomeChore(
        'bano-suelo',
        'Barrer y fregar el baño',
        'Retira la alfombrilla, recoge el suelo y friega desde el fondo hacia la puerta.',
        10),
  ]),
  HomeRoom('lavadero', 'Ropa y lavadero', 'laundry', [
    HomeChore(
        'lavadero-separar',
        'Separar la ropa para lavar',
        'Revisa los bolsillos y agrupa la ropa según sus etiquetas de cuidado.',
        5),
    HomeChore(
        'lavadero-lavadora',
        'Poner una lavadora',
        'Carga la ropa, añade detergente y elige el programa. Estos minutos son para ponerla en marcha; el ciclo tarda aparte.',
        5),
    HomeChore(
        'lavadero-tender',
        'Tender la ropa',
        'Saca la ropa lavada y tiéndela o pásala a la secadora si las prendas lo permiten.',
        10),
    HomeChore(
        'lavadero-doblar',
        'Doblar una tanda de ropa',
        'Reúne la ropa seca y dobla una tanda pequeña sobre una superficie despejada.',
        10),
    HomeChore(
        'lavadero-planchar',
        'Planchar una tanda pequeña',
        'Elige unas pocas prendas y ajusta la plancha a sus etiquetas. Termina esa tanda antes de guardar la plancha.',
        15),
    HomeChore('lavadero-guardar', 'Guardar la ropa limpia',
        'Lleva las prendas dobladas o colgadas a sus cajones y perchas.', 5),
  ]),
];

HomeChore? homeChore(String? id) {
  for (final room in homeRooms) {
    for (final chore in room.chores) {
      if (chore.id == id) return chore;
    }
  }
  return null;
}
