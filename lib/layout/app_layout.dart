import 'package:bulk_finder/components/background/bg_pattern.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  const AppLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BackgroundWidget(
          child: child,
        ),
      ),
    );
  }
}
