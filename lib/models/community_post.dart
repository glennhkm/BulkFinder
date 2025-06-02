class CommunityPost {
  final String id;
  final String userId;
  final String category;
  final String content;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.category,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    List<String>? tagList;
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagList = List<String>.from(json['tags']);
      } else if (json['tags'] is String) {
        tagList = [json['tags'] as String];
      }
    }

    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      tags: tagList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'content': content,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 