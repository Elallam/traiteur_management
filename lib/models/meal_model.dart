import 'package:traiteur_management/models/article_model.dart';

class MealModel {
  final String id;
  final String name;
  final String description;
  final List<MealIngredient> ingredients;
  final double calculatedPrice;
  final double sellingPrice;
  final String category; // appetizer, main, dessert, drink, etc.
  final int servings;
  final int preparationTime; // in minutes
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isAvailable;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calculatedPrice,
    required this.sellingPrice,
    required this.category,
    required this.servings,
    required this.preparationTime,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isAvailable = true,
  });

  // Convert from Firestore document
  factory MealModel.fromMap(Map<String, dynamic> map, String id) {
    return MealModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)
          ?.map((ingredient) => MealIngredient.fromMap(ingredient))
          .toList() ?? [],
      calculatedPrice: (map['calculatedPrice'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'main',
      servings: map['servings'] ?? 1,
      preparationTime: map['preparationTime'] ?? 0,
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ingredients': ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'calculatedPrice': calculatedPrice,
      'sellingPrice': sellingPrice,
      'category': category,
      'servings': servings,
      'preparationTime': preparationTime,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'isAvailable': isAvailable,
    };
  }

  // Create a copy with updated fields
  MealModel copyWith({
    String? id,
    String? name,
    String? description,
    List<MealIngredient>? ingredients,
    double? calculatedPrice,
    double? sellingPrice,
    String? category,
    int? servings,
    int? preparationTime,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isAvailable,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      calculatedPrice: calculatedPrice ?? this.calculatedPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      category: category ?? this.category,
      servings: servings ?? this.servings,
      preparationTime: preparationTime ?? this.preparationTime,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  // Calculate profit margin
  double get profitMargin => sellingPrice - calculatedPrice;

  // Calculate profit percentage
  double get profitPercentage {
    if (calculatedPrice == 0) return 0.0;
    return (profitMargin / calculatedPrice) * 100;
  }

  // Check if all ingredients are available
  bool canBePrepared(List<ArticleModel> availableArticles) {
    for (var ingredient in ingredients) {
      var article = availableArticles.firstWhere(
            (article) => article.id == ingredient.articleId,
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

      if (article.id.isEmpty || article.quantity < ingredient.quantity) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return 'MealModel(id: $id, name: $name, price: $sellingPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Meal ingredient model
class MealIngredient {
  final String articleId;
  final String articleName;
  final double quantity;
  final String unit;
  final double pricePerUnit;

  MealIngredient({
    required this.articleId,
    required this.articleName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
  });

  factory MealIngredient.fromMap(Map<String, dynamic> map) {
    return MealIngredient(
      articleId: map['articleId'] ?? '',
      articleName: map['articleName'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      pricePerUnit: (map['pricePerUnit'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'articleName': articleName,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
    };
  }

  // Calculate total cost for this ingredient
  double get totalCost => quantity * pricePerUnit;

  @override
  String toString() {
    return 'MealIngredient(article: $articleName, quantity: $quantity $unit)';
  }
}