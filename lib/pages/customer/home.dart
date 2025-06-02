import 'package:bulk_finder/theme/theme.dart';
import 'package:bulk_finder/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'search.dart'; // Impor SearchScreen

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    // Load stores data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().loadStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14.0,
      );
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Notification Icon (Top Right)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: AppTheme.brand_01, size: 24),
                      onPressed: () {
                        // Navigasi ke NotificationScreen
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Ingin Belanja apa hari ini ?',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          onTap: () {
                            // Navigasi ke SearchScreen saat search field disentuh
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.brand_01,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          color: Colors.white,
                          onPressed: () {
                            final query = _searchController.text;
                            print('Search query (via button): $query');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // App Name and Map Description
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 16.0, top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'BulkFinder',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.brand_01,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Peta interaktif menampilkan toko',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Map Section (Inside Card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                              color: AppTheme.brand_01, width: 1.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: SizedBox(
                            height: 400,
                            child: Consumer<StoreProvider>(
                              builder: (context, storeProvider, child) {
                                return FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _currentPosition != null
                                        ? LatLng(_currentPosition!.latitude,
                                            _currentPosition!.longitude)
                                        : const LatLng(-6.200000, 106.816666),
                                    initialZoom: 14.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                      userAgentPackageName: 'com.example.bulk_finder',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        // User's current location marker
                                        if (_currentPosition != null)
                                          Marker(
                                            point: LatLng(
                                              _currentPosition!.latitude,
                                              _currentPosition!.longitude,
                                            ),
                                            child: const Icon(
                                              Icons.person_pin_circle,
                                              color: Colors.blue,
                                              size: 40,
                                            ),
                                          ),
                                        // Store markers from database
                                        ...storeProvider.stores
                                            .where((store) => store.latitude != null && store.longitude != null)
                                            .map((store) => Marker(
                                                  point: LatLng(store.latitude!, store.longitude!),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Show store info dialog
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: Text(store.storeName),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Alamat: ${store.address}'),
                                                              if (store.addressDetails != null)
                                                                Text('Detail: ${store.addressDetails}'),
                                                              Text('Jam Operasional: ${store.operatingHours}'),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: Text('Tutup'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      'assets/images/shoplogo.png',
                                                      width: 40,
                                                      height: 40,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Floating button di pojok kanan atas map
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            icon: const Icon(Icons.my_location, color: AppTheme.brand_01),
                            tooltip: 'Center ke Lokasi Saya',
                            onPressed: () async {
                              try {
                                Position position = await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high,
                                );
                                setState(() {
                                  _currentPosition = position;
                                });
                                _mapController.move(
                                  LatLng(position.latitude, position.longitude),
                                  14.0,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Berita Terkini Section
                Container(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 16.0, top: 16.0, bottom: 16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Berita Terkini',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brand_01,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Single Card for all news
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            // Berita 1: Harga Beras
                            _buildNewsItem(
                              imagePath: 'assets/images/beras.png',
                              title: 'Harga Beras Naik di Pasar Lokal',
                              showDivider: true,
                            ),
                            // Berita 2: Harga Cabai
                            _buildNewsItem(
                              imagePath: 'assets/images/cabai.png',
                              title: 'Harga Cabai Melonjak Jelang Hari Raya',
                              showDivider: true,
                            ),
                            // Berita 3: Bawang
                            _buildNewsItem(
                              imagePath: 'assets/images/bawang.png',
                              title: 'Bawang jadi langka',
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build news items
  Widget _buildNewsItem({
    required String imagePath,
    required String title,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
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
                      'Baca selengkapnya...',
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
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
      ],
    );
  }
}
