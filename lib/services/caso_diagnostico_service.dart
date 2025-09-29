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
      print('Probando conexión con Firebase...');
      
      // Verificar autenticación
      final user = _auth.currentUser;
      print('Usuario autenticado: ${user != null ? 'Sí' : 'No'}');
      if (user != null) {
        print('ID de usuario: ${user.uid}');
        print('Email: ${user.email}');
      } else {
        print('ADVERTENCIA: No hay usuario autenticado');
        return false;
      }
      
      // Probar escritura en una colección temporal
      final testDoc = await _firestore.collection('test_connection').add({
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid ?? 'anónimo',
        'test': true
      });
      
      print('Documento de prueba creado con ID: ${testDoc.id}');
      
      // Leer el documento recién creado
      final docSnapshot = await testDoc.get();
      print('Documento leído: ${docSnapshot.exists ? 'Sí' : 'No'}');
      
      // Eliminar el documento de prueba
      await testDoc.delete();
      print('Documento de prueba eliminado');
      
      return true;
    } catch (e) {
      print('ERROR al probar conexión con Firebase: $e');
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
      print('========== INICIO crearCasoDesdeDignostico ==========');
      
      // Probar la conexión con Firebase primero
      final connectionOk = await testFirebaseConnection();
      print('Conexión con Firebase: ${connectionOk ? 'OK' : 'FALLIDA'}');
      if (!connectionOk) {
        throw Exception('No se pudo conectar con Firebase');
      }
      
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        print('ERROR: Usuario no autenticado');
        throw Exception('Usuario no autenticado');
      }

      print('Usuario autenticado: ${currentUser!.uid} (${currentUser!.email})');
      print('Nombre del caso: $nombre');
      print('ID del diagnóstico: ${diagnostico.id}');
      print('Diagnóstico completo: ${diagnostico.toFirestore()}');

      // Asegurarnos de que el diagnóstico tenga el userId correcto
      if (diagnostico.userId.isEmpty) {
        print('Corrigiendo userId en diagnóstico (estaba vacío)');
        // No podemos modificar el diagnóstico directamente, así que lo clonamos
        final diagnosticoData = diagnostico.toFirestore();
        diagnosticoData['userId'] = currentUser!.uid;
        
        try {
          // Actualizar el diagnóstico en Firestore
          print('Actualizando diagnóstico en Firestore...');
          await FirebaseFirestore.instance.collection('diagnosticos')
              .doc(diagnostico.id)
              .set(diagnosticoData);
          print('Diagnóstico actualizado correctamente');
        } catch (e) {
          print('ERROR al actualizar diagnóstico: $e');
          // Continuar de todos modos
        }
            
        // Crear un nuevo objeto DiagnosticoModel con los datos actualizados
        final updatedDiagnostico = DiagnosticoModel(
          id: diagnostico.id,
          userId: currentUser!.uid,
          diseaseName: diagnostico.diseaseName,
          confidence: diagnostico.confidence,
          recommendations: diagnostico.recommendations,
          details: diagnostico.details,
          location: diagnostico.location,
          cropStage: diagnostico.cropStage,
          description: diagnostico.description,
          imageUrl: diagnostico.imageUrl,
          createdAt: diagnostico.createdAt,
        );
        
        // Usar el diagnóstico actualizado
        diagnostico = updatedDiagnostico;
        print('Diagnóstico actualizado con userId: ${diagnostico.userId}');
      }

      // Crear el modelo del caso
      print('Creando modelo de caso...');
      final docRef = _casosCollection.doc();
      print('ID del nuevo caso: ${docRef.id}');
      
      final caso = CasoDiagnosticoModel.fromDiagnostico(
        id: docRef.id,
        nombre: nombre,
        diagnostico: diagnostico,
        contenidoLog: contenidoLog,
      );
      print('Modelo de caso creado correctamente');

      // Verificar datos antes de guardar
      final casoData = caso.toFirestore();
      print('Datos del caso a guardar:');
      casoData.forEach((key, value) {
        print('  $key: $value');
      });
      
      // Asegurarnos de que el userId esté presente
      if (casoData['userId'] == null || casoData['userId'].isEmpty) {
        print('Corrigiendo userId en casoData (estaba vacío)');
        casoData['userId'] = currentUser!.uid;
      }

      // Guardar en Firestore
      print('Guardando caso en Firestore...');
      try {
        await docRef.set(casoData);
        print('Caso guardado exitosamente en Firestore');
      } catch (e) {
        print('ERROR al guardar caso en Firestore: $e');
        throw Exception('Error al guardar caso: $e');
      }
      
      // Verificar que el caso se haya guardado correctamente
      try {
        print('Verificando que el caso se haya guardado...');
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          print('ÉXITO: El caso existe en Firestore con ID: ${docRef.id}');
        } else {
          print('ERROR: El caso NO existe en Firestore a pesar de guardarlo');
          throw Exception('El caso no se guardó correctamente');
        }
      } catch (e) {
        print('ERROR al verificar caso: $e');
      }
      
      print('========== FIN crearCasoDesdeDignostico ==========');
      return caso;
    } catch (e) {
      print('Error al crear caso: $e');
      throw Exception('Error al crear caso: $e');
    }
  }

  // Obtener todos los casos de un usuario
  static Stream<List<CasoDiagnosticoModel>> getUserCasos() {
    try {
      print('========== INICIO getUserCasos ==========');
      
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        print('ERROR: Usuario no autenticado en getUserCasos');
        return Stream.value([]);
      }

      print('Usuario autenticado: ${currentUser!.uid} (${currentUser!.email})');
      print('Consultando colección: ${_casosCollection.path}');
      
      // Probar primero con una consulta directa
      _firestore.collection('casos_diagnostico')
          .where('userId', isEqualTo: currentUser!.uid)
          .get()
          .then((snapshot) {
        print('Consulta directa: Se encontraron ${snapshot.docs.length} documentos');
        if (snapshot.docs.isNotEmpty) {
          print('IDs de documentos: ${snapshot.docs.map((d) => d.id).join(', ')}');
          snapshot.docs.forEach((doc) {
            print('Documento ${doc.id}: ${doc.data()}');
          });
        } else {
          print('No se encontraron documentos en la consulta directa');
          
          // Verificar si la colección existe
          _firestore.collection('casos_diagnostico').get().then((allDocs) {
            print('Total de documentos en la colección: ${allDocs.docs.length}');
          }).catchError((e) {
            print('Error al consultar toda la colección: $e');
          });
        }
      }).catchError((e) {
        print('Error en consulta directa: $e');
      });
      
      // Devolver el stream normal (temporalmente sin orderBy para evitar error de índice)
      return _casosCollection
          .where('userId', isEqualTo: currentUser!.uid)
          // .orderBy('createdAt', descending: true) // Comentado temporalmente
          .snapshots()
          .map((snapshot) {
        print('Stream: Snapshot recibido con ${snapshot.docs.length} documentos');
        
        // Imprimir IDs de documentos para depuración
        if (snapshot.docs.isNotEmpty) {
          print('Stream: IDs de documentos: ${snapshot.docs.map((d) => d.id).join(', ')}');
          // Imprimir el primer documento completo
          if (snapshot.docs.isNotEmpty) {
            print('Primer documento: ${snapshot.docs.first.data()}');
          }
        } else {
          print('Stream: No se encontraron documentos');
        }
        
        final casos = snapshot.docs
            .map((doc) {
              try {
                return CasoDiagnosticoModel.fromFirestore(doc);
              } catch (e) {
                print('Error al convertir documento ${doc.id} a modelo: $e');
                return null;
              }
            })
            .where((caso) => caso != null)
            .cast<CasoDiagnosticoModel>()
            .toList();
            
        print('Stream: Se convirtieron ${casos.length} documentos a modelos');
        print('========== FIN getUserCasos ==========');
        return casos;
      });
    } catch (e) {
      print('ERROR GENERAL en getUserCasos: $e');
      return Stream.value([]);
    }
  }

  // Obtener un caso específico
  static Stream<CasoDiagnosticoModel?> getCaso(String casoId) {
    return _casosCollection
        .doc(casoId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return CasoDiagnosticoModel.fromFirestore(doc);
          }
          return null;
        });
  }

  // Añadir un log a un caso
  static Future<void> addLogToCaso({
    required String casoId,
    required String contenido,
    String? imagenUrl,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el caso actual
      final docRef = _casosCollection.doc(casoId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Caso no encontrado');
      }
      
      final caso = CasoDiagnosticoModel.fromFirestore(docSnapshot);
      
      // Añadir el nuevo log
      final casoActualizado = caso.addLog(
        contenido: contenido,
        usuarioId: currentUser!.uid,
        usuarioNombre: currentUser!.displayName,
        imagenUrl: imagenUrl,
      );
      
      // Actualizar en Firestore
      await docRef.update({
        'logs': casoActualizado.logs.map((log) => log.toFirestore()).toList(),
        'updatedAt': Timestamp.fromDate(casoActualizado.updatedAt),
      });
    } catch (e) {
      throw Exception('Error al añadir log: $e');
    }
  }

  // Añadir una imagen a un caso
  static Future<void> addImageToCaso({
    required String casoId,
    required String imageUrl,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el caso actual
      final docRef = _casosCollection.doc(casoId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Caso no encontrado');
      }
      
      final caso = CasoDiagnosticoModel.fromFirestore(docSnapshot);
      
      // Añadir la nueva imagen
      final casoActualizado = caso.addImage(imageUrl);
      
      // Actualizar en Firestore
      await docRef.update({
        'imageUrls': casoActualizado.imageUrls,
        'updatedAt': Timestamp.fromDate(casoActualizado.updatedAt),
      });
    } catch (e) {
      throw Exception('Error al añadir imagen: $e');
    }
  }

  // Cambiar el estado de un caso
  static Future<void> cambiarEstadoCaso({
    required String casoId,
    required EstadoCaso nuevoEstado,
    String? comentario,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el caso actual
      final docRef = _casosCollection.doc(casoId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Caso no encontrado');
      }
      
      final caso = CasoDiagnosticoModel.fromFirestore(docSnapshot);
      
      // Cambiar el estado
      final casoActualizado = caso.cambiarEstado(nuevoEstado);
      
      // Actualizar en Firestore
      await docRef.update({
        'estado': estadoCasoToString(nuevoEstado),
        'updatedAt': Timestamp.fromDate(casoActualizado.updatedAt),
      });

      // Añadir log de cambio de estado si hay comentario
      if (comentario != null && comentario.isNotEmpty) {
        final estadoTexto = nuevoEstado == EstadoCaso.activo ? 'Activo' : 'Cerrado';
        await addLogToCaso(
          casoId: casoId,
          contenido: 'Caso marcado como $estadoTexto: $comentario',
        );
      }
    } catch (e) {
      throw Exception('Error al cambiar estado: $e');
    }
  }

  // Actualizar nombre del caso
  static Future<void> actualizarNombreCaso({
    required String casoId,
    required String nuevoNombre,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Actualizar en Firestore
      await _casosCollection.doc(casoId).update({
        'nombre': nuevoNombre,
        'updatedAt': Timestamp.now(),
      });

      // Añadir log de cambio de nombre
      await addLogToCaso(
        casoId: casoId,
        contenido: 'Nombre del caso actualizado a: $nuevoNombre',
      );
    } catch (e) {
      throw Exception('Error al actualizar nombre: $e');
    }
  }

  // Eliminar un caso
  static Future<void> eliminarCaso(String casoId) async {
    try {
      // Verificar que el usuario esté autenticado
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _casosCollection.doc(casoId).delete();
    } catch (e) {
      throw Exception('Error al eliminar caso: $e');
    }
  }
}
