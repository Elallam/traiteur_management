class EquipmentModel {
  final String id;
  final String name;
  final int totalQuantity;
  final int availableQuantity;
  final String category; // chairs, tables, utensils, decorations, etc.
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.category,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory EquipmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EquipmentModel(
      id: id,
      name: map['name'] ?? '',
      totalQuantity: map['totalQuantity'] ?? 0,
      availableQuantity: map['availableQuantity'] ?? 0,
      category: map['category'] ?? 'other',
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalQuantity': totalQuantity,
      'availableQuantity': availableQuantity,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  // Create a copy with updated fields
  EquipmentModel copyWith({
    String? id,
    String? name,
    int? totalQuantity,
    int? availableQuantity,
    String? category,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate checked out quantity
  int get checkedOutQuantity => totalQuantity - availableQuantity;

  // Check if equipment is available
  bool get isAvailable => availableQuantity > 0;

  // Check if all equipment is checked out
  bool get isFullyCheckedOut => availableQuantity == 0;

  // Get availability percentage
  double get availabilityPercentage {
    if (totalQuantity == 0) return 0.0;
    return (availableQuantity / totalQuantity) * 100;
  }

  @override
  String toString() {
    return 'EquipmentModel(id: $id, name: $name, available: $availableQuantity/$totalQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EquipmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Equipment checkout tracking model
class EquipmentCheckout {
  final String id;
  final String equipmentId;
  final String employeeId;
  final String employeeName;
  final int quantity;
  final DateTime checkoutDate;
  final DateTime? returnDate;
  final String? occasionId;
  final String status; // 'checked_out', 'returned', 'overdue'
  final String? notes;

  EquipmentCheckout({
    required this.id,
    required this.equipmentId,
    required this.employeeId,
    required this.employeeName,
    required this.quantity,
    required this.checkoutDate,
    this.returnDate,
    this.occasionId,
    required this.status,
    this.notes,
  });

  factory EquipmentCheckout.fromMap(Map<String, dynamic> map, String id) {
    return EquipmentCheckout(
      id: id,
      equipmentId: map['equipmentId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      quantity: map['quantity'] ?? 0,
      checkoutDate: map['checkoutDate']?.toDate() ?? DateTime.now(),
      returnDate: map['returnDate']?.toDate(),
      occasionId: map['occasionId'],
      status: map['status'] ?? 'checked_out',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'quantity': quantity,
      'checkoutDate': checkoutDate,
      'returnDate': returnDate,
      'occasionId': occasionId,
      'status': status,
      'notes': notes,
    };
  }

  EquipmentCheckout copyWith({
    String? id,
    String? equipmentId,
    String? employeeId,
    String? employeeName,
    int? quantity,
    DateTime? checkoutDate,
    DateTime? returnDate,
    String? occasionId,
    String? status,
    String? notes,
  }) {
    return EquipmentCheckout(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      quantity: quantity ?? this.quantity,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      returnDate: returnDate ?? this.returnDate,
      occasionId: occasionId ?? this.occasionId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Check if checkout is overdue (more than 7 days without return)
  bool get isOverdue {
    if (status == 'returned') return false;
    final daysSinceCheckout = DateTime.now().difference(checkoutDate).inDays;
    return daysSinceCheckout > 7;
  }

  // Get duration since checkout
  Duration get checkoutDuration => DateTime.now().difference(checkoutDate);
}