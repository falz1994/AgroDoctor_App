import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shared_models.dart';
import '../models/diagnostico_model.dart';

class CasoDiagnosticoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference _casosCollection = _firestore.collection('casos_diagnostico');

  // Obtener el usuario actual
  static User? get currentUser => _auth.currentUser;
  
  // Función para probar la conexión con Firebase
  static Future<bool> testFirebaseConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      final testDoc = await _firestore.collection('test_connection').add({
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'test': true
      });
      
      await testDoc.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Crear un nuevo caso a partir de un diagnóstico
  static Future<CasoDiagnosticoModel> crearCasoDesdeDignostico({
    required DiagnosticoModel diagnostico,
    required String nombre,
    String? contenidoLog,
  }) async {
    try {
      print('🔄 Creando caso: $nombre');
      
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Asegurar que el diagnóstico tenga el userId correcto
      if (diagnostico.userId.isEmpty) {
        final diagnosticoData = diagnostico.toFirestore();
        diagnosticoData['userId'] = currentUser!.uid;
        
        await FirebaseFirestore.instance.collection('diagnosticos')
            .doc(diagnostico.id)
            .set(diagnosticoData);
      }

      // Crear el modelo del caso
      final docRef = _casosCollection.doc();
      final caso = CasoDiagnosticoModel.fromDiagnostico(
        id: docRef.id,
        nombre: nombre,
        diagnostico: diagnostico,
        contenidoLog: contenidoLog,
      );

      // Verificar datos antes de guardar
      final casoData = caso.toFirestore();
      
      // Asegurarnos de que el userId esté presente
      if (casoData['userId'] == null || casoData['userId'].isEmpty) {
        casoData['userId'] = currentUser!.uid;
      }

      // Guardar en Firestore
      await docRef.set(casoData);
      print('✅ Caso guardado exitosamente: ${docRef.id}');
      
      return caso;
    } catch (e) {
      print('❌ Error al crear caso: $e');
      throw Exception('Error al crear caso: $e');
    }
  }

  // Obtener todos los casos de un usuario
  static Stream<List<CasoDiagnosticoModel>> getUserCasos() {
    try {
      print('📋 Obteniendo casos para usuario: ${currentUser?.uid}');
      
      if (currentUser == null) {
        return Stream.value([]);
      }

      return _casosCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .snapshots()
          .map((snapshot) {
        print('📊 Casos encontrados: ${snapshot.docs.length}');
        
        return snapshot.docs.map((doc) {
          try {
            return CasoDiagnosticoModel.fromFirestore(doc);
          } catch (e) {
            print('❌ Error al convertir documento ${doc.id}: $e');
            return null;
          }
        }).where((caso) => caso != null).cast<CasoDiagnosticoModel>().toList();
      });
    } catch (e) {
      print('❌ Error al obtener casos: $e');
      return Stream.value([]);
    }
  }

  // Obtener todos los casos (para admin)
  static Stream<List<CasoDiagnosticoModel>> getAllCasos() {
    try {
      print('📋 Obteniendo todos los casos (admin)');
      
      return _casosCollection
          .snapshots()
          .map((snapshot) {
        print('📊 Total de casos: ${snapshot.docs.length}');
        
        return snapshot.docs.map((doc) {
          try {
            return CasoDiagnosticoModel.fromFirestore(doc);
          } catch (e) {
            print('❌ Error al convertir documento ${doc.id}: $e');
            return null;
          }
        }).where((caso) => caso != null).cast<CasoDiagnosticoModel>().toList();
      });
    } catch (e) {
      print('❌ Error al obtener todos los casos: $e');
      return Stream.value([]);
    }
  }

  // Obtener un caso específico por ID
  static Future<CasoDiagnosticoModel?> getCasoById(String casoId) async {
    try {
      final doc = await _casosCollection.doc(casoId).get();
      if (doc.exists) {
        return CasoDiagnosticoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener caso $casoId: $e');
      return null;
    }
  }

  // Actualizar un caso
  static Future<bool> actualizarCaso(String casoId, Map<String, dynamic> datos) async {
    try {
      await _casosCollection.doc(casoId).update(datos);
      print('✅ Caso actualizado: $casoId');
      return true;
    } catch (e) {
      print('❌ Error al actualizar caso $casoId: $e');
      return false;
    }
  }

  // Eliminar un caso
  static Future<bool> eliminarCaso(String casoId) async {
    try {
      await _casosCollection.doc(casoId).delete();
      print('✅ Caso eliminado: $casoId');
      return true;
    } catch (e) {
      print('❌ Error al eliminar caso $casoId: $e');
      return false;
    }
  }
}
