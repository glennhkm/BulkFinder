class Store {
  final String id;
  final String sellerId;
  final String storeName;
  final String address;
  final String? addressDetails;
  final String? storeFrontPicture;
  final String operatingHours;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.sellerId,
    required this.storeName,
    required this.address,
    this.addressDetails,
    this.storeFrontPicture,
    required this.operatingHours,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      storeName: json['store_name'] as String,
      address: json['address'] as String,
      addressDetails: json['address_details'] as String?,
      storeFrontPicture: json['store_front_picture'] as String?,
      operatingHours: json['operating_hours'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'store_name': storeName,
      'address': address,
      'address_details': addressDetails,
      'store_front_picture': storeFrontPicture,
      'operating_hours': operatingHours,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 