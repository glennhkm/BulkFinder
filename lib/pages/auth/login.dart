import 'package:bulk_finder/components/background/bg_pattern.dart';
import 'package:bulk_finder/components/buttons/button.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              Image.asset(
                'assets/images/auth.png',
                width: 400,
                height: 400,
              ),
              Text(
                "Masuk",
                style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brand_01),
              ),
              const SizedBox(height: 10),
              Text(
                "Masuk untuk mengakses semua fitur pada Bulk Finder",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              Container(
                  padding: const EdgeInsets.only(
                      left: 32, right: 32, top: 60, bottom: 32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.brand_01,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brand_01.withOpacity(0.8),
                        blurRadius: 16,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Masukkan email anda",
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.white38),
                          labelStyle: TextStyle(color: Colors.white54),
                          hintStyle: TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white24,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Masukkan password anda",
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white38),
                          labelStyle: TextStyle(color: Colors.white54),
                          hintStyle: TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white24,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: Text(
                              "Lupa Password?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Button(
                        text: "Masuk",
                        onPressed: () {},
                        backgroundColor: AppTheme.brand_02,
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Belum punya akun? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            children: [
                              TextSpan(
                                text: "Daftar",
                                style: TextStyle(
                                  color: AppTheme.brand_02,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
