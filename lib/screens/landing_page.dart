import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/login_modal.dart';
import '../widgets/noticias_page_view.dart';
import '../widgets/clima_widget.dart';
import '../models/noticia_model.dart';
import '../models/shared_models.dart';
import '../services/caso_diagnostico_service.dart';
import '../providers/auth_provider.dart';
import '../utils/admin_utils.dart';
import 'caso_detail_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.user;

    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      // Material landing: AppBar con fondo blanco y sombra ligera
      backgroundColor: isSmallScreen ? null : Colors.grey[100],
      drawer: isSmallScreen ? _buildDrawer(context, isLoggedIn, user) : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: AppColors.primaryColor,
        title: Text("AgroDoctor", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700)),
        actions: [
          if (!isSmallScreen) ...[
            TextButton(onPressed: () => Navigator.pushNamed(context, '/'), child: Text("Inicio", style: TextStyle(color: AppColors.primaryColor))),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/reportes'), child: Text("Reportes", style: TextStyle(color: AppColors.primaryColor))),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/casos'), child: Text("Mis Casos", style: TextStyle(color: AppColors.primaryColor))),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/productos'), child: Text("Productos", style: TextStyle(color: AppColors.primaryColor))),
          ],
          isLoggedIn
              ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') Navigator.pushNamed(context, '/profile');
                    if (value == 'admin') Navigator.pushNamed(context, '/admin');
                    if (value == 'logout') _handleLogout(context, authProvider);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(children: const [Icon(Icons.person, size: 18), SizedBox(width: 8), Text('Mi Perfil')]),
                    ),
                    if (AdminUtils.isAdmin(authProvider.user))
                      PopupMenuItem<String>(value: 'admin', child: Row(children: const [Icon(Icons.admin_panel_settings, size: 18), SizedBox(width: 8), Text('Panel de Administración')])),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Cerrar Sesión')])),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          backgroundColor: user?.photoURL == null ? AppColors.primaryColor : null,
                          child: user?.photoURL == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 8),
                        if (user?.displayName != null) Text(user!.displayName!, style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                )
              : TextButton(onPressed: () => _showLoginModal(context), child: Text("Iniciar Sesión", style: TextStyle(color: AppColors.primaryColor))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner full-bleed
            LayoutBuilder(builder: (context, constraints) {
              debugPrint('ANCHO DEL BANNER: ${constraints.maxWidth}');
              return Container(
                height: 350,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryColor, AppColors.secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset("assets/logo.png", height: 76),
                      const SizedBox(height: 18),
                      Text(
                        'Diagnóstico Agrícola Inteligente',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Identifica plagas y enfermedades desde una foto — rápido y sencillo',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/diagnostico'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 4),
                        child: const Text("Realizar Diagnóstico", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ),
              );
            }),

            // Contenido centrado (reformateado para evitar problemas de parsing)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Transform.translate(
                  offset: isSmallScreen ? Offset.zero : const Offset(0, -28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSmallScreen ? Colors.transparent : Colors.white,
                      borderRadius: isSmallScreen ? null : BorderRadius.circular(12),
                      boxShadow: isSmallScreen
                          ? null
                          : [
                              BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (isLoggedIn)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, "Mis Casos Activos", icon: Icons.folder, actionLabel: "Ver todos", onAction: () => Navigator.pushNamed(context, '/casos')),
                                const SizedBox(height: 10),
                                SizedBox(height: 200, child: _buildCasosActivosCarousel(context)),
                              ],
                            ),
                          ),

                        // Noticias
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildSectionHeader(context, "Últimas Noticias del IPSA", icon: Icons.newspaper, actionLabel: "Ver más", onAction: () {}),
                            const SizedBox(height: 20),
                            // Noticias estilizadas dentro de una Card para look más pulido
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: NoticiasPageView(noticias: NoticiasData.getNoticias()),
                              ),
                            ),
                          ]),
                        ),

                        // Clima
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildSectionHeader(context, "Pronóstico del Clima - Managua", icon: Icons.wb_sunny),
                            const SizedBox(height: 20),
                            // Clima dentro de una tarjeta ligera
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(padding: const EdgeInsets.all(12), child: ClimaWidget(pronostico: PronosticoClima.getPronosticoManagua())),
                            ),
                          ]),
                        ),

                        // Reportes
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildSectionHeader(context, "Reportes Agrícolas", icon: Icons.bar_chart, actionLabel: "Ver todos", onAction: () => Navigator.pushNamed(context, '/reportes')),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(child: _buildReporteCard("Producción de Frijol", "Ver datos de producción por departamento", Icons.agriculture, () => Navigator.pushNamed(context, '/reportes'))),
                              const SizedBox(width: 15),
                              Expanded(child: _buildReporteCard("Precios del Mercado", "Consultar precios actualizados del frijol", Icons.attach_money, () => Navigator.pushNamed(context, '/reportes'))),
                            ]),
                          ]),
                        ),

                        // Productos
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildSectionHeader(context, "Productos Destacados", icon: Icons.shopping_bag, actionLabel: "Ver todos", onAction: () => Navigator.pushNamed(context, '/productos')),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 260,
                              child: ListView(scrollDirection: Axis.horizontal, children: [
                                _buildProductoCard("Insecticida Orgánico", "350.00", "Protección natural para cultivos de frijol", Icons.pest_control, 15, () => Navigator.pushNamed(context, '/productos')),
                                const SizedBox(width: 15),
                                _buildProductoCard("Fertilizante Premium", "480.00", "Especial para leguminosas", Icons.eco, 10, () => Navigator.pushNamed(context, '/productos')),
                                const SizedBox(width: 15),
                                _buildProductoCard("Semillas Certificadas", "220.00", "Frijol INTA Rojo de alta calidad", Icons.grass, 0, () => Navigator.pushNamed(context, '/productos')),
                                const SizedBox(width: 15),
                                _buildProductoCard("Kit de Herramientas", "850.00", "Todo lo necesario para la cosecha", Icons.handyman, 5, () => Navigator.pushNamed(context, '/productos')),
                              ]),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer full-bleed, con contenido centrado y alineado al mismo ancho
            Container(
              color: AppColors.primaryColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("AgroDoctor © 2025", style: TextStyle(color: Colors.white)),
                        Text("Contacto: info@agrodoctor.com", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (BuildContext context) {
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: const LoginModal());
      },
    );
  }

  Widget _buildProductoCard(String nombre, String precio, String descripcion, IconData icono, int descuento, VoidCallback onTap) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Icon / imagen circular con fondo degradado
              Container(
                height: 92,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[50]),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [AppColors.primaryColor.withOpacity(0.15), AppColors.secondaryColor.withOpacity(0.1)]),
                    ),
                    child: Icon(icono, size: 36, color: AppColors.primaryColor),
                  ),
                  const Spacer(),
                  if (descuento > 0)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: Text('-$descuento%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ),
              const SizedBox(height: 10),
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(descripcion, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [
                Text('C\$ $precio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                const Spacer(),
                ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Comprar', style: TextStyle(fontSize: 13))),
              ])
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildReporteCard(String titulo, String descripcion, IconData icono, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(height: 44, width: 44, decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: AppColors.primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 12),
            // titulo se mueve arriba para un header compacto
            const SizedBox(height: 8),
            Text(descripcion, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Ver detalles', style: TextStyle(color: AppColors.secondaryColor, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.secondaryColor),
            ])
          ]),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, dynamic authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Cerrar sesión'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Has cerrado sesión'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        Future.delayed(const Duration(milliseconds: 300), () { if (context.mounted) Navigator.pushReplacementNamed(context, '/'); });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildDrawer(BuildContext context, bool isLoggedIn, dynamic user) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primaryColor),
          child: Container(
            height: 120,
            alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image.asset("assets/logo.png", height: 36),
              const SizedBox(height: 8),
              if (isLoggedIn && user != null) ...[
                CircleAvatar(radius: 18, backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL) : null, backgroundColor: Colors.white, child: user.photoURL == null ? const Icon(Icons.person, size: 22, color: AppColors.primaryColor) : null),
                const SizedBox(height: 6),
                Text(user.displayName ?? "Usuario", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ] else ...[
                ElevatedButton(onPressed: () { Navigator.pop(context); _showLoginModal(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryColor), child: const Text("Iniciar Sesión")),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.home), title: const Text('Inicio'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/'); }),
        const SizedBox(height: 4),
        ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.bar_chart), title: const Text('Reportes'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/reportes'); }),
        const SizedBox(height: 4),
        ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.folder), title: const Text('Mis Casos'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/casos'); }),
        const SizedBox(height: 4),
        ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.shopping_bag), title: const Text('Productos'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/productos'); }),
        if (isLoggedIn) ...[
          const SizedBox(height: 2),
          ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.person), title: const Text('Mi Perfil'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/profile'); }),
          const SizedBox(height: 2),
          ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 6), leading: const Icon(Icons.logout), title: const Text('Cerrar Sesión'), onTap: () { Navigator.pop(context); _handleLogout(context, Provider.of<AuthProvider>(context, listen: false)); }),
        ],
      ]),
    );
  }

  Widget _buildCasosActivosCarousel(BuildContext context) {
    return StreamBuilder<List<CasoDiagnosticoModel>>(
      stream: CasoDiagnosticoService.getUserCasos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, color: Colors.red, size: 40), const SizedBox(height: 8), Text('Error al cargar casos', style: TextStyle(fontSize: 14, color: Colors.grey[600]))]));

        final casos = snapshot.data ?? [];
        final casosActivos = casos.where((caso) => caso.estado == EstadoCaso.activo).toList();
        if (casosActivos.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_off, size: 50, color: Colors.grey), SizedBox(height: 8), Text('No tienes casos activos', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)), SizedBox(height: 4), Text('Realiza un diagnóstico para crear tu primer caso', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center)]));

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), itemCount: casosActivos.length, itemBuilder: (context, index) => _buildCasoCard(context, casosActivos[index])),
        );
      },
    );
  }

  Widget _buildCasoCard(BuildContext context, CasoDiagnosticoModel caso) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CasoDetailPage(caso: caso))),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
              border: Border.all(color: AppColors.primaryColor, width: 2),
            ),
          child: Row(children: [
            // accent stripe
            Container(width: 8, height: 160, decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text(caso.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Text('Activo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.medical_services, size: 14, color: Colors.grey[600]), const SizedBox(width: 6), Expanded(child: Text(caso.diseaseName ?? 'Sin diagnóstico', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)), if (caso.confidence != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: caso.confidence! > 70 ? Colors.red.shade100 : Colors.amber.shade100, borderRadius: BorderRadius.circular(6)), child: Text('${caso.confidence}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: caso.confidence! > 70 ? Colors.red.shade700 : Colors.amber.shade700)))]),
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]), const SizedBox(width: 4), Text('Creado: ${_formatDate(caso.createdAt)}', style: TextStyle(fontSize: 10, color: Colors.grey[600]))]),
                  const Spacer(),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CasoDetailPage(caso: caso))), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('Ver Detalles', style: TextStyle(fontSize: 12)))]),
                ]),
              ),
            )
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildSectionHeader(BuildContext context, String title, {IconData? icon, String? actionLabel, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          if (icon != null) ...[
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
          ),
          if (actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(actionLabel, style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
            ),
        ],
      ),
    );
  }
}

