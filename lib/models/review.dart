class Review {
  final String id;
  final String userId;
  final String storeId;
  final String? category;
  final String reviewText;
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.storeId,
    this.category,
    required this.reviewText,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storeId: json['store_id'] as String,
      category: json['category'] as String?,
      reviewText: json['review_text'] as String,
      rating: json['rating'] is int ? json['rating'] as int : int.parse(json['rating'].toString()),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'category': category,
      'review_text': reviewText,
      'rating': rating,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 