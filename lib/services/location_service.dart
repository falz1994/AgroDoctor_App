import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/web_config.dart';

class LocationService {
  // Verificar y solicitar permisos de ubicación
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Los servicios de ubicación están desactivados. Por favor actívalos.')));
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Los permisos de ubicación fueron denegados')));
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Los permisos de ubicación están permanentemente denegados')));
      return false;
    }
    
    return true;
  }

  // Obtener la posición actual
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    // Manejo especial para web
    if (WebConfig.isWeb) {
      try {
        // En web, primero verificamos si el servicio está disponible
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Los servicios de ubicación están desactivados en el navegador.')));
          return null;
        }
        
        // Solicitar permisos para web
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Permisos de ubicación denegados')));
            return null;
          }
        }
        
        // Obtener posición en web
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
      } catch (e) {
        debugPrint('Error de ubicación en web: ${e.toString()}');
        return null;
      }
    } else {
      // Comportamiento normal para móviles
      final hasPermission = await handleLocationPermission(context);
      
      if (!hasPermission) return null;
      
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
    }
  }

  // Obtener la dirección a partir de coordenadas
  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
