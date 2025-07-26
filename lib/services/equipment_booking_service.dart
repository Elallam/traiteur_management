// lib/services/equipment_booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_model.dart';
import '../models/occasion_model.dart';

class EquipmentBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _equipmentBookingsCollection = 'equipment_bookings';
  static const String _occasionsCollection = 'occasions';
  static const String _equipmentCollection = 'equipment';

  /// Check equipment availability for a specific date range
  Future<Map<String, int>> checkEquipmentAvailability({
    required DateTime startDate,
    required DateTime endDate,
    String? excludeOccasionId, // For editing existing occasions
  }) async {
    try {
      // Get all occasions that overlap with the requested date range
      QuerySnapshot occasionsSnapshot = await _firestore
          .collection(_occasionsCollection)
          .where('date', isGreaterThanOrEqualTo: startDate.subtract(const Duration(days: 1)))
          .where('date', isLessThanOrEqualTo: endDate.add(const Duration(days: 1)))
          .where('status', whereIn: ['planned', 'confirmed', 'in_progress'])
          .where('isActive', isEqualTo: true)
          .get();

      // Map to store equipment ID -> total booked quantity
      Map<String, int> bookedQuantities = {};

      for (var doc in occasionsSnapshot.docs) {
        // Skip the current occasion if we're editing
        if (excludeOccasionId != null && doc.id == excludeOccasionId) {
          continue;
        }

        OccasionModel occasion = OccasionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Check if dates overlap
        if (_datesOverlap(startDate, endDate, occasion.date, occasion.date)) {
          for (var equipment in occasion.equipment) {
            bookedQuantities[equipment.equipmentId] =
                (bookedQuantities[equipment.equipmentId] ?? 0) + equipment.quantity;
          }
        }
      }

      return bookedQuantities;
    } catch (e) {
      throw 'Failed to check equipment availability: $e';
    }
  }

  /// Get available quantity for specific equipment on date range
  Future<int> getAvailableQuantity({
    required String equipmentId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeOccasionId,
  }) async {
    try {
      // Get equipment total quantity
      DocumentSnapshot equipmentDoc = await _firestore
          .collection(_equipmentCollection)
          .doc(equipmentId)
          .get();

      if (!equipmentDoc.exists) {
        throw 'Equipment not found';
      }

      EquipmentModel equipment = EquipmentModel.fromMap(
        equipmentDoc.data() as Map<String, dynamic>,
        equipmentDoc.id,
      );

      // Get booked quantities for the date range
      Map<String, int> bookedQuantities = await checkEquipmentAvailability(
        startDate: startDate,
        endDate: endDate,
        excludeOccasionId: excludeOccasionId,
      );

      int bookedQuantity = bookedQuantities[equipmentId] ?? 0;
      return equipment.totalQuantity - bookedQuantity;
    } catch (e) {
      throw 'Failed to get available quantity: $e';
    }
  }

  /// Validate equipment booking for an occasion
  Future<Map<String, dynamic>> validateEquipmentBooking({
    required List<OccasionEquipment> requestedEquipment,
    required DateTime occasionDate,
    String? excludeOccasionId,
  }) async {
    try {
      List<Map<String, dynamic>> conflicts = [];
      bool hasConflicts = false;

      for (var equipment in requestedEquipment) {
        int availableQuantity = await getAvailableQuantity(
          equipmentId: equipment.equipmentId,
          startDate: occasionDate,
          endDate: occasionDate,
          excludeOccasionId: excludeOccasionId,
        );

        if (equipment.quantity > availableQuantity) {
          hasConflicts = true;
          conflicts.add({
            'equipmentId': equipment.equipmentId,
            'equipmentName': equipment.equipmentName,
            'requested': equipment.quantity,
            'available': availableQuantity,
            'conflict': equipment.quantity - availableQuantity,
          });
        }
      }

      return {
        'isValid': !hasConflicts,
        'conflicts': conflicts,
      };
    } catch (e) {
      throw 'Failed to validate equipment booking: $e';
    }
  }

  /// Get equipment availability report for a date range
  Future<Map<String, dynamic>> getEquipmentAvailabilityReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all equipment
      QuerySnapshot equipmentSnapshot = await _firestore
          .collection(_equipmentCollection)
          .where('isActive', isEqualTo: true)
          .get();

      List<EquipmentModel> allEquipment = equipmentSnapshot.docs
          .map((doc) => EquipmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Get booked quantities
      Map<String, int> bookedQuantities = await checkEquipmentAvailability(
        startDate: startDate,
        endDate: endDate,
      );

      // Create availability report
      List<Map<String, dynamic>> availabilityReport = [];

      for (var equipment in allEquipment) {
        int bookedQuantity = bookedQuantities[equipment.id] ?? 0;
        int availableQuantity = equipment.totalQuantity - bookedQuantity;

        availabilityReport.add({
          'equipment': equipment,
          'totalQuantity': equipment.totalQuantity,
          'bookedQuantity': bookedQuantity,
          'availableQuantity': availableQuantity,
          'utilizationRate': equipment.totalQuantity > 0
              ? (bookedQuantity / equipment.totalQuantity) * 100
              : 0.0,
        });
      }

      // Sort by utilization rate (highest first)
      availabilityReport.sort((a, b) =>
          b['utilizationRate'].compareTo(a['utilizationRate']));

      return {
        'report': availabilityReport,
        'totalEquipmentTypes': allEquipment.length,
        'fullyBookedTypes': availabilityReport.where((item) =>
        item['availableQuantity'] == 0).length,
      };
    } catch (e) {
      throw 'Failed to generate equipment availability report: $e';
    }
  }

  /// Auto-checkout equipment when occasion starts
  Future<void> autoCheckoutEquipmentForOccasion({
    required String occasionId,
    required String employeeId,
    required String employeeName,
  }) async {
    try {
      // Get occasion details
      DocumentSnapshot occasionDoc = await _firestore
          .collection(_occasionsCollection)
          .doc(occasionId)
          .get();

      if (!occasionDoc.exists) {
        throw 'Occasion not found';
      }

      OccasionModel occasion = OccasionModel.fromMap(
        occasionDoc.data() as Map<String, dynamic>,
        occasionDoc.id,
      );

      // Create checkout records for all equipment
      WriteBatch batch = _firestore.batch();

      for (var equipment in occasion.equipment) {
        // Create equipment checkout
        EquipmentCheckout checkout = EquipmentCheckout(
          id: '', // Will be set by Firestore
          equipmentId: equipment.equipmentId,
          employeeId: employeeId,
          employeeName: employeeName,
          quantity: equipment.quantity,
          checkoutDate: DateTime.now(),
          occasionId: occasionId,
          status: 'checked_out',
          notes: 'Auto-checkout for occasion: ${occasion.title}',
        );

        // Add checkout record to batch
        DocumentReference checkoutRef = _firestore
            .collection('equipment_checkouts')
            .doc();
        batch.set(checkoutRef, checkout.toMap());

        // Update equipment availability
        DocumentReference equipmentRef = _firestore
            .collection(_equipmentCollection)
            .doc(equipment.equipmentId);

        batch.update(equipmentRef, {
          'availableQuantity': FieldValue.increment(-equipment.quantity),
          'updatedAt': DateTime.now(),
        });

        // Update occasion equipment status
        List<Map<String, dynamic>> updatedEquipment = occasion.equipment.map((eq) {
          if (eq.equipmentId == equipment.equipmentId) {
            return eq.copyWith(
              status: 'checked_out',
              checkoutDate: DateTime.now(),
            ).toMap();
          }
          return eq.toMap();
        }).toList();

        batch.update(
          _firestore.collection(_occasionsCollection).doc(occasionId),
          {
            'equipment': updatedEquipment,
            'updatedAt': DateTime.now(),
          },
        );
      }

      // Execute batch
      await batch.commit();
    } catch (e) {
      throw 'Failed to auto-checkout equipment: $e';
    }
  }

  /// Auto-return equipment when occasion ends
  Future<void> autoReturnEquipmentForOccasion(String occasionId) async {
    try {
      // Get all checkouts for this occasion
      QuerySnapshot checkoutsSnapshot = await _firestore
          .collection('equipment_checkouts')
          .where('occasionId', isEqualTo: occasionId)
          .where('status', isEqualTo: 'checked_out')
          .get();

      if (checkoutsSnapshot.docs.isEmpty) {
        return; // No equipment to return
      }

      WriteBatch batch = _firestore.batch();

      for (var doc in checkoutsSnapshot.docs) {
        EquipmentCheckout checkout = EquipmentCheckout.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Update checkout status
        batch.update(doc.reference, {
          'status': 'returned',
          'returnDate': DateTime.now(),
        });

        // Update equipment availability
        DocumentReference equipmentRef = _firestore
            .collection(_equipmentCollection)
            .doc(checkout.equipmentId);

        batch.update(equipmentRef, {
          'availableQuantity': FieldValue.increment(checkout.quantity),
          'updatedAt': DateTime.now(),
        });
      }

      // Update occasion equipment status
      DocumentSnapshot occasionDoc = await _firestore
          .collection(_occasionsCollection)
          .doc(occasionId)
          .get();

      if (occasionDoc.exists) {
        OccasionModel occasion = OccasionModel.fromMap(
          occasionDoc.data() as Map<String, dynamic>,
          occasionDoc.id,
        );

        List<Map<String, dynamic>> updatedEquipment = occasion.equipment.map((eq) {
          return eq.copyWith(
            status: 'returned',
            returnDate: DateTime.now(),
          ).toMap();
        }).toList();

        batch.update(occasionDoc.reference, {
          'equipment': updatedEquipment,
          'updatedAt': DateTime.now(),
        });
      }

      // Execute batch
      await batch.commit();
    } catch (e) {
      throw 'Failed to auto-return equipment: $e';
    }
  }

  /// Get upcoming equipment checkouts (for reminders)
  Future<List<Map<String, dynamic>>> getUpcomingEquipmentCheckouts() async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      QuerySnapshot occasionsSnapshot = await _firestore
          .collection(_occasionsCollection)
          .where('date', isGreaterThanOrEqualTo: now)
          .where('date', isLessThanOrEqualTo: tomorrow)
          .where('status', whereIn: ['planned', 'confirmed'])
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> upcomingCheckouts = [];

      for (var doc in occasionsSnapshot.docs) {
        OccasionModel occasion = OccasionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        if (occasion.equipment.isNotEmpty) {
          upcomingCheckouts.add({
            'occasion': occasion,
            'equipmentCount': occasion.equipment.length,
            'totalItems': occasion.equipment.fold(0, (sum, eq) => sum + eq.quantity),
            'hoursUntil': occasion.date.difference(now).inHours,
          });
        }
      }

      // Sort by date
      upcomingCheckouts.sort((a, b) =>
          (a['occasion'] as OccasionModel).date.compareTo((b['occasion'] as OccasionModel).date));

      return upcomingCheckouts;
    } catch (e) {
      throw 'Failed to get upcoming equipment checkouts: $e';
    }
  }

  /// Helper method to check if two date ranges overlap
  bool _datesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2.add(const Duration(days: 1))) &&
        end1.isAfter(start2.subtract(const Duration(days: 1)));
  }

  /// Get equipment booking calendar data
  Future<Map<String, List<Map<String, dynamic>>>> getEquipmentBookingCalendar({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      QuerySnapshot occasionsSnapshot = await _firestore
          .collection(_occasionsCollection)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('status', whereIn: ['planned', 'confirmed', 'in_progress'])
          .where('isActive', isEqualTo: true)
          .orderBy('date')
          .get();

      Map<String, List<Map<String, dynamic>>> calendar = {};

      for (var doc in occasionsSnapshot.docs) {
        OccasionModel occasion = OccasionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        String dateKey = '${occasion.date.year}-${occasion.date.month.toString().padLeft(2, '0')}-${occasion.date.day.toString().padLeft(2, '0')}';

        if (!calendar.containsKey(dateKey)) {
          calendar[dateKey] = [];
        }

        calendar[dateKey]!.add({
          'occasion': occasion,
          'equipmentSummary': _generateEquipmentSummary(occasion.equipment),
        });
      }

      return calendar;
    } catch (e) {
      throw 'Failed to get equipment booking calendar: $e';
    }
  }

  /// Generate equipment summary for calendar display
  Map<String, int> _generateEquipmentSummary(List<OccasionEquipment> equipment) {
    Map<String, int> summary = {};

    for (var eq in equipment) {
      summary[eq.equipmentName] = (summary[eq.equipmentName] ?? 0) + eq.quantity;
    }

    return summary;
  }
}