import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/caso_diagnostico_service.dart';
import '../models/shared_models.dart';
import 'caso_detail_page.dart';

class CasosPage extends StatefulWidget {
  const CasosPage({super.key});

  @override
  State<CasosPage> createState() => _CasosPageState();
}

class _CasosPageState extends State<CasosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Casos'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Forzar actualización de la lista
              setState(() {});
            },
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: StreamBuilder<List<CasoDiagnosticoModel>>(
        stream: CasoDiagnosticoService.getUserCasos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
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
                      // Forzar reconstrucción
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final casos = snapshot.data ?? [];
          
          if (casos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes casos registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Realiza un diagnóstico para crear tu primer caso',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: casos.length,
            itemBuilder: (context, index) {
              final caso = casos[index];
              return _buildCasoCard(context, caso);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/diagnostico');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Diagnóstico'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCasoCard(BuildContext context, CasoDiagnosticoModel caso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CasoDetailPage(caso: caso),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caso.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: caso.estado == EstadoCaso.activo ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estadoCasoToString(caso.estado),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información del diagnóstico
              Row(
                children: [
                  Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      caso.diseaseName ?? 'Sin diagnóstico',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (caso.confidence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: caso.confidence! > 70 
                            ? Colors.red.shade100 
                            : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${caso.confidence}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: caso.confidence! > 70 
                              ? Colors.red.shade700 
                              : Colors.amber.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fecha de creación
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Creado: ${_formatDate(caso.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.update, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Actualizado: ${_formatDate(caso.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Botón para ver detalles
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CasoDetailPage(caso: caso),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver Detalles'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
