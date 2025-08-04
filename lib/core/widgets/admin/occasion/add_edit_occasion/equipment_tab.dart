// core/widgets/admin/occasion/add_edit_occasion/equipment_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/equipment_model.dart';
import '../../../../../models/occasion_model.dart';
import '../../../../../providers/equipment_booking_provider.dart';
import '../../../../../providers/stock_provider.dart';
import '../../../../../core/widgets/equipment_availability_widget.dart';

class EquipmentTab extends StatelessWidget {
  final List<OccasionEquipment> selectedEquipment;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String? occasionId;
  final Function(EquipmentModel, int) onEquipmentUpdated;

  const EquipmentTab({
    super.key,
    required this.selectedEquipment,
    required this.selectedDate,
    required this.selectedTime,
    required this.occasionId,
    required this.onEquipmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<StockProvider, EquipmentBookingProvider>(
      builder: (context, stockProvider, bookingProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableEquipment = stockProvider.getAvailableEquipment();
        final groupedEquipment = <String, List<EquipmentModel>>{};

        for (var equipment in availableEquipment) {
          groupedEquipment.putIfAbsent(
              equipment.category,
                  () => []
          ).add(equipment);
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: EquipmentAvailabilityWidget(
                occasionDate: DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                ),
                selectedEquipment: selectedEquipment,
                onEquipmentChanged: (updatedEquipment) {
                  // Update parent state through callback
                  for (var eq in updatedEquipment) {
                    final equipment = stockProvider.getEquipmentById(eq.equipmentId);
                    if (equipment != null) {
                      onEquipmentUpdated(equipment, eq.quantity);
                    }
                  }
                },
                excludeOccasionId: occasionId,
              ),
            ),
            Expanded(
              child: _EquipmentList(
                groupedEquipment: groupedEquipment,
                selectedEquipment: selectedEquipment,
                onEquipmentUpdated: onEquipmentUpdated,
                stockProvider: stockProvider,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EquipmentList extends StatefulWidget {
  final Map<String, List<EquipmentModel>> groupedEquipment;
  final List<OccasionEquipment> selectedEquipment;
  final Function(EquipmentModel, int) onEquipmentUpdated;
  final StockProvider stockProvider;

  const _EquipmentList({
    required this.groupedEquipment,
    required this.selectedEquipment,
    required this.onEquipmentUpdated,
    required this.stockProvider,
  });

  @override
  State<_EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<_EquipmentList> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (widget.selectedEquipment.isNotEmpty) ...[
            _SelectedEquipmentSummary(
              selectedEquipment: widget.selectedEquipment,
              stockProvider: widget.stockProvider,
              onEquipmentUpdated: widget.onEquipmentUpdated,
            ),
            const SizedBox(height: 16),
          ],
          // Search and category tabs would go here
          ...widget.groupedEquipment.entries
              .where((entry) => _selectedCategory == null ||
              entry.key == _selectedCategory)
              .map((entry) => _EquipmentCategory(
            category: entry.key,
            equipmentList: entry.value,
            selectedEquipment: widget.selectedEquipment,
            onEquipmentUpdated: widget.onEquipmentUpdated,
          ))
              .toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SelectedEquipmentSummary extends StatelessWidget {
  final List<OccasionEquipment> selectedEquipment;
  final StockProvider stockProvider;
  final Function(EquipmentModel, int) onEquipmentUpdated;

  const _SelectedEquipmentSummary({
    required this.selectedEquipment,
    required this.stockProvider,
    required this.onEquipmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Row(
          children: [
            const Icon(Icons.checklist, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(child: Text('Selected Equipment')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${selectedEquipment.length}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedEquipment.length,
              itemBuilder: (context, index) {
                final eq = selectedEquipment[index];
                final equipment = stockProvider.getEquipmentById(eq.equipmentId);
                if (equipment == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory, size: 18, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.equipmentName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (equipment.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                equipment.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => onEquipmentUpdated(equipment, eq.quantity - 1),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${eq.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: eq.quantity < equipment.availableQuantity
                                ? () => onEquipmentUpdated(equipment, eq.quantity + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCategory extends StatelessWidget {
  final String category;
  final List<EquipmentModel> equipmentList;
  final List<OccasionEquipment> selectedEquipment;
  final Function(EquipmentModel, int) onEquipmentUpdated;

  const _EquipmentCategory({
    required this.category,
    required this.equipmentList,
    required this.selectedEquipment,
    required this.onEquipmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        ...equipmentList.map((eq) => _EquipmentCard(
          equipment: eq,
          isSelected: selectedEquipment.any((e) => e.equipmentId == eq.id),
          selectedQuantity: selectedEquipment
              .firstWhere(
                (e) => e.equipmentId == eq.id,
            orElse: () => OccasionEquipment(
              equipmentId: eq.id,
              equipmentName: eq.name,
              quantity: 0,
              status: '',
            ),
          )
              .quantity,
          onQuantityChanged: (newQuantity) =>
              onEquipmentUpdated(eq, newQuantity),
        )),
      ],
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final bool isSelected;
  final int selectedQuantity;
  final Function(int) onQuantityChanged;

  const _EquipmentCard({
    required this.equipment,
    required this.isSelected,
    required this.selectedQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSelected) {
              onQuantityChanged(selectedQuantity - 1);
            } else if (equipment.availableQuantity > 0) {
              onQuantityChanged(1);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (equipment.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              equipment.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _AvailabilityBadge(equipment: equipment),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(height: 16),
                  _QuantityControls(
                    equipment: equipment,
                    quantity: selectedQuantity,
                    onQuantityChanged: onQuantityChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final EquipmentModel equipment;

  const _AvailabilityBadge({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: equipment.availableQuantity > 0
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${equipment.availableQuantity} available',
        style: TextStyle(
          color: equipment.availableQuantity > 0 ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final EquipmentModel equipment;
  final int quantity;
  final Function(int) onQuantityChanged;

  const _QuantityControls({
    required this.equipment,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Quantity:'),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onQuantityChanged(quantity - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.blue,
                  ),
                  Container(
                    width: 40,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: quantity < equipment.availableQuantity
                        ? () => onQuantityChanged(quantity + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: quantity < equipment.availableQuantity
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: quantity / equipment.totalQuantity,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              quantity <= equipment.availableQuantity
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: ${equipment.availableQuantity}/${equipment.totalQuantity}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () => onQuantityChanged(0),
                child: const Text('Remove All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}