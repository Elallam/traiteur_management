import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/equipment_model.dart';
import '../models/meal_model.dart';
import '../models/occasion_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _articlesCollection = 'articles';
  static const String _equipmentCollection = 'equipment';
  static const String _mealsCollection = 'meals';
  static const String _occasionsCollection = 'occasions';
  static const String _equipmentCheckoutsCollection = 'equipment_checkouts';

  // ==================== USERS ====================

  /// Get all users
  Future<List<UserModel>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch users: $e';
    }
  }

  /// Get employees only
  Future<List<UserModel>> getEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'employee')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch employees: $e';
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  /// Delete user (soft delete)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // ==================== ARTICLES ====================

  /// Get all articles
  Future<List<ArticleModel>> getArticles() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_articlesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch articles: $e';
    }
  }

  /// Get articles by category
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_articlesCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch articles by category: $e';
    }
  }

  /// Add new article
  Future<String> addArticle(ArticleModel article) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_articlesCollection)
          .add(article.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add article: $e';
    }
  }

  /// Update article
  Future<void> updateArticle(ArticleModel article) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(article.id)
          .update(article.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update article: $e';
    }
  }

  /// Delete article (soft delete)
  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to delete article: $e';
    }
  }

  /// Update article quantity
  Future<void> updateArticleQuantity(String articleId, int newQuantity) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(articleId)
          .update({
        'quantity': newQuantity,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update article quantity: $e';
    }
  }

  // ==================== EQUIPMENT ====================

  /// Get all equipment
  Future<List<EquipmentModel>> getEquipment() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => EquipmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch equipment: $e';
    }
  }

  /// Get equipment by category
  Future<List<EquipmentModel>> getEquipmentByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => EquipmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch equipment by category: $e';
    }
  }

  /// Add new equipment
  Future<String> addEquipment(EquipmentModel equipment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_equipmentCollection)
          .add(equipment.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add equipment: $e';
    }
  }

  /// Update equipment
  Future<void> updateEquipment(EquipmentModel equipment) async {
    try {
      await _firestore
          .collection(_equipmentCollection)
          .doc(equipment.id)
          .update(equipment.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update equipment: $e';
    }
  }

  /// Delete equipment (soft delete)
  Future<void> deleteEquipment(String equipmentId) async {
    try {
      await _firestore
          .collection(_equipmentCollection)
          .doc(equipmentId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to delete equipment: $e';
    }
  }

  /// Update equipment availability
  Future<void> updateEquipmentAvailability(String equipmentId, int availableQuantity) async {
    try {
      await _firestore
          .collection(_equipmentCollection)
          .doc(equipmentId)
          .update({
        'availableQuantity': availableQuantity,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update equipment availability: $e';
    }
  }

  // ==================== EQUIPMENT CHECKOUTS ====================

  /// Add equipment checkout
  Future<String> addEquipmentCheckout(EquipmentCheckout checkout) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .add(checkout.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add equipment checkout: $e';
    }
  }

  /// Get equipment checkouts by employee
  Future<List<EquipmentCheckout>> getEquipmentCheckoutsByEmployee(String employeeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('checkoutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch equipment checkouts: $e';
    }
  }

  /// Get active equipment checkouts
  Future<List<EquipmentCheckout>> getActiveEquipmentCheckouts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('status', isEqualTo: 'checked_out')
          .orderBy('checkoutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch active equipment checkouts: $e';
    }
  }

  /// Return equipment
  Future<void> returnEquipment(String checkoutId) async {
    try {
      await _firestore
          .collection(_equipmentCheckoutsCollection)
          .doc(checkoutId)
          .update({
        'status': 'returned',
        'returnDate': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to return equipment: $e';
    }
  }

  // ==================== MEALS ====================

  /// Get all meals
  Future<List<MealModel>> getMeals() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_mealsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => MealModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch meals: $e';
    }
  }

  /// Get meals by category
  Future<List<MealModel>> getMealsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_mealsCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => MealModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch meals by category: $e';
    }
  }

  /// Add new meal
  Future<String> addMeal(MealModel meal) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_mealsCollection)
          .add(meal.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add meal: $e';
    }
  }

  /// Update meal
  Future<void> updateMeal(MealModel meal) async {
    try {
      await _firestore
          .collection(_mealsCollection)
          .doc(meal.id)
          .update(meal.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update meal: $e';
    }
  }

  /// Delete meal (soft delete)
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore
          .collection(_mealsCollection)
          .doc(mealId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to delete meal: $e';
    }
  }

  /// Update meal availability
  Future<void> updateMealAvailability(String mealId, bool isAvailable) async {
    try {
      await _firestore
          .collection(_mealsCollection)
          .doc(mealId)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update meal availability: $e';
    }
  }

  // ==================== OCCASIONS ====================

  /// Get all occasions
  Future<List<OccasionModel>> getOccasions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_occasionsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OccasionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch occasions: $e';
    }
  }

  /// Get occasions by status
  Future<List<OccasionModel>> getOccasionsByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_occasionsCollection)
          .where('status', isEqualTo: status)
          .where('isActive', isEqualTo: true)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => OccasionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch occasions by status: $e';
    }
  }

  /// Get upcoming occasions (next 30 days)
  Future<List<OccasionModel>> getUpcomingOccasions() async {
    try {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      QuerySnapshot snapshot = await _firestore
          .collection(_occasionsCollection)
          .where('date', isGreaterThanOrEqualTo: now)
          .where('date', isLessThanOrEqualTo: thirtyDaysFromNow)
          .where('isActive', isEqualTo: true)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => OccasionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch upcoming occasions: $e';
    }
  }

  /// Add new occasion
  Future<String> addOccasion(OccasionModel occasion) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_occasionsCollection)
          .add(occasion.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add occasion: $e';
    }
  }

  /// Update occasion
  Future<void> updateOccasion(OccasionModel occasion) async {
    try {
      await _firestore
          .collection(_occasionsCollection)
          .doc(occasion.id)
          .update(occasion.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update occasion: $e';
    }
  }

  /// Delete occasion (soft delete)
  Future<void> deleteOccasion(String occasionId) async {
    try {
      await _firestore
          .collection(_occasionsCollection)
          .doc(occasionId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to delete occasion: $e';
    }
  }

  /// Update occasion status
  Future<void> updateOccasionStatus(String occasionId, String status) async {
    try {
      await _firestore
          .collection(_occasionsCollection)
          .doc(occasionId)
          .update({
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update occasion status: $e';
    }
  }

  // ==================== ANALYTICS & REPORTS ====================

  /// Get profit report for date range
  Future<Map<String, dynamic>> getProfitReport(DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_occasionsCollection)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('status', whereIn: ['completed', 'in_progress'])
          .where('isActive', isEqualTo: true)
          .get();

      List<OccasionModel> occasions = snapshot.docs
          .map((doc) => OccasionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      double totalRevenue = 0;
      double totalCost = 0;
      int totalOccasions = occasions.length;

      for (var occasion in occasions) {
        totalRevenue += occasion.totalPrice;
        totalCost += occasion.totalCost;
      }

      double totalProfit = totalRevenue - totalCost;
      double profitMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;

      return {
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'totalProfit': totalProfit,
        'profitMargin': profitMargin,
        'totalOccasions': totalOccasions,
        'averageOrderValue': totalOccasions > 0 ? totalRevenue / totalOccasions : 0,
      };
    } catch (e) {
      throw 'Failed to generate profit report: $e';
    }
  }

  /// Get low stock articles
  Future<List<ArticleModel>> getLowStockArticles() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_articlesCollection)
          .where('quantity', isLessThan: 10)
          .where('isActive', isEqualTo: true)
          .orderBy('quantity')
          .get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch low stock articles: $e';
    }
  }

  /// Get overdue equipment checkouts
  Future<List<EquipmentCheckout>> getOverdueEquipmentCheckouts() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('status', isEqualTo: 'checked_out')
          .where('checkoutDate', isLessThan: sevenDaysAgo)
          .orderBy('checkoutDate')
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch overdue equipment checkouts: $e';
    }
  }

  // ==================== REAL-TIME STREAMS ====================

  /// Stream articles
  Stream<List<ArticleModel>> streamArticles() {
    return _firestore
        .collection(_articlesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Stream equipment
  Stream<List<EquipmentModel>> streamEquipment() {
    return _firestore
        .collection(_equipmentCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EquipmentModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Stream meals
  Stream<List<MealModel>> streamMeals() {
    return _firestore
        .collection(_mealsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Stream occasions
  Stream<List<OccasionModel>> streamOccasions() {
    return _firestore
        .collection(_occasionsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => OccasionModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Stream employee equipment checkouts
  Stream<List<EquipmentCheckout>> streamEmployeeCheckouts(String employeeId) {
    return _firestore
        .collection(_equipmentCheckoutsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('checkoutDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EquipmentCheckout.fromMap(doc.data(), doc.id))
        .toList());
  }
}