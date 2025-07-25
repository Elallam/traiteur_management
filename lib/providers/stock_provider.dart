import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../models/equipment_model.dart';
import '../models/meal_model.dart';
import '../services/firestore_service.dart';

class StockProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Articles
  List<ArticleModel> _articles = [];
  List<ArticleModel> get articles => _articles;

  // Equipment
  List<EquipmentModel> _equipment = [];
  List<EquipmentModel> get equipment => _equipment;

  // Equipment Checkouts
  List<EquipmentCheckout> _equipmentCheckouts = [];
  List<EquipmentCheckout> get equipmentCheckouts => _equipmentCheckouts;

  // Meals
  List<MealModel> _meals = [];
  List<MealModel> get meals => _meals;

  // Categories
  List<String> get articleCategories {
    return _articles.map((article) => article.category).toSet().toList()..sort();
  }

  List<String> get equipmentCategories {
    return _equipment.map((equipment) => equipment.category).toSet().toList()..sort();
  }

  List<String> get mealCategories {
    return _meals.map((meal) => meal.category).toSet().toList()..sort();
  }

  // ==================== ARTICLES ====================

  /// Load all articles
  Future<void> loadArticles() async {
    _setLoading(true);
    _clearError();

    try {
      _articles = await _firestoreService.getArticles();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Add new article
  Future<bool> addArticle(ArticleModel article) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.addArticle(article);
      await loadArticles(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update article
  Future<bool> updateArticle(ArticleModel article) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateArticle(article);
      await loadArticles(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete article
  Future<bool> deleteArticle(String articleId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteArticle(articleId);
      await loadArticles(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update article quantity
  Future<bool> updateArticleQuantity(String articleId, int newQuantity) async {
    try {
      await _firestoreService.updateArticleQuantity(articleId, newQuantity);
      await loadArticles(); // Refresh the list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Get articles by category
  List<ArticleModel> getArticlesByCategory(String category) {
    return _articles.where((article) => article.category == category).toList();
  }

  /// Get low stock articles
  List<ArticleModel> getLowStockArticles() {
    return _articles.where((article) => article.isLowStock).toList();
  }

  /// Calculate total articles value
  double getTotalArticlesValue() {
    return _articles.fold(0.0, (sum, article) => sum + article.totalValue);
  }

  // ==================== EQUIPMENT ====================

  /// Load all equipment
  Future<void> loadEquipment() async {
    _setLoading(true);
    _clearError();

    try {
      _equipment = await _firestoreService.getEquipment();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Add new equipment
  Future<bool> addEquipment(EquipmentModel equipment) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.addEquipment(equipment);
      await loadEquipment(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update equipment
  Future<bool> updateEquipment(EquipmentModel equipment) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateEquipment(equipment);
      await loadEquipment(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete equipment
  Future<bool> deleteEquipment(String equipmentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteEquipment(equipmentId);
      await loadEquipment(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update equipment availability
  Future<bool> updateEquipmentAvailability(String equipmentId, int availableQuantity) async {
    try {
      await _firestoreService.updateEquipmentAvailability(equipmentId, availableQuantity);
      await loadEquipment(); // Refresh the list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Get equipment by category
  List<EquipmentModel> getEquipmentByCategory(String category) {
    return _equipment.where((equipment) => equipment.category == category).toList();
  }

  /// Get available equipment
  List<EquipmentModel> getAvailableEquipment() {
    return _equipment.where((equipment) => equipment.isAvailable).toList();
  }

  /// Get fully checked out equipment
  List<EquipmentModel> getFullyCheckedOutEquipment() {
    return _equipment.where((equipment) => equipment.isFullyCheckedOut).toList();
  }

  // ==================== EQUIPMENT CHECKOUTS ====================

  /// Load equipment checkouts by employee
  Future<void> loadEquipmentCheckoutsByEmployee(String employeeId) async {
    _setLoading(true);
    _clearError();

    try {
      _equipmentCheckouts = await _firestoreService.getEquipmentCheckoutsByEmployee(employeeId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Load active equipment checkouts
  Future<void> loadActiveEquipmentCheckouts() async {
    _setLoading(true);
    _clearError();

    try {
      _equipmentCheckouts = await _firestoreService.getActiveEquipmentCheckouts();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Checkout equipment
  Future<bool> checkoutEquipment({
    required String equipmentId,
    required String employeeId,
    required String employeeName,
    required int quantity,
    String? occasionId,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Find the equipment
      EquipmentModel? equipment = _equipment.firstWhere(
            (eq) => eq.id == equipmentId,
        orElse: () => throw 'Equipment not found',
      );

      // Check if enough quantity is available
      if (equipment.availableQuantity < quantity) {
        throw 'Not enough equipment available. Available: ${equipment.availableQuantity}, Requested: $quantity';
      }

      // Create checkout record
      EquipmentCheckout checkout = EquipmentCheckout(
        id: '', // Will be set by Firestore
        equipmentId: equipmentId,
        employeeId: employeeId,
        employeeName: employeeName,
        quantity: quantity,
        checkoutDate: DateTime.now(),
        occasionId: occasionId,
        status: 'checked_out',
        notes: notes,
      );

      // Add checkout record
      await _firestoreService.addEquipmentCheckout(checkout);

      // Update equipment availability
      int newAvailableQuantity = equipment.availableQuantity - quantity;
      await _firestoreService.updateEquipmentAvailability(equipmentId, newAvailableQuantity);

      // Refresh data
      await loadEquipment();
      await loadActiveEquipmentCheckouts();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Return equipment
  Future<bool> returnEquipment(String checkoutId) async {
    _setLoading(true);
    _clearError();

    try {
      // Find the checkout record
      EquipmentCheckout? checkout = _equipmentCheckouts.firstWhere(
            (c) => c.id == checkoutId,
        orElse: () => throw 'Checkout record not found',
      );

      // Find the equipment
      EquipmentModel? equipment = _equipment.firstWhere(
            (eq) => eq.id == checkout.equipmentId,
        orElse: () => throw 'Equipment not found',
      );

      // Update checkout status
      await _firestoreService.returnEquipment(checkoutId);

      // Update equipment availability
      int newAvailableQuantity = equipment.availableQuantity + checkout.quantity;
      await _firestoreService.updateEquipmentAvailability(equipment.id, newAvailableQuantity);

      // Refresh data
      await loadEquipment();
      await loadActiveEquipmentCheckouts();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Get overdue equipment checkouts
  Future<List<EquipmentCheckout>> getOverdueEquipmentCheckouts() async {
    try {
      return await _firestoreService.getOverdueEquipmentCheckouts();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // ==================== MEALS ====================

  /// Load all meals
  Future<void> loadMeals() async {
    _setLoading(true);
    _clearError();

    try {
      _meals = await _firestoreService.getMeals();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  /// Add new meal
  Future<bool> addMeal(MealModel meal) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.addMeal(meal);
      await loadMeals(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update meal
  Future<bool> updateMeal(MealModel meal) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.updateMeal(meal);
      await loadMeals(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete meal
  Future<bool> deleteMeal(String mealId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.deleteMeal(mealId);
      await loadMeals(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update meal availability
  Future<bool> updateMealAvailability(String mealId, bool isAvailable) async {
    try {
      await _firestoreService.updateMealAvailability(mealId, isAvailable);
      await loadMeals(); // Refresh the list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Get meals by category
  List<MealModel> getMealsByCategory(String category) {
    return _meals.where((meal) => meal.category == category).toList();
  }

  /// Get available meals
  List<MealModel> getAvailableMeals() {
    return _meals.where((meal) => meal.isAvailable).toList();
  }

  /// Calculate meal price based on ingredients
  double calculateMealPrice(List<MealIngredient> ingredients) {
    double totalCost = 0.0;

    for (var ingredient in ingredients) {
      // Find the article in our articles list
      ArticleModel? article = _articles.firstWhere(
            (a) => a.id == ingredient.articleId,
        orElse: () => ArticleModel(
          id: '',
          name: '',
          price: 0,
          quantity: 0,
          unit: '',
          category: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (article.id.isNotEmpty) {
        totalCost += ingredient.quantity * article.price;
      }
    }

    return totalCost;
  }

  /// Check if meal can be prepared with current stock
  bool canMealBePrepared(MealModel meal) {
    return meal.canBePrepared(_articles);
  }

  /// Get meals that can be prepared
  List<MealModel> getMealsThatCanBePrepared() {
    return _meals.where((meal) => meal.canBePrepared(_articles)).toList();
  }

  // ==================== ANALYTICS ====================

  /// Get stock summary
  Map<String, dynamic> getStockSummary() {
    int totalArticles = _articles.length;
    int lowStockArticles = getLowStockArticles().length;
    int totalEquipment = _equipment.length;
    int availableEquipment = getAvailableEquipment().length;
    int totalMeals = _meals.length;
    int availableMeals = getAvailableMeals().length;
    double totalStockValue = getTotalArticlesValue();

    return {
      'totalArticles': totalArticles,
      'lowStockArticles': lowStockArticles,
      'totalEquipment': totalEquipment,
      'availableEquipment': availableEquipment,
      'totalMeals': totalMeals,
      'availableMeals': availableMeals,
      'totalStockValue': totalStockValue,
    };
  }

  /// Get low stock alert count
  int getLowStockAlertCount() {
    return getLowStockArticles().length;
  }

  /// Get equipment utilization rate
  double getEquipmentUtilizationRate() {
    if (_equipment.isEmpty) return 0.0;

    int totalEquipmentCount = _equipment.fold(0, (sum, eq) => sum + eq.totalQuantity);
    int checkedOutCount = _equipment.fold(0, (sum, eq) => sum + eq.checkedOutQuantity);

    return totalEquipmentCount > 0 ? (checkedOutCount / totalEquipmentCount) * 100 : 0.0;
  }

  // ==================== SEARCH & FILTER ====================

  /// Search articles by name
  List<ArticleModel> searchArticles(String query) {
    return _articles
        .where((article) =>
    article.name.toLowerCase().contains(query.toLowerCase()) ||
        article.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Search equipment by name
  List<EquipmentModel> searchEquipment(String query) {
    return _equipment
        .where((equipment) =>
    equipment.name.toLowerCase().contains(query.toLowerCase()) ||
        equipment.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Search meals by name
  List<MealModel> searchMeals(String query) {
    return _meals
        .where((meal) =>
    meal.name.toLowerCase().contains(query.toLowerCase()) ||
        meal.category.toLowerCase().contains(query.toLowerCase()) ||
        meal.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ==================== LOAD ALL DATA ====================

  /// Load all stock data
  Future<void> loadAllStockData() async {
    await Future.wait([
      loadArticles(),
      loadEquipment(),
      loadMeals(),
      loadActiveEquipmentCheckouts(),
    ]);
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