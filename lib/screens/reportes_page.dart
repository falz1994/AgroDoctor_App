import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/reporte_model.dart';
import '../widgets/mapa_nicaragua_widget.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          // Actualizar la UI cuando cambia la pestaña
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes Agrícolas"),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.agriculture),
              text: "Producción",
            ),
            Tab(
              icon: Icon(Icons.attach_money),
              text: "Precios",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de producción
          _buildReporteProduccion(),
          
          // Pestaña de precios
          _buildReportePrecios(),
        ],
      ),
    );
  }

  Widget _buildReporteProduccion() {
    final departamentos = ReportesData.getDepartamentos();
    final datosProduccion = ReportesData.getProduccionFrijol();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          const Text(
            "Producción de Frijol en Nicaragua",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Datos de producción por departamento para el año 2024",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          
          // Mapa interactivo
          MapaNicaraguaWidget(
            tipoReporte: TipoReporte.produccion,
            departamentos: departamentos,
            datosProduccion: datosProduccion,
          ),
          
          const SizedBox(height: 30),
          
          // Estadísticas generales
          _buildEstadisticasProduccion(datosProduccion),
          
          const SizedBox(height: 30),
          
          // Tabla de datos
          _buildTablaProduccion(departamentos, datosProduccion),
        ],
      ),
    );
  }

  Widget _buildReportePrecios() {
    final departamentos = ReportesData.getDepartamentos();
    final datosPrecios = ReportesData.getPreciosFrijol();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          const Text(
            "Precios del Frijol en Nicaragua",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Precios actualizados al ${_formatFecha(DateTime.now())}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          
          // Mapa interactivo
          MapaNicaraguaWidget(
            tipoReporte: TipoReporte.precios,
            departamentos: departamentos,
            datosPrecios: datosPrecios,
          ),
          
          const SizedBox(height: 30),
          
          // Estadísticas generales
          _buildEstadisticasPrecios(datosPrecios),
          
          const SizedBox(height: 30),
          
          // Tabla de datos
          _buildTablaPrecios(departamentos, datosPrecios),
        ],
      ),
    );
  }

  Widget _buildEstadisticasProduccion(List<ProduccionData> datos) {
    // Calcular estadísticas
    final totalProduccion = datos.fold<double>(0, (sum, item) => sum + item.cantidadToneladas);
    final maxProduccion = datos.reduce((a, b) => a.cantidadToneladas > b.cantidadToneladas ? a : b);
    
    // Encontrar el departamento con mayor producción
    final departamentos = ReportesData.getDepartamentos();
    final departamentoMax = departamentos.firstWhere(
      (d) => d.id == maxProduccion.departamentoId,
      orElse: () => departamentos.first,
    );
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estadísticas Generales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildEstadisticaItem(
              "Producción total nacional",
              "${totalProduccion.toStringAsFixed(1)} toneladas",
              Icons.agriculture,
            ),
            _buildEstadisticaItem(
              "Mayor productor",
              "${departamentoMax.nombre} (${maxProduccion.cantidadToneladas.toStringAsFixed(1)} ton)",
              Icons.emoji_events,
            ),
            _buildEstadisticaItem(
              "Porcentaje del mayor productor",
              "${maxProduccion.porcentajeNacional.toStringAsFixed(1)}% del total nacional",
              Icons.percent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasPrecios(List<PrecioData> datos) {
    // Calcular estadísticas
    final precioPromedio = datos.fold<double>(0, (sum, item) => sum + item.precioQuintal) / datos.length;
    final precioMax = datos.reduce((a, b) => a.precioQuintal > b.precioQuintal ? a : b);
    final precioMin = datos.reduce((a, b) => a.precioQuintal < b.precioQuintal ? a : b);
    
    // Encontrar los departamentos con precios máximos y mínimos
    final departamentos = ReportesData.getDepartamentos();
    final departamentoMax = departamentos.firstWhere(
      (d) => d.id == precioMax.departamentoId,
      orElse: () => departamentos.first,
    );
    final departamentoMin = departamentos.firstWhere(
      (d) => d.id == precioMin.departamentoId,
      orElse: () => departamentos.first,
    );
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estadísticas de Precios",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildEstadisticaItem(
              "Precio promedio nacional",
              "C\$ ${precioPromedio.toStringAsFixed(2)} por quintal",
              Icons.attach_money,
            ),
            _buildEstadisticaItem(
              "Precio más alto",
              "${departamentoMax.nombre}: C\$ ${precioMax.precioQuintal.toStringAsFixed(2)}",
              Icons.arrow_upward,
            ),
            _buildEstadisticaItem(
              "Precio más bajo",
              "${departamentoMin.nombre}: C\$ ${precioMin.precioQuintal.toStringAsFixed(2)}",
              Icons.arrow_downward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTablaProduccion(List<DepartamentoData> departamentos, List<ProduccionData> datos) {
    // Ordenar datos por producción (de mayor a menor)
    final datosOrdenados = List<ProduccionData>.from(datos)
      ..sort((a, b) => b.cantidadToneladas.compareTo(a.cantidadToneladas));
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tabla de Producción por Departamento",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Departamento')),
                  DataColumn(label: Text('Producción (ton)')),
                  DataColumn(label: Text('% Nacional')),
                ],
                rows: datosOrdenados.map((dato) {
                  final departamento = departamentos.firstWhere(
                    (d) => d.id == dato.departamentoId,
                    orElse: () => departamentos.first,
                  );
                  
                  return DataRow(cells: [
                    DataCell(Text(departamento.nombre)),
                    DataCell(Text(dato.cantidadToneladas.toStringAsFixed(1))),
                    DataCell(Text('${dato.porcentajeNacional.toStringAsFixed(1)}%')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaPrecios(List<DepartamentoData> departamentos, List<PrecioData> datos) {
    // Ordenar datos por precio (de menor a mayor)
    final datosOrdenados = List<PrecioData>.from(datos)
      ..sort((a, b) => a.precioQuintal.compareTo(b.precioQuintal));
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tabla de Precios por Departamento",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Departamento')),
                    DataColumn(label: Text('Precio Quintal (C\$)')),
                  DataColumn(label: Text('Precio Libra (C\$)')),
                ],
                rows: datosOrdenados.map((dato) {
                  final departamento = departamentos.firstWhere(
                    (d) => d.id == dato.departamentoId,
                    orElse: () => departamentos.first,
                  );
                  
                  return DataRow(cells: [
                    DataCell(Text(departamento.nombre)),
                    DataCell(Text(dato.precioQuintal.toStringAsFixed(2))),
                    DataCell(Text(dato.precioLibra.toStringAsFixed(2))),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
