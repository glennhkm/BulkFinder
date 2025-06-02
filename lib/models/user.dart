class User {
  final String id;
  final String role; // 'customer' or 'seller'
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? gender;
  final String? passwordHash;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.gender,
    this.passwordHash,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      gender: json['gender'] as String?,
      passwordHash: json['password_hash'] as String?,
      profilePicture: json['profile_picture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'password_hash': passwordHash,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
