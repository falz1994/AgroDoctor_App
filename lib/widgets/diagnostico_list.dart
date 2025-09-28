import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diagnostico_model.dart';
import '../services/diagnostico_service.dart';
import '../constants/app_colors.dart';

class DiagnosticoList extends StatelessWidget {
  const DiagnosticoList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiagnosticoModel>>(
      stream: DiagnosticoService.getUserDiagnostics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar diagnósticos: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final diagnosticos = snapshot.data ?? [];

        if (diagnosticos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 20),
                Text(
                  'No tienes diagnósticos guardados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Realiza tu primer diagnóstico para comenzar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: diagnosticos.length,
          itemBuilder: (context, index) {
            final diagnostico = diagnosticos[index];
            return _buildDiagnosticoCard(context, diagnostico);
          },
        );
      },
    );
  }

  Widget _buildDiagnosticoCard(BuildContext context, DiagnosticoModel diagnostico) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDiagnosticoDetails(context, diagnostico),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y fecha
            Stack(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: diagnostico.imageUrl != null
                      ? Image.network(
                          diagnostico.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
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
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
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
                    child: Text(
                      dateFormat.format(diagnostico.createdAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
                  // Enfermedad
                  Text(
                    diagnostico.diseaseName ?? 'Diagnóstico',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Confianza
                  if (diagnostico.confidence != null)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Confianza: ${diagnostico.confidence}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  
                  // Ubicación
                  if (diagnostico.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            diagnostico.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  
                  // Etapa del cultivo
                  if (diagnostico.cropStage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            diagnostico.cropStage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
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
                    onPressed: () => _showDiagnosticoDetails(context, diagnostico),
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

  void _showDiagnosticoDetails(BuildContext context, DiagnosticoModel diagnostico) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y fecha
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            diagnostico.diseaseName ?? 'Diagnóstico',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(diagnostico.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Imagen
                    if (diagnostico.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          diagnostico.imageUrl!,
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
                    const SizedBox(height: 20),
                    
                    // Confianza
                    if (diagnostico.confidence != null)
                      _buildDetailItem(
                        'Nivel de confianza',
                        '${diagnostico.confidence}%',
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                      ),
                    
                    // Ubicación
                    if (diagnostico.location != null)
                      _buildDetailItem(
                        'Ubicación',
                        diagnostico.location!,
                        icon: Icons.location_on,
                      ),
                    
                    // Etapa del cultivo
                    if (diagnostico.cropStage != null)
                      _buildDetailItem(
                        'Etapa del cultivo',
                        diagnostico.cropStage!,
                        icon: Icons.eco,
                      ),
                    
                    // Descripción
                    if (diagnostico.description != null && diagnostico.description!.isNotEmpty)
                      _buildDetailItem(
                        'Descripción',
                        diagnostico.description!,
                        icon: Icons.description,
                      ),
                    
                    // Detalles
                    if (diagnostico.details != null && diagnostico.details!.isNotEmpty)
                      _buildDetailItem(
                        'Detalles',
                        diagnostico.details!,
                        icon: Icons.info,
                      ),
                    
                    // Recomendaciones
                    if (diagnostico.recommendations != null && diagnostico.recommendations!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Recomendaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...diagnostico.recommendations!.map((recommendation) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 32, bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16)),
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
                    ],
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String content, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 18, color: iconColor ?? AppColors.primaryColor),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
