class PropertyModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final PropertyType type;
  final PropertyStatus status;
  final double price;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? country;
  
  // Property Details
  final double? area; // in square feet
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpaces;
  final int? yearBuilt;
  final List<String> features; // e.g., ["Swimming Pool", "Garden", "Garage"]
  
  // Location
  final double? latitude;
  final double? longitude;
  
  // Media
  final List<String> imageUrls;
  final String? videoUrl;
  final String? virtualTourUrl;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final int favoritesCount;

  PropertyModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpaces,
    this.yearBuilt,
    this.features = const [],
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.videoUrl,
    this.virtualTourUrl,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.favoritesCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'price': price,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'parkingSpaces': parkingSpaces,
      'yearBuilt': yearBuilt,
      'features': features,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'virtualTourUrl': virtualTourUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'views': views,
      'favoritesCount': favoritesCount,
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: PropertyType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PropertyType.house,
      ),
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PropertyStatus.available,
      ),
      price: (map['price'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'],
      area: map['area']?.toDouble(),
      bedrooms: map['bedrooms'],
      bathrooms: map['bathrooms'],
      parkingSpaces: map['parkingSpaces'],
      yearBuilt: map['yearBuilt'],
      features: List<String>.from(map['features'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      virtualTourUrl: map['virtualTourUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      views: map['views'] ?? 0,
      favoritesCount: map['favoritesCount'] ?? 0,
    );
  }
}

enum PropertyType {
  house,
  apartment,
  condo,
  townhouse,
  villa,
  land,
  commercial,
}

enum PropertyStatus {
  available,
  pending,
  sold,
  rented,
}

