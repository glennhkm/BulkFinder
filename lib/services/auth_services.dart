import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bulk_finder/services/store_service.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Check if Supabase is properly configured
  bool _isSupabaseConfigured() {
    if (supabase == null) {
      print('Supabase client is not initialized');
      return false;
    }
    return true;
  }

  // Pendaftaran Customer
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    PlatformFile? profilePicture,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception(
          'Supabase belum dikonfigurasi. Silakan periksa file .env');
    }

    bool profilePictureUploaded = true;
    try {
      // Normalize email
      final normalizedEmail = email.trim().toLowerCase();
      print('Attempting to register customer with email: "$normalizedEmail"');
      
      final response = await supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Gagal membuat akun. Email mungkin sudah terdaftar.');
      }

      // For development - auto confirm email (remove this since we'll disable confirmation in dashboard)
      print('User registered successfully: ${response.user!.email}');

      String? profilePicturePath;
      if (profilePicture != null && profilePicture.bytes != null) {
        try {
          final fileName =
              '${response.user!.id}/${DateTime.now().millisecondsSinceEpoch}.${profilePicture.extension}';
          
          print('Attempting to upload profile picture: $fileName');
          
          await supabase.storage
              .from('profilepictures')
              .uploadBinary(fileName, profilePicture.bytes!);
          profilePicturePath = fileName;
          
          print('Profile picture uploaded successfully: $profilePicturePath');
        } catch (e) {
          print('Warning: Failed to upload profile picture: $e');
          profilePictureUploaded = false;
          // Continue without profile picture instead of failing
          profilePicturePath = null;
        }
      }

      // Insert user data - try with better error handling
      try {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'role': 'customer',
          'full_name': fullName,
          'email': normalizedEmail,
          'phone_number': phoneNumber,
          'gender': gender,
          'password_hash': password,
          'profile_picture': profilePicturePath,
        });
        
        print('User data inserted successfully');
      } catch (e) {
        print('Error inserting user data: $e');
        // If user data insertion fails, delete the auth user
        try {
          await supabase.auth.admin.deleteUser(response.user!.id);
        } catch (deleteError) {
          print('Failed to cleanup auth user: $deleteError');
        }
        throw Exception('Gagal menyimpan data user ke database: $e');
      }

      return {
        'success': true,
        'profilePictureUploaded': profilePictureUploaded
      };
    } catch (e) {
      throw Exception('Pendaftaran customer gagal: $e');
    }
  }

  // Pendaftaran Seller
  Future<void> registerSeller({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    PlatformFile? profilePicture,
    required String businessLicenseNumber,
    required String npwp,
    required PlatformFile ktpPicture,
    required String storeName,
    required String storeContact,
    required String storeAddress,
    required String addressDetails,
    PlatformFile? storefrontPicture,
    required String operatingHours,
    double? latitude,
    double? longitude,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception(
          'Supabase belum dikonfigurasi. Silakan periksa file .env');
    }

    try {
      // Normalize email
      final normalizedEmail = email.trim().toLowerCase();
      print('Attempting to register seller with email: "$normalizedEmail"');
      
      // Daftar pengguna di Supabase Auth
      final response = await supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Gagal membuat akun. Email mungkin sudah terdaftar.');
      }

      print('User registered successfully: ${response.user!.email}');

      // Upload foto profil jika ada
      String? profilePicturePath;
      if (profilePicture != null && profilePicture.bytes != null) {
        try {
          final fileName =
              '${response.user!.id}/profile_${DateTime.now().millisecondsSinceEpoch}.${profilePicture.extension}';
          await supabase.storage
              .from('profilepictures')
              .uploadBinary(fileName, profilePicture.bytes!);
          profilePicturePath = fileName;
        } catch (e) {
          print('Warning: Failed to upload profile picture: $e');
        }
      }

      // Upload foto KTP
      String? ktpFileName;
      if (ktpPicture.bytes != null) {
        try {
          ktpFileName =
              '${response.user!.id}/ktp_${DateTime.now().millisecondsSinceEpoch}.${ktpPicture.extension}';
          await supabase.storage
              .from('ktp')
              .uploadBinary(ktpFileName, ktpPicture.bytes!);
        } catch (e) {
          throw Exception('Gagal mengunggah foto KTP: $e');
        }
      }

      // Upload foto tampak depan toko
      String? storefrontPicturePath;
      if (storefrontPicture != null && storefrontPicture.bytes != null) {
        try {
          final fileName =
              '${response.user!.id}/storefront_${DateTime.now().millisecondsSinceEpoch}.${storefrontPicture.extension}';
          await supabase.storage
              .from('storepictures')
              .uploadBinary(fileName, storefrontPicture.bytes!);
          storefrontPicturePath = fileName;
        } catch (e) {
          print('Warning: Failed to upload storefront picture: $e');
        }
      }

      // Simpan data pengguna ke tabel users
      await supabase.from('users').insert({
        'id': response.user!.id,
        'role': 'seller',
        'full_name': fullName,
        'email': normalizedEmail,
        'phone_number': phoneNumber,
        'gender': gender,
        'password_hash': password,
        'profile_picture': profilePicturePath,
      });

      // Simpan data seller ke tabel sellers
      await supabase.from('sellers').insert({
        'user_id': response.user!.id,
        'business_license_number': businessLicenseNumber,
        'npwp': npwp,
        'ktp_picture': ktpFileName,
        'store_name': storeName,
        'store_contact': storeContact,
        'store_address': storeAddress,
        'address_details': addressDetails,
        'storefront_picture': storefrontPicturePath,
        'operating_hours': operatingHours,
        'latitude': latitude,
        'longitude': longitude,
      });

      // Tambahkan juga ke tabel stores
      await StoreService().createStore(
        sellerId: response.user!.id,
        storeName: storeName,
        address: storeAddress,
        addressDetails: addressDetails,
        storeFrontPicture: storefrontPicture, // bisa null
        operatingHours: operatingHours,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      print('Full error details: $e');
      
      // Better error handling
      if (e.toString().contains('email_address_invalid')) {
        throw Exception('Format email tidak valid. Gunakan format: nama@domain.com');
      } else if (e.toString().contains('email_already_exists')) {
        throw Exception('Email sudah terdaftar. Gunakan email lain atau login.');
      } else {
        throw Exception('Pendaftaran seller gagal: $e');
      }
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    if (!_isSupabaseConfigured()) {
      throw Exception(
          'Supabase belum dikonfigurasi. Silakan periksa file .env');
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal. Periksa email dan password Anda.');
      }
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Email atau password salah');
      }
      throw Exception('Login gagal: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    if (!_isSupabaseConfigured()) {
      return; // Silent fail for logout when not configured
    }

    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Update Password
  Future<void> changePassword(String newPassword) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Ambil Profil
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    try {
      final response =
          await supabase.from('users').select().eq('id', userId).single();
      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Update Profil
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String gender,
    PlatformFile? profilePicture,
  }) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }

    String? profilePicturePath;
    if (profilePicture != null && profilePicture.bytes != null) {
      try {
        final fileName =
            '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.${profilePicture.extension}';
        await supabase.storage
            .from('profilepictures')
            .uploadBinary(fileName, profilePicture.bytes!);
        profilePicturePath = fileName;
      } catch (e) {
        print('Warning: Failed to upload profile picture: $e');
      }
    }

    await supabase.from('users').update({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      if (profilePicturePath != null) 'profile_picture': profilePicturePath,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Ambil Profil Seller
  Future<Map<String, dynamic>?> getSellerProfile(String userId) async {
    if (!_isSupabaseConfigured()) {
      throw Exception('Supabase belum dikonfigurasi');
    }
    try {
      final response = await supabase.from('sellers').select().eq('user_id', userId).single();
      return response;
    } catch (e) {
      print('Error getting seller profile: $e');
      return null;
    }
  }
}
