import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/diagnostico_model.dart';
import '../widgets/diagnostico_list.dart';

class DiagnosticoResultsPage extends StatefulWidget {
  final DiagnosticoModel? diagnostico;
  final Map<String, dynamic>? resultados;

  const DiagnosticoResultsPage({
    super.key, 
    this.diagnostico,
    this.resultados,
  });

  @override
  State<DiagnosticoResultsPage> createState() => _DiagnosticoResultsPageState();
}

class _DiagnosticoResultsPageState extends State<DiagnosticoResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Si hay un diagnóstico específico, mostrar primero la pestaña de resultados
    if (widget.diagnostico != null || widget.resultados != null) {
      _tabController.index = 0;
      debugPrint('Mostrando pestaña de resultados con: ${widget.diagnostico != null ? 'diagnóstico guardado' : 'resultados sin guardar'}');
    } else {
      _tabController.index = 1; // Mostrar historial por defecto si no hay diagnóstico específico
      debugPrint('Mostrando pestaña de historial por defecto');
    }
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
        title: const Text("Diagnósticos"),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.medical_services),
              text: "Resultados",
            ),
            Tab(
              icon: Icon(Icons.history),
              text: "Historial",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de resultados del diagnóstico actual
          _buildResultsTab(),
          
          // Pestaña de historial de diagnósticos
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    // Si tenemos un diagnóstico específico, mostrar sus detalles
    if (widget.diagnostico != null) {
      return _buildDiagnosticoDetails(widget.diagnostico!);
    } 
    // Si tenemos resultados pero no un diagnóstico guardado
    else if (widget.resultados != null) {
      return _buildResultsDetails(widget.resultados!);
    } 
    // Si no hay diagnóstico específico ni resultados, mostrar mensaje
    else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'No hay resultados para mostrar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Realiza un diagnóstico para ver los resultados aquí',
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
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historial de Diagnósticos",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: DiagnosticoList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoDetails(DiagnosticoModel diagnostico) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y confianza
          Row(
            children: [
              Expanded(
                child: Text(
                  diagnostico.diseaseName ?? 'Diagnóstico',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              if (diagnostico.confidence != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${diagnostico.confidence}% confianza',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
          const SizedBox(height: 24),
          
          // Detalles
          _buildInfoSection(
            title: 'Detalles de la enfermedad',
            content: diagnostico.details ?? 'No hay detalles disponibles',
            icon: Icons.info_outline,
          ),
          
          // Recomendaciones
          if (diagnostico.recommendations != null && diagnostico.recommendations!.isNotEmpty)
            _buildRecommendationsSection(diagnostico.recommendations!),
          
          // Información adicional
          const SizedBox(height: 24),
          const Text(
            'Información adicional',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Ubicación
          if (diagnostico.location != null)
            _buildInfoItem(
              icon: Icons.location_on,
              title: 'Ubicación',
              content: diagnostico.location!,
            ),
          
          // Etapa del cultivo
          if (diagnostico.cropStage != null)
            _buildInfoItem(
              icon: Icons.eco,
              title: 'Etapa del cultivo',
              content: diagnostico.cropStage!,
            ),
          
          // Descripción
          if (diagnostico.description != null && diagnostico.description!.isNotEmpty)
            _buildInfoItem(
              icon: Icons.description,
              title: 'Descripción del problema',
              content: diagnostico.description!,
            ),
          
          // Fecha
          _buildInfoItem(
            icon: Icons.calendar_today,
            title: 'Fecha del diagnóstico',
            content: '${diagnostico.createdAt.day}/${diagnostico.createdAt.month}/${diagnostico.createdAt.year} ${diagnostico.createdAt.hour}:${diagnostico.createdAt.minute.toString().padLeft(2, '0')}',
          ),
          
          const SizedBox(height: 30),
          
          // Botón para nuevo diagnóstico
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/diagnostico');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nuevo diagnóstico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsDetails(Map<String, dynamic> results) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y confianza
          Row(
            children: [
              Expanded(
                child: Text(
                  results['disease'] ?? 'Diagnóstico',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              if (results['confidence'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${results['confidence']}% confianza',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Detalles
          _buildInfoSection(
            title: 'Detalles de la enfermedad',
            content: results['details'] ?? 'No hay detalles disponibles',
            icon: Icons.info_outline,
          ),
          
          // Recomendaciones
          if (results['recommendations'] != null && (results['recommendations'] as List).isNotEmpty)
            _buildRecommendationsSection(
              (results['recommendations'] as List).map((e) => e.toString()).toList()
            ),
          
          const SizedBox(height: 30),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/diagnostico');
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nuevo diagnóstico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Ver historial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecommendationsSection(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppColors.primaryColor),
            SizedBox(width: 8),
            Text(
              'Recomendaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendations.map((recommendation) {
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
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
