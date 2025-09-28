import 'package:flutter/material.dart';
import '../models/reporte_model.dart';
import '../services/geojson_service.dart';

class MapaNicaraguaGeoJsonWidget extends StatefulWidget {
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final Function(String)? onMunicipioTap;

  const MapaNicaraguaGeoJsonWidget({
    super.key,
    required this.tipoReporte,
    this.datosProduccion,
    this.datosPrecios,
    this.onMunicipioTap,
  });

  @override
  State<MapaNicaraguaGeoJsonWidget> createState() => _MapaNicaraguaGeoJsonWidgetState();
}

class _MapaNicaraguaGeoJsonWidgetState extends State<MapaNicaraguaGeoJsonWidget> {
  String? municipioSeleccionado;
  bool _isLoading = true;
  List<MunicipioData> _municipios = [];
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }
  
  Future<void> _cargarDatos() async {
    try {
      final municipios = await GeoJsonService.cargarMunicipiosNicaragua();
      setState(() {
        _municipios = municipios;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar municipios: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del mapa según el tipo de reporte
        Text(
          _getTitulo(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        
        // Leyenda del mapa
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLeyenda(),
          ],
        ),
        const SizedBox(height: 20),
        
        // Mapa interactivo
        AspectRatio(
          aspectRatio: 1.0, // Mapa cuadrado
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomPaint(
                        painter: MapaGeoJsonPainter(
                          municipios: _municipios,
                          tipoReporte: widget.tipoReporte,
                          datosProduccion: widget.datosProduccion,
                          datosPrecios: widget.datosPrecios,
                          municipioSeleccionado: municipioSeleccionado,
                        ),
                        child: GestureDetector(
                          onTapUp: (details) {
                            _handleTap(details.localPosition);
                          },
                        ),
                      ),
                ),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        
        // Información del municipio seleccionado
        if (municipioSeleccionado != null && !_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _buildInfoMunicipio(),
          ),
      ],
    );
  }

  // Título del mapa según el tipo de reporte
  String _getTitulo() {
    switch (widget.tipoReporte) {
      case TipoReporte.produccion:
        return 'Producción de Frijol por Municipio';
      case TipoReporte.precios:
        return 'Precios del Frijol por Municipio';
      case TipoReporte.rendimiento:
        return 'Rendimiento de Cultivos por Municipio';
      case TipoReporte.exportacion:
        return 'Exportaciones por Municipio';
    }
  }

  // Leyenda del mapa según el tipo de reporte
  Widget _buildLeyenda() {
    if (widget.tipoReporte == TipoReporte.produccion) {
      return Row(
        children: [
          _buildLeyendaItem(Colors.green[100]!, 'Baja'),
          _buildLeyendaItem(Colors.green[300]!, 'Media'),
          _buildLeyendaItem(Colors.green[500]!, 'Alta'),
          _buildLeyendaItem(Colors.green[800]!, 'Muy alta'),
        ],
      );
    } else if (widget.tipoReporte == TipoReporte.precios) {
      return Row(
        children: [
          _buildLeyendaItem(Colors.blue[100]!, 'Bajo'),
          _buildLeyendaItem(Colors.blue[300]!, 'Medio'),
          _buildLeyendaItem(Colors.blue[500]!, 'Alto'),
          _buildLeyendaItem(Colors.blue[800]!, 'Muy alto'),
        ],
      );
    }
    
    return const SizedBox();
  }

  // Elemento de la leyenda
  Widget _buildLeyendaItem(Color color, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(texto),
        ],
      ),
    );
  }

  // Maneja el tap en el mapa
  void _handleTap(Offset localPosition) {
    final size = context.size;
    if (size == null) return;
    
    // Convertir la posición local a coordenadas relativas
    final relativePosition = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );
    
    // Buscar el municipio que contiene el punto
    for (var municipio in _municipios) {
      for (var poligono in municipio.poligonos) {
        if (_puntoEnPoligono(relativePosition, poligono)) {
          setState(() {
            municipioSeleccionado = municipio.id;
          });
          
          // Llamar al callback si existe
          widget.onMunicipioTap?.call(municipio.id);
          return;
        }
      }
    }
  }

  // Verifica si un punto está dentro de un polígono
  bool _puntoEnPoligono(Offset punto, List<Offset> poligono) {
    // Implementación del algoritmo de punto en polígono
    bool dentro = false;
    for (int i = 0, j = poligono.length - 1; i < poligono.length; j = i++) {
      if ((poligono[i].dy > punto.dy) != (poligono[j].dy > punto.dy) &&
          punto.dx < (poligono[j].dx - poligono[i].dx) * (punto.dy - poligono[i].dy) /
                  (poligono[j].dy - poligono[i].dy) +
              poligono[i].dx) {
        dentro = !dentro;
      }
    }
    return dentro;
  }

  // Construye la información del municipio seleccionado
  Widget _buildInfoMunicipio() {
    final municipio = _municipios.firstWhere(
      (m) => m.id == municipioSeleccionado,
      orElse: () => _municipios.first,
    );
    
    // Buscar datos de producción o precios para este municipio
    // Nota: Actualmente los datos están por departamento, no por municipio
    // Se podría mejorar para tener datos específicos por municipio
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              municipio.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Departamento: ${municipio.departamento}'),
            const SizedBox(height: 10),
            
            // Mostrar datos según el tipo de reporte
            if (widget.tipoReporte == TipoReporte.produccion)
              const Text('Datos de producción no disponibles a nivel municipal'),
            if (widget.tipoReporte == TipoReporte.precios)
              const Text('Datos de precios no disponibles a nivel municipal'),
          ],
        ),
      ),
    );
  }
}

// Pintor personalizado para el mapa GeoJSON
class MapaGeoJsonPainter extends CustomPainter {
  final List<MunicipioData> municipios;
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final String? municipioSeleccionado;

  MapaGeoJsonPainter({
    required this.municipios,
    required this.tipoReporte,
    this.datosProduccion,
    this.datosPrecios,
    this.municipioSeleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar fondo del mapa
    final fondoPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, fondoPaint);
    
    // Agrupar municipios por departamento para asignar colores similares
    final Map<String, List<MunicipioData>> municipiosPorDepartamento = {};
    for (var municipio in municipios) {
      if (!municipiosPorDepartamento.containsKey(municipio.departamento)) {
        municipiosPorDepartamento[municipio.departamento] = [];
      }
      municipiosPorDepartamento[municipio.departamento]!.add(municipio);
    }
    
    // Dibujar municipios agrupados por departamento
    int departamentoIndex = 0;
    municipiosPorDepartamento.forEach((departamento, municipiosDelDepartamento) {
      // Color base para el departamento
      final Color colorBase = _getColorBaseDepartamento(departamentoIndex);
      departamentoIndex++;
      
      // Dibujar cada municipio del departamento
      for (var municipio in municipiosDelDepartamento) {
        // Dibujar cada polígono del municipio
        for (var poligono in municipio.poligonos) {
          final puntos = poligono.map((p) => 
            Offset(p.dx * size.width, p.dy * size.height)
          ).toList();
          
          if (puntos.length < 3) continue; // Necesitamos al menos 3 puntos para un polígono
          
          final path = Path()..addPolygon(puntos, true);
          
          // Color del municipio (variación del color del departamento)
          final index = municipiosDelDepartamento.indexOf(municipio);
          final colorRelleno = _getColorMunicipio(colorBase, index, municipiosDelDepartamento.length);
          
          final fillPaint = Paint()
            ..color = colorRelleno
            ..style = PaintingStyle.fill;
          
          // Dibujar relleno
          canvas.drawPath(path, fillPaint);
          
          // Dibujar contorno
          final strokePaint = Paint()
            ..color = municipio.id == municipioSeleccionado 
                ? Colors.red 
                : Colors.grey[600]!
            ..style = PaintingStyle.stroke
            ..strokeWidth = municipio.id == municipioSeleccionado ? 3.0 : 0.5;
          
          canvas.drawPath(path, strokePaint);
        }
        
        // Dibujar nombre del municipio si es lo suficientemente grande
        if (municipio.id == municipioSeleccionado || municipiosDelDepartamento.length < 10) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: municipio.nombre,
              style: TextStyle(
                color: Colors.black,
                fontSize: 8,
                fontWeight: municipio.id == municipioSeleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          
          textPainter.layout(maxWidth: size.width * 0.1);
          
          final textPosition = Offset(
            municipio.centro.dx * size.width - textPainter.width / 2,
            municipio.centro.dy * size.height - textPainter.height / 2,
          );
          
          textPainter.paint(canvas, textPosition);
        }
      }
    });
  }

  // Obtiene un color base para el departamento según su índice
  Color _getColorBaseDepartamento(int index) {
    final colores = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.teal[300]!,
      Colors.amber[300]!,
      Colors.cyan[300]!,
      Colors.pink[300]!,
      Colors.indigo[300]!,
      Colors.lime[300]!,
      Colors.brown[300]!,
      Colors.deepOrange[300]!,
      Colors.lightBlue[300]!,
      Colors.lightGreen[300]!,
      Colors.deepPurple[300]!,
      Colors.red[300]!,
      Colors.yellow[300]!,
    ];
    
    return colores[index % colores.length];
  }

  // Obtiene una variación del color base para el municipio
  Color _getColorMunicipio(Color colorBase, int index, int total) {
    // Variar ligeramente el color base para diferenciar municipios del mismo departamento
    final double factor = 0.8 + (index / total) * 0.4; // Factor entre 0.8 y 1.2
    
    return Color.fromARGB(
      colorBase.alpha,
      (colorBase.red * factor).clamp(0, 255).toInt(),
      (colorBase.green * factor).clamp(0, 255).toInt(),
      (colorBase.blue * factor).clamp(0, 255).toInt(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

