import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bulk_finder/models/review.dart';
import 'package:bulk_finder/models/store.dart';
import 'package:bulk_finder/models/user.dart' as UserModel;
import 'package:bulk_finder/services/store_service.dart';
import 'package:bulk_finder/services/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bulk_finder/providers/auth_providers.dart';

// Ganti dengan tema Anda jika sudah ada
class AppTheme {
  static const Color brand_01 = Color(0xFF2A6F47); // Warna hijau sesuai gambar
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedTabIndex = 0; // 0 untuk Ulasan Mu, 1 untuk Semua Ulasan
  bool _isLoading = true;
  String? _error;
  List<Review> myReviews = [];
  List<Review> allReviews = [];
  Map<String, Store> storeMap = {};
  Map<String, UserModel.User> userMap = {};
  List<Store> stores = [];

  final reviewService = ReviewService();
  final storeService = StoreService();
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id ?? Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');
      // Ambil semua toko
      final storeList = await storeService.getStores();
      print('Store List: $storeList');
      stores = storeList.map((e) => Store.fromJson(e)).toList();
      for (var s in stores) { storeMap[s.id] = s; }
      // Ambil review milik user
      final myReviewList = await reviewService.getUserReviews(userId);
      myReviews = myReviewList.map((e) => Review.fromJson(e)).toList();
      // Ambil semua review untuk semua toko
      List<Review> all = [];
      for (var s in stores) {
        final reviewList = await reviewService.getStoreReviews(s.id);
        all.addAll(reviewList.map((e) => Review.fromJson(e)));
      }
      allReviews = all;
      // Ambil user untuk setiap review
      final userIds = {...myReviews.map((r) => r.userId), ...allReviews.map((r) => r.userId)}.toList();
      for (var uid in userIds) {
        if (!userMap.containsKey(uid)) {
          final u = await authService.getProfile(uid);
          if (u != null) userMap[uid] = UserModel.User.fromJson(u);
        }
      }
      print('All Reviews:');
      for (var r in allReviews) {
        print('Review: storeId=${r.storeId}, userId=${r.userId}, reviewText=${r.reviewText}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : Column(
                    children: [
                      // App Bar
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.brand_01, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Ulasan',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.brand_01,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Tab Bar
                      const SizedBox(height: 24),
                      TabBar(
                        tabs: [
                          Tab(text: 'Ulasan Mu'),
                          Tab(text: 'Semua Ulasan'),
                        ],
                        labelColor: AppTheme.brand_01,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppTheme.brand_01,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 0: Ulasan Mu
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _showAddReviewDialog(context),
                                        icon: const Icon(Icons.add_comment, color: Colors.white),
                                        label: Text(
                                          'Tambah Ulasan',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.brand_01,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: _buildMyReviews()),
                              ],
                            ),
                            // Tab 1: Semua Ulasan
                            _buildAllReviews(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMyReviews() {
    if (myReviews.isEmpty) {
      return Center(
        child: Text(
          'Belum ada ulasan. Tambah ulasan untuk toko tempat Anda berbelanja!',
          style: GoogleFonts.poppins(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: myReviews.map((review) => _buildReviewCard(context, review: review, isMyReview: true)).toList(),
    );
  }

  Widget _buildAllReviews() {
    if (allReviews.isEmpty) {
      return Center(
        child: Text(
          'Belum ada ulasan untuk toko manapun.',
          style: GoogleFonts.poppins(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    final Map<String, List<Review>> grouped = {};
    for (var r in allReviews) {
      grouped.putIfAbsent(r.storeId, () => []).add(r);
    }
    for (var entry in grouped.entries) {
      print('Group storeId: ${entry.key}, review count: ${entry.value.length}, store: ${storeMap[entry.key]?.storeName}');
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: grouped.entries.map((entry) {
        final store = storeMap[entry.key];
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: AppTheme.brand_01),
                    const SizedBox(width: 8),
                    Text(
                      store?.storeName ?? 'Toko Tidak Dikenal (${entry.key})',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand_01,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...entry.value.map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReviewCard(context, review: review, isMyReview: false),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(BuildContext context, {required Review review, required bool isMyReview}) {
    final reviewer = userMap[review.userId];
    final store = storeMap[review.storeId];
    return Card(
      color: AppTheme.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    (reviewer?.fullName.isNotEmpty ?? false) ? reviewer!.fullName[0] : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reviewer?.fullName ?? 'Pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.store, color: AppTheme.brand_01, size: 20),
                const SizedBox(width: 8),
                Text(
                  store?.storeName ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ulasan: ${review.reviewText}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            if (isMyReview) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _showEditReviewDialog(context, review),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await reviewService.deleteReview(review.id);
                        await _fetchAllData();
                      } catch (e) {
                        print('Error deleting review: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghapus ulasan!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? Supabase.instance.client.auth.currentUser?.id;
    String? selectedStoreId;
    final reviewTextController = TextEditingController();
    final categoryTextController = TextEditingController();
    int rating = 0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.store, color: AppTheme.brand_01),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Ulasan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Toko',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      hint: Text(
                        'Pilih toko yang mau diulas',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      value: selectedStoreId,
                      items: stores.map((store) {
                        return DropdownMenuItem<String>(
                          value: store.id,
                          child: Text(store.storeName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStoreId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedStoreId != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: categoryTextController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama kategori',
                              hintStyle: GoogleFonts.poppins(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Ulasan',
                      'Tuliskan ulasan anda',
                      maxLines: 3,
                      controller: reviewTextController,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Beri Rating',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reviewText = reviewTextController.text;
                    final categoryName = categoryTextController.text.trim();
                    print('Selected Store: $selectedStoreId');
                    print('Category Name: $categoryName');
                    print('Review Text: $reviewText');
                    print('Rating: $rating');

                    if (selectedStoreId != null && categoryName.isNotEmpty && reviewText.isNotEmpty && rating > 0) {
                      await reviewService.addReview(
                        userId: userId!,
                        storeId: selectedStoreId!,
                        category: categoryName,
                        reviewText: reviewText,
                        rating: rating,
                      );
                      Navigator.pop(context);
                      await _fetchAllData();
                    } else {
                      print('Field validation failed: storeId=$selectedStoreId, category=$categoryName, reviewText="$reviewText", rating=$rating');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap isi semua field dan beri rating!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brand_01,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kirim Ulasan',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditReviewDialog(BuildContext context, Review review) {
    final reviewTextController = TextEditingController(text: review.reviewText);
    int rating = review.rating;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.store, color: AppTheme.brand_01),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Ulasan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      'Ulasan',
                      'Tuliskan ulasan anda',
                      initialValue: null, // controller digunakan, initialValue tidak perlu
                      maxLines: 3,
                      controller: reviewTextController,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Beri Rating',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reviewText = reviewTextController.text;
                    if (reviewText.isNotEmpty && rating > 0) {
                      await reviewService.updateReview(review.id, reviewText, rating);
                      Navigator.pop(context);
                      await _fetchAllData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap isi semua field dan beri rating!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brand_01,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Ulasan',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, String hint,
      {int maxLines = 1, String? initialValue, TextEditingController? controller, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          controller: controller ?? (initialValue != null ? TextEditingController(text: initialValue) : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}