import 'package:firebase_auth/firebase_auth.dart';

class AdminUtils {
  // Email del administrador autorizado
  static const String adminEmail = 'falzzz94@hotmail.com';
  
  /// Verifica si el usuario actual es el administrador
  static bool isAdmin(User? user) {
    return user?.email == adminEmail;
  }
  
  /// Verifica si el usuario actual es el administrador (versión con string)
  static bool isAdminByEmail(String? email) {
    return email == adminEmail;
  }
}
