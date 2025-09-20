import 'package:flutter/material.dart';
import '../screens/landing_page.dart';
import '../screens/register_page.dart';
import '../screens/diagnostico_wizard.dart';
import '../screens/profile_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String register = '/register';
  static const String diagnostico = '/diagnostico';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const LandingPage(),
    register: (context) => const RegisterPage(),
    diagnostico: (context) => const DiagnosticoWizard(),
    profile: (context) => const ProfilePage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case diagnostico:
        return MaterialPageRoute(builder: (_) => const DiagnosticoWizard());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no definida: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
