import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:bulk_finder/services/store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = ['Beras', 'Minyak', 'Cabai'];
  List<Map<String, dynamic>> _allStores = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    setState(() => _isLoading = true);
    try {
      final stores = await StoreService().getStores();
      setState(() {
        _allStores = stores;
        _searchResults = [];
        _isLoading = false;
        _hasSearched = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Bisa tampilkan error snackbar jika mau
    }
  }

  void _onSearch() {
    setState(() {
      String query = _searchController.text.trim().toLowerCase();
      _searchResults = _allStores.where((store) {
        final name = store['store_name']?.toString().toLowerCase() ?? '';
        final address = store['address']?.toString().toLowerCase() ?? '';
        final matchQuery = query.isEmpty || name.contains(query) || address.contains(query);
        return matchQuery;
      }).toList();
      _hasSearched = true;
      // Update riwayat pencarian
      if (query.isNotEmpty && !_searchHistory.contains(_searchController.text)) {
        _searchHistory.insert(0, _searchController.text);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.sublist(0, 10);
        }
      }
    });
  }

  void _onHistoryTap(String keyword) {
    setState(() {
      _searchController.text = keyword;
    });
    _onSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.brand_01),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cari Toko atau Barang',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.brand_01,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'cari sekarang',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: AppTheme.brand_01),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: Text('Beras', style: GoogleFonts.poppins()),
                          onPressed: () {
                            setState(() {
                              _searchController.text = 'Beras';
                            });
                            _onSearch();
                          },
                          backgroundColor: Colors.grey[200],
                        ),
                        ActionChip(
                          label: Text('Odol Gigi', style: GoogleFonts.poppins()),
                          onPressed: () {
                            setState(() {
                              _searchController.text = 'Odol Gigi';
                            });
                            _onSearch();
                          },
                          backgroundColor: Colors.grey[200],
                        ),
                        ActionChip(
                          label: Text('Minyak', style: GoogleFonts.poppins()),
                          onPressed: () {
                            setState(() {
                              _searchController.text = 'Minyak';
                            });
                            _onSearch();
                          },
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Button
            Center(
              child: ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brand_01,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Cari',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Riwayat Pencarian
            if (!_hasSearched)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Pencarian',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand_01,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _searchHistory.isEmpty
                      ? Text('Belum ada riwayat pencarian', style: GoogleFonts.poppins())
                      : Wrap(
                          spacing: 8,
                          children: _searchHistory.map((item) {
                            return ActionChip(
                              label: Text(item, style: GoogleFonts.poppins()),
                              onPressed: () => _onHistoryTap(item),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                        ),
                ],
              ),
            // Hasil Pencarian
            if (_hasSearched)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil Pencarian:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand_01,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                          ? Center(child: Text('Tidak ada hasil ditemukan', style: GoogleFonts.poppins()))
                          : Column(
                              children: _searchResults.map((result) => _buildSearchResultCard(result)).toList(),
                            ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    // Ambil gambar dari Supabase Storage jika ada
    String? imagePath = result['storefront_picture'];
    String? imageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      imageUrl = Supabase.instance.client.storage.from('store_pictures').getPublicUrl(imagePath);
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Gambar tidak tersedia')),
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Gambar tidak tersedia')),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.brand_01, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    result['address'] ?? '',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.brand_01),
                  ),
                  const Spacer(),
                  // Bisa tambahkan rating jika ada field rating di tabel
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                result['store_name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                result['address_details'] ?? '',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke peta atau detail toko
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brand_01,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lihat di Peta',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}