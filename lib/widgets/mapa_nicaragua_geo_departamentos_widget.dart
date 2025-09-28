import 'package:flutter/material.dart';
import '../models/reporte_model.dart';
import '../services/geojson_service.dart';

class MapaNicaraguaGeoDepartamentosWidget extends StatefulWidget {
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final Function(String)? onDepartamentoTap;

  const MapaNicaraguaGeoDepartamentosWidget({
    super.key,
    required this.tipoReporte,
    this.datosProduccion,
    this.datosPrecios,
    this.onDepartamentoTap,
  });

  @override
  State<MapaNicaraguaGeoDepartamentosWidget> createState() => _MapaNicaraguaGeoDepartamentosWidgetState();
}

class _MapaNicaraguaGeoDepartamentosWidgetState extends State<MapaNicaraguaGeoDepartamentosWidget> {
  String? departamentoSeleccionado;
  bool _isLoading = true;
  List<DepartamentoGeoData> _departamentos = [];
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }
  
  Future<void> _cargarDatos() async {
    try {
      final departamentos = await GeoJsonService.cargarDepartamentosNicaragua();
      setState(() {
        _departamentos = departamentos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar departamentos: $e');
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
        
        // Indicador de escala
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              "🔍 Toca un departamento para ver detalles",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // Mapa interactivo
        LayoutBuilder(
          builder: (context, constraints) {
            // Calcular el tamaño óptimo para el mapa
            final double mapWidth = constraints.maxWidth;
            final double mapHeight = constraints.maxWidth * 1.2; // Proporción más grande para Nicaragua
            
            return Container(
              width: mapWidth,
              height: mapHeight,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    width: mapWidth,
                    height: mapHeight,
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
                            painter: MapaGeoDepartamentosPainter(
                              departamentos: _departamentos,
                              tipoReporte: widget.tipoReporte,
                              datosProduccion: widget.datosProduccion,
                              datosPrecios: widget.datosPrecios,
                              departamentoSeleccionado: departamentoSeleccionado,
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
            );
          },
        ),
        
        // Información del departamento seleccionado
        if (departamentoSeleccionado != null && !_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _buildInfoDepartamento(),
          ),
      ],
    );
  }

  // Título del mapa según el tipo de reporte
  String _getTitulo() {
    switch (widget.tipoReporte) {
      case TipoReporte.produccion:
        return 'Producción de Frijol por Departamento';
      case TipoReporte.precios:
        return 'Precios del Frijol por Departamento';
      case TipoReporte.rendimiento:
        return 'Rendimiento de Cultivos por Departamento';
      case TipoReporte.exportacion:
        return 'Exportaciones por Departamento';
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
    
    // Buscar el departamento que contiene el punto
    for (var departamento in _departamentos) {
      for (var poligono in departamento.poligonos) {
        if (_puntoEnPoligono(relativePosition, poligono)) {
          setState(() {
            departamentoSeleccionado = departamento.id;
          });
          
          // Llamar al callback si existe
          widget.onDepartamentoTap?.call(departamento.id);
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

  // Construye la información del departamento seleccionado
  Widget _buildInfoDepartamento() {
    final departamento = _departamentos.firstWhere(
      (d) => d.id == departamentoSeleccionado,
      orElse: () => _departamentos.first,
    );
    
    if (widget.tipoReporte == TipoReporte.produccion && widget.datosProduccion != null) {
      final produccion = widget.datosProduccion!.firstWhere(
        (p) => p.departamentoId == _convertirIdDepartamento(departamento.id),
        orElse: () => ProduccionData(
          departamentoId: _convertirIdDepartamento(departamento.id),
          cantidadToneladas: 0,
          porcentajeNacional: 0,
          anio: DateTime.now().year,
        ),
      );
      
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                departamento.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Producción: ${produccion.cantidadToneladas.toStringAsFixed(1)} toneladas'),
              Text('Porcentaje nacional: ${produccion.porcentajeNacional.toStringAsFixed(1)}%'),
              Text('Año: ${produccion.anio}'),
              const SizedBox(height: 10),
              Text('Municipios: ${departamento.municipios.length}'),
            ],
          ),
        ),
      );
    } else if (widget.tipoReporte == TipoReporte.precios && widget.datosPrecios != null) {
      final precio = widget.datosPrecios!.firstWhere(
        (p) => p.departamentoId == _convertirIdDepartamento(departamento.id),
        orElse: () => PrecioData(
          departamentoId: _convertirIdDepartamento(departamento.id),
          precioQuintal: 0,
          precioLibra: 0,
          fechaActualizacion: DateTime.now(),
        ),
      );
      
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                departamento.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Precio por quintal: C\$ ${precio.precioQuintal.toStringAsFixed(2)}'),
              Text('Precio por libra: C\$ ${precio.precioLibra.toStringAsFixed(2)}'),
              Text('Actualizado: ${_formatFecha(precio.fechaActualizacion)}'),
              const SizedBox(height: 10),
              Text('Municipios: ${departamento.municipios.length}'),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox();
  }
  
  // Formatea una fecha
  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
  
  // Convierte el ID del GeoJSON al formato usado en los datos
  String _convertirIdDepartamento(String geoId) {
    // Mapeo de IDs de GeoJSON a IDs de datos
    final Map<String, String> mapeoIds = {
      'NIC.1_1': 'raan',
      'NIC.2_1': 'raas',
      'NIC.3_1': 'boaco',
      'NIC.4_1': 'carazo',
      'NIC.5_1': 'chinandega',
      'NIC.6_1': 'chontales',
      'NIC.7_1': 'esteli',
      'NIC.8_1': 'granada',
      'NIC.9_1': 'jinotega',
      'NIC.10_1': 'leon',
      'NIC.11_1': 'madriz',
      'NIC.12_1': 'managua',
      'NIC.13_1': 'masaya',
      'NIC.14_1': 'matagalpa',
      'NIC.15_1': 'nueva_segovia',
      'NIC.16_1': 'rio_san_juan',
      'NIC.17_1': 'rivas',
    };
    
    return mapeoIds[geoId] ?? geoId;
  }
}

// Pintor personalizado para el mapa de departamentos
class MapaGeoDepartamentosPainter extends CustomPainter {
  final List<DepartamentoGeoData> departamentos;
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final String? departamentoSeleccionado;

  MapaGeoDepartamentosPainter({
    required this.departamentos,
    required this.tipoReporte,
    this.datosProduccion,
    this.datosPrecios,
    this.departamentoSeleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar fondo del mapa
    final fondoPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, fondoPaint);
    
    // Dibujar departamentos
    for (var departamento in departamentos) {
      // Dibujar cada polígono del departamento
      for (var poligono in departamento.poligonos) {
        final puntos = poligono.map((p) => 
          Offset(p.dx * size.width, p.dy * size.height)
        ).toList();
        
        if (puntos.length < 3) continue; // Necesitamos al menos 3 puntos para un polígono
        
        final path = Path()..addPolygon(puntos, true);
        
        // Color según el tipo de reporte y datos
        final colorRelleno = _getColorDepartamento(departamento);
        
        final fillPaint = Paint()
          ..color = colorRelleno
          ..style = PaintingStyle.fill;
        
        // Dibujar relleno
        canvas.drawPath(path, fillPaint);
        
        // Dibujar contorno
        final strokePaint = Paint()
          ..color = departamento.id == departamentoSeleccionado 
              ? Colors.red 
              : Colors.grey[600]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = departamento.id == departamentoSeleccionado ? 3.0 : 1.0;
        
        canvas.drawPath(path, strokePaint);
      }
      
      // Dibujar nombre del departamento
      final textPainter = TextPainter(
        text: TextSpan(
          text: departamento.nombre,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: departamento.id == departamentoSeleccionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout(maxWidth: size.width * 0.2);
      
      final textPosition = Offset(
        departamento.centro.dx * size.width - textPainter.width / 2,
        departamento.centro.dy * size.height - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textPosition);
      
      // Si el departamento está seleccionado, mostrar valor
      if (departamento.id == departamentoSeleccionado) {
        String valor = '';
        
        if (tipoReporte == TipoReporte.produccion && datosProduccion != null) {
          final produccion = datosProduccion!.firstWhere(
            (p) => p.departamentoId == _convertirIdDepartamento(departamento.id),
            orElse: () => ProduccionData(
              departamentoId: _convertirIdDepartamento(departamento.id),
              cantidadToneladas: 0,
              porcentajeNacional: 0,
              anio: DateTime.now().year,
            ),
          );
          
          valor = '${produccion.cantidadToneladas.toStringAsFixed(1)} ton';
        } else if (tipoReporte == TipoReporte.precios && datosPrecios != null) {
          final precio = datosPrecios!.firstWhere(
            (p) => p.departamentoId == _convertirIdDepartamento(departamento.id),
            orElse: () => PrecioData(
              departamentoId: _convertirIdDepartamento(departamento.id),
              precioQuintal: 0,
              precioLibra: 0,
              fechaActualizacion: DateTime.now(),
            ),
          );
          
          valor = 'C\$ ${precio.precioQuintal.toStringAsFixed(0)}';
        }
        
        if (valor.isNotEmpty) {
          final valorTextPainter = TextPainter(
            text: TextSpan(
              text: valor,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                backgroundColor: Color.fromARGB(150, 255, 255, 255),
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          
          valorTextPainter.layout();
          
          final valorPosition = Offset(
            departamento.centro.dx * size.width - valorTextPainter.width / 2,
            departamento.centro.dy * size.height + textPainter.height / 2 + 5,
          );
          
          valorTextPainter.paint(canvas, valorPosition);
        }
      }
    }
  }

  // Determina el color de un departamento según los datos
  Color _getColorDepartamento(DepartamentoGeoData departamento) {
    // Si es un lago u otro elemento especial, pintarlo de azul
    if (departamento.esElementoEspecial) {
      return Colors.blue[200]!;
    }
    
    final String idConvertido = _convertirIdDepartamento(departamento.id);
    
    if (tipoReporte == TipoReporte.produccion && datosProduccion != null) {
      final produccion = datosProduccion!.firstWhere(
        (p) => p.departamentoId == idConvertido,
        orElse: () => ProduccionData(
          departamentoId: idConvertido,
          cantidadToneladas: 0,
          porcentajeNacional: 0,
          anio: DateTime.now().year,
        ),
      );
      
      // Color según el porcentaje de producción
      if (produccion.porcentajeNacional > 15) {
        return Colors.green[800]!;
      } else if (produccion.porcentajeNacional > 8) {
        return Colors.green[500]!;
      } else if (produccion.porcentajeNacional > 3) {
        return Colors.green[300]!;
      } else {
        return Colors.green[100]!;
      }
    } else if (tipoReporte == TipoReporte.precios && datosPrecios != null) {
      final precio = datosPrecios!.firstWhere(
        (p) => p.departamentoId == idConvertido,
        orElse: () => PrecioData(
          departamentoId: idConvertido,
          precioQuintal: 0,
          precioLibra: 0,
          fechaActualizacion: DateTime.now(),
        ),
      );
      
      // Color según el precio
      if (precio.precioQuintal > 2300) {
        return Colors.blue[800]!;
      } else if (precio.precioQuintal > 2100) {
        return Colors.blue[500]!;
      } else if (precio.precioQuintal > 2000) {
        return Colors.blue[300]!;
      } else {
        return Colors.blue[100]!;
      }
    }
    
    // Color por defecto
    return Colors.grey[300]!;
  }
  
  // Convierte el ID del GeoJSON al formato usado en los datos
  String _convertirIdDepartamento(String geoId) {
    // Mapeo de IDs de GeoJSON a IDs de datos
    final Map<String, String> mapeoIds = {
      'NIC.1_1': 'raan',
      'NIC.2_1': 'raas',
      'NIC.3_1': 'boaco',
      'NIC.4_1': 'carazo',
      'NIC.5_1': 'chinandega',
      'NIC.6_1': 'chontales',
      'NIC.7_1': 'esteli',
      'NIC.8_1': 'granada',
      'NIC.9_1': 'jinotega',
      'NIC.10_1': 'leon',
      'NIC.11_1': 'madriz',
      'NIC.12_1': 'managua',
      'NIC.13_1': 'masaya',
      'NIC.14_1': 'matagalpa',
      'NIC.15_1': 'nueva_segovia',
      'NIC.16_1': 'rio_san_juan',
      'NIC.17_1': 'rivas',
    };
    
    return mapeoIds[geoId] ?? geoId;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
