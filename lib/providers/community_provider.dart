import 'package:flutter/material.dart';
import 'package:bulk_finder/models/community_post.dart';
import 'package:bulk_finder/services/store_service.dart';

class CommunityProvider with ChangeNotifier {
  final _storeService = StoreService();
  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityPost> get posts => _posts;
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

  Future<void> loadPosts() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final postData = await _storeService.getCommunityPosts();
      _posts = postData.map((data) => CommunityPost.fromJson(data)).toList();
    } catch (e) {
      _setError(e.toString());
      print('Error loading posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPost({
    required String userId,
    required String category,
    required String content,
    List<String>? tags,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _storeService.createCommunityPost(
        userId: userId,
        category: category,
        content: content,
        tags: tags,
      );
      
      // Reload posts after creating new one
      await loadPosts();
      return true;
    } catch (e) {
      _setError(e.toString());
      print('Error creating post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
} 