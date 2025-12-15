import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';
import '../repositories/favorites_repository.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyRepository _propertyRepository = PropertyRepository();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();
  
  List<PropertyModel> _properties = [];
  List<PropertyModel> _favoriteProperties = [];
  List<String> _favoriteIds = [];
  final bool _isLoading = false;

  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get favoriteProperties => _favoriteProperties;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  // Load all properties
  void loadProperties() {
    _propertyRepository.getAllProperties().listen((properties) {
      _properties = properties;
      notifyListeners();
    });
  }

  // Search properties
  void searchProperties({
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
    _propertyRepository
        .searchProperties(
          city: city,
          state: state,
          type: type,
          status: status,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minBedrooms: minBedrooms,
          minBathrooms: minBathrooms,
          minArea: minArea,
          maxArea: maxArea,
          features: features,
          searchQuery: searchQuery,
        )
        .listen((properties) {
      _properties = properties;
      notifyListeners();
    });
  }

  // Load favorites
  void loadFavorites(String userId) {
    _favoritesRepository.getFavoritePropertyIds(userId).listen((ids) {
      _favoriteIds = ids;
      notifyListeners();
    });

    _favoritesRepository.getFavoriteProperties(userId).then((properties) {
      _favoriteProperties = properties;
      notifyListeners();
    });
  }

  // Toggle favorite
  Future<void> toggleFavorite(String userId, String propertyId) async {
    try {
      final isFavorited = await _favoritesRepository.isFavorited(userId, propertyId);
      if (isFavorited) {
        await _favoritesRepository.removeFromFavorites(userId, propertyId);
        await _propertyRepository.updateFavoritesCount(propertyId, -1);
      } else {
        await _favoritesRepository.addToFavorites(userId, propertyId);
        await _propertyRepository.updateFavoritesCount(propertyId, 1);
      }
      loadFavorites(userId);
    } catch (e) {
      rethrow;
    }
  }

  bool isFavorited(String propertyId) {
    return _favoriteIds.contains(propertyId);
  }
}

