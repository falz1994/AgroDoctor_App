import 'package:flutter/material.dart';
import '../screens/landing_page.dart';
import '../screens/register_page.dart';
import '../screens/diagnostico_wizard.dart';

class AppRoutes {
  static const String home = '/';
  static const String register = '/register';
  static const String diagnostico = '/diagnostico';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const LandingPage(),
    register: (context) => const RegisterPage(),
    diagnostico: (context) => const DiagnosticoWizard(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case diagnostico:
        return MaterialPageRoute(builder: (_) => const DiagnosticoWizard());
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
