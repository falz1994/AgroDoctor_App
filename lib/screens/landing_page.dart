import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/feature_card.dart';
import '../widgets/login_modal.dart';
import 'diagnostico_wizard.dart';
import 'register_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroDoctor"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          // Menú en la barra de navegación
          TextButton(
            onPressed: () {},
            child: const Text("Inicio", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Servicios", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Contacto", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
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
            Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo.jpg",
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "AgroDoctor",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tu aliado en el diagnóstico y cuidado de cultivos",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar al wizard de diagnóstico
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
                        "Comenzar Ahora",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Sección de características
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nuestros Servicios",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FeatureCard(
                          title: "Diagnóstico de Cultivos",
                          description: "Identifica enfermedades y plagas en tus cultivos con inteligencia artificial",
                          icon: Icons.eco,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FeatureCard(
                          title: "Recomendaciones",
                          description: "Recibe recomendaciones personalizadas para el tratamiento de tus cultivos",
                          icon: Icons.lightbulb,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FeatureCard(
                          title: "Seguimiento",
                          description: "Realiza un seguimiento del progreso y salud de tus cultivos",
                          icon: Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección "Acerca de"
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Acerca de AgroDoctor",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "AgroDoctor es una aplicación diseñada para ayudar a agricultores y aficionados a la jardinería a diagnosticar y tratar problemas en sus cultivos. Utilizando tecnología de inteligencia artificial, podemos identificar enfermedades, plagas y deficiencias nutricionales para proporcionar soluciones efectivas y personalizadas.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
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
}
