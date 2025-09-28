import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Nombre de usuario
                  Text(
                    user?.displayName ?? "Usuario",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Email
                  Text(
                    user?.email ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Información de la cuenta
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text("Información personal"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Historial de diagnósticos"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Configuración"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text("Ayuda y soporte"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Cerrar Sesión",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Mostrar indicador de carga
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        
                        // Cerrar sesión
                        await authProvider.signOut();
                        
                        if (context.mounted) {
                          // Cerrar diálogo de carga
                          Navigator.pop(context);
                          
                          // Forzar reconstrucción completa de la app
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                          
                          // Mostrar mensaje de confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Has cerrado sesión exitosamente'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          
                          // Forzar actualización del estado
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              // Recargar la página
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

