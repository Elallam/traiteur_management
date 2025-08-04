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
  final double equipmentPrice; // NEW: Total equipment rental price
  final double transportPrice; // NEW: Transport/delivery cost
  final double profitMarginPercentage; // NEW: Profit margin percentage
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
    this.equipmentPrice = 0.0, // NEW: Default to 0
    this.transportPrice = 0.0, // NEW: Default to 0
    this.profitMarginPercentage = 0.0, // NEW: Default to 0
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
      equipmentPrice: (map['equipmentPrice'] ?? 0.0).toDouble(), // NEW
      transportPrice: (map['transportPrice'] ?? 0.0).toDouble(), // NEW
      profitMarginPercentage: (map['profitMarginPercentage'] ?? 0.0).toDouble(), // NEW
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
      'equipmentPrice': equipmentPrice, // NEW
      'transportPrice': transportPrice, // NEW
      'profitMarginPercentage': profitMarginPercentage, // NEW
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
    double? equipmentPrice, // NEW
    double? transportPrice, // NEW
    double? profitMarginPercentage, // NEW
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
      equipmentPrice: equipmentPrice ?? this.equipmentPrice, // NEW
      transportPrice: transportPrice ?? this.transportPrice, // NEW
      profitMarginPercentage: profitMarginPercentage ?? this.profitMarginPercentage, // NEW
      expectedGuests: expectedGuests ?? this.expectedGuests,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate base cost (meals + equipment + transport)
  double get baseCost => totalCost + equipmentPrice + transportPrice;

  // Calculate profit using the profit margin percentage
  double get calculatedProfit => baseCost * (profitMarginPercentage / 100);

  // Calculate final total price including profit margin
  double get finalTotalPrice => baseCost + calculatedProfit;

  // Calculate actual profit (difference between total price and base cost)
  double get profit => totalPrice - baseCost;

  // Calculate actual profit percentage based on current prices
  double get actualProfitPercentage {
    if (baseCost == 0) return 0.0;
    return (profit / baseCost) * 100;
  }

  // Get meals total cost
  double get mealsCost => meals.fold(0.0, (sum, meal) => sum + meal.totalPrice);

  // Get breakdown of all costs
  Map<String, double> get costBreakdown => {
    'mealsCost': mealsCost,
    'equipmentPrice': equipmentPrice,
    'transportPrice': transportPrice,
    'baseCost': baseCost,
    'profitAmount': calculatedProfit,
    'finalTotal': finalTotalPrice,
  };

  // Legacy profit calculation for backward compatibility
  double get legacyProfit => totalPrice - totalCost;

  // Legacy profit percentage calculation for backward compatibility
  double get legacyProfitPercentage {
    if (totalCost == 0) return 0.0;
    return (legacyProfit / totalCost) * 100;
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
    return 'OccasionModel(id: $id, title: $title, date: $date, status: $status, equipmentPrice: $equipmentPrice, transportPrice: $transportPrice)';
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

// Occasion equipment model - UPDATED with price information
class OccasionEquipment {
  final String equipmentId;
  final String equipmentName;
  final int quantity;
  final double unitRentalPrice; // NEW: Price per unit for rental
  final double totalRentalPrice; // NEW: Total rental price for this equipment
  final DateTime? checkoutDate;
  final DateTime? returnDate;
  final String status; // assigned, checked_out, returned

  OccasionEquipment({
    required this.equipmentId,
    required this.equipmentName,
    required this.quantity,
    this.unitRentalPrice = 0.0, // NEW: Default to 0
    this.totalRentalPrice = 0.0, // NEW: Default to 0
    this.checkoutDate,
    this.returnDate,
    required this.status,
  });

  factory OccasionEquipment.fromMap(Map<String, dynamic> map) {
    return OccasionEquipment(
      equipmentId: map['equipmentId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitRentalPrice: (map['unitRentalPrice'] ?? 0.0).toDouble(), // NEW
      totalRentalPrice: (map['totalRentalPrice'] ?? 0.0).toDouble(), // NEW
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
      'unitRentalPrice': unitRentalPrice, // NEW
      'totalRentalPrice': totalRentalPrice, // NEW
      'checkoutDate': checkoutDate,
      'returnDate': returnDate,
      'status': status,
    };
  }

  OccasionEquipment copyWith({
    String? equipmentId,
    String? equipmentName,
    int? quantity,
    double? unitRentalPrice, // NEW
    double? totalRentalPrice, // NEW
    DateTime? checkoutDate,
    DateTime? returnDate,
    String? status,
  }) {
    return OccasionEquipment(
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      quantity: quantity ?? this.quantity,
      unitRentalPrice: unitRentalPrice ?? this.unitRentalPrice, // NEW
      totalRentalPrice: totalRentalPrice ?? this.totalRentalPrice, // NEW
      checkoutDate: checkoutDate ?? this.checkoutDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'OccasionEquipment(equipment: $equipmentName, quantity: $quantity, status: $status, rentalPrice: $totalRentalPrice)';
  }
}