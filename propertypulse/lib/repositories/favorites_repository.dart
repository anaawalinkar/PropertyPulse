import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add to favorites
  Future<void> addToFavorites(String userId, String propertyId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'addedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String propertyId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Check if property is favorited
  Future<bool> isFavorited(String userId, String propertyId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  // Get favorite property IDs
  Stream<List<String>> getFavoritePropertyIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['propertyId'] as String)
            .toList());
  }

  // Get favorite properties with details
  Future<List<PropertyModel>> getFavoriteProperties(String userId) async {
    try {
      final favoriteIds = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      if (favoriteIds.docs.isEmpty) return [];

      final List<String> propertyIds =
          favoriteIds.docs.map((doc) => doc.data()['propertyId'] as String).toList();

      final properties = await _firestore
          .collection('properties')
          .where(FieldPath.documentId, whereIn: propertyIds)
          .get();

      return properties.docs
          .map((doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite properties: $e');
    }
  }
}

