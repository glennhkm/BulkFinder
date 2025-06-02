import 'package:bulk_finder/layout/app_layout.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';

// Authentication and Registration Pages
import 'package:bulk_finder/pages/auth/login.dart';
import 'package:bulk_finder/pages/auth/forgot-password.dart';
import 'package:bulk_finder/pages/auth/register.dart';
import 'package:bulk_finder/pages/auth/splash_screen.dart';
import 'package:bulk_finder/pages/auth/registration_succes.dart';

// Customer Pages
import 'package:bulk_finder/pages/customer/main_navigation.dart';

// Seller Pages
import 'package:bulk_finder/pages/seller/main_navigation.dart';

// Notification Page
import 'package:bulk_finder/pages/notification.dart';

// Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bulk_finder/providers/auth_providers.dart';
import 'package:bulk_finder/providers/store_provider.dart';
import 'package:bulk_finder/providers/community_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: "assets/.env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    print('Using hardcoded Supabase configuration');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file');
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    print('Using fallback configuration or app will fail to authenticate.');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: 'Bulk Finder',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          // Authentication and Registration Routes
          '/': (context) => AppLayout(child: const SplashScreen()),
          '/login': (context) => AppLayout(child: const LoginScreen()),
          '/forgot-password': (context) => AppLayout(child: const ForgotPasswordScreen()), 
          '/register': (context) => AppLayout(child: const RegisterScreen()),
          '/registration_success': (context) => AppLayout(child: const RegistrationSuccessScreen()),

          // Customer Routes
          '/home-customer': (context) => AppLayout(child: const MainNavigationCustomer()),

          // Seller Routes
          '/home-seller': (context) => AppLayout(child: const MainNavigationSeller()),

          // Notification Route
          '/notifications': (context) => AppLayout(child: const NotificationScreen())
        },
      ),
    );
  }
}