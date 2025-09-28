import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'utils/app_routes.dart';
import 'services/firebase_options.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AgroDoctorApp());
}

class AgroDoctorApp extends StatelessWidget {
  const AgroDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgroDoctor',
        theme: AppTheme.theme,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}