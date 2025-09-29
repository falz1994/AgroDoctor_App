import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/shared_models.dart';
import '../services/caso_diagnostico_service.dart';
import '../constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CasosList extends StatefulWidget {
  const CasosList({super.key});
  
  @override
  State<CasosList> createState() => _CasosListState();
}

class _CasosListState extends State<CasosList> {
  // Agregar un listener para cambios en la autenticación
  StreamSubscription<User?>? _authSubscription;
  
  @override
  void initState() {
    super.initState();
    // Escuchar cambios en la autenticación
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          // Forzar reconstrucción cuando cambia el estado de autenticación
          print('CasosList: Estado de autenticación cambiado: ${user != null ? 'Autenticado' : 'No autenticado'}');
        });
      }
    });
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario está autenticado
    final currentUser = CasoDiagnosticoService.currentUser;
    print('CasosList build: Usuario autenticado: ${currentUser != null}');
    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Inicia sesión para ver tus casos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes navegar a la pantalla de login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Necesitas iniciar sesión para ver tus casos'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<CasoDiagnosticoModel>>(
      stream: CasoDiagnosticoService.getUserCasos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar casos: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Forzar reconstrucción del widget para reintentar
                    setState(() {});
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final casos = snapshot.data ?? [];
        print('CasosList: Se encontraron ${casos.length} casos');
        
        // Mostrar información sobre los estados de los casos
        if (casos.isNotEmpty) {
          final activos = casos.where((caso) => caso.estado == EstadoCaso.activo).length;
          final resueltos = casos.where((caso) => caso.estado == EstadoCaso.cerrado).length;
          print('CasosList: Casos activos: $activos, Casos resueltos: $resueltos');
        }

        if (casos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No tienes casos guardados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cada vez que realices un diagnóstico se creará un caso para seguimiento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dirígete a la sección de Diagnóstico para crear tu primer caso',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud),
                  label: const Text('Probar conexión con Firebase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    // Mostrar indicador de carga
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    try {
                      // Probar la conexión
                      final result = await CasoDiagnosticoService.testFirebaseConnection();
                      
                      // Cerrar el indicador de carga
                      Navigator.pop(context);
                      
                      // Mostrar resultado
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result 
                              ? 'Conexión con Firebase exitosa' 
                              : 'Error de conexión con Firebase'),
                            backgroundColor: result ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      // Cerrar el indicador de carga
                      Navigator.pop(context);
                      
                      // Mostrar error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: casos.length,
          itemBuilder: (context, index) {
            final caso = casos[index];
            return _buildCasoCard(context, caso);
          },
        );
      },
    );
  }

  Widget _buildCasoCard(BuildContext context, CasoDiagnosticoModel caso) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final bool isActive = caso.estado == EstadoCaso.activo;
    final Color estadoColor = isActive ? Colors.green : Colors.grey;
    final String estadoText = isActive ? 'ACTIVO' : 'RESUELTO';
    
    // Borde de color según el estado
    final borderColor = isActive ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.3);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _showCasoDetails(context, caso),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de estado en la parte superior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: estadoColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? Icons.pending_actions : Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CASO $estadoText',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Imagen principal
            Stack(
              children: [
                // Imagen
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: caso.imageUrls.isNotEmpty
                      ? Image.network(
                          caso.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.folder,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                
                // Fecha
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    color: Colors.black.withOpacity(0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Creado: ${dateFormat.format(caso.createdAt)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        if (caso.updatedAt != caso.createdAt)
                          Text(
                            'Act: ${dateFormat.format(caso.updatedAt)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del caso
                  Text(
                    caso.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Enfermedad
                  if (caso.diseaseName != null)
                    Row(
                      children: [
                        const Icon(Icons.medical_services, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            caso.diseaseName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Confianza
                  if (caso.confidence != null)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Confianza: ${caso.confidence}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  
                  // Última actualización
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.update, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Última actualización: ${dateFormat.format(caso.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  // Número de logs
                  Row(
                    children: [
                      const Icon(Icons.history, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${caso.logs.length} ${caso.logs.length == 1 ? 'entrada' : 'entradas'} en el registro',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showCasoDetails(context, caso),
                    child: const Text('Ver detalles'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCasoDetails(BuildContext context, CasoDiagnosticoModel caso) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con nombre y estado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caso.nombre,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (caso.diseaseName != null)
                                Text(
                                  caso.diseaseName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: caso.estado == EstadoCaso.activo 
                                ? Colors.green 
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            caso.estado == EstadoCaso.activo 
                                ? 'Activo' 
                                : 'Cerrado',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imágenes
                        if (caso.imageUrls.isNotEmpty) ...[
                          const Text(
                            'Imágenes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: caso.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      caso.imageUrls[index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Detalles
                        if (caso.details != null && caso.details!.isNotEmpty) ...[
                          const Text(
                            'Detalles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              caso.details!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Recomendaciones
                        if (caso.recommendations != null && caso.recommendations!.isNotEmpty) ...[
                          const Text(
                            'Recomendaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: caso.recommendations!.map((recommendation) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Text(
                                          recommendation,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Registro de actividad (logs)
                        const Text(
                          'Registro de Actividad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Timeline de logs
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: caso.logs.length,
                          itemBuilder: (context, index) {
                            final log = caso.logs[index];
                            final bool isFirst = index == 0;
                            final bool isLast = index == caso.logs.length - 1;
                            
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Línea de tiempo
                                SizedBox(
                                  width: 20,
                                  child: Column(
                                    children: [
                                      // Línea superior (no mostrar para el primer elemento)
                                      if (!isFirst)
                                        Container(
                                          width: 2,
                                          height: 20,
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                        ),
                                      
                                      // Punto
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: isFirst ? AppColors.primaryColor : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      
                                      // Línea inferior (no mostrar para el último elemento)
                                      if (!isLast)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            width: 2,
                                            height: 60,
                                            color: AppColors.primaryColor.withOpacity(0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Contenido del log
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Fecha
                                        Text(
                                          dateFormat.format(log.fecha),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        
                                        // Contenido
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isFirst 
                                                ? AppColors.primaryColor.withOpacity(0.1) 
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isFirst 
                                                  ? AppColors.primaryColor.withOpacity(0.3) 
                                                  : Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            log.contenido,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        
                                        // Imagen del log (si existe)
                                        if (log.imagenUrl != null) ...[
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              log.imagenUrl!,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 100,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botones de acción
                        Row(
                          children: [
                            // Botón para añadir actualización
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showAddLogDialog(context, caso);
                                },
                                icon: const Icon(Icons.add_comment),
                                label: const Text('Añadir actualización'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Botón para cambiar estado
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showChangeStatusDialog(context, caso);
                              },
                              icon: Icon(
                                caso.estado == EstadoCaso.activo 
                                    ? Icons.check_circle 
                                    : Icons.refresh,
                              ),
                              label: Text(
                                caso.estado == EstadoCaso.activo 
                                    ? 'Resolver Caso' 
                                    : 'Reabrir Caso',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: caso.estado == EstadoCaso.activo 
                                    ? Colors.green 
                                    : Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddLogDialog(BuildContext context, CasoDiagnosticoModel caso) {
    final TextEditingController contenidoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Actualización'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: contenidoController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  hintText: 'Escriba la actualización del caso',
                ),
                maxLines: 5,
              ),
              // Nota: Aquí se podría añadir la funcionalidad para adjuntar imágenes
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contenidoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, ingrese contenido para la actualización')),
                );
                return;
              }

              try {
                Navigator.pop(context);
                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                
                // Añadir log al caso
                await CasoDiagnosticoService.addLogToCaso(
                  casoId: caso.id,
                  contenido: contenidoController.text.trim(),
                );
                
                // Cerrar indicador de carga
                if (context.mounted) Navigator.pop(context);
                
                // Mostrar mensaje de éxito
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Actualización añadida exitosamente')),
                  );
                  // Mostrar detalles del caso actualizado
                  _showCasoDetails(context, caso);
                }
              } catch (e) {
                // Cerrar indicador de carga
                if (context.mounted) Navigator.pop(context);
                
                // Mostrar mensaje de error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al añadir actualización: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context, CasoDiagnosticoModel caso) {
    final TextEditingController comentarioController = TextEditingController();
    final bool isActive = caso.estado == EstadoCaso.activo;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'Resolver Caso' : 'Reabrir Caso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isActive 
                    ? '¿Está seguro que desea resolver este caso? Esto marcará el caso como completado.' 
                    : '¿Está seguro que desea reabrir este caso? Esto marcará el caso como activo nuevamente.',
              ),
              const SizedBox(height: 16),
              // Estado actual
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle : Icons.check_circle_outline,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estado actual: ${isActive ? "ACTIVO" : "RESUELTO"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: comentarioController,
                decoration: InputDecoration(
                  labelText: 'Comentario (opcional)',
                  hintText: isActive 
                      ? 'Añada un comentario sobre la resolución del caso' 
                      : 'Añada un comentario sobre la reapertura del caso',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                
                // Cambiar estado del caso
                final nuevoEstado = isActive ? EstadoCaso.cerrado : EstadoCaso.activo;
                await CasoDiagnosticoService.cambiarEstadoCaso(
                  casoId: caso.id,
                  nuevoEstado: nuevoEstado,
                  comentario: comentarioController.text.trim().isNotEmpty 
                      ? comentarioController.text.trim() 
                      : null,
                );
                
                // Cerrar indicador de carga
                if (context.mounted) Navigator.pop(context);
                
                // Mostrar mensaje de éxito
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isActive 
                            ? 'Caso resuelto exitosamente' 
                            : 'Caso reabierto exitosamente'
                      ),
                    ),
                  );
                }
              } catch (e) {
                // Cerrar indicador de carga
                if (context.mounted) Navigator.pop(context);
                
                // Mostrar mensaje de error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cambiar estado: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.green : Colors.blue,
            ),
            child: Text(isActive ? 'Resolver Caso' : 'Reabrir Caso'),
          ),
        ],
      ),
    );
  }
}
