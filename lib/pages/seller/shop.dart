import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bulk_finder/pages/seller/shop_manage.dart';
import 'package:bulk_finder/models/seller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bulk_finder/services/auth_services.dart';
import 'package:bulk_finder/pages/seller/items.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Seller? seller;
  bool isLoading = true;
  List<Map<String, dynamic>> _items = [];
  String? storeId;

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  Future<void> _loadSellerProfile() async {
    setState(() { isLoading = true; });
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await AuthService().getSellerProfile(user.id);
      if (data != null) {
        setState(() {
          seller = Seller.fromJson(data);
        });
        final stores = await Supabase.instance.client
            .from('stores')
            .select()
            .eq('seller_id', seller!.userId);
        if (stores.isNotEmpty) {
          storeId = stores.first['id'] as String;
          print('DEBUG: storeId = $storeId');
          await _loadItems();
        } else {
          print('DEBUG: Tidak ada store untuk seller ini');
        }
      }
    }
    setState(() { isLoading = false; });
  }

  Future<void> _loadItems() async {
    if (storeId == null) {
      print('DEBUG: storeId null');
      return;
    }
    final items = await Supabase.instance.client
        .from('items')
        .select()
        .eq('store_id', storeId!);
    print('DEBUG: items = $items');
    setState(() {
      _items = List<Map<String, dynamic>>.from(items);
    });
  }

  // Data barang statis
  final List<Map<String, dynamic>> items = [
    {
      'name': 'Beras',
      'price': 'Rp. 15.000 / Kg',
      'stock': '1200 Kg (Tersedia Banyak)',
      'info':
          'Banyak (> 1000 Kg)\n"Cukup" (250 - 1000 Kg)\n"Stok Terbatas" (< 250 Kg)',
    },
    {
      'name': 'Cabai',
      'price': 'Rp. 50.000 / Kg',
      'stock': '300 Kg (Tersedia Banyak)',
      'info':
          'Banyak (> 1000 Kg)\n"Cukup" (250 - 1000 Kg)\n"Stok Terbatas" (< 250 Kg)',
    },
    {
      'name': 'Bawang',
      'price': 'Rp. 30.000 / Kg',
      'stock': '150 Kg (Cukup)',
      'info':
          'Banyak (> 1000 Kg)\n"Cukup" (250 - 1000 Kg)\n"Stok Terbatas" (< 250 Kg)',
    },
  ];

  // Kategori statis
  final List<String> categories = ['Bahan Makanan', 'Alat Mandi', 'Lain-lain'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : seller == null
                ? const Center(child: Text('Data toko tidak ditemukan'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.brand_01, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Toko',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.brand_01,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ShopManageScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                  label: Text(
                                    'Kelola Toko',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.brand_01,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        // Informasi Toko
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.brand_01,
                              width: 2.0,
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Toko',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brand_01,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Nama toko',
                                    labelStyle: GoogleFonts.poppins(color: AppTheme.brand_01),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(text: seller?.storeName ?? '-'),
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Alamat toko',
                                    labelStyle: GoogleFonts.poppins(color: AppTheme.brand_01),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(text: seller?.storeAddress ?? '-'),
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Kontak toko',
                                    labelStyle: GoogleFonts.poppins(color: AppTheme.brand_01),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(text: seller?.storeContact ?? '-'),
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Detail alamat',
                                    labelStyle: GoogleFonts.poppins(color: AppTheme.brand_01),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(text: seller?.addressDetails ?? '-'),
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                // Peta mini statis lokasi toko
                                if (seller?.latitude != null && seller?.longitude != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Lokasi Toko di Peta', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.brand_01)),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 180,
                                        child: FlutterMap(
                                          options: MapOptions(
                                            initialCenter: LatLng(seller!.latitude!, seller!.longitude!),
                                            initialZoom: 16.0,
                                            interactiveFlags: InteractiveFlag.none, // Tidak bisa digeser/zoom
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              subdomains: const ['a', 'b', 'c'],
                                              userAgentPackageName: 'com.example.bulk_finder',
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: LatLng(seller!.latitude!, seller!.longitude!),
                                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Jam operasional',
                                    labelStyle: GoogleFonts.poppins(color: AppTheme.brand_01),
                                    border: const OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(text: seller?.operatingHours ?? '-'),
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                if (seller?.storefrontPicture != null && seller!.storefrontPicture!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Foto Tampak Depan Toko', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.brand_01)),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: Supabase.instance.client.storage.from('storepictures').getPublicUrl(seller!.storefrontPicture!),
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[200],
                                            height: 180,
                                            child: const Center(child: Icon(Icons.image, size: 40)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stok Barang Toko
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.brand_01,
                              width: 2.0,
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stok barang toko',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brand_01,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _openAddItemPage,
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: Text(
                                    'Tambah Barang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.brand_01,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  child: RefreshIndicator(
                                    onRefresh: _loadItems,
                                    child: _items.isEmpty
                                        ? const Center(child: Text('Belum ada barang yang ditambahkan.'))
                                        : ListView.builder(
                                            itemCount: _items.length,
                                            itemBuilder: (context, index) {
                                              final item = _items[index];
                                              return ListTile(
                                                leading: const Icon(Icons.fastfood, color: AppTheme.brand_01),
                                                title: Text(
                                                  item['item_name'] ?? '-',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Kategori: ${item['category_name'] ?? '-'}',
                                                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                                                    ),
                                                    Text(
                                                      'Harga: Rp${item['price_per_kg']}',
                                                      style: GoogleFonts.poppins(fontSize: 14),
                                                    ),
                                                    Text(
                                                      'Stok: ${item['stock']}',
                                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.edit, color: AppTheme.brand_01),
                                                  onPressed: () => _showUpdateStockDialog(item),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Future<void> _openAddItemPage() async {
    // Buka SellerItemsPage sebagai dialog, setelah close refresh list barang
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          height: 600,
          child: SellerItemsPage(),
        ),
      ),
    );
    await _loadItems();
  }

  Future<void> _showUpdateStockDialog(Map<String, dynamic> item) async {
    final _stockController = TextEditingController(text: item['stock'].toString());
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text('Perbarui Stok', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok Baru'),
                validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setStateDialog(() => isLoading = true);
                        try {
                          final newStock = int.tryParse(_stockController.text) ?? 0;
                          await Supabase.instance.client
                              .from('items')
                              .update({'stock': newStock})
                              .eq('id', item['id']);

                          // Insert notification
                          await Supabase.instance.client
                              .from('notifications')
                              .insert({
                                'user_id': Supabase.instance.client.auth.currentUser?.id,
                                'store_id': storeId,
                                'message': 'Stok barang "${item['item_name']}" telah diperbarui menjadi $newStock.',
                              });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Stok berhasil diperbarui')),
                            );
                            await _loadItems();
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal perbarui stok: $e')),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom widget untuk chip kategori
class SingleChoiceChip extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const SingleChoiceChip({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<SingleChoiceChip> createState() => _SingleChoiceChipState();
}

class _SingleChoiceChipState extends State<SingleChoiceChip> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(
        widget.categories.length,
        (int index) {
          return ChoiceChip(
            label: Text(widget.categories[index]),
            selected: _selectedIndex == index,
            onSelected: (bool selected) {
              setState(() {
                _selectedIndex = selected ? index : null;
              });
              if (selected) {
                widget.onCategorySelected(widget.categories[index]);
              }
            },
            selectedColor: AppTheme.brand_01.withOpacity(0.1),
            backgroundColor: Colors.grey[200],
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color:
                  _selectedIndex == index ? AppTheme.brand_01 : Colors.black87,
            ),
          );
        },
      ),
    );
  }
}
