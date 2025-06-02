import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bulk_finder/theme/theme.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Header dengan judul dan ikon notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'BulkFinder',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand_01,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications,
                        color: AppTheme.brand_01,
                        size: 28,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subjudul dan deskripsi
              Text(
                'Toko Kamu',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brand_01,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Beberapa informasi tentang toko kamu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Card Informasi Toko
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.brand_01, // Warna border sesuai tema
                    width: 2.0, // Ketebalan border 2
                  ),
                ),
                color: Colors.white, // Latar belakang putih
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildIndicator(
                        icon: Icons.receipt_long,
                        label: 'Jumlah Transaksi',
                        value: '32 Transaksi',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A6F47), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      _buildIndicator(
                        icon: Icons.recycling,
                        label: 'Plastik Diselamatkan',
                        value: '4.8 Kg',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A6F47), Color(0xFF8BC34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      _buildIndicator(
                        icon: Icons.inventory_2,
                        label: 'Stok Barang',
                        value: 'Banyak',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A6F47), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      _buildIndicator(
                        icon: Icons.star,
                        label: 'Rating Tokomu',
                        value: '4.7',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A6F47), Color(0xFFFFCA28)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      _buildIndicator(
                        icon: Icons.comment,
                        label: 'Jumlah Ulasan',
                        value: '57 Ulasan',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A6F47), Color(0xFF8BC34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Berita Terkini
              Text(
                'Berita Terkini',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brand_01,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildNewsItem(
                      imagePath: 'assets/images/beras.png',
                      title: 'Waspada beras palsu',
                      subtitle: 'Selengkapnya >',
                    ),
                    const Divider(color: Colors.grey, thickness: 1),
                    _buildNewsItem(
                      imagePath: 'assets/images/cabai.png',
                      title: 'Harga cabai naik',
                      subtitle: 'Selengkapnya >',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.brand_01,
        ),
      ),
    );
  }

  Widget _buildNewsItem({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              height: 80,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 120,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      'Error loading image',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.brand_01,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
