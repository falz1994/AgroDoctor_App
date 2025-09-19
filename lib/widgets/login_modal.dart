import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/register_page.dart';

class LoginModal extends StatelessWidget {
  const LoginModal({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            "assets/logo.jpg",
            height: 100,
          ),
          const SizedBox(height: 10),

          // Email
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Correo",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 15),

          // Password
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Contraseña",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 20),

          // Botón de Login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Aquí va la lógica de login
              },
              child: const Text(
                "Iniciar Sesión",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Botón de registro
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el modal
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              "¿No tienes cuenta? Regístrate",
              style: TextStyle(color: AppColors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
