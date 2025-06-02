import 'dart:async';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  int countdown = 5;
  bool isStoreOwner = false; // Default value, will be updated after build

  @override
  void initState() {
    super.initState();
    // Schedule the redirect logic after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRedirect();
    });
  }

  void _handleRedirect() {
    // Safely access route arguments after the first frame
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() {
      isStoreOwner = args?['isStoreOwner'] ?? false;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            isStoreOwner ? '/home-seller' : '/home-customer',
          );
        }
      } else {
        setState(() => countdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Add this to handle overflow
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Optional: limit width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/success.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
                Text(
                  'Berhasil Mendaftar !',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brand_01,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Selamat bergabung dengan Bulk Finder',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}