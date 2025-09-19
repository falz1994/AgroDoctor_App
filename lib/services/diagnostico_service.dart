import 'dart:io';
import 'package:flutter/material.dart';

class DiagnosticoService {
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
  static void showDiagnosisResults(BuildContext context, Map<String, dynamic> results) {
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
