import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarSeller extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavbarSeller({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NavbarSeller> createState() => _NavbarSellerState();
}

class _NavbarSellerState extends State<NavbarSeller> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Toko',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Komunitas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: AppTheme.brand_01,
      unselectedItemColor: Colors.grey[600],
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10, // Efek shadow
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
    );
  }
}