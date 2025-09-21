class NoticiaModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String contenido;
  final String imagen;
  final DateTime fecha;
  final String fuente;

  NoticiaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
    required this.imagen,
    required this.fecha,
    required this.fuente,
  });
}

// Datos ficticios para noticias del IPSA
class NoticiasData {
  static List<NoticiaModel> getNoticias() {
    return [
      NoticiaModel(
        id: '1',
        titulo: 'IPSA realiza jornada de capacitación sobre manejo integrado de plagas en frijol',
        descripcion: 'Más de 100 productores de frijol fueron capacitados en técnicas modernas para el control de plagas.',
        contenido: 'El Instituto de Protección y Sanidad Agropecuaria (IPSA) llevó a cabo una jornada de capacitación dirigida a productores de frijol de la región norte del país. Durante el evento, especialistas compartieron técnicas avanzadas para el manejo integrado de plagas, enfatizando métodos sostenibles que reducen el uso de agroquímicos. Los participantes aprendieron a identificar las principales plagas que afectan el cultivo de frijol y las estrategias más efectivas para su control, incluyendo el uso de controladores biológicos y prácticas culturales adecuadas.',
        imagen: 'https://www.ipsa.gob.ni/portals/0/img/noticias/capacitacion-frijol.jpg',
        fecha: DateTime(2025, 9, 15),
        fuente: 'IPSA Nicaragua',
      ),
      NoticiaModel(
        id: '2',
        titulo: 'Alerta fitosanitaria: Detectan brote de roya en cultivos de maíz',
        descripcion: 'El IPSA emite alerta por la detección de casos de roya en plantaciones de maíz en varios departamentos.',
        contenido: 'El IPSA ha emitido una alerta fitosanitaria tras detectar un brote de roya en cultivos de maíz en los departamentos de Matagalpa, Jinotega y Nueva Segovia. Los especialistas del instituto recomiendan a los productores implementar medidas preventivas y de control para evitar la propagación de esta enfermedad. Entre las recomendaciones se incluye la aplicación de fungicidas específicos, la eliminación de plantas afectadas y la rotación de cultivos. El IPSA ha desplegado brigadas técnicas para brindar asesoría directa a los productores de las zonas afectadas.',
        imagen: 'https://www.ipsa.gob.ni/portals/0/img/noticias/roya-maiz.jpg',
        fecha: DateTime(2025, 9, 10),
        fuente: 'IPSA Nicaragua',
      ),
      NoticiaModel(
        id: '3',
        titulo: 'IPSA y FAO firman convenio para fortalecer producción de arroz',
        descripcion: 'Nuevo convenio busca aumentar la productividad y resistencia de cultivos de arroz en Nicaragua.',
        contenido: 'El Instituto de Protección y Sanidad Agropecuaria (IPSA) y la Organización de las Naciones Unidas para la Alimentación y la Agricultura (FAO) firmaron un convenio de cooperación técnica para fortalecer la producción de arroz en Nicaragua. El acuerdo contempla la implementación de un programa de mejoramiento genético para desarrollar variedades más resistentes a plagas y enfermedades, así como capacitación técnica para productores. Este convenio beneficiará a más de 5,000 productores de arroz en todo el país y se espera un incremento del 15% en la productividad en los próximos tres años.',
        imagen: 'https://www.ipsa.gob.ni/portals/0/img/noticias/convenio-arroz.jpg',
        fecha: DateTime(2025, 9, 5),
        fuente: 'IPSA Nicaragua',
      ),
      NoticiaModel(
        id: '4',
        titulo: 'Nuevas tecnologías para el cultivo de sorgo presentadas por el IPSA',
        descripcion: 'Productores conocen innovaciones tecnológicas para mejorar la producción de sorgo.',
        contenido: 'El IPSA presentó nuevas tecnologías para el cultivo de sorgo durante una feria agrícola realizada en Chinandega. Las innovaciones incluyen sistemas de riego más eficientes, variedades mejoradas con mayor resistencia a la sequía y técnicas de siembra directa que reducen la erosión del suelo. Los especialistas del instituto destacaron que estas tecnologías pueden incrementar la productividad hasta en un 30% y reducir los costos de producción. Además, se presentaron resultados de investigaciones sobre el uso de biofertilizantes que han mostrado excelentes resultados en parcelas demostrativas.',
        imagen: 'https://www.ipsa.gob.ni/portals/0/img/noticias/tecnologia-sorgo.jpg',
        fecha: DateTime(2025, 8, 28),
        fuente: 'IPSA Nicaragua',
      ),
      NoticiaModel(
        id: '5',
        titulo: 'IPSA certifica nuevas semillas de maíz de alta productividad',
        descripcion: 'Nuevas variedades de semillas certificadas prometen aumentar rendimiento de maíz en un 25%.',
        contenido: 'El Instituto de Protección y Sanidad Agropecuaria ha certificado tres nuevas variedades de semillas de maíz desarrolladas por el Instituto Nicaragüense de Tecnología Agropecuaria (INTA). Estas nuevas variedades, denominadas INTA-NB8, INTA-Sequía y INTA-Nutrimaíz, han demostrado un rendimiento superior en un 25% comparado con las variedades tradicionales, además de mayor resistencia a plagas y enfermedades comunes. El IPSA iniciará la distribución de estas semillas certificadas a través de su programa de apoyo a pequeños y medianos productores, con el objetivo de mejorar la seguridad alimentaria en las zonas rurales del país.',
        imagen: 'https://www.ipsa.gob.ni/portals/0/img/noticias/semillas-maiz.jpg',
        fecha: DateTime(2025, 8, 20),
        fuente: 'IPSA Nicaragua',
      ),
    ];
  }
}

// Datos ficticios para el pronóstico del clima
class PronosticoClima {
  final String dia;
  final String fecha;
  final String condicion;
  final String icono;
  final double tempMax;
  final double tempMin;
  final int probabilidadLluvia;

  PronosticoClima({
    required this.dia,
    required this.fecha,
    required this.condicion,
    required this.icono,
    required this.tempMax,
    required this.tempMin,
    required this.probabilidadLluvia,
  });

  static List<PronosticoClima> getPronosticoManagua() {
    return [
      PronosticoClima(
        dia: 'Lunes',
        fecha: '22/09/2025',
        condicion: 'Parcialmente nublado',
        icono: 'partly_cloudy',
        tempMax: 32.5,
        tempMin: 23.8,
        probabilidadLluvia: 20,
      ),
      PronosticoClima(
        dia: 'Martes',
        fecha: '23/09/2025',
        condicion: 'Lluvia ligera',
        icono: 'rainy',
        tempMax: 30.2,
        tempMin: 22.5,
        probabilidadLluvia: 60,
      ),
      PronosticoClima(
        dia: 'Miércoles',
        fecha: '24/09/2025',
        condicion: 'Soleado',
        icono: 'sunny',
        tempMax: 33.8,
        tempMin: 24.1,
        probabilidadLluvia: 10,
      ),
      PronosticoClima(
        dia: 'Jueves',
        fecha: '25/09/2025',
        condicion: 'Tormentas eléctricas',
        icono: 'thunderstorm',
        tempMax: 29.5,
        tempMin: 23.0,
        probabilidadLluvia: 80,
      ),
      PronosticoClima(
        dia: 'Viernes',
        fecha: '26/09/2025',
        condicion: 'Lluvia moderada',
        icono: 'heavy_rain',
        tempMax: 28.7,
        tempMin: 22.3,
        probabilidadLluvia: 75,
      ),
    ];
  }
}
