import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/providers/stock_provider.dart';
import '../models/occasion_model.dart';
import '../models/meal_model.dart';
import '../models/equipment_model.dart';
import '../services/firestore_service.dart';

class OccasionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StockProvider _stockProvider = StockProvider();

  bool _isLoading = false;
  String? _errorMessage;

  String _currentSortField = 'date';
  bool _isSortAscending = true;


  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get currentSortField => _currentSortField;
  bool get isSortAscending => _isSortAscending;


  // Occasions
  List<OccasionModel> _occasions = [];
  List<OccasionModel> get occasions => _occasions;

  // Occasion statuses
  static const List<String> occasionStatuses = [
    'planned',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled'
  ];

  // ==================== OCCASIONS CRUD ====================

  /// Load all occasions
  Future<void> loadOccasions() async {
    _setLoading(true);
    _clearError();

    try {
      _occasions = await _firestoreService.getOccasions();
      sortOccasions(_currentSortField); // Apply current sorting
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Add new occasion
  Future<bool> addOccasion(OccasionModel occasion) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.addOccasion(occasion);
      await loadOccasions(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update occasion
  Future<bool> updateOccasion(OccasionModel occasion) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateOccasion(occasion);
      await loadOccasions(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete occasion
  Future<bool> deleteOccasion(String occasionId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteOccasion(occasionId);
      await loadOccasions(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update occasion status
  Future<bool> updateOccasionStatus(String occasionId, String status) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateOccasionStatus(occasionId, status);
      await loadOccasions(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==================== OCCASION FILTERING ====================

  /// Get occasions by status
  List<OccasionModel> getOccasionsByStatus(String status) {
    return _occasions.where((occasion) => occasion.status == status).toList();
  }

  /// Get upcoming occasions (next 30 days)
  List<OccasionModel> getUpcomingOccasions() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return _occasions.where((occasion) {
      return occasion.date.isAfter(now) &&
          occasion.date.isBefore(thirtyDaysFromNow) &&
          occasion.status != 'cancelled';
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get today's occasions
  List<OccasionModel> getTodaysOccasions() {
    return _occasions.where((occasion) => occasion.isToday).toList();
  }

  /// Get overdue occasions
  List<OccasionModel> getOverdueOccasions() {
    return _occasions.where((occasion) => occasion.isOverdue).toList();
  }

  /// Get completed occasions
  List<OccasionModel> getCompletedOccasions() {
    return _occasions.where((occasion) => occasion.status == 'completed').toList();
  }

  /// Get occasions by date range
  List<OccasionModel> getOccasionsByDateRange(DateTime startDate, DateTime endDate) {
    return _occasions.where((occasion) {
      return occasion.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          occasion.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // ==================== OCCASION CALCULATIONS ====================

  /// Calculate occasion totals
  Map<String, double> calculateOccasionTotals({
    required List<OccasionMeal> meals,
    required List<OccasionEquipment> equipment,
    required double equipmentCost,
    required double transportCost,
    required double profitMargin,
    required BuildContext context,
  }) {
    double totalMealCost = 0.0;
    double totalMealPrice = 0.0;
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    for (var meal in meals) {
      totalMealPrice += meal.totalPrice;
      // Note: We would need meal cost calculation here
      MealModel? m = stockProvider.getMealById(meal.mealId);
      totalMealCost += m!.calculatedPrice*meal.quantity;
    }

    //Todo: update the totalCost and totalPrice based on the given formula
    double totalCost = totalMealCost + equipmentCost + transportCost;
    double totalPrice = totalMealPrice + totalCost + totalCost*profitMargin/100;

    return {
      'totalCost': totalCost,
      'totalPrice': totalPrice,
      'profit': totalPrice - totalCost,
      'profitMargin': totalPrice > 0 ? ((totalPrice - totalCost) / totalPrice) * 100 : 0,
    };
  }

  /// Create occasion from form data
  OccasionModel createOccasion({
    required String title,
    required String description,
    required DateTime date,
    required String address,
    required String clientName,
    required String clientPhone,
    required String clientEmail,
    required List<OccasionMeal> meals,
    required List<OccasionEquipment> equipment,
    required int expectedGuests,
    required double equipmentCost,
    required double transportCost,
    required double profitMargin,
    String? notes,
    required BuildContext context,
  }) {
    final totals = calculateOccasionTotals(
        meals: meals,
        equipment: equipment,
        equipmentCost: equipmentCost,
        transportCost: transportCost,
        profitMargin: profitMargin,
        context: context
    );

    return OccasionModel(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      date: date,
      address: address,
      clientName: clientName,
      clientPhone: clientPhone,
      clientEmail: clientEmail,
      meals: meals,
      equipment: equipment,
      totalCost: totals['totalCost']!,
      totalPrice: totals['totalPrice']!,
      expectedGuests: expectedGuests,
      status: 'planned',
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ==================== ANALYTICS ====================

  /// Get occasion statistics
  Map<String, dynamic> getOccasionStatistics() {
    int totalOccasions = _occasions.length;
    int upcomingOccasions = getUpcomingOccasions().length;
    int todaysOccasions = getTodaysOccasions().length;
    int overdueOccasions = getOverdueOccasions().length;
    int completedOccasions = getCompletedOccasions().length;

    // Calculate revenue and profit from completed occasions
    List<OccasionModel> completed = getCompletedOccasions();
    double totalRevenue = completed.fold(0.0, (sum, occasion) => sum + occasion.totalPrice);
    double totalProfit = completed.fold(0.0, (sum, occasion) => sum + occasion.profit);

    // Status distribution
    Map<String, int> statusDistribution = {};
    for (String status in occasionStatuses) {
      statusDistribution[status] = getOccasionsByStatus(status).length;
    }

    return {
      'totalOccasions': totalOccasions,
      'upcomingOccasions': upcomingOccasions,
      'todaysOccasions': todaysOccasions,
      'overdueOccasions': overdueOccasions,
      'completedOccasions': completedOccasions,
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'averageOrderValue': completedOccasions > 0 ? totalRevenue / completedOccasions : 0,
      'statusDistribution': statusDistribution,
    };
  }

  /// Get monthly revenue
  Map<String, double> getMonthlyRevenue(int year) {
    Map<String, double> monthlyRevenue = {};

    for (int month = 1; month <= 12; month++) {
      String monthKey = '$year-${month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] = 0.0;
    }

    List<OccasionModel> yearOccasions = _occasions.where((occasion) {
      return occasion.date.year == year &&
          (occasion.status == 'completed' || occasion.status == 'in_progress');
    }).toList();

    for (var occasion in yearOccasions) {
      String monthKey = '${occasion.date.year}-${occasion.date.month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + occasion.totalPrice;
    }

    return monthlyRevenue;
  }

  /// Get profit report for date range
  Future<Map<String, dynamic>> getProfitReport(DateTime startDate, DateTime endDate) async {
    try {
      return await _firestoreService.getProfitReport(startDate, endDate);
    } catch (e) {
      _setError(e.toString());
      return {
        'totalRevenue': 0.0,
        'totalCost': 0.0,
        'totalProfit': 0.0,
        'profitMargin': 0.0,
        'totalOccasions': 0,
        'averageOrderValue': 0.0,
      };
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Search occasions
  List<OccasionModel> searchOccasions(String query) {
    return _occasions.where((occasion) {
      return occasion.title.toLowerCase().contains(query.toLowerCase()) ||
          occasion.clientName.toLowerCase().contains(query.toLowerCase()) ||
          occasion.address.toLowerCase().contains(query.toLowerCase()) ||
          occasion.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filter occasions by multiple criteria
  List<OccasionModel> filterOccasions({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? clientName,
  }) {
    return _occasions.where((occasion) {
      bool matchesStatus = status == null || occasion.status == status;
      bool matchesStartDate = startDate == null || occasion.date.isAfter(startDate.subtract(const Duration(days: 1)));
      bool matchesEndDate = endDate == null || occasion.date.isBefore(endDate.add(const Duration(days: 1)));
      bool matchesClient = clientName == null ||
          occasion.clientName.toLowerCase().contains(clientName.toLowerCase());

      return matchesStatus && matchesStartDate && matchesEndDate && matchesClient;
    }).toList();
  }

  // ==================== NOTIFICATIONS ====================

  /// Get occasions requiring attention
  List<Map<String, dynamic>> getOccasionsRequiringAttention() {
    List<Map<String, dynamic>> alerts = [];

    // Today's occasions
    for (var occasion in getTodaysOccasions()) {
      alerts.add({
        'type': 'today',
        'title': 'Today\'s Event',
        'message': '${occasion.title} is scheduled for today',
        'occasion': occasion,
        'priority': 'high',
      });
    }

    // Overdue occasions
    for (var occasion in getOverdueOccasions()) {
      alerts.add({
        'type': 'overdue',
        'title': 'Overdue Event',
        'message': '${occasion.title} is overdue (${occasion.daysUntil.abs()} days ago)',
        'occasion': occasion,
        'priority': 'urgent',
      });
    }

    // Upcoming occasions (next 3 days)
    List<OccasionModel> upcoming = getUpcomingOccasions()
        .where((occasion) => occasion.daysUntil <= 3 && occasion.daysUntil > 0)
        .toList();

    for (var occasion in upcoming) {
      alerts.add({
        'type': 'upcoming',
        'title': 'Upcoming Event',
        'message': '${occasion.title} is in ${occasion.daysUntil} day(s)',
        'occasion': occasion,
        'priority': 'medium',
      });
    }

    // Sort by priority: urgent > high > medium
    alerts.sort((a, b) {
      Map<String, int> priorityOrder = {'urgent': 3, 'high': 2, 'medium': 1};
      return priorityOrder[b['priority']]!.compareTo(priorityOrder[a['priority']]!);
    });

    return alerts;
  }

  /// Get alert count
  int getAlertCount() {
    return getOccasionsRequiringAttention().length;
  }

  void sortOccasions(String field, {bool? ascending}) {
    _currentSortField = field;
    _isSortAscending = ascending ?? !_isSortAscending;

    switch (field) {
      case 'date':
        _occasions.sort((a, b) => _isSortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case 'name':
        _occasions.sort((a, b) => _isSortAscending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'totalCost':
        _occasions.sort((a, b) => _isSortAscending
            ? a.totalCost.compareTo(b.totalCost)
            : b.totalCost.compareTo(a.totalCost));
        break;
      case 'totalPrice':
        _occasions.sort((a, b) => _isSortAscending
            ? a.totalPrice.compareTo(b.totalPrice)
            : b.totalPrice.compareTo(a.totalPrice));
        break;
      default:
        _occasions.sort((a, b) => a.date.compareTo(b.date));
    }

    notifyListeners();
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

  /// Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}