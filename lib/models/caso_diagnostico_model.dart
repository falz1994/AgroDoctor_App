import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoCaso {
  activo,
  cerrado
}

class LogEntry {
  final String id;
  final String contenido;
  final DateTime fecha;
  final String? usuarioId;
  final String? usuarioNombre;
  final String? imagenUrl;

  LogEntry({
    required this.id,
    required this.contenido,
    required this.fecha,
    this.usuarioId,
    this.usuarioNombre,
    this.imagenUrl,
  });

  // Convertir de Firestore a LogEntry
  factory LogEntry.fromFirestore(Map<String, dynamic> data) {
    return LogEntry(
      id: data['id'] ?? '',
      contenido: data['contenido'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      usuarioId: data['usuarioId'],
      usuarioNombre: data['usuarioNombre'],
      imagenUrl: data['imagenUrl'],
    );
  }

  // Convertir LogEntry a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'contenido': contenido,
      'fecha': Timestamp.fromDate(fecha),
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'imagenUrl': imagenUrl,
    };
  }
}

class CasoDiagnosticoModel {
  final String id;
  final String nombre;
  final String userId;
  final EstadoCaso estado;
  final String? diseaseName;
  final int? confidence;
  final List<String>? recommendations;
  final String? details;
  final String? location;
  final String? cropStage;
  final String? description;
  final List<String> imageUrls;
  final List<LogEntry> logs;
  final DateTime createdAt;
  final DateTime updatedAt;

  CasoDiagnosticoModel({
    required this.id,
    required this.nombre,
    required this.userId,
    required this.estado,
    this.diseaseName,
    this.confidence,
    this.recommendations,
    this.details,
    this.location,
    this.cropStage,
    this.description,
    required this.imageUrls,
    required this.logs,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir de Firestore a CasoDiagnosticoModel
  factory CasoDiagnosticoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convertir logs de Firestore
    List<LogEntry> logs = [];
    if (data['logs'] != null) {
      logs = List<Map<String, dynamic>>.from(data['logs'])
          .map((log) => LogEntry.fromFirestore(log))
          .toList();
    }

    return CasoDiagnosticoModel(
      id: doc.id,
      nombre: data['nombre'] ?? 'Caso sin nombre',
      userId: data['userId'] ?? '',
      estado: _stringToEstadoCaso(data['estado'] ?? 'activo'),
      diseaseName: data['diseaseName'],
      confidence: data['confidence'],
      recommendations: data['recommendations'] != null 
          ? List<String>.from(data['recommendations']) 
          : null,
      details: data['details'],
      location: data['location'],
      cropStage: data['cropStage'],
      description: data['description'],
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls']) 
          : [],
      logs: logs,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convertir CasoDiagnosticoModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'userId': userId,
      'estado': estadoCasoToString(estado),
      'diseaseName': diseaseName,
      'confidence': confidence,
      'recommendations': recommendations,
      'details': details,
      'location': location,
      'cropStage': cropStage,
      'description': description,
      'imageUrls': imageUrls,
      'logs': logs.map((log) => log.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Crear un caso a partir de un diagnóstico existente
  factory CasoDiagnosticoModel.fromDiagnostico({
    required String id,
    required String nombre,
    required dynamic diagnostico,
    String? contenidoLog,
  }) {
    final now = DateTime.now();
    
    // Crear el log inicial
    final logInicial = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contenido: contenidoLog ?? 'Caso creado a partir de diagnóstico inicial',
      fecha: now,
      usuarioId: diagnostico.userId,
    );

    return CasoDiagnosticoModel(
      id: id,
      nombre: nombre,
      userId: diagnostico.userId,
      estado: EstadoCaso.activo,
      diseaseName: diagnostico.diseaseName,
      confidence: diagnostico.confidence,
      recommendations: diagnostico.recommendations,
      details: diagnostico.details,
      location: diagnostico.location,
      cropStage: diagnostico.cropStage,
      description: diagnostico.description,
      imageUrls: diagnostico.imageUrl != null ? [diagnostico.imageUrl] : [],
      logs: [logInicial],
      createdAt: diagnostico.createdAt,
      updatedAt: now,
    );
  }

  // Añadir un nuevo log al caso
  CasoDiagnosticoModel addLog({
    required String contenido,
    String? usuarioId,
    String? usuarioNombre,
    String? imagenUrl,
  }) {
    final now = DateTime.now();
    final nuevoLog = LogEntry(
      id: now.millisecondsSinceEpoch.toString(),
      contenido: contenido,
      fecha: now,
      usuarioId: usuarioId,
      usuarioNombre: usuarioNombre,
      imagenUrl: imagenUrl,
    );

    return CasoDiagnosticoModel(
      id: id,
      nombre: nombre,
      userId: userId,
      estado: estado,
      diseaseName: diseaseName,
      confidence: confidence,
      recommendations: recommendations,
      details: details,
      location: location,
      cropStage: cropStage,
      description: description,
      imageUrls: imageUrls,
      logs: [...logs, nuevoLog],
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  // Añadir una nueva imagen al caso
  CasoDiagnosticoModel addImage(String imageUrl) {
    return CasoDiagnosticoModel(
      id: id,
      nombre: nombre,
      userId: userId,
      estado: estado,
      diseaseName: diseaseName,
      confidence: confidence,
      recommendations: recommendations,
      details: details,
      location: location,
      cropStage: cropStage,
      description: description,
      imageUrls: [...imageUrls, imageUrl],
      logs: logs,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Cambiar el estado del caso
  CasoDiagnosticoModel cambiarEstado(EstadoCaso nuevoEstado) {
    return CasoDiagnosticoModel(
      id: id,
      nombre: nombre,
      userId: userId,
      estado: nuevoEstado,
      diseaseName: diseaseName,
      confidence: confidence,
      recommendations: recommendations,
      details: details,
      location: location,
      cropStage: cropStage,
      description: description,
      imageUrls: imageUrls,
      logs: logs,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Convertir string a EstadoCaso
  static EstadoCaso _stringToEstadoCaso(String estado) {
    switch (estado.toLowerCase()) {
      case 'cerrado':
        return EstadoCaso.cerrado;
      case 'activo':
      default:
        return EstadoCaso.activo;
    }
  }

  // Convertir EstadoCaso a string
  static String estadoCasoToString(EstadoCaso estado) {
    switch (estado) {
      case EstadoCaso.cerrado:
        return 'cerrado';
      case EstadoCaso.activo:
        return 'activo';
    }
  }
}
