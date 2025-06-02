import 'package:bulk_finder/components/buttons/button.dart';
import 'package:bulk_finder/components/svg/svg_icon.dart';
import 'package:bulk_finder/components/svg/svg_string.dart';
import 'package:bulk_finder/providers/auth_providers.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      if (currentUser != null) {
        // User is logged in, load user data and redirect
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadUser(currentUser.id);
        
        if (authProvider.user != null) {
          // Redirect based on user role
          if (authProvider.user!.role == 'customer') {
            Navigator.pushReplacementNamed(context, '/home-customer');
          } else if (authProvider.user!.role == 'seller') {
            Navigator.pushReplacementNamed(context, '/home-seller');
          }
          return;
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
    
    // No user logged in or error occurred, show login options
    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Selamat Datang di",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.brand_01,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              "Bawa Wadahmu, Temukan Tokonya",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brand_01),
            ),
            const SizedBox(height: 20),
            Text(
              "Memuat...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Column(
            children: [
              Text(
                "Selamat Datang di",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brand_01,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                "Bawa Wadahmu, Temukan Tokonya",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(), // Push the button to bottom
          Button(
            text: "Mulai Sekarang",
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            iconOnRight: true,
            icon: SvgIcon(width: 20, height: 20, svgString: arrowSvg),
          ),
          const SizedBox(height: 32), // Bottom spacing
        ],
      ),
    );
  }
}
