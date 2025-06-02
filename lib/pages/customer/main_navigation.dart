import 'package:flutter/material.dart';
import 'package:bulk_finder/components/navbar/navbar_customer.dart';
import 'package:bulk_finder/pages/customer/home.dart';
import 'package:bulk_finder/pages/customer/review.dart';
import 'package:bulk_finder/pages/customer/comunity.dart';
import 'package:bulk_finder/pages/customer/profile.dart';

class MainNavigationCustomer extends StatefulWidget {
  const MainNavigationCustomer({super.key});

  @override
  State<MainNavigationCustomer> createState() => _MainNavigationCustomerState();
}

class _MainNavigationCustomerState extends State<MainNavigationCustomer> {
  int _selectedIndex = 0;

  // List of screens for each navigation item
  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const ReviewScreen(),
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
      bottomNavigationBar: NavbarCustomer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 