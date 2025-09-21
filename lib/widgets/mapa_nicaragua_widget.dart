import 'package:flutter/material.dart';
import '../models/reporte_model.dart';

class MapaNicaraguaWidget extends StatefulWidget {
  final TipoReporte tipoReporte;
  final List<DepartamentoData> departamentos;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final Function(String)? onDepartamentoTap;

  const MapaNicaraguaWidget({
    super.key,
    required this.tipoReporte,
    required this.departamentos,
    this.datosProduccion,
    this.datosPrecios,
    this.onDepartamentoTap,
  });

  @override
  State<MapaNicaraguaWidget> createState() => _MapaNicaraguaWidgetState();
}

class _MapaNicaraguaWidgetState extends State<MapaNicaraguaWidget> {
  String? departamentoSeleccionado;
  
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
          child: Container(
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
              child: CustomPaint(
                painter: MapaPainter(
                  departamentos: widget.departamentos,
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
        ),
        
        // Información del departamento seleccionado
        if (departamentoSeleccionado != null)
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
    for (var departamento in widget.departamentos) {
      if (_puntoEnPoligono(relativePosition, departamento.poligono)) {
        setState(() {
          departamentoSeleccionado = departamento.id;
        });
        
        // Llamar al callback si existe
        widget.onDepartamentoTap?.call(departamento.id);
        return;
      }
    }
  }

  // Verifica si un punto está dentro de un polígono
  bool _puntoEnPoligono(Offset punto, List<Offset> poligono) {
    // Implementación simple del algoritmo de punto en polígono
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
    final departamento = widget.departamentos.firstWhere(
      (d) => d.id == departamentoSeleccionado,
      orElse: () => widget.departamentos.first,
    );
    
    if (widget.tipoReporte == TipoReporte.produccion && widget.datosProduccion != null) {
      final produccion = widget.datosProduccion!.firstWhere(
        (p) => p.departamentoId == departamentoSeleccionado,
        orElse: () => ProduccionData(
          departamentoId: departamentoSeleccionado!,
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
            ],
          ),
        ),
      );
    } else if (widget.tipoReporte == TipoReporte.precios && widget.datosPrecios != null) {
      final precio = widget.datosPrecios!.firstWhere(
        (p) => p.departamentoId == departamentoSeleccionado,
        orElse: () => PrecioData(
          departamentoId: departamentoSeleccionado!,
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
}

// Pintor personalizado para el mapa
class MapaPainter extends CustomPainter {
  final List<DepartamentoData> departamentos;
  final TipoReporte tipoReporte;
  final List<ProduccionData>? datosProduccion;
  final List<PrecioData>? datosPrecios;
  final String? departamentoSeleccionado;

  MapaPainter({
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
      final puntos = departamento.poligono.map((p) => 
        Offset(p.dx * size.width, p.dy * size.height)
      ).toList();
      
      final path = Path()..addPolygon(puntos, true);
      
      // Color según el tipo de reporte y datos
      final colorRelleno = _getColorDepartamento(departamento.id);
      
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
      
      // Dibujar nombre del departamento
      final textPainter = TextPainter(
        text: TextSpan(
          text: departamento.nombre,
          style: TextStyle(
            color: _getTextColor(colorRelleno),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final textPosition = Offset(
        departamento.centro.dx * size.width - textPainter.width / 2,
        departamento.centro.dy * size.height - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textPosition);
    }
  }

  // Determina el color de un departamento según los datos
  Color _getColorDepartamento(String departamentoId) {
    if (tipoReporte == TipoReporte.produccion && datosProduccion != null) {
      final produccion = datosProduccion!.firstWhere(
        (p) => p.departamentoId == departamentoId,
        orElse: () => ProduccionData(
          departamentoId: departamentoId,
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
        (p) => p.departamentoId == departamentoId,
        orElse: () => PrecioData(
          departamentoId: departamentoId,
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
    
    return Colors.grey[300]!;
  }

  // Determina el color del texto según el color de fondo
  Color _getTextColor(Color backgroundColor) {
    // Calcular la luminosidad del color de fondo
    final luminosidad = (0.299 * backgroundColor.red + 
                         0.587 * backgroundColor.green + 
                         0.114 * backgroundColor.blue) / 255;
    
    // Si es oscuro, usar texto blanco; si es claro, usar texto negro
    return luminosidad > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
