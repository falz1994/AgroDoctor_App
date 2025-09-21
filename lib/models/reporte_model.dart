import 'package:flutter/material.dart';

// Modelo para datos de departamentos
class DepartamentoData {
  final String id;
  final String nombre;
  final List<Offset> poligono; // Puntos para dibujar el polígono en el mapa
  final Offset centro; // Punto central para colocar etiquetas

  DepartamentoData({
    required this.id,
    required this.nombre,
    required this.poligono,
    required this.centro,
  });
}

// Modelo para datos de producción
class ProduccionData {
  final String departamentoId;
  final double cantidadToneladas;
  final double porcentajeNacional;
  final int anio;

  ProduccionData({
    required this.departamentoId,
    required this.cantidadToneladas,
    required this.porcentajeNacional,
    required this.anio,
  });
}

// Modelo para datos de precios
class PrecioData {
  final String departamentoId;
  final double precioQuintal; // Precio en córdobas por quintal
  final double precioLibra; // Precio en córdobas por libra
  final DateTime fechaActualizacion;

  PrecioData({
    required this.departamentoId,
    required this.precioQuintal,
    required this.precioLibra,
    required this.fechaActualizacion,
  });
}

// Enumeración para tipos de reportes
enum TipoReporte {
  produccion,
  precios,
  rendimiento,
  exportacion
}

// Clase para gestionar los datos de reportes
class ReportesData {
  // Lista de departamentos de Nicaragua con sus coordenadas aproximadas
  // Nota: Estas coordenadas son simplificadas para representación en un canvas
  static List<DepartamentoData> getDepartamentos() {
    return [
      DepartamentoData(
        id: 'managua',
        nombre: 'Managua',
        poligono: [
          Offset(0.5, 0.5), Offset(0.55, 0.48), Offset(0.53, 0.55), Offset(0.48, 0.55)
        ],
        centro: Offset(0.51, 0.52),
      ),
      DepartamentoData(
        id: 'matagalpa',
        nombre: 'Matagalpa',
        poligono: [
          Offset(0.5, 0.35), Offset(0.58, 0.32), Offset(0.56, 0.42), Offset(0.48, 0.4)
        ],
        centro: Offset(0.53, 0.37),
      ),
      DepartamentoData(
        id: 'jinotega',
        nombre: 'Jinotega',
        poligono: [
          Offset(0.45, 0.25), Offset(0.55, 0.2), Offset(0.58, 0.3), Offset(0.48, 0.35)
        ],
        centro: Offset(0.51, 0.27),
      ),
      DepartamentoData(
        id: 'esteli',
        nombre: 'Estelí',
        poligono: [
          Offset(0.4, 0.3), Offset(0.48, 0.28), Offset(0.45, 0.38), Offset(0.38, 0.35)
        ],
        centro: Offset(0.43, 0.33),
      ),
      DepartamentoData(
        id: 'leon',
        nombre: 'León',
        poligono: [
          Offset(0.35, 0.5), Offset(0.45, 0.48), Offset(0.43, 0.58), Offset(0.33, 0.55)
        ],
        centro: Offset(0.39, 0.53),
      ),
      DepartamentoData(
        id: 'chinandega',
        nombre: 'Chinandega',
        poligono: [
          Offset(0.25, 0.4), Offset(0.35, 0.38), Offset(0.33, 0.48), Offset(0.23, 0.45)
        ],
        centro: Offset(0.29, 0.43),
      ),
      DepartamentoData(
        id: 'boaco',
        nombre: 'Boaco',
        poligono: [
          Offset(0.58, 0.48), Offset(0.65, 0.45), Offset(0.63, 0.55), Offset(0.56, 0.53)
        ],
        centro: Offset(0.61, 0.5),
      ),
      DepartamentoData(
        id: 'chontales',
        nombre: 'Chontales',
        poligono: [
          Offset(0.63, 0.55), Offset(0.7, 0.53), Offset(0.68, 0.63), Offset(0.61, 0.6)
        ],
        centro: Offset(0.65, 0.58),
      ),
      DepartamentoData(
        id: 'rivas',
        nombre: 'Rivas',
        poligono: [
          Offset(0.45, 0.7), Offset(0.55, 0.68), Offset(0.53, 0.78), Offset(0.43, 0.75)
        ],
        centro: Offset(0.49, 0.73),
      ),
      DepartamentoData(
        id: 'granada',
        nombre: 'Granada',
        poligono: [
          Offset(0.55, 0.6), Offset(0.62, 0.58), Offset(0.6, 0.65), Offset(0.53, 0.63)
        ],
        centro: Offset(0.57, 0.62),
      ),
      DepartamentoData(
        id: 'masaya',
        nombre: 'Masaya',
        poligono: [
          Offset(0.52, 0.55), Offset(0.58, 0.53), Offset(0.56, 0.6), Offset(0.5, 0.58)
        ],
        centro: Offset(0.54, 0.56),
      ),
      DepartamentoData(
        id: 'carazo',
        nombre: 'Carazo',
        poligono: [
          Offset(0.48, 0.6), Offset(0.55, 0.58), Offset(0.53, 0.65), Offset(0.46, 0.63)
        ],
        centro: Offset(0.5, 0.62),
      ),
      DepartamentoData(
        id: 'nueva_segovia',
        nombre: 'Nueva Segovia',
        poligono: [
          Offset(0.4, 0.15), Offset(0.5, 0.13), Offset(0.48, 0.23), Offset(0.38, 0.2)
        ],
        centro: Offset(0.44, 0.18),
      ),
      DepartamentoData(
        id: 'madriz',
        nombre: 'Madriz',
        poligono: [
          Offset(0.35, 0.23), Offset(0.45, 0.2), Offset(0.43, 0.3), Offset(0.33, 0.28)
        ],
        centro: Offset(0.39, 0.25),
      ),
      DepartamentoData(
        id: 'rio_san_juan',
        nombre: 'Río San Juan',
        poligono: [
          Offset(0.6, 0.75), Offset(0.7, 0.73), Offset(0.68, 0.83), Offset(0.58, 0.8)
        ],
        centro: Offset(0.64, 0.78),
      ),
      DepartamentoData(
        id: 'raan',
        nombre: 'RAAN',
        poligono: [
          Offset(0.65, 0.2), Offset(0.85, 0.15), Offset(0.83, 0.4), Offset(0.63, 0.35)
        ],
        centro: Offset(0.74, 0.27),
      ),
      DepartamentoData(
        id: 'raas',
        nombre: 'RAAS',
        poligono: [
          Offset(0.7, 0.45), Offset(0.9, 0.4), Offset(0.88, 0.7), Offset(0.68, 0.65)
        ],
        centro: Offset(0.79, 0.55),
      ),
    ];
  }

  // Datos de producción de frijol por departamento (datos simulados)
  static List<ProduccionData> getProduccionFrijol() {
    return [
      ProduccionData(
        departamentoId: 'matagalpa',
        cantidadToneladas: 28500,
        porcentajeNacional: 22.8,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'jinotega',
        cantidadToneladas: 25000,
        porcentajeNacional: 20.0,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'nueva_segovia',
        cantidadToneladas: 15600,
        porcentajeNacional: 12.5,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'esteli',
        cantidadToneladas: 12300,
        porcentajeNacional: 9.8,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'raan',
        cantidadToneladas: 10200,
        porcentajeNacional: 8.2,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'chontales',
        cantidadToneladas: 8500,
        porcentajeNacional: 6.8,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'boaco',
        cantidadToneladas: 7200,
        porcentajeNacional: 5.8,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'madriz',
        cantidadToneladas: 5800,
        porcentajeNacional: 4.6,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'leon',
        cantidadToneladas: 4200,
        porcentajeNacional: 3.4,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'chinandega',
        cantidadToneladas: 3100,
        porcentajeNacional: 2.5,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'raas',
        cantidadToneladas: 2200,
        porcentajeNacional: 1.8,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'rio_san_juan',
        cantidadToneladas: 1500,
        porcentajeNacional: 1.2,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'managua',
        cantidadToneladas: 800,
        porcentajeNacional: 0.6,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'masaya',
        cantidadToneladas: 400,
        porcentajeNacional: 0.3,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'granada',
        cantidadToneladas: 300,
        porcentajeNacional: 0.2,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'carazo',
        cantidadToneladas: 250,
        porcentajeNacional: 0.2,
        anio: 2024,
      ),
      ProduccionData(
        departamentoId: 'rivas',
        cantidadToneladas: 150,
        porcentajeNacional: 0.1,
        anio: 2024,
      ),
    ];
  }

  // Datos de precios del frijol por departamento (datos simulados)
  static List<PrecioData> getPreciosFrijol() {
    final DateTime fechaActual = DateTime.now();
    
    return [
      PrecioData(
        departamentoId: 'managua',
        precioQuintal: 2200,
        precioLibra: 22.0,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'matagalpa',
        precioQuintal: 1950,
        precioLibra: 19.5,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'jinotega',
        precioQuintal: 1900,
        precioLibra: 19.0,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'esteli',
        precioQuintal: 2050,
        precioLibra: 20.5,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'leon',
        precioQuintal: 2150,
        precioLibra: 21.5,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'chinandega',
        precioQuintal: 2180,
        precioLibra: 21.8,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'boaco',
        precioQuintal: 2000,
        precioLibra: 20.0,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'chontales',
        precioQuintal: 2100,
        precioLibra: 21.0,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'rivas',
        precioQuintal: 2250,
        precioLibra: 22.5,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'granada',
        precioQuintal: 2220,
        precioLibra: 22.2,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'masaya',
        precioQuintal: 2230,
        precioLibra: 22.3,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'carazo',
        precioQuintal: 2210,
        precioLibra: 22.1,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'nueva_segovia',
        precioQuintal: 1980,
        precioLibra: 19.8,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'madriz',
        precioQuintal: 2020,
        precioLibra: 20.2,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'rio_san_juan',
        precioQuintal: 2300,
        precioLibra: 23.0,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'raan',
        precioQuintal: 2350,
        precioLibra: 23.5,
        fechaActualizacion: fechaActual,
      ),
      PrecioData(
        departamentoId: 'raas',
        precioQuintal: 2380,
        precioLibra: 23.8,
        fechaActualizacion: fechaActual,
      ),
    ];
  }
}
