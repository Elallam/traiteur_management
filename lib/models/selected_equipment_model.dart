class SelectedEquipmentModel {
  final String equipmentId;
  final String equipmentName;
  int quantity;

  SelectedEquipmentModel({
    required this.equipmentId,
    required this.equipmentName,
    required this.quantity,
  });

  SelectedEquipmentModel copyWith({
    String? equipmentId,
    String? equipmentName,
    int? quantity,
  }) {
    return SelectedEquipmentModel(
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SelectedEquipmentModel &&
              runtimeType == other.runtimeType &&
              equipmentId == other.equipmentId;

  @override
  int get hashCode => equipmentId.hashCode;
}