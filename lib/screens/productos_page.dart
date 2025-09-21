import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/producto_model.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  CategoriaProducto? _categoriaSeleccionada;
  String _busqueda = '';
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarDestacados = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener productos según los filtros
    List<ProductoModel> productos = _getProductosFiltrados();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace Agrícola"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _busqueda = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                });
              },
            ),
          ),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filtro de destacados
                FilterChip(
                  label: const Text('Destacados'),
                  selected: _mostrarDestacados,
                  onSelected: (selected) {
                    setState(() {
                      _mostrarDestacados = selected;
                      if (selected) {
                        _categoriaSeleccionada = null;
                      }
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppColors.secondaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.secondaryColor,
                ),
                const SizedBox(width: 8),
                
                // Filtros por categoría
                FilterChip(
                  label: const Text('Todos'),
                  selected: _categoriaSeleccionada == null && !_mostrarDestacados,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _categoriaSeleccionada = null;
                        _mostrarDestacados = false;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                
                ..._buildCategoriaChips(),
              ],
            ),
          ),

          const SizedBox(height: 8),
          
          // Resultados
          Expanded(
            child: productos.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron productos',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      return _buildProductoCard(productos[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Construir chips para cada categoría
  List<Widget> _buildCategoriaChips() {
    final categorias = [
      CategoriaProducto.insecticida,
      CategoriaProducto.fertilizante,
      CategoriaProducto.herramienta,
      CategoriaProducto.semilla,
      CategoriaProducto.maquinaria,
      CategoriaProducto.otro,
    ];

    return categorias.map((categoria) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(ProductoModel(
            id: '',
            nombre: '',
            descripcion: '',
            precio: 0,
            moneda: '',
            vendedor: '',
            vendedorId: '',
            categoria: categoria,
            disponible: true,
            stock: 0,
            fechaPublicacion: DateTime.now(),
          ).categoriaNombre),
          selected: _categoriaSeleccionada == categoria,
          onSelected: (selected) {
            setState(() {
              _categoriaSeleccionada = selected ? categoria : null;
              _mostrarDestacados = false;
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          checkmarkColor: AppColors.primaryColor,
        ),
      );
    }).toList();
  }

  // Obtener productos filtrados según los criterios seleccionados
  List<ProductoModel> _getProductosFiltrados() {
    List<ProductoModel> productos;

    if (_mostrarDestacados) {
      productos = ProductosData.getProductosDestacados();
    } else if (_categoriaSeleccionada != null) {
      productos = ProductosData.getProductosPorCategoria(_categoriaSeleccionada!);
    } else {
      productos = ProductosData.getProductos();
    }

    // Aplicar filtro de búsqueda si hay texto
    if (_busqueda.isNotEmpty) {
      productos = productos.where((producto) {
        return producto.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
               producto.descripcion.toLowerCase().contains(_busqueda.toLowerCase()) ||
               (producto.etiquetas?.any((tag) => tag.toLowerCase().contains(_busqueda.toLowerCase())) ?? false);
      }).toList();
    }

    return productos;
  }

  // Construir tarjeta de producto
  Widget _buildProductoCard(ProductoModel producto) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _mostrarDetallesProducto(producto);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y badge de descuento
            Stack(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: producto.imagenUrl != null
                        ? Image.network(
                            producto.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              _getCategoryIcon(producto.categoria),
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                
                // Badge de descuento
                if (producto.descuento != null && producto.descuento! > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${producto.descuento!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  
                // Badge de categoría
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      producto.categoriaNombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Información del producto
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Precio
                  Row(
                    children: [
                      if (producto.descuento != null && producto.descuento! > 0) ...[
                        Text(
                          '${producto.moneda} ${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${producto.moneda} ${producto.precioFinal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: producto.descuento != null && producto.descuento! > 0
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  
                  // Vendedor
                  Text(
                    producto.vendedor,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar detalles del producto
  void _mostrarDetallesProducto(ProductoModel producto) {
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
                  // Imagen del producto
                  Stack(
                    children: [
                      // Imagen
                      SizedBox(
                        width: double.infinity,
                        height: 250,
                        child: producto.imagenUrl != null
                            ? Image.network(
                                producto.imagenUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  _getCategoryIcon(producto.categoria),
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      
                      // Botón de cerrar
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      
                      // Badge de descuento
                      if (producto.descuento != null && producto.descuento! > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '-${producto.descuento!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Información del producto
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y categoría
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                producto.categoriaNombre,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Precio
                        Row(
                          children: [
                            if (producto.descuento != null && producto.descuento! > 0) ...[
                              Text(
                                '${producto.moneda} ${producto.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              '${producto.moneda} ${producto.precioFinal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: producto.descuento != null && producto.descuento! > 0
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Vendedor
                        Row(
                          children: [
                            const Icon(Icons.store, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Vendedor: ${producto.vendedor}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Stock
                        Row(
                          children: [
                            const Icon(Icons.inventory_2, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Stock disponible: ${producto.stock} unidades',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          producto.descripcion,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Etiquetas
                        if (producto.etiquetas != null && producto.etiquetas!.isNotEmpty) ...[
                          const Text(
                            'Etiquetas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: producto.etiquetas!.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey[200],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Botón de contactar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Aquí iría la lógica para contactar al vendedor
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contactando al vendedor...'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Contactar Vendedor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Botón de agregar al carrito
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Aquí iría la lógica para agregar al carrito
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto agregado al carrito'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              side: BorderSide(color: AppColors.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Agregar al Carrito',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  // Obtener ícono según la categoría
  IconData _getCategoryIcon(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.insecticida:
        return Icons.pest_control;
      case CategoriaProducto.fertilizante:
        return Icons.eco;
      case CategoriaProducto.herramienta:
        return Icons.handyman;
      case CategoriaProducto.semilla:
        return Icons.grass;
      case CategoriaProducto.maquinaria:
        return Icons.agriculture;
      case CategoriaProducto.otro:
        return Icons.category;
    }
  }
}
