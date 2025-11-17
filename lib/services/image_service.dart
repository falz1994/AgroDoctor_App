import '../platform/file.dart';
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
          // En web, wrap the XFile inside our platform File wrapper so
          // callers can use readAsBytes() uniformly.
          return File(image as dynamic);
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
          // Wrap XFile for web
          return File(image as dynamic);
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
