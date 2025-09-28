import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/login_modal.dart';
import '../widgets/diagnostico_list.dart';
import '../widgets/noticias_page_view.dart';
import '../widgets/clima_widget.dart';
import '../models/noticia_model.dart';
import '../providers/auth_provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.user;
    
    // Use MediaQuery to determine screen size
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      drawer: isSmallScreen ? _buildDrawer(context, isLoggedIn, user) : null,
      appBar: AppBar(
        title: const Text("AgroDoctor"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          // En pantallas grandes, mostrar menú horizontal
          if (!isSmallScreen) ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text("Inicio", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reportes');
              },
              child: const Text("Reportes", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/diagnostico-results');
              },
              child: const Text("Mis Diagnósticos", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/productos');
              },
              child: const Text("Productos", style: TextStyle(color: Colors.white)),
            ),
          ],
          
          // Botón de inicio de sesión o perfil
          isLoggedIn
              ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.pushNamed(context, '/profile');
                    } else if (value == 'logout') {
                      // Cerrar sesión de forma síncrona para evitar problemas
                      _handleLogout(context, authProvider);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 18),
                          const SizedBox(width: 8),
                          const Text('Mi Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          backgroundColor: Colors.white,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, size: 16, color: AppColors.primaryColor)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        if (user?.displayName != null)
                          Text(
                            user!.displayName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    _showLoginModal(context);
                  },
                  child: const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner principal
            LayoutBuilder(
              builder: (context, constraints) {
                // Imprimir el ancho disponible en consola
                debugPrint('ANCHO DEL BANNER: [32m${constraints.maxWidth}[0m');
                return Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - kToolbarHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Image.asset(
                              "assets/logo.png",
                              height: 90,
                            ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/diagnostico');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Realizar Diagnóstico Ahora",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Sección de noticias del IPSA
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Últimas Noticias del IPSA",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Navegar a una página con todas las noticias
                        },
                        icon: const Icon(Icons.newspaper),
                        label: const Text("Ver más"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NoticiasPageView(noticias: NoticiasData.getNoticias()),
                ],
              ),
            ),
            
            // Sección de pronóstico del clima
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pronóstico del Clima - Managua",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClimaWidget(pronostico: PronosticoClima.getPronosticoManagua()),
                ],
              ),
            ),
            
            // Sección de reportes agrícolas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reportes Agrícolas",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reportes');
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text("Ver todos"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Tarjetas de reportes
                  Row(
                    children: [
                      Expanded(
                        child: _buildReporteCard(
                          "Producción de Frijol",
                          "Ver datos de producción por departamento",
                          Icons.agriculture,
                          () {
                            Navigator.pushNamed(context, '/reportes');
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildReporteCard(
                          "Precios del Mercado",
                          "Consultar precios actualizados del frijol",
                          Icons.attach_money,
                          () {
                            Navigator.pushNamed(context, '/reportes');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección de productos destacados
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Productos Destacados",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/productos');
                        },
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text("Ver todos"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Lista horizontal de productos
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildProductoCard(
                          "Insecticida Orgánico",
                          "350.00",
                          "Protección natural para cultivos de frijol",
                          Icons.pest_control,
                          15,
                          () {
                            Navigator.pushNamed(context, '/productos');
                          },
                        ),
                        const SizedBox(width: 15),
                        _buildProductoCard(
                          "Fertilizante Premium",
                          "480.00",
                          "Especial para leguminosas",
                          Icons.eco,
                          10,
                          () {
                            Navigator.pushNamed(context, '/productos');
                          },
                        ),
                        const SizedBox(width: 15),
                        _buildProductoCard(
                          "Semillas Certificadas",
                          "220.00",
                          "Frijol INTA Rojo de alta calidad",
                          Icons.grass,
                          0,
                          () {
                            Navigator.pushNamed(context, '/productos');
                          },
                        ),
                        const SizedBox(width: 15),
                        _buildProductoCard(
                          "Kit de Herramientas",
                          "850.00",
                          "Todo lo necesario para la cosecha",
                          Icons.handyman,
                          5,
                          () {
                            Navigator.pushNamed(context, '/productos');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Sección de diagnósticos recientes (solo para usuarios autenticados)
            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mis Diagnósticos",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/diagnostico-results');
                          },
                          icon: const Icon(Icons.history),
                          label: const Text("Ver todos"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 400, // Altura fija para el listado
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Importamos el widget de listado de diagnósticos
                                DiagnosticoList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.primaryColor,
              child: const Column(
                children: [
                  Text(
                    "AgroDoctor © 2025",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Contacto: info@agrodoctor.com",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el modal de login
  void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const LoginModal(),
        );
      },
    );
  }
  
  // Construir tarjeta de producto
  Widget _buildProductoCard(String nombre, String precio, String descripcion, IconData icono, int descuento, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y badge de descuento
              Stack(
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icono,
                      size: 40,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (descuento > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '-$descuento%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nombre del producto
              Text(
                nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Precio
              Text(
                'C\$ $precio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: descuento > 0 ? Colors.red : AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              
              // Descripción
              Text(
                descripcion,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir tarjeta de reporte
  Widget _buildReporteCard(String titulo, String descripcion, IconData icono, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                size: 40,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Ver detalles",
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.secondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función para manejar el cierre de sesión
  Future<void> _handleLogout(BuildContext context, dynamic authProvider) async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Esperar a que se cierre la sesión
      await authProvider.signOut();

      if (context.mounted) {
        // Cerrar el diálogo de carga
        Navigator.pop(context);

        // Mostrar mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Has cerrado sesión'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );

        // Forzar reconstrucción completa de la app
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false
        );

        // Recargar después de un breve retraso para asegurar que todo se actualice
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      }
    } catch (e) {
      // En caso de error, cerrar el diálogo y mostrar mensaje
      if (context.mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Construir el drawer para pantallas pequeñas
  Widget _buildDrawer(BuildContext context, bool isLoggedIn, dynamic user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    height: 36,
                  ),
                  const SizedBox(height: 8),
                  if (isLoggedIn && user != null) ...[
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL)
                          : null,
                      backgroundColor: Colors.white,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 22, color: AppColors.primaryColor)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.displayName ?? "Usuario",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar drawer
                        _showLoginModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                      ),
                      child: const Text("Iniciar Sesión"),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamed(context, '/');
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamed(context, '/reportes');
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            leading: const Icon(Icons.history),
            title: const Text('Mis Diagnósticos'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamed(context, '/diagnostico-results');
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Productos'),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.pushNamed(context, '/productos');
            },
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 2),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context); // Cerrar drawer
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const SizedBox(height: 2),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context); // Cerrar drawer
                _handleLogout(context, Provider.of<AuthProvider>(context, listen: false));
              },
            ),
          ],
        ],
      ),
    );
  }
}

