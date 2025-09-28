import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/reporte_model.dart';
import '../widgets/mapa_nicaragua_geojson_widget.dart';

class MapaDetalladoPage extends StatefulWidget {
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;

  const MapaDetalladoPage({
    super.key,
    required this.tipoReporte,
    this.datosProduccion,
    this.datosPrecios,
  });

  @override
  State<MapaDetalladoPage> createState() => _MapaDetalladoPageState();
}

class _MapaDetalladoPageState extends State<MapaDetalladoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitulo()),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            Text(
              _getDescripcion(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            
            // Mapa GeoJSON detallado
            MapaNicaraguaGeoJsonWidget(
              tipoReporte: widget.tipoReporte,
              datosProduccion: widget.datosProduccion,
              datosPrecios: widget.datosPrecios,
              onMunicipioTap: (municipioId) {
                debugPrint('Municipio seleccionado: $municipioId');
              },
            ),
            
            const SizedBox(height: 30),
            
            // Instrucciones
            const Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instrucciones",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Toca un municipio para ver su información",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "• Los colores agrupan municipios por departamento",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "• El mapa muestra los 153 municipios de Nicaragua",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitulo() {
    switch (widget.tipoReporte) {
      case TipoReporte.produccion:
        return 'Mapa Detallado de Producción';
      case TipoReporte.precios:
        return 'Mapa Detallado de Precios';
      case TipoReporte.rendimiento:
        return 'Mapa Detallado de Rendimiento';
      case TipoReporte.exportacion:
        return 'Mapa Detallado de Exportaciones';
    }
  }

  String _getDescripcion() {
    switch (widget.tipoReporte) {
      case TipoReporte.produccion:
        return 'Visualización de datos de producción de frijol por municipio en Nicaragua';
      case TipoReporte.precios:
        return 'Visualización de precios del frijol por municipio en Nicaragua';
      case TipoReporte.rendimiento:
        return 'Visualización de rendimiento de cultivos por municipio en Nicaragua';
      case TipoReporte.exportacion:
        return 'Visualización de exportaciones por municipio en Nicaragua';
    }
  }
}
