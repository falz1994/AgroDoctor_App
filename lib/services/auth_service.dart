import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Para web, el clientId se configura en el index.html
  // Para aplicaciones móviles, se usa la configuración predeterminada
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  // Estado actual del usuario
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  
  // Constructor
  AuthService() {
    // Inicializar el estado actual
    _user = _auth.currentUser;
    
    // Escuchar cambios en el estado de autenticación
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    
    // También escuchar cambios en el usuario
    _auth.userChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    
    // Verificar el estado de autenticación inmediatamente
    _auth.authStateChanges().first.then((user) {
      _user = user;
      notifyListeners();
    });
  }
  
  // Registro con email y contraseña
  Future<bool> registerWithEmailAndPassword(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar el nombre del usuario
      await userCredential.user!.updateDisplayName(name);
      
      // Actualizar el perfil del usuario
      await userCredential.user!.reload();
      _user = _auth.currentUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    }
  }
  
  // Inicio de sesión con email y contraseña
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    }
  }
  
  // Inicio de sesión con Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Iniciar el flujo de autenticación de Google
      debugPrint('Iniciando flujo de autenticación de Google');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Si el usuario cancela el inicio de sesión
      if (googleUser == null) {
        debugPrint('Usuario canceló el inicio de sesión con Google');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      debugPrint('Usuario Google obtenido: ${googleUser.email}');
      
      // Obtener detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _error = 'No se pudieron obtener los tokens de autenticación de Google';
        debugPrint(_error);
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Crear credencial para Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );
      
      debugPrint('Iniciando sesión en Firebase con credencial de Google');
      
      // Iniciar sesión con la credencial
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('Sesión iniciada correctamente: ${userCredential.user?.email}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al iniciar sesión con Google: ${e.toString()}';
      debugPrint('Error detallado en Google Sign-In: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Forzar cierre de sesión de Google
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _googleSignIn.signOut();
      
      // Forzar cierre de sesión de Firebase
      await _auth.signOut();
      
      // Forzar limpieza del estado
      _user = null;
      
      // Forzar recargar el estado de autenticación
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      
      // Incluso si hay error, intentamos forzar la limpieza del estado
      _user = null;
      notifyListeners();
    }
  }
  
  // Manejo de errores de autenticación
  void _handleAuthError(FirebaseAuthException e) {
    _isLoading = false;
    
    switch (e.code) {
      case 'user-not-found':
        _error = 'No existe un usuario con este correo electrónico.';
        break;
      case 'wrong-password':
        _error = 'Contraseña incorrecta.';
        break;
      case 'email-already-in-use':
        _error = 'Este correo electrónico ya está registrado.';
        break;
      case 'weak-password':
        _error = 'La contraseña es demasiado débil.';
        break;
      case 'invalid-email':
        _error = 'El formato del correo electrónico no es válido.';
        break;
      default:
        _error = 'Error de autenticación: ${e.message}';
    }
    
    notifyListeners();
  }
}

