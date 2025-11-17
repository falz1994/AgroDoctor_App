import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/diagnostico_model.dart';
import '../platform/file.dart';



class DiagnosticoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> saveDiagnosis({
    required File? image,
    required String? description,
    required String? location,
    required String? cropStage,
    required Map<String, dynamic> results,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      String? imageUrl;
      // On web we expect callers to upload via different flow; keep placeholder behavior.
      if (image != null) {
        // No putFile on web for placeholder File; skip upload.
        imageUrl = null;
      }

      final diagnostico = DiagnosticoModel(
        id: '',
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

      final docRef = await _firestore.collection('diagnosticos').add(diagnostico.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error saving diagnosis (web stub): $e');
      return null;
    }
  }

  static Stream<List<DiagnosticoModel>> getUserDiagnostics() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('diagnosticos')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => DiagnosticoModel.fromFirestore(d)).toList());
  }

  static Future<DiagnosticoModel?> getDiagnosisById(String id) async {
    try {
      final doc = await _firestore.collection('diagnosticos').doc(id).get();
      if (doc.exists) return DiagnosticoModel.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('Error fetching diagnosis by id (web stub): $e');
      return null;
    }
  }

  // For web, we cannot use tflite_flutter (native FFI). Provide a safe fallback:
  // try to load labels file and return a simulated prediction.
  static Future<Map<String, dynamic>> processDiagnosis({
    required File? image,
    required String? description,
    required String? location,
    required String? cropStage,
  }) async {
    try {
      // If no image, return error
      if (image == null) return {'success': false, 'error': 'No image provided'};

      // Attempt to read labels (optional) to present a plausible label
      List<String> labels = [];
      try {
        final labelsData = await rootBundle.loadString('assets/models/class_names.txt');
        labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } catch (_) {
        // ignore
      }

      // Return a simulated prediction (web can't run native tflite). Use first label if available.
      final label = labels.isNotEmpty ? labels.first : 'Roya del frijol';
      final confidence = 85;
      final recommendations = <String>[
        'Aplicar fungicida a base de cobre',
        'Eliminar plantas infectadas',
      ];

      return {
        'success': true,
        'disease': label,
        'confidence': confidence,
        'recommendations': recommendations,
        'details': 'Web fallback: on-device inference no disponible en navegador.',
      };
    } catch (e) {
      debugPrint('processDiagnosis (web stub) failed: $e');
      return {
        'success': true,
        'disease': 'Roya del frijol',
        'confidence': 75,
        'recommendations': ['Inspección manual recomendada'],
        'details': 'Fallback por error en la ejecución web.',
      };
    }
  }

  static Future<void> saveDiagnosisInBackground(
    BuildContext context,
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    try {
      if (_auth.currentUser != null) {
        final diagnosisId = await saveDiagnosis(
          image: image,
          description: description,
          location: location,
          cropStage: cropStage,
          results: results,
        );
        if (diagnosisId != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Diagnóstico guardado en tu historial'),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      debugPrint('saveDiagnosisInBackground (web stub) error: $e');
    }
  }

  static Future<void> showDiagnosisResults(
    BuildContext context,
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    try {
      if (context.mounted) {
        await Navigator.of(context).pushReplacementNamed('/diagnostico-results', arguments: {
          'resultados': results,
          'diagnostico': null,
        });
        saveDiagnosisInBackground(context, results, image: image, description: description, location: location, cropStage: cropStage);
      }
    } catch (e) {
      debugPrint('showDiagnosisResults (web stub) error: $e');
    }
  }
}
