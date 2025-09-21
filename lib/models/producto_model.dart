import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoriaProducto {
  insecticida,
  fertilizante,
  herramienta,
  semilla,
  maquinaria,
  otro
}

class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String moneda; // NIO, USD, etc.
  final String vendedor;
  final String vendedorId;
  final String? imagenUrl;
  final CategoriaProducto categoria;
  final bool disponible;
  final int stock;
  final List<String>? etiquetas;
  final DateTime fechaPublicacion;
  final double? descuento; // Porcentaje de descuento (0-100)

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.moneda,
    required this.vendedor,
    required this.vendedorId,
    this.imagenUrl,
    required this.categoria,
    required this.disponible,
    required this.stock,
    this.etiquetas,
    required this.fechaPublicacion,
    this.descuento,
  });

  // Convertir de Firestore a ProductoModel
  factory ProductoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductoModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      moneda: data['moneda'] ?? 'NIO',
      vendedor: data['vendedor'] ?? '',
      vendedorId: data['vendedorId'] ?? '',
      imagenUrl: data['imagenUrl'],
      categoria: _stringToCategoria(data['categoria'] ?? 'otro'),
      disponible: data['disponible'] ?? true,
      stock: data['stock'] ?? 0,
      etiquetas: data['etiquetas'] != null ? List<String>.from(data['etiquetas']) : null,
      fechaPublicacion: (data['fechaPublicacion'] as Timestamp).toDate(),
      descuento: data['descuento']?.toDouble(),
    );
  }

  // Convertir ProductoModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'moneda': moneda,
      'vendedor': vendedor,
      'vendedorId': vendedorId,
      'imagenUrl': imagenUrl,
      'categoria': _categoriaToString(categoria),
      'disponible': disponible,
      'stock': stock,
      'etiquetas': etiquetas,
      'fechaPublicacion': Timestamp.fromDate(fechaPublicacion),
      'descuento': descuento,
    };
  }

  // Convertir string a CategoriaProducto
  static CategoriaProducto _stringToCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'insecticida':
        return CategoriaProducto.insecticida;
      case 'fertilizante':
        return CategoriaProducto.fertilizante;
      case 'herramienta':
        return CategoriaProducto.herramienta;
      case 'semilla':
        return CategoriaProducto.semilla;
      case 'maquinaria':
        return CategoriaProducto.maquinaria;
      default:
        return CategoriaProducto.otro;
    }
  }

  // Convertir CategoriaProducto a string
  static String _categoriaToString(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.insecticida:
        return 'insecticida';
      case CategoriaProducto.fertilizante:
        return 'fertilizante';
      case CategoriaProducto.herramienta:
        return 'herramienta';
      case CategoriaProducto.semilla:
        return 'semilla';
      case CategoriaProducto.maquinaria:
        return 'maquinaria';
      case CategoriaProducto.otro:
        return 'otro';
    }
  }

  // Obtener el precio con descuento
  double get precioFinal {
    if (descuento != null && descuento! > 0) {
      return precio * (1 - descuento! / 100);
    }
    return precio;
  }

  // Obtener el nombre de la categoría para mostrar
  String get categoriaNombre {
    switch (categoria) {
      case CategoriaProducto.insecticida:
        return 'Insecticida';
      case CategoriaProducto.fertilizante:
        return 'Fertilizante';
      case CategoriaProducto.herramienta:
        return 'Herramienta';
      case CategoriaProducto.semilla:
        return 'Semilla';
      case CategoriaProducto.maquinaria:
        return 'Maquinaria';
      case CategoriaProducto.otro:
        return 'Otro';
    }
  }
}

// Clase para gestionar datos de productos de ejemplo
class ProductosData {
  // Datos de productos de ejemplo
  static List<ProductoModel> getProductos() {
    final DateTime ahora = DateTime.now();
    
    return [
      ProductoModel(
        id: 'insect001',
        nombre: 'Insecticida Orgánico para Frijol',
        descripcion: 'Insecticida orgánico especial para el control de plagas en cultivos de frijol. No daña el medio ambiente y es seguro para los cultivos.',
        precio: 350.0,
        moneda: 'NIO',
        vendedor: 'AgroEcológico S.A.',
        vendedorId: 'vendor001',
        imagenUrl: 'https://example.com/insecticida1.jpg',
        categoria: CategoriaProducto.insecticida,
        disponible: true,
        stock: 45,
        etiquetas: ['orgánico', 'frijol', 'ecológico', 'natural'],
        fechaPublicacion: ahora.subtract(const Duration(days: 5)),
      ),
      ProductoModel(
        id: 'fert001',
        nombre: 'Fertilizante Premium para Leguminosas',
        descripcion: 'Fertilizante de alta calidad especialmente formulado para cultivos de frijol y otras leguminosas. Mejora el rendimiento y la calidad de la cosecha.',
        precio: 480.0,
        moneda: 'NIO',
        vendedor: 'AgroNutrientes',
        vendedorId: 'vendor002',
        imagenUrl: 'https://example.com/fertilizante1.jpg',
        categoria: CategoriaProducto.fertilizante,
        disponible: true,
        stock: 30,
        etiquetas: ['premium', 'leguminosas', 'alto rendimiento'],
        fechaPublicacion: ahora.subtract(const Duration(days: 10)),
        descuento: 15.0,
      ),
      ProductoModel(
        id: 'herr001',
        nombre: 'Kit de Herramientas para Cosecha',
        descripcion: 'Kit completo con las herramientas esenciales para la cosecha de frijol. Incluye tijeras de poda, guantes, bolsas y más.',
        precio: 850.0,
        moneda: 'NIO',
        vendedor: 'Herramientas del Campo',
        vendedorId: 'vendor003',
        imagenUrl: 'https://example.com/herramientas1.jpg',
        categoria: CategoriaProducto.herramienta,
        disponible: true,
        stock: 15,
        etiquetas: ['kit', 'cosecha', 'herramientas', 'calidad'],
        fechaPublicacion: ahora.subtract(const Duration(days: 15)),
      ),
      ProductoModel(
        id: 'sem001',
        nombre: 'Semillas de Frijol INTA Rojo',
        descripcion: 'Semillas certificadas de frijol variedad INTA Rojo. Alto rendimiento y resistencia a enfermedades comunes.',
        precio: 220.0,
        moneda: 'NIO',
        vendedor: 'Semillas Certificadas',
        vendedorId: 'vendor004',
        imagenUrl: 'https://example.com/semillas1.jpg',
        categoria: CategoriaProducto.semilla,
        disponible: true,
        stock: 100,
        etiquetas: ['certificadas', 'INTA', 'alto rendimiento'],
        fechaPublicacion: ahora.subtract(const Duration(days: 3)),
      ),
      ProductoModel(
        id: 'maq001',
        nombre: 'Desgranadora de Frijol Manual',
        descripcion: 'Desgranadora manual de frijol de alta eficiencia. Ideal para pequeños y medianos productores.',
        precio: 3200.0,
        moneda: 'NIO',
        vendedor: 'Maquinaria Agrícola',
        vendedorId: 'vendor005',
        imagenUrl: 'https://example.com/maquinaria1.jpg',
        categoria: CategoriaProducto.maquinaria,
        disponible: true,
        stock: 5,
        etiquetas: ['desgranadora', 'manual', 'eficiente'],
        fechaPublicacion: ahora.subtract(const Duration(days: 20)),
        descuento: 10.0,
      ),
      ProductoModel(
        id: 'insect002',
        nombre: 'Insecticida para Control de Mosca Blanca',
        descripcion: 'Insecticida especializado para el control de mosca blanca en cultivos de frijol. Protección duradera.',
        precio: 420.0,
        moneda: 'NIO',
        vendedor: 'AgroProtección',
        vendedorId: 'vendor006',
        imagenUrl: 'https://example.com/insecticida2.jpg',
        categoria: CategoriaProducto.insecticida,
        disponible: true,
        stock: 25,
        etiquetas: ['mosca blanca', 'protección', 'duradero'],
        fechaPublicacion: ahora.subtract(const Duration(days: 8)),
      ),
      ProductoModel(
        id: 'fert002',
        nombre: 'Abono Orgánico para Suelos',
        descripcion: 'Abono 100% orgánico para mejorar la calidad del suelo. Ideal para cultivos de frijol y otras leguminosas.',
        precio: 300.0,
        moneda: 'NIO',
        vendedor: 'EcoFertilizantes',
        vendedorId: 'vendor007',
        imagenUrl: 'https://example.com/fertilizante2.jpg',
        categoria: CategoriaProducto.fertilizante,
        disponible: true,
        stock: 40,
        etiquetas: ['orgánico', 'suelo', 'ecológico'],
        fechaPublicacion: ahora.subtract(const Duration(days: 12)),
      ),
      ProductoModel(
        id: 'herr002',
        nombre: 'Azadón Profesional',
        descripcion: 'Azadón de alta calidad para labores agrícolas. Mango ergonómico y hoja resistente.',
        precio: 380.0,
        moneda: 'NIO',
        vendedor: 'Herramientas del Campo',
        vendedorId: 'vendor003',
        imagenUrl: 'https://example.com/herramientas2.jpg',
        categoria: CategoriaProducto.herramienta,
        disponible: true,
        stock: 20,
        etiquetas: ['azadón', 'profesional', 'ergonómico'],
        fechaPublicacion: ahora.subtract(const Duration(days: 18)),
        descuento: 5.0,
      ),
      ProductoModel(
        id: 'sem002',
        nombre: 'Semillas de Frijol Negro',
        descripcion: 'Semillas certificadas de frijol negro. Variedad resistente a sequía y enfermedades.',
        precio: 240.0,
        moneda: 'NIO',
        vendedor: 'Semillas Certificadas',
        vendedorId: 'vendor004',
        imagenUrl: 'https://example.com/semillas2.jpg',
        categoria: CategoriaProducto.semilla,
        disponible: true,
        stock: 80,
        etiquetas: ['certificadas', 'frijol negro', 'resistente'],
        fechaPublicacion: ahora.subtract(const Duration(days: 7)),
      ),
      ProductoModel(
        id: 'maq002',
        nombre: 'Fumigadora de Mochila 20L',
        descripcion: 'Fumigadora de mochila con capacidad de 20 litros. Ideal para aplicación de insecticidas y fertilizantes líquidos.',
        precio: 1200.0,
        moneda: 'NIO',
        vendedor: 'Maquinaria Agrícola',
        vendedorId: 'vendor005',
        imagenUrl: 'https://example.com/maquinaria2.jpg',
        categoria: CategoriaProducto.maquinaria,
        disponible: true,
        stock: 12,
        etiquetas: ['fumigadora', 'mochila', '20L'],
        fechaPublicacion: ahora.subtract(const Duration(days: 25)),
      ),
      ProductoModel(
        id: 'otro001',
        nombre: 'Manual de Cultivo de Frijol',
        descripcion: 'Guía completa para el cultivo exitoso de frijol. Incluye técnicas de siembra, cuidado y cosecha.',
        precio: 150.0,
        moneda: 'NIO',
        vendedor: 'Editorial Agrícola',
        vendedorId: 'vendor008',
        imagenUrl: 'https://example.com/manual1.jpg',
        categoria: CategoriaProducto.otro,
        disponible: true,
        stock: 30,
        etiquetas: ['manual', 'guía', 'cultivo'],
        fechaPublicacion: ahora.subtract(const Duration(days: 30)),
      ),
      ProductoModel(
        id: 'insect003',
        nombre: 'Repelente Natural de Plagas',
        descripcion: 'Repelente natural a base de extractos vegetales para el control de plagas en cultivos de frijol.',
        precio: 280.0,
        moneda: 'NIO',
        vendedor: 'AgroEcológico S.A.',
        vendedorId: 'vendor001',
        imagenUrl: 'https://example.com/insecticida3.jpg',
        categoria: CategoriaProducto.insecticida,
        disponible: true,
        stock: 35,
        etiquetas: ['natural', 'repelente', 'extracto vegetal'],
        fechaPublicacion: ahora.subtract(const Duration(days: 9)),
        descuento: 8.0,
      ),
    ];
  }

  // Obtener productos por categoría
  static List<ProductoModel> getProductosPorCategoria(CategoriaProducto categoria) {
    return getProductos().where((p) => p.categoria == categoria).toList();
  }

  // Obtener productos destacados (con descuento)
  static List<ProductoModel> getProductosDestacados() {
    return getProductos().where((p) => p.descuento != null && p.descuento! > 0).toList();
  }

  // Buscar productos por término
  static List<ProductoModel> buscarProductos(String termino) {
    termino = termino.toLowerCase();
    return getProductos().where((p) => 
      p.nombre.toLowerCase().contains(termino) || 
      p.descripcion.toLowerCase().contains(termino) ||
      (p.etiquetas?.any((tag) => tag.toLowerCase().contains(termino)) ?? false)
    ).toList();
  }
}
