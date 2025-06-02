class Seller {
  final String id;
  final String userId;
  final String? businessLicenseNumber;
  final String? npwp;
  final String? ktpPicture;
  final String? storeName;
  final String? storeContact;
  final String? storeAddress;
  final String? addressDetails;
  final String? storefrontPicture;
  final String? operatingHours;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Seller({
    required this.id,
    required this.userId,
    this.businessLicenseNumber,
    this.npwp,
    this.ktpPicture,
    this.storeName,
    this.storeContact,
    this.storeAddress,
    this.addressDetails,
    this.storefrontPicture,
    this.operatingHours,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessLicenseNumber: json['business_license_number'] as String?,
      npwp: json['npwp'] as String?,
      ktpPicture: json['ktp_picture'] as String?,
      storeName: json['store_name'] as String?,
      storeContact: json['store_contact'] as String?,
      storeAddress: json['store_address'] as String?,
      addressDetails: json['address_details'] as String?,
      storefrontPicture: json['storefront_picture'] as String?,
      operatingHours: json['operating_hours'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
} 