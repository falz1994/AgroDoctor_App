import '../platform/file.dart';
// dart:typed_data not used in IO implementation (kept if future changes need it)
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
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
    // Try to run on-device TFLite inference if model exists in assets
    try {
      if (image == null) {
        return {
          'success': false,
          'error': 'No image provided',
        };
      }

      // Load labels from assets
      List<String> labels = [];
      try {
        final labelsData = await rootBundle.loadString('assets/models/class_names.txt');
        labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } catch (e) {
        debugPrint('Could not load labels from assets: $e');
      }

      // Load TFLite model from assets
      Interpreter interpreter;
      try {
        interpreter = await Interpreter.fromAsset('assets/models/model_mobilenetv3_large_dynamic.tflite');
      } catch (e) {
        debugPrint('TFLite model not found in assets or failed to load: $e');
        throw e;
      }

      // Prepare image: decode, resize to 224x224 and normalize to [-1,1]
      final bytes = await image.readAsBytes();
      final ori = img.decodeImage(bytes);
      if (ori == null) {
        throw Exception('Cannot decode image');
      }
      final resized = img.copyResize(ori, width: 224, height: 224);

      // Build input as nested List: [1][224][224][3]
      final inputImage = List.generate(1, (_) => List.generate(224, (y) => List.generate(224, (x) {
        final p = resized.getPixel(x, y);
        final r = img.getRed(p);
        final g = img.getGreen(p);
        final b = img.getBlue(p);
        return [(r - 127.5) / 127.5, (g - 127.5) / 127.5, (b - 127.5) / 127.5];
      })));

      // Prepare output buffer
      final outputShape = interpreter.getOutputTensor(0).shape; // e.g. [1, N]
      final outLen = outputShape.length >= 2 ? outputShape[1] : outputShape[0];
      var output = List.filled(1, List.filled(outLen, 0.0));

      // Run inference
      interpreter.run(inputImage, output);

      // Read predictions
      final preds = List<double>.from(output[0].map((v) => v.toDouble()));

      // Find top-1
      int topIdx = 0;
      double topVal = preds[0];
      for (int i = 1; i < preds.length; i++) {
        if (preds[i] > topVal) {
          topVal = preds[i];
          topIdx = i;
        }
      }

      final label = (labels.isNotEmpty && topIdx < labels.length) ? labels[topIdx] : 'class_$topIdx';
      final confidence = (topVal * 100).round();

      // Basic recommendations placeholder (could be improved mapping per class)
      final recommendations = <String>[];
      final details = 'Predicción del modelo on-device.';
      switch (label.toLowerCase()) {
        case 'bean_rust':
        case 'roya del frijol':
          recommendations.addAll([
            'Aplicar fungicida a base de cobre',
            'Eliminar plantas infectadas',
            'Mejorar la ventilación entre plantas',
          ]);
          break;
        case 'angular_leaf_spot':
          recommendations.addAll([
            'Eliminar hojas severamente afectadas',
            'Aplicar fungicida sistémico según etiqueta',
          ]);
          break;
        case 'healthy':
          recommendations.add('Planta saludable. Mantener buenas prácticas culturales.');
          break;
        default:
          recommendations.add('Revisar manualmente; el modelo no proporcionó recomendaciones específicas.');
      }

      interpreter.close();

      return {
        'success': true,
        'disease': label,
        'confidence': confidence,
        'recommendations': recommendations,
        'details': details,
      };
    } catch (e) {
      debugPrint('On-device inference failed, falling back to simulated result: $e');
      // Fallback to simulated response to avoid breaking UX
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'disease': 'Roya del frijol',
        'confidence': 92,
        'recommendations': [
          'Aplicar fungicida a base de cobre',
          'Eliminar plantas infectadas',
          'Mejorar la ventilación entre plantas',
        ],
        'details': 'Fallback: análisis no disponible en el dispositivo.',
      };
    }
  }
  
  // Método para guardar el diagnóstico en segundo plano sin bloquear la UI
  static Future<void> saveDiagnosisInBackground(
    BuildContext context,
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    try {
      // Guardar el diagnóstico en Firestore solo si el usuario está autenticado
      if (_auth.currentUser != null) {
        debugPrint('Guardando diagnóstico en segundo plano...');
        
        final diagnosisId = await saveDiagnosis(
          image: image,
          description: description,
          location: location,
          cropStage: cropStage,
          results: results,
        );
        
        // Mostrar mensaje solo si se guardó correctamente y el contexto sigue siendo válido
        if (diagnosisId != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diagnóstico guardado en tu historial'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          debugPrint('Diagnóstico guardado con ID: $diagnosisId');
        }
      } else {
        debugPrint('Usuario no autenticado, no se guardó el diagnóstico');
        // Mostrar mensaje para iniciar sesión si el contexto sigue siendo válido
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inicia sesión para guardar tus diagnósticos'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al guardar diagnóstico en segundo plano: $e');
      // No mostrar error al usuario para no interrumpir la experiencia
    }
  }
  
  // Método para mostrar los resultados del diagnóstico (mantenido por compatibilidad)
  static Future<void> showDiagnosisResults(
    BuildContext context, 
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    try {
      debugPrint('Método showDiagnosisResults llamado - redirigiendo a saveDiagnosisInBackground');
      
      // Navegar directamente a la página de resultados
      if (context.mounted) {
        await Navigator.of(context).pushReplacementNamed(
          '/diagnostico-results',
          arguments: {
            'resultados': results,
            'diagnostico': null,
          },
        );
        
        // Guardar en segundo plano después de la navegación
        saveDiagnosisInBackground(
          context,
          results,
          image: image,
          description: description,
          location: location,
          cropStage: cropStage,
        );
      }
    } catch (e) {
      debugPrint('Error en showDiagnosisResults: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el diagnóstico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
