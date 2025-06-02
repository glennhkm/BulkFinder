import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StoreService {
  final supabase = Supabase.instance.client;

  // Check if Supabase is properly configured
  bool _isSupabaseConfigured() {
    try {
      supabase.auth.currentUser;
      return true;
    } catch (e) {
      print('Supabase not properly configured: $e');
      return false;
    }
  }

  // Create Store (method yang dipanggil dari provider)
  Future<void> createStore({
    required String sellerId,
    required String storeName,
    required String address,
    String? addressDetails,
    dynamic storeFrontPicture,
    required String operatingHours,
    double? latitude,
    double? longitude,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    String? storeFrontPicturePath;
    
    // Upload foto toko jika ada
    if (storeFrontPicture != null && storeFrontPicture is PlatformFile) {
      try {
        if (storeFrontPicture.bytes != null) {
          final fileName = '$sellerId/store_${DateTime.now().millisecondsSinceEpoch}.${storeFrontPicture.extension}';
          await supabase.storage.from('store_pictures').uploadBinary(fileName, storeFrontPicture.bytes!);
          storeFrontPicturePath = fileName;
        }
      } catch (e) {
        print('Warning: Failed to upload store picture: $e');
      }
    }

    await supabase.from('stores').insert({
      'seller_id': sellerId,
      'store_name': storeName,
      'address': address,
      'address_details': addressDetails,
      'storefront_picture': storeFrontPicturePath,
      'operating_hours': operatingHours,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Ambil Semua Toko untuk Peta
  Future<List<Map<String, dynamic>>> getStores() async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    try {
      return await supabase.from('stores').select();
    } catch (e) {
      print('Error getting stores: $e');
      return [];
    }
  }

  // Tambah Kategori Barang
  Future<void> addCategory(String storeId, String categoryName) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('item_categories').insert({
      'store_id': storeId,
      'category_name': categoryName,
    });
  }

  // Tambah Barang
  Future<void> addItem({
    required String storeId, // Fixed parameter name
    required String categoryId,
    required String itemName,
    required double pricePerKg,
    required int stock,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('items').insert({
      'store_id': storeId,
      'category_id': categoryId,
      'item_name': itemName,
      'price_per_kg': pricePerKg,
      'stock': stock,
    });
  }

  // Perbarui Stok
  Future<void> updateStock(String itemId, int newStock) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('items').update({'stock': newStock}).eq('id', itemId);
  }

  // Community Posts methods (untuk CommunityProvider)
  Future<List<Map<String, dynamic>>> getCommunityPosts() async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    
    try {
      return await supabase.from('community_posts').select();
    } catch (e) {
      print('Error getting community posts: $e');
      return [];
    }
  }

  Future<void> createCommunityPost({
    required String userId,
    required String category,
    required String content,
    List<String>? tags,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('community_posts').insert({
      'user_id': userId,
      'category': category,
      'content': content,
      'tags': tags,
    });
  }

  // Ambil Kategori berdasarkan Store
  Future<List<Map<String, dynamic>>> getCategoriesByStore(String storeId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    try {
      return await supabase.from('item_categories').select().eq('store_id', storeId);
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Ambil Item berdasarkan Kategori
  Future<List<Map<String, dynamic>>> getItemsByCategory(String categoryId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    try {
      return await supabase.from('items').select().eq('category_id', categoryId);
    } catch (e) {
      print('Error getting items: $e');
      return [];
    }
  }
}

class ReviewService {
  final supabase = Supabase.instance.client;

  // Check if Supabase is properly configured
  bool _isSupabaseConfigured() {
    try {
      supabase.auth.currentUser;
      return true;
    } catch (e) {
      print('Supabase not properly configured: $e');
      return false;
    }
  }

  // Tambah Ulasan
  Future<void> addReview({
    required String userId,
    required String storeId,
    String? category,
    required String reviewText,
    required int rating,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('reviews').insert({
      'user_id': userId,
      'store_id': storeId,
      'category': category,
      'review_text': reviewText,
      'rating': rating,
    });
  }

  // Ambil Ulasan Pengguna
  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    if (!_isSupabaseConfigured()) return [];
    return await supabase.from('reviews').select().eq('user_id', userId);
  }

  // Ambil Ulasan Toko
  Future<List<Map<String, dynamic>>> getStoreReviews(String storeId) async {
    if (!_isSupabaseConfigured()) return [];
    return await supabase.from('reviews').select().eq('store_id', storeId);
  }

  // Edit Ulasan
  Future<void> updateReview(String reviewId, String reviewText, int rating, {String? category}) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    await supabase.from('reviews').update({
      'review_text': reviewText,
      'rating': rating,
      if (category != null) 'category': category,
    }).eq('id', reviewId);
  }

  // Hapus Ulasan
  Future<void> deleteReview(String reviewId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('reviews').delete().eq('id', reviewId);
  }
}

class CommunityService {
  final supabase = Supabase.instance.client;

  // Check if Supabase is properly configured
  bool _isSupabaseConfigured() {
    try {
      supabase.auth.currentUser;
      return true;
    } catch (e) {
      print('Supabase not properly configured: $e');
      return false;
    }
  }

  // Tambah Postingan
  Future<void> addPost({
    required String userId,
    required String category,
    required String content,
    required List<String> tags,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.from('community_posts').insert({
      'user_id': userId,
      'category': category,
      'content': content,
      'tags': tags,
    });
  }

  // Ambil Semua Postingan
  Future<List<Map<String, dynamic>>> getPosts() async {
    if (!_isSupabaseConfigured()) return [];
    return await supabase.from('community_posts').select();
  }

  // Like Post
  Future<void> likePost(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    // Cek apakah sudah like, jika belum baru insert
    final res = await supabase.from('post_likes').select().eq('user_id', userId).eq('post_id', postId);
    if (res.isEmpty) {
      await supabase.from('post_likes').insert({
        'user_id': userId,
        'post_id': postId,
      });
    }
  }

  // Unlike Post
  Future<void> unlikePost(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    await supabase.from('post_likes').delete().eq('user_id', userId).eq('post_id', postId);
  }

  // Get Like Count
  Future<int> getPostLikesCount(String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    final res = await supabase.from('post_likes').select().eq('post_id', postId);
    return res.length;
  }

  // Check if user liked post
  Future<bool> isPostLiked(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    final res = await supabase.from('post_likes').select().eq('user_id', userId).eq('post_id', postId);
    return res.isNotEmpty;
  }

  // Save Post
  Future<void> savePost(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    // Cek apakah sudah save, jika belum baru insert
    final res = await supabase.from('saved_posts').select().eq('user_id', userId).eq('post_id', postId);
    if (res.isEmpty) {
      await supabase.from('saved_posts').insert({
        'user_id': userId,
        'post_id': postId,
      });
    }
  }

  // Unsave Post
  Future<void> unsavePost(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    await supabase.from('saved_posts').delete().eq('user_id', userId).eq('post_id', postId);
  }

  // Get Saved Posts for user
  Future<List<Map<String, dynamic>>> getSavedPosts(String userId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    return await supabase.from('saved_posts').select().eq('user_id', userId);
  }

  // Check if user saved post
  Future<bool> isPostSaved(String userId, String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    final res = await supabase.from('saved_posts').select().eq('user_id', userId).eq('post_id', postId);
    return res.isNotEmpty;
  }

  // Report Post
  Future<void> reportPost(String userId, String postId, String reason) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    // Cek apakah sudah report, jika belum baru insert
    final res = await supabase.from('reported_posts').select().eq('user_id', userId).eq('post_id', postId);
    if (res.isEmpty) {
      await supabase.from('reported_posts').insert({
        'user_id': userId,
        'post_id': postId,
        'reason': reason,
      });
    }
  }

  // Get Report Count
  Future<int> getReportsCount(String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    final res = await supabase.from('reported_posts').select().eq('post_id', postId);
    return res.length;
  }

  // Tambah Komentar
  Future<void> addComment(String userId, String postId, String commentText) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    await supabase.from('post_comments').insert({
      'user_id': userId,
      'post_id': postId,
      'comment_text': commentText,
    });
  }

  // Ambil Komentar berdasarkan Post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    return await supabase.from('post_comments')
      .select()
      .eq('post_id', postId)
      .order('created_at', ascending: true);
  }
}

class NotificationService {
  final supabase = Supabase.instance.client;

  // Check if Supabase is properly configured
  bool _isSupabaseConfigured() {
    try {
      supabase.auth.currentUser;
      return true;
    } catch (e) {
      print('Supabase not properly configured: $e');
      return false;
    }
  }

  // Ambil Notifikasi Publik
  Future<List<Map<String, dynamic>>> getPublicNotifications() async {
    if (!_isSupabaseConfigured()) return [];
    
    try {
      // Fixed: use isFilter instead of is_
      return await supabase.from('notifications').select().isFilter('user_id', null);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Realtime Notifikasi
  void listenToNotifications(Function(List<Map<String, dynamic>>) onData) {
    if (!_isSupabaseConfigured()) return;
    
    try {
      supabase.from('notifications').stream(primaryKey: ['id']).listen(onData);
    } catch (e) {
      print('Error listening to notifications: $e');
    }
  }
}