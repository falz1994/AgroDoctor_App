import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Getters para acceder a los datos del servicio de autenticación
  bool get isLoading => _authService.isLoading;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get error => _authService.error;
  dynamic get user => _authService.user;
  
  // Constructor
  AuthProvider() {
    _authService.addListener(_onAuthServiceChanged);
  }
  
  // Métodos para interactuar con el servicio de autenticación
  Future<bool> registerWithEmailAndPassword(String name, String email, String password) async {
    return await _authService.registerWithEmailAndPassword(name, email, password);
  }
  
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }
  
  Future<bool> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
  }
  
  // Método para reaccionar a cambios en el servicio de autenticación
  void _onAuthServiceChanged() {
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthServiceChanged);
    super.dispose();
  }
}

