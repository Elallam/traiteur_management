class EquipmentModel {
  final String id;
  final String name;
  final int totalQuantity;
  final int availableQuantity;
  final String category; // chairs, tables, utensils, decorations, etc.
  final String? description;
  final String? imagePath; // Changed from imageUrl to imagePath
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double? price;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.category,
    this.description,
    this.imagePath, // Updated parameter name
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.price,
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
      imagePath: map['imagePath'], // Updated field name
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      price: map['price'] ?? 0.0,
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
      'imagePath': imagePath, // Updated field name
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'price': price,
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
    String? imagePath, // Updated parameter name
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? price,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath, // Updated field
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
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


// Equipment checkout tracking model - UPDATED with approval workflow fields
class EquipmentCheckout {
  final String id;
  final String equipmentId;
  final String employeeId;
  final String employeeName;
  final int quantity;
  final DateTime? requestDate; // When the request was made
  final DateTime? checkoutDate; // When approved and checked out
  final DateTime? returnDate;
  final String? occasionId;
  final String status; // 'pending_approval', 'approved', 'rejected', 'checked_out', 'returned', 'overdue'
  final String? notes;
  final double? price;
  final String? requestId; // Group related requests together
  final String? equipmentName; // For easier notification display
  final String? approvedBy; // Admin who approved/rejected
  final DateTime? approvalDate; // When approved/rejected
  final String? rejectionReason; // If rejected, why

  EquipmentCheckout({
    required this.id,
    required this.equipmentId,
    required this.employeeId,
    required this.employeeName,
    required this.quantity,
    this.requestDate,
    this.checkoutDate,
    this.returnDate,
    this.occasionId,
    required this.status,
    this.notes,
    this.price,
    this.requestId,
    this.equipmentName,
    this.approvedBy,
    this.approvalDate,
    this.rejectionReason,
  });

  factory EquipmentCheckout.fromMap(Map<String, dynamic> map, String id) {
    return EquipmentCheckout(
      id: id,
      equipmentId: map['equipmentId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      quantity: map['quantity'] ?? 0,
      requestDate: map['requestDate']?.toDate(),
      checkoutDate: map['checkoutDate']?.toDate(),
      returnDate: map['returnDate']?.toDate(),
      occasionId: map['occasionId'],
      status: map['status'] ?? 'pending_approval',
      notes: map['notes'],
      price: map['price'] ?? 0.0,
      requestId: map['requestId'],
      equipmentName: map['equipmentName'],
      approvedBy: map['approvedBy'],
      approvalDate: map['approvalDate']?.toDate(),
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'quantity': quantity,
      'requestDate': requestDate,
      'checkoutDate': checkoutDate,
      'returnDate': returnDate,
      'occasionId': occasionId,
      'status': status,
      'notes': notes,
      'price': price,
      'requestId': requestId,
      'equipmentName': equipmentName,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate,
      'rejectionReason': rejectionReason,
    };
  }

  EquipmentCheckout copyWith({
    String? id,
    String? equipmentId,
    String? employeeId,
    String? employeeName,
    int? quantity,
    DateTime? requestDate,
    DateTime? checkoutDate,
    DateTime? returnDate,
    String? occasionId,
    String? status,
    String? notes,
    double? price,
    String? requestId,
    String? equipmentName,
    String? approvedBy,
    DateTime? approvalDate,
    String? rejectionReason,
  }) {
    return EquipmentCheckout(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      quantity: quantity ?? this.quantity,
      requestDate: requestDate ?? this.requestDate,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      returnDate: returnDate ?? this.returnDate,
      occasionId: occasionId ?? this.occasionId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      requestId: requestId ?? this.requestId,
      equipmentName: equipmentName ?? this.equipmentName,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Check if checkout is overdue (more than 7 days without return)
  bool get isOverdue {
    if (status == 'returned' || checkoutDate == null) return false;
    final daysSinceCheckout = DateTime.now().difference(checkoutDate!).inDays;
    return daysSinceCheckout > 7;
  }

  // Get duration since checkout
  Duration get checkoutDuration {
    if (checkoutDate == null) return Duration.zero;
    return DateTime.now().difference(checkoutDate!);
  }

  // Get duration since request
  Duration get requestDuration {
    if (requestDate == null) return Duration.zero;
    return DateTime.now().difference(requestDate!);
  }

  // Check if request is pending
  bool get isPending => status == 'pending_approval';

  // Check if approved
  bool get isApproved => ['approved', 'checked_out', 'returned'].contains(status);

  // Check if rejected
  bool get isRejected => status == 'rejected';

  // Check if checked out
  bool get isCheckedOut => status == 'checked_out';

  // Check if returned
  bool get isReturned => status == 'returned';
}