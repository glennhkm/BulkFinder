import 'package:flutter/material.dart';
import 'package:bulk_finder/services/auth_services.dart';
import 'package:bulk_finder/models/user.dart' as UserModel;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  UserModel.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadUser(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userData = await _authService.getProfile(userId);
      if (userData != null) {
        _user = UserModel.User.fromJson(userData);
      }
    } catch (e) {
      _setError(e.toString());
      print('Error loading user: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.login(email, password);
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      if (currentUser != null) {
        await loadUser(currentUser.id);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      print('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _user = null;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      print('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    dynamic profilePicture,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.registerCustomer(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        password: password,
        profilePicture: profilePicture,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      print('Customer registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerSeller({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    dynamic profilePicture,
    required String businessLicenseNumber,
    required String npwp,
    required dynamic ktpPicture,
    required String storeName,
    required String storeContact,
    required String storeAddress,
    required String addressDetails,
    dynamic storefrontPicture,
    required String operatingHours,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.registerSeller(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        password: password,
        profilePicture: profilePicture,
        businessLicenseNumber: businessLicenseNumber,
        npwp: npwp,
        ktpPicture: ktpPicture,
        storeName: storeName,
        storeContact: storeContact,
        storeAddress: storeAddress,
        addressDetails: addressDetails,
        storefrontPicture: storefrontPicture,
        operatingHours: operatingHours,
        latitude: latitude,
        longitude: longitude,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      print('Seller registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}