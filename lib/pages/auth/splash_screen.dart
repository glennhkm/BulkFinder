import 'package:bulk_finder/components/background/bg_pattern.dart';
import 'package:bulk_finder/components/buttons/button.dart';
import 'package:bulk_finder/components/svg/svg_icon.dart';
import 'package:bulk_finder/components/svg/svg_string.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      "Selamat Datang di",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand_01,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Bawa Wadahmu, Temukan Tokonya",
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
          ),
        ),
      ),
    );
  }
}
