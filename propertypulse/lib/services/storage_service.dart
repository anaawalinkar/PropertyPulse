import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadPropertyImage(File imageFile, String propertyId) async {
    try {
      // Verify file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage
          .ref()
          .child('properties')
          .child(propertyId)
          .child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );
      
      final TaskSnapshot snapshot = await uploadTask;
      
      // Check if upload was successful
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
      // Wait a moment for the file to be fully processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Provide more specific error messages for Firebase errors
      String errorMessage = 'Failed to upload image: ';
      switch (e.code) {
        case 'object-not-found':
          errorMessage += 'Storage bucket or path not found. Check Firebase Storage configuration.';
          break;
        case 'unauthorized':
          errorMessage += 'Unauthorized. Check Firebase Storage security rules.';
          break;
        case 'canceled':
          errorMessage += 'Upload was canceled.';
          break;
        case 'unknown':
          errorMessage += 'Unknown error: ${e.message}';
          break;
        default:
          errorMessage += '${e.code}: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<String>> uploadMultiplePropertyImages(
    List<File> imageFiles,
    String propertyId,
  ) async {
    try {
      final List<String> downloadUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        
        // Verify file exists before attempting upload
        if (!await imageFile.exists()) {
          throw Exception(
            'Image file ${i + 1} does not exist at path: ${imageFile.path}',
          );
        }
        
        try {
          final url = await uploadPropertyImage(imageFile, propertyId);
          downloadUrls.add(url);
        } catch (e) {
          // If one image fails, clean up any successfully uploaded images
          for (final url in downloadUrls) {
            try {
              await deleteImage(url);
            } catch (_) {
              // Ignore cleanup errors
            }
          }
          throw Exception('Failed to upload image ${i + 1}: $e');
        }
      }
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Verify file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage
          .ref()
          .child('profiles')
          .child(userId)
          .child(fileName);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );
      
      final TaskSnapshot snapshot = await uploadTask;
      
      // Check if upload was successful
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
      // Wait a moment for the file to be fully processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Provide more specific error messages for Firebase errors
      String errorMessage = 'Failed to upload profile image: ';
      switch (e.code) {
        case 'object-not-found':
          errorMessage += 'Storage bucket or path not found. Check Firebase Storage configuration.';
          break;
        case 'unauthorized':
          errorMessage += 'Unauthorized. Check Firebase Storage security rules.';
          break;
        case 'canceled':
          errorMessage += 'Upload was canceled.';
          break;
        case 'unknown':
          errorMessage += 'Unknown error: ${e.message}';
          break;
        default:
          errorMessage += '${e.code}: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}

