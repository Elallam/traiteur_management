// category_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> loadCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .get();

      _categories.clear();
      _categories.addAll(
          snapshot.docs.map((doc) =>
              CategoryModel.fromMap(doc.data(), doc.id)
          ).toList()
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<CategoryModel> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  Future<String> addCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(category.toMap());

      final newCategory = category.copyWith(id: docRef.id);
      _categories.add(newCategory);
      notifyListeners();
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore
          .collection('categories')
          .doc(id)
          .delete();

      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<CategoryModel>> get categoriesStream {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            CategoryModel.fromMap(doc.data(), doc.id)
        ).toList()
    );
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      // First check local cache
      final localCategory = _categories.firstWhere(
            (category) => category.id == id,
        orElse: () => throw Exception('Category not found locally'),
      );
      return localCategory;
    } catch (_) {
      // If not found locally, fetch from Firestore
      try {
        final doc = await _firestore.collection('categories').doc(id).get();
        if (doc.exists) {
          final category = CategoryModel.fromMap(doc.data()!, doc.id);
          // Add to local cache
          if (!_categories.any((c) => c.id == category.id)) {
            _categories.add(category);
            notifyListeners();
          }
          return category;
        }
        return null;
      } catch (e) {
        return null;
      }
    }
  }
}