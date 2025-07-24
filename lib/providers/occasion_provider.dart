import 'package:flutter/foundation.dart';

// Placeholder Occasion Provider - Will be implemented in Phase 3
class OccasionProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Occasions
  List<dynamic> _occasions = [];
  List<dynamic> get occasions => _occasions;

  // Methods to be implemented in Phase 3
  Future<void> loadOccasions() async {
    // TODO: Implement in Phase 3
  }

  Future<void> createOccasion(Map<String, dynamic> occasionData) async {
    // TODO: Implement in Phase 3
  }

  Future<void> updateOccasion(String id, Map<String, dynamic> occasionData) async {
    // TODO: Implement in Phase 3
  }

  Future<void> deleteOccasion(String id) async {
    // TODO: Implement in Phase 3
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}