import 'package:bulk_finder/layout/app_layout.dart';
import 'package:bulk_finder/pages/auth/login.dart';
import 'package:bulk_finder/pages/auth/register.dart';
import 'package:bulk_finder/pages/auth/splash_screen.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => AppLayout(child: const SplashScreen()),
        '/login': (context) => AppLayout(child: const LoginScreen()),
        '/register': (context) => AppLayout(child: const RegisterScreen()),
      },
    );
  }
}
