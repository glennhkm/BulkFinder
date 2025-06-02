import 'package:flutter/material.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bulk_finder/services/store_service.dart';

class SellerItemsPage extends StatefulWidget {
  const SellerItemsPage({super.key});

  @override
  State<SellerItemsPage> createState() => _SellerItemsPageState();
}

class _SellerItemsPageState extends State<SellerItemsPage> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _storeId;

  @override
  void initState() {
    super.initState();
    _fetchStoreAndItems();
  }

  Future<void> _fetchStoreAndItems() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User tidak login');
      // Ambil store milik seller ini
      final stores = await Supabase.instance.client
          .from('stores')
          .select()
          .eq('seller_id', user.id);
      if (stores.isEmpty) throw Exception('Toko tidak ditemukan');
      final store = stores.first;
      _storeId = store['id'];
      // Ambil barang
      final items = await Supabase.instance.client
          .from('items')
          .select()
          .eq('store_id', _storeId!);
      // Ambil kategori GLOBAL (tanpa filter store_id)
      final categories = await Supabase.instance.client
          .from('item_categories')
          .select();
      setState(() {
        _items = List<Map<String, dynamic>>.from(items);
        _categories = List<Map<String, dynamic>>.from(categories);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _showAddItemDialog() async {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    final _stockController = TextEditingController();
    String? selectedCategoryName;
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text('Tambah Barang', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: _categories.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Belum ada kategori. Silakan hubungi admin untuk menambah kategori.',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nama Barang'),
                            validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'Harga per Kg'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(labelText: 'Stok'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedCategoryName,
                            items: _categories.map<DropdownMenuItem<String>>((cat) {
                              return DropdownMenuItem<String>(
                                value: cat['category_name'] as String,
                                child: Text(cat['category_name'] ?? '-'),
                              );
                            }).toList(),
                            onChanged: (val) => setStateDialog(() => selectedCategoryName = val),
                            decoration: const InputDecoration(labelText: 'Kategori'),
                            validator: (v) => v == null ? 'Pilih kategori' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading || _categories.isEmpty
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setStateDialog(() => isLoading = true);
                        try {
                          final price = double.tryParse(_priceController.text) ?? 0;
                          final stock = int.tryParse(_stockController.text) ?? 0;
                          await Supabase.instance.client.from('items').insert({
                            'store_id': _storeId!,
                            'category_name': selectedCategoryName,
                            'item_name': _nameController.text.trim(),
                            'price_per_kg': price,
                            'stock': stock,
                          });
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Barang berhasil ditambahkan')),
                            );
                            _fetchStoreAndItems();
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal tambah barang: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.brand_01),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum ada barang', style: GoogleFonts.poppins(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddItemDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Barang', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brand_01,
                          iconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchStoreAndItems,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item['item_name'] ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kategori: ${item['category_name']}', style: GoogleFonts.poppins()),
                              Text('Harga: Rp${item['price_per_kg']}', style: GoogleFonts.poppins()),
                              Text('Stok: ${item['stock']}', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _isLoading
          ? null
          : _items.isNotEmpty
              ? FloatingActionButton(
                  onPressed: _showAddItemDialog,
                  backgroundColor: AppTheme.brand_01,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
    );
  }
} 