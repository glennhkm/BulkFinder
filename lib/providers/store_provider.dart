import 'package:flutter/material.dart';
import 'package:bulk_finder/models/store.dart';
import 'package:bulk_finder/services/store_service.dart';

class StoreProvider with ChangeNotifier {
  final _storeService = StoreService();
  List<Store> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadStores() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final storeData = await _storeService.getStores();
      _stores = storeData.map((data) => Store.fromJson(data)).toList();
    } catch (e) {
      _setError(e.toString());
      print('Error loading stores: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createStore({
    required String sellerId,
    required String storeName,
    required String address,
    String? addressDetails,
    dynamic storeFrontPicture,
    required String operatingHours,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _storeService.createStore(
        sellerId: sellerId,
        storeName: storeName,
        address: address,
        addressDetails: addressDetails,
        storeFrontPicture: storeFrontPicture,
        operatingHours: operatingHours,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Reload stores after creating new one
      await loadStores();
      return true;
    } catch (e) {
      _setError(e.toString());
      print('Error creating store: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
} 