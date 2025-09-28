import 'package:flutter/material.dart';
import '../screens/landing_page.dart';
import '../screens/register_page.dart';
import '../screens/diagnostico_wizard.dart';
import '../screens/profile_page.dart';
import '../screens/diagnostico_results_page.dart';
import '../screens/reportes_page.dart';
import '../screens/productos_page.dart';
import '../models/diagnostico_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String register = '/register';
  static const String diagnostico = '/diagnostico';
  static const String profile = '/profile';
  static const String diagnosticoResults = '/diagnostico-results';
  static const String reportes = '/reportes';
  static const String productos = '/productos';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const LandingPage(),
    register: (context) => const RegisterPage(),
    diagnostico: (context) => const DiagnosticoWizard(),
    profile: (context) => const ProfilePage(),
    diagnosticoResults: (context) => const DiagnosticoResultsPage(),
    reportes: (context) => const ReportesPage(),
    productos: (context) => const ProductosPage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extraer argumentos
    final args = settings.arguments;
    
    debugPrint('Navegando a: ${settings.name}, con argumentos: ${args != null ? 'sí' : 'no'}');
    
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case diagnostico:
        return MaterialPageRoute(builder: (_) => const DiagnosticoWizard());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case diagnosticoResults:
        // Si hay argumentos, pasarlos a la página de resultados
        if (args is Map<String, dynamic>) {
          final diagnostico = args['diagnostico'] as DiagnosticoModel?;
          final resultados = args['resultados'] as Map<String, dynamic>?;
          
          debugPrint('Navegando a resultados con: diagnostico=${diagnostico != null}, resultados=${resultados != null}');
          
          return MaterialPageRoute(
            builder: (_) => DiagnosticoResultsPage(
              diagnostico: diagnostico,
              resultados: resultados,
            ),
          );
        }
        debugPrint('Navegando a resultados sin argumentos');
        return MaterialPageRoute(builder: (_) => const DiagnosticoResultsPage());
        
      case reportes:
        return MaterialPageRoute(builder: (_) => const ReportesPage());
        
      case productos:
        return MaterialPageRoute(builder: (_) => const ProductosPage());
      default:
        debugPrint('Ruta no definida: ${settings.name}');
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
