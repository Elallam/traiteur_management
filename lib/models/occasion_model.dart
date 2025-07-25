class OccasionModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String address;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final List<OccasionMeal> meals;
  final List<OccasionEquipment> equipment;
  final double totalCost;
  final double totalPrice;
  final int expectedGuests;
  final String status; // planned, confirmed, in_progress, completed, cancelled
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  OccasionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.address,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.meals,
    required this.equipment,
    required this.totalCost,
    required this.totalPrice,
    required this.expectedGuests,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory OccasionModel.fromMap(Map<String, dynamic> map, String id) {
    return OccasionModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      address: map['address'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      clientEmail: map['clientEmail'] ?? '',
      meals: (map['meals'] as List<dynamic>?)
          ?.map((meal) => OccasionMeal.fromMap(meal))
          .toList() ?? [],
      equipment: (map['equipment'] as List<dynamic>?)
          ?.map((eq) => OccasionEquipment.fromMap(eq))
          .toList() ?? [],
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      expectedGuests: map['expectedGuests'] ?? 0,
      status: map['status'] ?? 'planned',
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'address': address,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'equipment': equipment.map((eq) => eq.toMap()).toList(),
      'totalCost': totalCost,
      'totalPrice': totalPrice,
      'expectedGuests': expectedGuests,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  // Create a copy with updated fields
  OccasionModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? address,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    List<OccasionMeal>? meals,
    List<OccasionEquipment>? equipment,
    double? totalCost,
    double? totalPrice,
    int? expectedGuests,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return OccasionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      address: address ?? this.address,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      meals: meals ?? this.meals,
      equipment: equipment ?? this.equipment,
      totalCost: totalCost ?? this.totalCost,
      totalPrice: totalPrice ?? this.totalPrice,
      expectedGuests: expectedGuests ?? this.expectedGuests,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate profit
  double get profit => totalPrice - totalCost;

  // Calculate profit percentage
  double get profitPercentage {
    if (totalCost == 0) return 0.0;
    return (profit / totalCost) * 100;
  }

  // Check if occasion is upcoming (within next 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 7;
  }

  // Check if occasion is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if occasion is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(date) && status != 'completed' && status != 'cancelled';
  }

  // Get days until occasion
  int get daysUntil => date.difference(DateTime.now()).inDays;

  @override
  String toString() {
    return 'OccasionModel(id: $id, title: $title, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OccasionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Occasion meal model
class OccasionMeal {
  final String mealId;
  final String mealName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OccasionMeal({
    required this.mealId,
    required this.mealName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OccasionMeal.fromMap(Map<String, dynamic> map) {
    return OccasionMeal(
      mealId: map['mealId'] ?? '',
      mealName: map['mealName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealId': mealId,
      'mealName': mealName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  @override
  String toString() {
    return 'OccasionMeal(meal: $mealName, quantity: $quantity)';
  }
}

// Occasion equipment model
class OccasionEquipment {
  final String equipmentId;
  final String equipmentName;
  final int quantity;
  final DateTime? checkoutDate;
  final DateTime? returnDate;
  final String status; // assigned, checked_out, returned

  OccasionEquipment({
    required this.equipmentId,
    required this.equipmentName,
    required this.quantity,
    this.checkoutDate,
    this.returnDate,
    required this.status,
  });

  factory OccasionEquipment.fromMap(Map<String, dynamic> map) {
    return OccasionEquipment(
      equipmentId: map['equipmentId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      quantity: map['quantity'] ?? 0,
      checkoutDate: map['checkoutDate']?.toDate(),
      returnDate: map['returnDate']?.toDate(),
      status: map['status'] ?? 'assigned',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'quantity': quantity,
      'checkoutDate': checkoutDate,
      'returnDate': returnDate,
      'status': status,
    };
  }

  OccasionEquipment copyWith({
    String? equipmentId,
    String? equipmentName,
    int? quantity,
    DateTime? checkoutDate,
    DateTime? returnDate,
    String? status,
  }) {
    return OccasionEquipment(
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      quantity: quantity ?? this.quantity,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'OccasionEquipment(equipment: $equipmentName, quantity: $quantity, status: $status)';
  }
}