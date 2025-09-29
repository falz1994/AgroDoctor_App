import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/shared_models.dart';

class CasoDetailPage extends StatelessWidget {
  final CasoDiagnosticoModel caso;

  const CasoDetailPage({
    super.key,
    required this.caso,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caso.nombre),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditCasoDialog(context);
            },
            tooltip: 'Editar caso',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general del caso
            _buildInfoCard(
              title: 'Información del Caso',
              children: [
                _buildInfoRow('Nombre', caso.nombre),
                _buildInfoRow('Estado', estadoCasoToString(caso.estado)),
                _buildInfoRow('Creado', _formatDate(caso.createdAt)),
                _buildInfoRow('Actualizado', _formatDate(caso.updatedAt)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información del diagnóstico
            _buildInfoCard(
              title: 'Diagnóstico',
              children: [
                _buildInfoRow('Enfermedad', caso.diseaseName ?? 'Sin diagnóstico'),
                if (caso.confidence != null)
                  _buildInfoRow('Confianza', '${caso.confidence}%'),
                if (caso.location != null)
                  _buildInfoRow('Ubicación', caso.location!),
                if (caso.cropStage != null)
                  _buildInfoRow('Etapa del cultivo', caso.cropStage!),
                if (caso.description != null)
                  _buildInfoRow('Descripción', caso.description!),
              ],
            ),
            
            if (caso.details != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Detalles de la Enfermedad',
                children: [
                  Text(
                    caso.details!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            
            if (caso.recommendations != null && 
                caso.recommendations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Recomendaciones',
                children: [
                  ...caso.recommendations!.map((rec) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (caso.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Imágenes del Diagnóstico',
                children: [
                  ...caso.imageUrls.map((imageUrl) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (caso.logs.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Registros del Caso',
                children: [
                  ...caso.logs.map((log) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.contenido,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(log.fecha),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditCasoDialog(BuildContext context) {
    final nombreController = TextEditingController(text: caso.nombre);
    final estadoController = TextEditingController(text: estadoCasoToString(caso.estado));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Caso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del caso',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: estadoCasoToString(caso.estado),
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'activo', child: Text('Activo')),
                DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
              ],
              onChanged: (value) {
                estadoController.text = value ?? estadoCasoToString(caso.estado);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí implementarías la lógica para actualizar el caso
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caso actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
