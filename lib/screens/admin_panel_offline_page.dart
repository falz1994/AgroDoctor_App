import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AdminPanelOfflinePage extends StatefulWidget {
  const AdminPanelOfflinePage({super.key});

  @override
  State<AdminPanelOfflinePage> createState() => _AdminPanelOfflinePageState();
}

class _AdminPanelOfflinePageState extends State<AdminPanelOfflinePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _connectionStatus = 'Desconectado';
  String _errorMessage = '';

  // Datos simulados para modo offline
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'user1',
      'displayName': 'Usuario de Prueba 1',
      'email': 'usuario1@example.com',
      'photoURL': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 'user2',
      'displayName': 'Usuario de Prueba 2',
      'email': 'usuario2@example.com',
      'photoURL': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
  ];

  final List<Map<String, dynamic>> _mockCasos = [
    {
      'id': 'caso1',
      'nombre': 'Caso de prueba 1',
      'userId': 'user1',
      'estado': 'activo',
      'diseaseName': 'Enfermedad de prueba 1',
      'confidence': 85,
      'description': 'Descripción de prueba',
      'imageUrls': ['https://via.placeholder.com/150'],
      'logs': [
        {
          'id': '1',
          'contenido': 'Caso creado para pruebas',
          'fecha': DateTime.now().subtract(const Duration(days: 5)),
          'usuarioId': 'user1',
        }
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'caso2',
      'nombre': 'Caso de prueba 2',
      'userId': 'user2',
      'estado': 'cerrado',
      'diseaseName': 'Enfermedad de prueba 2',
      'confidence': 92,
      'description': 'Descripción de prueba 2',
      'imageUrls': ['https://via.placeholder.com/150'],
      'logs': [
        {
          'id': '1',
          'contenido': 'Caso creado para pruebas',
          'fecha': DateTime.now().subtract(const Duration(days: 10)),
          'usuarioId': 'user2',
        },
        {
          'id': '2',
          'contenido': 'Caso cerrado',
          'fecha': DateTime.now().subtract(const Duration(days: 3)),
          'usuarioId': 'user2',
        }
      ],
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
      'updatedAt': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  final List<Map<String, dynamic>> _mockDiagnosticos = [
    {
      'id': 'diag1',
      'userId': 'user1',
      'diseaseName': 'Enfermedad de prueba 1',
      'confidence': 75,
      'recommendations': ['Recomendación 1', 'Recomendación 2'],
      'details': 'Detalles de prueba',
      'description': 'Descripción de prueba',
      'imageUrl': 'https://via.placeholder.com/150',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'diag2',
      'userId': 'user2',
      'diseaseName': 'Enfermedad de prueba 2',
      'confidence': 88,
      'recommendations': ['Recomendación 1', 'Recomendación 2', 'Recomendación 3'],
      'details': 'Detalles de prueba 2',
      'description': 'Descripción de prueba 2',
      'imageUrl': 'https://via.placeholder.com/150',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

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
        title: const Text("Panel de Administración (Modo Offline)"),
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
            icon: const Icon(Icons.info_outline),
            tooltip: 'Estado de conexión',
            onPressed: () {
              _showConnectionStatusDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de modo offline
          Container(
            color: Colors.orange.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Modo offline: Usando datos de prueba',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Intentar conectar'),
                  onPressed: () {
                    _simulateConnectionAttempt();
                  },
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildCasesTab(),
                _buildDiagnosticosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulateConnectionAttempt() {
    setState(() {
      // Iniciar carga
    });

    // Simular intento de conexión
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Intentando conectar con Firebase...'),
          ],
        ),
      ),
    );

    // Simular demora y fallo
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Cerrar diálogo
      
      setState(() {
        _errorMessage = 'Error de conexión: No se pudo conectar con Firebase. Verifique su configuración y conexión a internet.';
      });

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  void _showConnectionStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de conexión'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow('Estado', _connectionStatus, Colors.orange),
              const SizedBox(height: 16),
              const Text('Información de depuración:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              const Text('Solución de problemas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('1. Verifique su conexión a internet'),
              const Text('2. Revise la configuración de Firebase en firebase_options.dart'),
              const Text('3. Asegúrese de que las reglas de seguridad de Firestore permitan el acceso'),
              const Text('4. Verifique que el proyecto de Firebase esté correctamente configurado'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateConnectionAttempt();
            },
            child: const Text('Reintentar conexión'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return _mockUsers.isEmpty
        ? const Center(
            child: Text('No hay usuarios registrados'),
          )
        : ListView.builder(
            itemCount: _mockUsers.length,
            itemBuilder: (context, index) {
              final userData = _mockUsers[index];
              final userId = userData['id'] as String;
              final email = userData['email'] as String;
              final displayName = userData['displayName'] as String;
              final photoUrl = userData['photoURL'] as String?;
              
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
  }

  Widget _buildCasesTab() {
    return _mockCasos.isEmpty
        ? const Center(
            child: Text('No hay casos registrados'),
          )
        : ListView.builder(
            itemCount: _mockCasos.length,
            itemBuilder: (context, index) {
              final casoData = _mockCasos[index];
              final casoId = casoData['id'] as String;
              final nombre = casoData['nombre'] as String;
              final userId = casoData['userId'] as String;
              final estado = casoData['estado'] as String;
              final DateTime createdAt = casoData['createdAt'] as DateTime;
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
  }

  Widget _buildDiagnosticosTab() {
    return _mockDiagnosticos.isEmpty
        ? const Center(
            child: Text('No hay diagnósticos registrados'),
          )
        : ListView.builder(
            itemCount: _mockDiagnosticos.length,
            itemBuilder: (context, index) {
              final diagnosticoData = _mockDiagnosticos[index];
              final diagnosticoId = diagnosticoData['id'] as String;
              final diseaseName = diagnosticoData['diseaseName'] as String;
              final userId = diagnosticoData['userId'] as String;
              final confidence = diagnosticoData['confidence']?.toString() ?? 'N/A';
              final DateTime createdAt = diagnosticoData['createdAt'] as DateTime;
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
                ? (userData['createdAt'] as DateTime).toString() 
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
                ? (casoData['createdAt'] as DateTime).toString() 
                : 'Desconocida'),
              _buildDetailRow('Última Actualización', casoData['updatedAt'] != null 
                ? (casoData['updatedAt'] as DateTime).toString() 
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
                      ? (log['fecha'] as DateTime).toString() 
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
                ? (diagnosticoData['createdAt'] as DateTime).toString() 
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
