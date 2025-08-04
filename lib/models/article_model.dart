class ArticleModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String unit; // kg, pieces, liters, etc.
  final String category; // fruits, vegetables, meat, dairy, etc.
  final String? description;
  final String? imagePath; // Changed from imageUrl to imagePath for local images
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ArticleModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.category,
    this.description,
    this.imagePath, // Updated parameter name
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    return ArticleModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'pieces',
      category: map['category'] ?? 'other',
      description: map['description'],
      imagePath: map['imagePath'], // Updated field name
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'description': description,
      'imagePath': imagePath, // Updated field name
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  // Create a copy with updated fields
  ArticleModel copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? unit,
    String? category,
    String? description,
    String? imagePath, // Updated parameter name
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath, // Updated field
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate total value
  double get totalValue => price * quantity;

  // Check if low stock (less than 10% of original quantity)
  bool get isLowStock => quantity < 10;

  @override
  String toString() {
    return 'ArticleModel(id: $id, name: $name, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArticleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
