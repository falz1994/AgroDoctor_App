import 'package:flutter/foundation.dart';

class WebConfig {
  /// Verifica si la aplicación se está ejecutando en la web
  static bool get isWeb => kIsWeb;
  
  /// Obtiene la URL base para las peticiones API en web
  static String get baseUrl {
    if (isWeb) {
      return 'https://api.agrodoctor.com'; // Cambia esto por tu URL real
    }
    return 'https://api.agrodoctor.com'; // URL para móviles
  }
  
  /// Configuración específica para Google Maps en web
  static String get googleMapsApiKey {
    if (isWeb) {
      return 'YOUR_WEB_API_KEY'; // Reemplaza con tu API key para web
    }
    return 'YOUR_MOBILE_API_KEY'; // API key para móviles
  }
}
