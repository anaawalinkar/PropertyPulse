import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class PropertyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create property
  Future<void> createProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection('properties')
          .doc(property.id)
          .set(property.toMap());
    } catch (e) {
      throw Exception('Failed to create property: $e');
    }
  }

  // Update property
  Future<void> updateProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection('properties')
          .doc(property.id)
          .update(property.toMap());
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  // Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // Get property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      final doc = await _firestore.collection('properties').doc(propertyId).get();
      if (doc.exists) {
        return PropertyModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: $e');
    }
  }

  // Get properties by seller
  Stream<List<PropertyModel>> getPropertiesBySeller(String sellerId) {
    return _firestore
        .collection('properties')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Advanced search with complex Firestore queries
  Stream<List<PropertyModel>> searchProperties({
    String? city,
    String? state,
    PropertyType? type,
    PropertyStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    double? minArea,
    double? maxArea,
    List<String>? features,
    String? searchQuery,
  }) {
    Query query = _firestore.collection('properties');

    // Filter by status (always filter available/pending)
    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    } else {
      query = query.where('status', whereIn: [
        PropertyStatus.available.toString().split('.').last,
        PropertyStatus.pending.toString().split('.').last,
      ]);
    }

    // Filter by city
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    // Filter by state
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }

    // Filter by type
    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    // Price range
    if (minPrice != null && minPrice > 0) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null && maxPrice > 0) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    // Bedrooms
    if (minBedrooms != null && minBedrooms > 0) {
      query = query.where('bedrooms', isGreaterThanOrEqualTo: minBedrooms);
    }

    // Bathrooms
    if (minBathrooms != null && minBathrooms > 0) {
      query = query.where('bathrooms', isGreaterThanOrEqualTo: minBathrooms);
    }

    // Area range
    if (minArea != null && minArea > 0) {
      query = query.where('area', isGreaterThanOrEqualTo: minArea);
    }
    if (maxArea != null && maxArea > 0) {
      query = query.where('area', isLessThanOrEqualTo: maxArea);
    }

    // Order by price
    query = query.orderBy('price');

    return query.snapshots().map((snapshot) {
      List<PropertyModel> properties = snapshot.docs
          .map((doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by features (client-side as Firestore doesn't support array-contains-all efficiently)
      if (features != null && features.isNotEmpty) {
        properties = properties.where((property) {
          return features.every((feature) => property.features.contains(feature));
        }).toList();
      }

      // Filter by search query (client-side for text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        properties = properties.where((property) {
          return property.title.toLowerCase().contains(queryLower) ||
              property.description.toLowerCase().contains(queryLower) ||
              property.address.toLowerCase().contains(queryLower) ||
              property.city.toLowerCase().contains(queryLower);
        }).toList();
      }

      return properties;
    });
  }

  // Get all properties (for home feed)
  Stream<List<PropertyModel>> getAllProperties({int limit = 50}) {
    return _firestore
        .collection('properties')
        .where('status', whereIn: [
          PropertyStatus.available.toString().split('.').last,
          PropertyStatus.pending.toString().split('.').last,
        ])
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Increment views
  Future<void> incrementViews(String propertyId) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .update({'views': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to increment views: $e');
    }
  }

  // Update favorites count
  Future<void> updateFavoritesCount(String propertyId, int delta) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .update({'favoritesCount': FieldValue.increment(delta)});
    } catch (e) {
      throw Exception('Failed to update favorites count: $e');
    }
  }
}

