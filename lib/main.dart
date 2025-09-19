import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const AgroDoctorApp());
}

class AgroDoctorApp extends StatelessWidget {
  const AgroDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroDoctor',
      theme: AppTheme.theme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}