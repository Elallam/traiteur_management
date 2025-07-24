import 'package:flutter/foundation.dart';

// Placeholder Stock Provider - Will be implemented in Phase 3
class StockProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Articles
  List<dynamic> _articles = [];
  List<dynamic> get articles => _articles;

  // Equipment
  List<dynamic> _equipment = [];
  List<dynamic> get equipment => _equipment;

  // Meals
  List<dynamic> _meals = [];
  List<dynamic> get meals => _meals;

  // Methods to be implemented in Phase 3
  Future<void> loadArticles() async {
    // TODO: Implement in Phase 3
  }

  Future<void> loadEquipment() async {
    // TODO: Implement in Phase 3
  }

  Future<void> loadMeals() async {
    // TODO: Implement in Phase 3
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}