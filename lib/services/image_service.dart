import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/web_config.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  // Tomar una foto con la cámara
  static Future<File?> takePicture() async {
    // En web, el manejo de archivos es diferente
    if (WebConfig.isWeb) {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          // En web no podemos devolver un File directamente
          // pero para mantener la compatibilidad con el resto del código
          // devolvemos un File con la ruta del XFile
          return File(image.path);
        }
      } catch (e) {
        debugPrint('Error al tomar foto en web: ${e.toString()}');
      }
      return null;
    } else {
      // Comportamiento normal para móviles
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    }
  }
  
  // Seleccionar una imagen de la galería
  static Future<File?> pickFromGallery() async {
    // En web, el manejo de archivos es diferente
    if (WebConfig.isWeb) {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          // En web no podemos devolver un File directamente
          return File(image.path);
        }
      } catch (e) {
        debugPrint('Error al seleccionar imagen en web: ${e.toString()}');
      }
      return null;
    } else {
      // Comportamiento normal para móviles
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    }
  }
}
