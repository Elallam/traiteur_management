// CategoryModel_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String type; // 'article', 'meal', or 'equipment'
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'article',
      icon: map['icon'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}