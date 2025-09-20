import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosticoModel {
  final String id;
  final String userId;
  final String? diseaseName;
  final int? confidence;
  final List<String>? recommendations;
  final String? details;
  final String? location;
  final String? cropStage;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  DiagnosticoModel({
    required this.id,
    required this.userId,
    this.diseaseName,
    this.confidence,
    this.recommendations,
    this.details,
    this.location,
    this.cropStage,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  // Convertir de Firestore a DiagnosticoModel
  factory DiagnosticoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiagnosticoModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      diseaseName: data['diseaseName'],
      confidence: data['confidence'],
      recommendations: data['recommendations'] != null 
          ? List<String>.from(data['recommendations']) 
          : null,
      details: data['details'],
      location: data['location'],
      cropStage: data['cropStage'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir DiagnosticoModel a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'recommendations': recommendations,
      'details': details,
      'location': location,
      'cropStage': cropStage,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
