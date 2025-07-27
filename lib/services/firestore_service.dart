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

  // ==================== EQUIPMENT OPERATIONS ====================

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

  /// Get equipment by ID
  Future<EquipmentModel> getEquipmentById(String equipmentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_equipmentCollection)
          .doc(equipmentId)
          .get();

      if (!doc.exists) {
        throw 'Equipment not found';
      }

      return EquipmentModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw 'Failed to get equipment: $e';
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

  /// Search equipment by name or description
  Future<List<EquipmentModel>> searchEquipment(String query) async {
    try {
      if (query.isEmpty) {
        return await getEquipment();
      }

      // Get all equipment and filter on client side (Firestore limitation)
      List<EquipmentModel> allEquipment = await getEquipment();

      String lowerQuery = query.toLowerCase();
      return allEquipment.where((equipment) =>
      equipment.name.toLowerCase().contains(lowerQuery) ||
          equipment.category.toLowerCase().contains(lowerQuery) ||
          (equipment.description?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();
    } catch (e) {
      throw 'Failed to search equipment: $e';
    }
  }

  /// Get equipment categories
  Future<List<String>> getEquipmentCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCollection)
          .where('isActive', isEqualTo: true)
          .get();

      Set<String> categories = {};
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      throw 'Failed to get equipment categories: $e';
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

  /// Check if equipment is available in requested quantity
  Future<bool> isEquipmentAvailable(String equipmentId, int requestedQuantity) async {
    try {
      EquipmentModel equipment = await getEquipmentById(equipmentId);
      return equipment.availableQuantity >= requestedQuantity;
    } catch (e) {
      return false;
    }
  }

  /// Equipment stream for real-time updates
  Stream<List<EquipmentModel>> getEquipmentStream() {
    return _firestore
        .collection(_equipmentCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EquipmentModel.fromMap(
      doc.data(),
      doc.id,
    ))
        .toList());
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

  /// Get equipment checkout by ID
  Future<EquipmentCheckout> getEquipmentCheckoutById(String checkoutId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .doc(checkoutId)
          .get();

      if (!doc.exists) {
        throw 'Equipment checkout not found';
      }

      return EquipmentCheckout.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw 'Failed to get equipment checkout: $e';
    }
  }

  /// Update equipment checkout
  Future<void> updateEquipmentCheckout(EquipmentCheckout checkout) async {
    try {
      await _firestore
          .collection(_equipmentCheckoutsCollection)
          .doc(checkout.id)
          .update(checkout.toMap());
    } catch (e) {
      throw 'Failed to update equipment checkout: $e';
    }
  }

  /// Get equipment checkouts by employee (updated method name for consistency)
  Future<List<EquipmentCheckout>> getEmployeeCheckouts(String employeeId) async {
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

  /// Get all equipment checkouts (for admin)
  Future<List<EquipmentCheckout>> getAllEquipmentCheckouts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .orderBy('checkoutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get equipment checkouts: $e';
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

  /// Get overdue equipment checkouts
  Future<List<EquipmentCheckout>> getOverdueCheckouts() async {
    try {
      // Get all active checkouts first
      List<EquipmentCheckout> activeCheckouts = await getActiveEquipmentCheckouts();

      // Filter for overdue items (more than 7 days)
      DateTime overdueThreshold = DateTime.now().subtract(const Duration(days: 7));

      return activeCheckouts
          .where((checkout) => checkout.checkoutDate.isBefore(overdueThreshold))
          .toList();
    } catch (e) {
      throw 'Failed to get overdue checkouts: $e';
    }
  }

  /// Get equipment checkouts for specific equipment
  Future<List<EquipmentCheckout>> getEquipmentCheckouts(String equipmentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('equipmentId', isEqualTo: equipmentId)
          .orderBy('checkoutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get equipment checkouts: $e';
    }
  }

  /// Get equipment checkouts for specific occasion
  Future<List<EquipmentCheckout>> getOccasionCheckouts(String occasionId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('occasionId', isEqualTo: occasionId)
          .orderBy('checkoutDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get occasion checkouts: $e';
    }
  }

  /// Return equipment (enhanced method)
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

  /// Delete equipment checkout
  Future<void> deleteEquipmentCheckout(String checkoutId) async {
    try {
      await _firestore
          .collection(_equipmentCheckoutsCollection)
          .doc(checkoutId)
          .delete();
    } catch (e) {
      throw 'Failed to delete equipment checkout: $e';
    }
  }

  /// Get employee checkouts stream for real-time updates
  Stream<List<EquipmentCheckout>> getEmployeeCheckoutsStream(String employeeId) {
    return _firestore
        .collection(_equipmentCheckoutsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('checkoutDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EquipmentCheckout.fromMap(
      doc.data(),
      doc.id,
    ))
        .toList());
  }

  /// Get active checkouts stream for real-time updates
  Stream<List<EquipmentCheckout>> getActiveCheckoutsStream() {
    return _firestore
        .collection(_equipmentCheckoutsCollection)
        .where('status', isEqualTo: 'checked_out')
        .orderBy('checkoutDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EquipmentCheckout.fromMap(
      doc.data(),
      doc.id,
    ))
        .toList());
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch update equipment availability (for performance)
  Future<void> batchUpdateEquipmentAvailability(
      List<Map<String, dynamic>> updates) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (Map<String, dynamic> update in updates) {
        DocumentReference docRef = _firestore
            .collection(_equipmentCollection)
            .doc(update['equipmentId']);

        batch.update(docRef, {
          'availableQuantity': update['newAvailableQuantity'],
          'updatedAt': DateTime.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch update equipment availability: $e';
    }
  }

  /// Batch return equipment
  Future<void> batchReturnEquipment(List<String> checkoutIds) async {
    try {
      WriteBatch batch = _firestore.batch();
      DateTime returnDate = DateTime.now();

      for (String checkoutId in checkoutIds) {
        DocumentReference docRef = _firestore
            .collection(_equipmentCheckoutsCollection)
            .doc(checkoutId);

        batch.update(docRef, {
          'status': 'returned',
          'returnDate': returnDate,
        });
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch return equipment: $e';
    }
  }

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



  // ==================== VALIDATION HELPERS ====================

  /// Validate checkout request before processing
  Future<Map<String, dynamic>> validateCheckoutRequest(
      List<Map<String, dynamic>> checkoutItems) async {
    try {
      List<String> unavailableItems = [];
      bool isValid = true;

      for (Map<String, dynamic> item in checkoutItems) {
        String equipmentId = item['equipmentId'];
        int requestedQuantity = item['quantity'];

        bool available = await isEquipmentAvailable(equipmentId, requestedQuantity);
        if (!available) {
          EquipmentModel equipment = await getEquipmentById(equipmentId);
          unavailableItems.add(
              '${equipment.name} (requested: $requestedQuantity, available: ${equipment.availableQuantity})');
          isValid = false;
        }
      }

      return {
        'isValid': isValid,
        'unavailableItems': unavailableItems,
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': e.toString(),
        'unavailableItems': [],
      };
    }
  }

  // ==================== ANALYTICS AND REPORTING ====================

  /// Get equipment utilization statistics
  Future<Map<String, dynamic>> getEquipmentUtilizationStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all checkouts in date range
      QuerySnapshot checkoutsSnapshot = await _firestore
          .collection(_equipmentCheckoutsCollection)
          .where('checkoutDate', isGreaterThanOrEqualTo: startDate)
          .where('checkoutDate', isLessThanOrEqualTo: endDate)
          .get();

      List<EquipmentCheckout> checkouts = checkoutsSnapshot.docs
          .map((doc) => EquipmentCheckout.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      // Get all equipment
      List<EquipmentModel> allEquipment = await getEquipment();

      // Calculate utilization per equipment
      Map<String, dynamic> utilizationData = {};

      for (EquipmentModel equipment in allEquipment) {
        List<EquipmentCheckout> equipmentCheckouts = checkouts
            .where((checkout) => checkout.equipmentId == equipment.id)
            .toList();

        int totalDaysCheckedOut = 0;
        for (EquipmentCheckout checkout in equipmentCheckouts) {
          DateTime returnDate = checkout.returnDate ?? DateTime.now();
          int daysOut = returnDate.difference(checkout.checkoutDate).inDays + 1;
          totalDaysCheckedOut += (daysOut * checkout.quantity);
        }

        int totalPossibleDays = endDate.difference(startDate).inDays + 1;
        int maxPossibleUtilization = totalPossibleDays * equipment.totalQuantity;

        double utilizationRate = maxPossibleUtilization > 0
            ? (totalDaysCheckedOut / maxPossibleUtilization) * 100
            : 0.0;

        utilizationData[equipment.id] = {
          'equipmentName': equipment.name,
          'category': equipment.category,
          'totalQuantity': equipment.totalQuantity,
          'checkoutCount': equipmentCheckouts.length,
          'totalDaysOut': totalDaysCheckedOut,
          'utilizationRate': utilizationRate,
        };
      }

      return {
        'dateRange': {'start': startDate, 'end': endDate},
        'totalEquipment': allEquipment.length,
        'totalCheckouts': checkouts.length,
        'utilizationData': utilizationData,
      };
    } catch (e) {
      throw 'Failed to get utilization stats: $e';
    }
  }

  /// Get top utilized equipment
  Future<List<Map>> getTopUtilizedEquipment({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    try {
      Map<String, dynamic> stats = await getEquipmentUtilizationStats(
        startDate: startDate,
        endDate: endDate,
      );

      Map<String, dynamic> utilizationData = stats['utilizationData'];

      List<Map> sortedEquipment = utilizationData.entries
          .map((entry) => {
        'equipmentId': entry.key,
        ...entry.value,
      })
          .toList();

      sortedEquipment.sort((a, b) =>
          (b['utilizationRate'] as double).compareTo(a['utilizationRate'] as double));

      return sortedEquipment.take(limit).toList();
    } catch (e) {
      throw 'Failed to get top utilized equipment: $e';
    }
  }

  // ==================== ADDITIONAL HELPER METHODS ====================

  /// Get equipment dashboard stats for admin
  Future<Map<String, dynamic>> getEquipmentDashboardStats() async {
    try {
      List<EquipmentModel> allEquipment = await getEquipment();
      List<EquipmentCheckout> activeCheckouts = await getActiveEquipmentCheckouts();
      List<EquipmentCheckout> overdueCheckouts = await getOverdueCheckouts();

      int totalEquipment = allEquipment.length;
      int totalQuantity = allEquipment.fold(0, (sum, eq) => sum + eq.totalQuantity);
      int availableQuantity = allEquipment.fold(0, (sum, eq) => sum + eq.availableQuantity);
      int checkedOutQuantity = totalQuantity - availableQuantity;

      return {
        'totalEquipmentTypes': totalEquipment,
        'totalQuantity': totalQuantity,
        'availableQuantity': availableQuantity,
        'checkedOutQuantity': checkedOutQuantity,
        'activeCheckouts': activeCheckouts.length,
        'overdueCheckouts': overdueCheckouts.length,
        'utilizationRate': totalQuantity > 0 ? (checkedOutQuantity / totalQuantity) * 100 : 0.0,
      };
    } catch (e) {
      throw 'Failed to get equipment dashboard stats: $e';
    }
  }

  /// Get employee checkout summary
  Future<Map<String, dynamic>> getEmployeeCheckoutSummary(String employeeId) async {
    try {
      List<EquipmentCheckout> allCheckouts = await getEmployeeCheckouts(employeeId);

      int totalCheckouts = allCheckouts.length;
      int activeCheckouts = allCheckouts.where((c) => c.status == 'checked_out').length;
      int returnedItems = allCheckouts.where((c) => c.status == 'returned').length;
      int overdueItems = allCheckouts.where((c) => c.isOverdue).length;

      return {
        'totalCheckouts': totalCheckouts,
        'activeCheckouts': activeCheckouts,
        'returnedItems': returnedItems,
        'overdueItems': overdueItems,
      };
    } catch (e) {
      throw 'Failed to get employee checkout summary: $e';
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