import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_schedule_model.dart';

class TourScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create tour schedule
  Future<void> createTourSchedule(TourScheduleModel tour) async {
    try {
      // Check for conflicts (double-booking prevention)
      final conflicts = await _firestore
          .collection('tours')
          .where('propertyId', isEqualTo: tour.propertyId)
          .where('status', whereIn: [
            TourStatus.pending.toString().split('.').last,
            TourStatus.confirmed.toString().split('.').last,
          ])
          .where('scheduledDateTime', isLessThanOrEqualTo: tour.scheduledDateTime)
          .where('endDateTime', isGreaterThanOrEqualTo: tour.scheduledDateTime)
          .get();

      if (conflicts.docs.isNotEmpty) {
        throw Exception('Time slot is already booked');
      }

      await _firestore.collection('tours').doc(tour.id).set(tour.toMap());
    } catch (e) {
      throw Exception('Failed to create tour schedule: $e');
    }
  }

  // Update tour schedule
  Future<void> updateTourSchedule(TourScheduleModel tour) async {
    try {
      // Check for conflicts if time is being changed
      if (tour.status == TourStatus.pending || tour.status == TourStatus.confirmed) {
        final conflicts = await _firestore
            .collection('tours')
            .where('propertyId', isEqualTo: tour.propertyId)
            .where('status', whereIn: [
              TourStatus.pending.toString().split('.').last,
              TourStatus.confirmed.toString().split('.').last,
            ])
            .where(FieldPath.documentId, isNotEqualTo: tour.id)
            .where('scheduledDateTime', isLessThanOrEqualTo: tour.scheduledDateTime)
            .where('endDateTime', isGreaterThanOrEqualTo: tour.scheduledDateTime)
            .get();

        if (conflicts.docs.isNotEmpty) {
          throw Exception('Time slot is already booked');
        }
      }

      await _firestore
          .collection('tours')
          .doc(tour.id)
          .update(tour.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update tour schedule: $e');
    }
  }

  // Get tours for a property
  Stream<List<TourScheduleModel>> getToursForProperty(String propertyId) {
    return _firestore
        .collection('tours')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('scheduledDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourScheduleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get tours for a seller
  Stream<List<TourScheduleModel>> getToursForSeller(String sellerId) {
    return _firestore
        .collection('tours')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('scheduledDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourScheduleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get tours for a buyer
  Stream<List<TourScheduleModel>> getToursForBuyer(String buyerId) {
    return _firestore
        .collection('tours')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('scheduledDateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourScheduleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get available time slots for a property (for a specific date)
  Future<List<DateTime>> getAvailableTimeSlots(
    String propertyId,
    DateTime date,
    Duration tourDuration,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final bookedTours = await _firestore
          .collection('tours')
          .where('propertyId', isEqualTo: propertyId)
          .where('status', whereIn: [
            TourStatus.pending.toString().split('.').last,
            TourStatus.confirmed.toString().split('.').last,
          ])
          .where('scheduledDateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduledDateTime', isLessThan: endOfDay)
          .get();

      final bookedSlots = bookedTours.docs
          .map((doc) => TourScheduleModel.fromMap(doc.data() as Map<String, dynamic>).scheduledDateTime)
          .toList();

      // Generate available slots (every hour from 9 AM to 6 PM)
      final List<DateTime> availableSlots = [];
      DateTime currentSlot = startOfDay.add(const Duration(hours: 9));

      while (currentSlot.hour < 18) {
        bool isAvailable = true;
        for (final bookedSlot in bookedSlots) {
          final bookedEnd = bookedSlot.add(tourDuration);
          if (currentSlot.isBefore(bookedEnd) &&
              currentSlot.add(tourDuration).isAfter(bookedSlot)) {
            isAvailable = false;
            break;
          }
        }

        if (isAvailable) {
          availableSlots.add(currentSlot);
        }

        currentSlot = currentSlot.add(const Duration(hours: 1));
      }

      return availableSlots;
    } catch (e) {
      throw Exception('Failed to get available time slots: $e');
    }
  }

  // Cancel tour
  Future<void> cancelTour(String tourId) async {
    try {
      await _firestore.collection('tours').doc(tourId).update({
        'status': TourStatus.cancelled.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel tour: $e');
    }
  }

  // Confirm tour
  Future<void> confirmTour(String tourId) async {
    try {
      await _firestore.collection('tours').doc(tourId).update({
        'status': TourStatus.confirmed.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to confirm tour: $e');
    }
  }
}

