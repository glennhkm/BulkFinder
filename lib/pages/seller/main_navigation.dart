import 'package:flutter/material.dart';
import 'package:bulk_finder/components/navbar/navbar_seller.dart';
import 'package:bulk_finder/pages/seller/home.dart';
import 'package:bulk_finder/pages/seller/shop.dart';
import 'package:bulk_finder/pages/seller/comunity.dart';
import 'package:bulk_finder/pages/seller/profile.dart';

class MainNavigationSeller extends StatefulWidget {
  const MainNavigationSeller({super.key});

  @override
  State<MainNavigationSeller> createState() => _MainNavigationSellerState();
}

class _MainNavigationSellerState extends State<MainNavigationSeller> {
  int _selectedIndex = 0;

  // List of screens for each navigation item
  final List<Widget> _screens = [
    const SellerHomeScreen(),
    const ShopScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavbarSeller(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 