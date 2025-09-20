import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Método para guardar un diagnóstico en Firestore
  static Future<String?> saveDiagnosis({
    required File? image,
    required String? description,
    required String? location,
    required String? cropStage,
    required Map<String, dynamic> results,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null; // Usuario no autenticado
      }
      
      String? imageUrl;
      
      // Si hay una imagen, subirla a Firebase Storage
      if (image != null) {
        final storageRef = _storage.ref().child('diagnosticos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      
      // Crear el modelo de diagnóstico
      final diagnostico = DiagnosticoModel(
        id: '', // Se asignará automáticamente por Firestore
        userId: user.uid,
        diseaseName: results['disease'],
        confidence: results['confidence'],
        recommendations: results['recommendations'] != null 
            ? List<String>.from(results['recommendations']) 
            : null,
        details: results['details'],
        location: location,
        cropStage: cropStage,
        description: description,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      
      // Guardar en Firestore
      final docRef = await _firestore.collection('diagnosticos').add(diagnostico.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error al guardar diagnóstico: $e');
      return null;
    }
  }
  
  // Método para obtener los diagnósticos de un usuario
  static Stream<List<DiagnosticoModel>> getUserDiagnostics() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('diagnosticos')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DiagnosticoModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Método para obtener un diagnóstico específico
  static Future<DiagnosticoModel?> getDiagnosisById(String id) async {
    try {
      final doc = await _firestore.collection('diagnosticos').doc(id).get();
      if (doc.exists) {
        return DiagnosticoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener diagnóstico: $e');
      return null;
    }
  }
  // Esta función simula el proceso de diagnóstico
  // En una implementación real, aquí se conectaría con la API de IA
  static Future<Map<String, dynamic>> processDiagnosis({
    required File? image,
    required String? description,
    required String? location,
    required String? cropStage,
  }) async {
    // Simular un proceso de diagnóstico que toma tiempo
    await Future.delayed(const Duration(seconds: 3));
    
    // Datos simulados de respuesta
    return {
      'success': true,
      'disease': 'Roya del frijol',
      'confidence': 92,
      'recommendations': [
        'Aplicar fungicida a base de cobre',
        'Eliminar plantas infectadas',
        'Mejorar la ventilación entre plantas',
        'Evitar riego por aspersión',
      ],
      'details': 'La roya del frijol es una enfermedad fúngica causada por Uromyces appendiculatus. '
          'Se caracteriza por pústulas de color marrón rojizo en las hojas y tallos. '
          'Es más común en condiciones de alta humedad y temperaturas moderadas.',
    };
  }
  
  // Método para mostrar los resultados del diagnóstico
  static void showDiagnosisResults(
    BuildContext context, 
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    // Guardar el diagnóstico en Firestore
    String? diagnosisId;
    
    if (_auth.currentUser != null) {
      diagnosisId = await saveDiagnosis(
        image: image,
        description: description,
        location: location,
        cropStage: cropStage,
        results: results,
      );
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resultado del Diagnóstico"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enfermedad detectada: ${results['disease']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Nivel de confianza: ${results['confidence']}%",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recomendaciones:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ...List.generate(
              results['recommendations'].length,
              (index) => Text("• ${results['recommendations'][index]}"),
            ),
            const SizedBox(height: 10),
            if (_auth.currentUser == null)
              const Text(
                "Inicia sesión para guardar este diagnóstico",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            if (diagnosisId != null)
              const Text(
                "Este diagnóstico ha sido guardado en tu historial",
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a la página principal
            },
            child: const Text("Aceptar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Ver más detalles"),
          ),
        ],
      ),
    );
  }
}
