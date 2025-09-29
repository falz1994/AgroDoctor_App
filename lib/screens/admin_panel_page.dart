import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: "Usuarios",
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: "Casos",
            ),
            Tab(
              icon: Icon(Icons.medical_services),
              text: "Diagnósticos",
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Depurar Firestore',
            onPressed: () {
              _showDebugDialog(context);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildCasesTab(),
          _buildDiagnosticosTab(),
        ],
      ),
    );
  }
  
  void _showDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depuración de Firestore'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Herramientas para verificar y crear colecciones de prueba en Firestore.'),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Verificar colecciones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    // Verificar colecciones
                    final usersSnapshot = await _firestore.collection('users').get();
                    final casosSnapshot = await _firestore.collection('casos_diagnostico').get();
                    final diagnosticosSnapshot = await _firestore.collection('diagnosticos').get();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Colecciones encontradas:\n'
                            'users: ${usersSnapshot.docs.length} documentos\n'
                            'casos_diagnostico: ${casosSnapshot.docs.length} documentos\n'
                            'diagnosticos: ${diagnosticosSnapshot.docs.length} documentos'
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al verificar colecciones: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Crear usuario de prueba'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    // Crear usuario de prueba
                    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
                    await _firestore.collection('users').doc(userId).set({
                      'displayName': 'Usuario de Prueba',
                      'email': 'test@example.com',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario de prueba creado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    
                    setState(() {}); // Forzar reconstrucción
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear usuario: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.create_new_folder),
                label: const Text('Crear caso de prueba'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    // Crear caso de prueba
                    final casoId = 'caso_${DateTime.now().millisecondsSinceEpoch}';
                    await _firestore.collection('casos_diagnostico').doc(casoId).set({
                      'nombre': 'Caso de prueba',
                      'userId': 'user_test',
                      'estado': 'activo',
                      'diseaseName': 'Enfermedad de prueba',
                      'confidence': 85,
                      'description': 'Descripción de prueba',
                      'imageUrls': ['https://via.placeholder.com/150'],
                      'logs': [
                        {
                          'id': '1',
                          'contenido': 'Caso creado para pruebas',
                          'fecha': Timestamp.now(),
                          'usuarioId': 'user_test',
                        }
                      ],
                      'createdAt': Timestamp.now(),
                      'updatedAt': Timestamp.now(),
                    });
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Caso de prueba creado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    
                    setState(() {}); // Forzar reconstrucción
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear caso: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.healing),
                label: const Text('Crear diagnóstico de prueba'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    // Crear diagnóstico de prueba
                    final diagnosticoId = 'diag_${DateTime.now().millisecondsSinceEpoch}';
                    await _firestore.collection('diagnosticos').doc(diagnosticoId).set({
                      'userId': 'user_test',
                      'diseaseName': 'Enfermedad de prueba',
                      'confidence': 75,
                      'recommendations': ['Recomendación 1', 'Recomendación 2'],
                      'details': 'Detalles de prueba',
                      'description': 'Descripción de prueba',
                      'imageUrl': 'https://via.placeholder.com/150',
                      'createdAt': Timestamp.now(),
                    });
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Diagnóstico de prueba creado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    
                    setState(() {}); // Forzar reconstrucción
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear diagnóstico: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    print('Iniciando construcción de pestaña de usuarios');
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        print('Estado de la conexión: ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Esperando datos de usuarios...');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('ERROR en pestaña de usuarios: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});  // Forzar reconstrucción
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];
        print('Usuarios encontrados: ${users.length}');
        
        if (users.isEmpty) {
          print('No se encontraron usuarios en la colección');
          
          // Verificar si la colección existe
          _firestore.collection('users').get().then((allDocs) {
            print('Verificación directa - Total de documentos en users: ${allDocs.docs.length}');
          }).catchError((e) {
            print('Error al verificar colección users: $e');
          });
          
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay usuarios registrados'),
                SizedBox(height: 8),
                Text('La colección "users" está vacía', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            final email = userData['email'] ?? 'Sin email';
            final displayName = userData['displayName'] ?? 'Usuario sin nombre';
            final photoUrl = userData['photoURL'];
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(displayName),
                subtitle: Text(email),
                trailing: Text('ID: $userId'),
                onTap: () {
                  _showUserDetailsDialog(context, userId, userData);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCasesTab() {
    print('Iniciando construcción de pestaña de casos');
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('casos_diagnostico').snapshots(),
      builder: (context, snapshot) {
        print('Estado de la conexión (casos): ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Esperando datos de casos...');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('ERROR en pestaña de casos: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Verificar si la colección existe
                    _firestore.collection('casos_diagnostico').get().then((allDocs) {
                      print('Verificación directa - Total de documentos en casos_diagnostico: ${allDocs.docs.length}');
                      setState(() {});  // Forzar reconstrucción
                    }).catchError((e) {
                      print('Error al verificar colección casos_diagnostico: $e');
                    });
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final casos = snapshot.data?.docs ?? [];
        print('Casos encontrados: ${casos.length}');
        
        if (casos.isEmpty) {
          print('No se encontraron casos en la colección');
          
          // Verificar si la colección existe
          _firestore.collection('casos_diagnostico').get().then((allDocs) {
            print('Verificación directa - Total de documentos en casos_diagnostico: ${allDocs.docs.length}');
          }).catchError((e) {
            print('Error al verificar colección casos_diagnostico: $e');
          });
          
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay casos registrados'),
                SizedBox(height: 8),
                Text('La colección "casos_diagnostico" está vacía', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: casos.length,
          itemBuilder: (context, index) {
            final casoData = casos[index].data() as Map<String, dynamic>;
            final casoId = casos[index].id;
            final nombre = casoData['nombre'] ?? 'Caso sin nombre';
            final userId = casoData['userId'] ?? 'Sin usuario';
            final estado = casoData['estado'] ?? 'desconocido';
            final DateTime createdAt = (casoData['createdAt'] as Timestamp).toDate();
            final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: estado == 'activo' ? Colors.green : Colors.grey,
                  child: const Icon(Icons.folder, color: Colors.white),
                ),
                title: Text(nombre),
                subtitle: Text('Usuario: $userId - Fecha: $formattedDate'),
                trailing: Chip(
                  label: Text(estado),
                  backgroundColor: estado == 'activo' ? Colors.green.shade100 : Colors.grey.shade300,
                ),
                onTap: () {
                  _showCasoDetailsDialog(context, casoId, casoData);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosticosTab() {
    print('Iniciando construcción de pestaña de diagnósticos');
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('diagnosticos').snapshots(),
      builder: (context, snapshot) {
        print('Estado de la conexión (diagnósticos): ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Esperando datos de diagnósticos...');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('ERROR en pestaña de diagnósticos: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Verificar si la colección existe
                    _firestore.collection('diagnosticos').get().then((allDocs) {
                      print('Verificación directa - Total de documentos en diagnósticos: ${allDocs.docs.length}');
                      setState(() {});  // Forzar reconstrucción
                    }).catchError((e) {
                      print('Error al verificar colección diagnósticos: $e');
                    });
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final diagnosticos = snapshot.data?.docs ?? [];
        print('Diagnósticos encontrados: ${diagnosticos.length}');
        
        if (diagnosticos.isEmpty) {
          print('No se encontraron diagnósticos en la colección');
          
          // Verificar si la colección existe
          _firestore.collection('diagnosticos').get().then((allDocs) {
            print('Verificación directa - Total de documentos en diagnósticos: ${allDocs.docs.length}');
          }).catchError((e) {
            print('Error al verificar colección diagnósticos: $e');
          });
          
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay diagnósticos registrados'),
                SizedBox(height: 8),
                Text('La colección "diagnosticos" está vacía', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: diagnosticos.length,
          itemBuilder: (context, index) {
            final diagnosticoData = diagnosticos[index].data() as Map<String, dynamic>;
            final diagnosticoId = diagnosticos[index].id;
            final diseaseName = diagnosticoData['diseaseName'] ?? 'Sin enfermedad';
            final userId = diagnosticoData['userId'] ?? 'Sin usuario';
            final confidence = diagnosticoData['confidence']?.toString() ?? 'N/A';
            final DateTime createdAt = diagnosticoData['createdAt'] != null 
                ? (diagnosticoData['createdAt'] as Timestamp).toDate()
                : DateTime.now();
            final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  child: const Icon(Icons.medical_services, color: Colors.white),
                ),
                title: Text(diseaseName),
                subtitle: Text('Usuario: $userId - Fecha: $formattedDate'),
                trailing: Chip(
                  label: Text('$confidence%'),
                  backgroundColor: int.tryParse(confidence) != null && int.parse(confidence) > 70 
                      ? Colors.red.shade100 
                      : Colors.amber.shade100,
                ),
                onTap: () {
                  _showDiagnosticoDetailsDialog(context, diagnosticoId, diagnosticoData);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Usuario: ${userData['displayName'] ?? 'Sin nombre'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userData['photoURL'] != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['photoURL']),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', userId),
              _buildDetailRow('Email', userData['email'] ?? 'Sin email'),
              _buildDetailRow('Nombre', userData['displayName'] ?? 'Sin nombre'),
              _buildDetailRow('Teléfono', userData['phoneNumber'] ?? 'Sin teléfono'),
              _buildDetailRow('Email Verificado', (userData['emailVerified'] ?? false).toString()),
              _buildDetailRow('Fecha de Creación', userData['createdAt'] != null 
                ? (userData['createdAt'] as Timestamp).toDate().toString() 
                : 'Desconocida'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showCasoDetailsDialog(BuildContext context, String casoId, Map<String, dynamic> casoData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Caso: ${casoData['nombre'] ?? 'Sin nombre'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', casoId),
              _buildDetailRow('Usuario', casoData['userId'] ?? 'Sin usuario'),
              _buildDetailRow('Estado', casoData['estado'] ?? 'Desconocido'),
              _buildDetailRow('Enfermedad', casoData['diseaseName'] ?? 'Sin diagnóstico'),
              _buildDetailRow('Confianza', casoData['confidence'] != null ? '${casoData['confidence']}%' : 'N/A'),
              _buildDetailRow('Ubicación', casoData['location'] ?? 'Sin ubicación'),
              _buildDetailRow('Etapa del cultivo', casoData['cropStage'] ?? 'Sin información'),
              _buildDetailRow('Descripción', casoData['description'] ?? 'Sin descripción'),
              _buildDetailRow('Fecha de Creación', casoData['createdAt'] != null 
                ? (casoData['createdAt'] as Timestamp).toDate().toString() 
                : 'Desconocida'),
              _buildDetailRow('Última Actualización', casoData['updatedAt'] != null 
                ? (casoData['updatedAt'] as Timestamp).toDate().toString() 
                : 'Desconocida'),
              
              const SizedBox(height: 16),
              const Text('Imágenes:', style: TextStyle(fontWeight: FontWeight.bold)),
              if ((casoData['imageUrls'] as List?)?.isNotEmpty ?? false)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (casoData['imageUrls'] as List).length,
                    itemBuilder: (context, index) {
                      final imageUrl = (casoData['imageUrls'] as List)[index];
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          imageUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
                )
              else
                const Text('No hay imágenes'),
                
              const SizedBox(height: 16),
              const Text('Registros:', style: TextStyle(fontWeight: FontWeight.bold)),
              if ((casoData['logs'] as List?)?.isNotEmpty ?? false)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (casoData['logs'] as List).length,
                  itemBuilder: (context, index) {
                    final log = (casoData['logs'] as List)[index] as Map<String, dynamic>;
                    final contenido = log['contenido'] ?? 'Sin contenido';
                    final fecha = log['fecha'] != null 
                      ? (log['fecha'] as Timestamp).toDate().toString() 
                      : 'Fecha desconocida';
                    return ListTile(
                      title: Text(contenido),
                      subtitle: Text(fecha),
                      dense: true,
                    );
                  },
                )
              else
                const Text('No hay registros'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticoDetailsDialog(BuildContext context, String diagnosticoId, Map<String, dynamic> diagnosticoData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Diagnóstico: ${diagnosticoData['diseaseName'] ?? 'Sin nombre'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', diagnosticoId),
              _buildDetailRow('Usuario', diagnosticoData['userId'] ?? 'Sin usuario'),
              _buildDetailRow('Enfermedad', diagnosticoData['diseaseName'] ?? 'Sin diagnóstico'),
              _buildDetailRow('Confianza', diagnosticoData['confidence'] != null ? '${diagnosticoData['confidence']}%' : 'N/A'),
              _buildDetailRow('Ubicación', diagnosticoData['location'] ?? 'Sin ubicación'),
              _buildDetailRow('Etapa del cultivo', diagnosticoData['cropStage'] ?? 'Sin información'),
              _buildDetailRow('Descripción', diagnosticoData['description'] ?? 'Sin descripción'),
              _buildDetailRow('Fecha de Creación', diagnosticoData['createdAt'] != null 
                ? (diagnosticoData['createdAt'] as Timestamp).toDate().toString() 
                : 'Desconocida'),
              
              const SizedBox(height: 16),
              const Text('Imagen:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (diagnosticoData['imageUrl'] != null)
                Center(
                  child: Image.network(
                    diagnosticoData['imageUrl'],
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  ),
                )
              else
                const Text('No hay imagen'),
                
              if (diagnosticoData['recommendations'] != null) ...[
                const SizedBox(height: 16),
                const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (diagnosticoData['recommendations'] as List).length,
                  itemBuilder: (context, index) {
                    final recommendation = (diagnosticoData['recommendations'] as List)[index];
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(recommendation),
                      dense: true,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
