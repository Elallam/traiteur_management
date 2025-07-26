// lib/providers/equipment_booking_provider.dart
import 'package:flutter/foundation.dart';
import '../models/equipment_model.dart';
import '../models/occasion_model.dart';
import '../services/equipment_booking_service.dart';
import '../services/firestore_service.dart';

class EquipmentBookingProvider extends ChangeNotifier {
  final EquipmentBookingService _bookingService = EquipmentBookingService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Equipment availability data
  Map<String, int> _equipmentAvailability = {};
  Map<String, int> get equipmentAvailability => _equipmentAvailability;

  // Equipment booking calendar
  Map<String, List<Map<String, dynamic>>> _bookingCalendar = {};
  Map<String, List<Map<String, dynamic>>> get bookingCalendar => _bookingCalendar;

  // Availability report
  List<Map<String, dynamic>> _availabilityReport = [];
  List<Map<String, dynamic>> get availabilityReport => _availabilityReport;

  // ==================== EQUIPMENT AVAILABILITY ====================

  /// Check equipment availability for date range
  Future<void> checkEquipmentAvailability({
    required DateTime startDate,
    required DateTime endDate,
    String? excludeOccasionId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _equipmentAvailability = await _bookingService.checkEquipmentAvailability(
        startDate: startDate,
        endDate: endDate,
        excludeOccasionId: excludeOccasionId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Get available quantity for specific equipment
  Future<int> getAvailableQuantity({
    required String equipmentId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeOccasionId,
  }) async {
    try {
      return await _bookingService.getAvailableQuantity(
        equipmentId: equipmentId,
        startDate: startDate,
        endDate: endDate,
        excludeOccasionId: excludeOccasionId,
      );
    } catch (e) {
      _setError(e.toString());
      return 0;
    }
  }

  /// Validate equipment booking
  Future<Map<String, dynamic>> validateEquipmentBooking({
    required List<OccasionEquipment> equipment,
    required DateTime occasionDate,
    String? excludeOccasionId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _bookingService.validateEquipmentBooking(
        requestedEquipment: equipment,
        occasionDate: occasionDate,
        excludeOccasionId: excludeOccasionId,
      );
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {
        'isValid': false,
        'conflicts': [],
        'error': e.toString(),
      };
    }
  }

  /// Generate equipment availability report
  Future<void> generateAvailabilityReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final reportData = await _bookingService.getEquipmentAvailabilityReport(
        startDate: startDate,
        endDate: endDate,
      );

      _availabilityReport = reportData['report'] as List<Map<String, dynamic>>;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // ==================== EQUIPMENT CHECKOUT AUTOMATION ====================

  /// Auto-checkout equipment when occasion starts
  Future<bool> autoCheckoutEquipment({
    required String occasionId,
    required String employeeId,
    required String employeeName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _bookingService.autoCheckoutEquipmentForOccasion(
        occasionId: occasionId,
        employeeId: employeeId,
        employeeName: employeeName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Auto-return equipment when occasion ends
  Future<bool> autoReturnEquipment(String occasionId) async {
    _setLoading(true);
    _clearError();

    try {
      await _bookingService.autoReturnEquipmentForOccasion(occasionId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==================== BOOKING CALENDAR ====================

  /// Load equipment booking calendar
  Future<void> loadBookingCalendar({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _bookingCalendar = await _bookingService.getEquipmentBookingCalendar(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Get occasions for specific date
  List<Map<String, dynamic>> getOccasionsForDate(DateTime date) {
    String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _bookingCalendar[dateKey] ?? [];
  }

  /// Check if date has equipment conflicts
  bool dateHasConflicts(DateTime date) {
    final occasions = getOccasionsForDate(date);

    // Simple conflict detection - if more than one occasion needs same equipment
    Map<String, int> equipmentDemand = {};

    for (var occasionData in occasions) {
      OccasionModel occasion = occasionData['occasion'];
      for (var equipment in occasion.equipment) {
        equipmentDemand[equipment.equipmentId] =
            (equipmentDemand[equipment.equipmentId] ?? 0) + equipment.quantity;
      }
    }

    // This is a simplified check - you'd need actual equipment quantities for full validation
    return occasions.length > 1 && equipmentDemand.isNotEmpty;
  }

  // ==================== UPCOMING CHECKOUTS ====================

  /// Get upcoming equipment checkouts
  Future<List<Map<String, dynamic>>> getUpcomingCheckouts() async {
    try {
      return await _bookingService.getUpcomingEquipmentCheckouts();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== EQUIPMENT SUGGESTIONS ====================

  /// Get alternative equipment suggestions when conflicts occur
  Future<List<Map<String, dynamic>>> getAlternativeEquipmentSuggestions({
    required List<OccasionEquipment> conflictedEquipment,
    required DateTime occasionDate,
  }) async {
    try {
      List<EquipmentModel> allEquipment = await _firestoreService.getEquipment();
      List<Map<String, dynamic>> suggestions = [];

      for (var conflicted in conflictedEquipment) {
        // Find equipment in same category
        EquipmentModel? originalEquipment = allEquipment.firstWhere(
              (eq) => eq.id == conflicted.equipmentId,
          orElse: () => EquipmentModel(
            id: '',
            name: '',
            totalQuantity: 0,
            availableQuantity: 0,
            category: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (originalEquipment.id.isEmpty) continue;

        // Find alternatives in same category
        List<EquipmentModel> alternatives = allEquipment.where((eq) =>
        eq.category == originalEquipment.category &&
            eq.id != originalEquipment.id &&
            eq.isActive
        ).toList();

        for (var alternative in alternatives) {
          int availableQuantity = await getAvailableQuantity(
            equipmentId: alternative.id,
            startDate: occasionDate,
            endDate: occasionDate,
          );

          if (availableQuantity >= conflicted.quantity) {
            suggestions.add({
              'original': conflicted,
              'alternative': alternative,
              'availableQuantity': availableQuantity,
              'category': alternative.category,
            });
          }
        }
      }

      return suggestions;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== ANALYTICS ====================

  /// Get equipment utilization statistics
  Future<Map<String, dynamic>> getEquipmentUtilizationStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportData = await _bookingService.getEquipmentAvailabilityReport(
        startDate: startDate,
        endDate: endDate,
      );

      List<Map<String, dynamic>> report = reportData['report'];

      double totalUtilization = 0.0;
      int equipmentCount = report.length;
      int fullyBookedCount = 0;
      int underutilizedCount = 0; // Less than 30% utilization

      for (var item in report) {
        double utilization = item['utilizationRate'];
        totalUtilization += utilization;

        if (utilization >= 100.0) {
          fullyBookedCount++;
        } else if (utilization < 30.0) {
          underutilizedCount++;
        }
      }

      return {
        'averageUtilization': equipmentCount > 0 ? totalUtilization / equipmentCount : 0.0,
        'totalEquipmentTypes': equipmentCount,
        'fullyBookedTypes': fullyBookedCount,
        'underutilizedTypes': underutilizedCount,
        'utilizationRate': fullyBookedCount > 0 ? (fullyBookedCount / equipmentCount) * 100 : 0.0,
        'report': report,
      };
    } catch (e) {
      _setError(e.toString());
      return {
        'averageUtilization': 0.0,
        'totalEquipmentTypes': 0,
        'fullyBookedTypes': 0,
        'underutilizedTypes': 0,
        'utilizationRate': 0.0,
        'report': [],
      };
    }
  }

  /// Get most popular equipment
  Future<List<Map<String, dynamic>>> getMostPopularEquipment({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportData = await _bookingService.getEquipmentAvailabilityReport(
        startDate: startDate,
        endDate: endDate,
      );

      List<Map<String, dynamic>> report = reportData['report'];

      // Sort by utilization rate (highest first)
      report.sort((a, b) => b['utilizationRate'].compareTo(a['utilizationRate']));

      // Return top 10
      return report.take(10).toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Get equipment-related alerts
  Future<List<Map<String, dynamic>>> getEquipmentAlerts() async {
    try {
      List<Map<String, dynamic>> alerts = [];

      // Get upcoming checkouts
      List<Map<String, dynamic>> upcomingCheckouts = await getUpcomingCheckouts();

      for (var checkout in upcomingCheckouts) {
        OccasionModel occasion = checkout['occasion'];
        int hoursUntil = checkout['hoursUntil'];

        if (hoursUntil <= 2) {
          alerts.add({
            'type': 'urgent_checkout',
            'title': 'Equipment Checkout Due',
            'message': 'Equipment for "${occasion.title}" needs checkout in $hoursUntil hour(s)',
            'occasionId': occasion.id,
            'priority': 'urgent',
            'data': checkout,
          });
        } else if (hoursUntil <= 24) {
          alerts.add({
            'type': 'upcoming_checkout',
            'title': 'Equipment Checkout Tomorrow',
            'message': 'Equipment for "${occasion.title}" needs checkout tomorrow',
            'occasionId': occasion.id,
            'priority': 'high',
            'data': checkout,
          });
        }
      }

      return alerts;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}