// lib/core/widgets/equipment_availability_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../../models/equipment_model.dart';
import '../../models/occasion_model.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/stock_provider.dart';

class EquipmentAvailabilityWidget extends StatefulWidget {
  final DateTime occasionDate;
  final List<OccasionEquipment> selectedEquipment;
  final Function(List<OccasionEquipment>) onEquipmentChanged;
  final String? excludeOccasionId;

  const EquipmentAvailabilityWidget({
    Key? key,
    required this.occasionDate,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    this.excludeOccasionId,
  }) : super(key: key);

  @override
  State<EquipmentAvailabilityWidget> createState() => _EquipmentAvailabilityWidgetState();
}

class _EquipmentAvailabilityWidgetState extends State<EquipmentAvailabilityWidget> {
  Map<String, int> _availableQuantities = {};
  List<Map<String, dynamic>> _conflicts = [];
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateEquipmentAvailability();
    });
  }

  @override
  void didUpdateWidget(EquipmentAvailabilityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.occasionDate != widget.occasionDate ||
        oldWidget.selectedEquipment != widget.selectedEquipment) {
      _validateEquipmentAvailability();
    }
  }

  Future<void> _validateEquipmentAvailability() async {
    if (widget.selectedEquipment.isEmpty) {
      setState(() {
        _conflicts = [];
        _availableQuantities = {};
      });
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

      // Validate equipment booking
      final validation = await bookingProvider.validateEquipmentBooking(
        equipment: widget.selectedEquipment,
        occasionDate: widget.occasionDate,
        excludeOccasionId: widget.excludeOccasionId,
      );

      // Get individual availability for each equipment
      Map<String, int> availableQuantities = {};
      for (var equipment in widget.selectedEquipment) {
        int available = await bookingProvider.getAvailableQuantity(
          equipmentId: equipment.equipmentId,
          startDate: widget.occasionDate,
          endDate: widget.occasionDate,
          excludeOccasionId: widget.excludeOccasionId,
        );
        availableQuantities[equipment.equipmentId] = available;
      }

      setState(() {
        _conflicts = List<Map<String, dynamic>>.from(validation['conflicts'] ?? []);
        _availableQuantities = availableQuantities;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _conflicts = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking availability: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date and status
        _buildHeader(),
        const SizedBox(height: 16),

        // Availability status
        if (_isValidating)
          _buildLoadingIndicator()
        else if (_conflicts.isNotEmpty)
          _buildConflictsSection()
        else if (widget.selectedEquipment.isNotEmpty)
            _buildSuccessIndicator(),

        const SizedBox(height: 16),

        // Equipment list with availability
        _buildEquipmentList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: _conflicts.isEmpty && widget.selectedEquipment.isNotEmpty
                ? AppColors.success
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Equipment Availability Check',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(widget.occasionDate)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isValidating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_conflicts.isEmpty && widget.selectedEquipment.isNotEmpty)
            const Icon(Icons.check_circle, color: AppColors.success)
          else if (_conflicts.isNotEmpty)
              const Icon(Icons.error, color: AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Checking equipment availability...',
            style: TextStyle(color: AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Equipment Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '${widget.selectedEquipment.length} equipment item(s) can be booked for this date.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error, color: AppColors.error),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Equipment Availability Conflicts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: _showAlternativeSuggestions,
                child: const Text('View Alternatives'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_conflicts.map((conflict) => _buildConflictItem(conflict))),
        ],
      ),
    );
  }

  Widget _buildConflictItem(Map<String, dynamic> conflict) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: conflict['equipmentName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ': Requested ${conflict['requested']}, '
                        'Available ${conflict['available']} '
                        '(Short by ${conflict['conflict']})',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList() {
    if (widget.selectedEquipment.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.black),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No Equipment Selected',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Add equipment to check availability',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: widget.selectedEquipment.map((equipment) {
        int availableQuantity = _availableQuantities[equipment.equipmentId] ?? 0;
        bool hasConflict = _conflicts.any((c) => c['equipmentId'] == equipment.equipmentId);

        return _buildEquipmentAvailabilityCard(equipment, availableQuantity, hasConflict);
      }).toList(),
    );
  }

  Widget _buildEquipmentAvailabilityCard(
      OccasionEquipment equipment,
      int availableQuantity,
      bool hasConflict,
      ) {
    Color statusColor = hasConflict ? AppColors.error : AppColors.success;
    IconData statusIcon = hasConflict ? Icons.error : Icons.check_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.equipmentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Requested: ${equipment.quantity}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Available: $availableQuantity',
                        style: TextStyle(
                          color: hasConflict ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasConflict)
              TextButton(
                onPressed: () => _adjustQuantity(equipment, availableQuantity),
                child: const Text('Adjust'),
              ),
          ],
        ),
      ),
    );
  }

  void _adjustQuantity(OccasionEquipment equipment, int maxAvailable) {
    showDialog(
      context: context,
      builder: (context) => _QuantityAdjustDialog(
        equipment: equipment,
        maxAvailable: maxAvailable,
        onAdjust: (newQuantity) {
          List<OccasionEquipment> updatedEquipment = widget.selectedEquipment.map((eq) {
            if (eq.equipmentId == equipment.equipmentId) {
              return eq.copyWith(quantity: newQuantity);
            }
            return eq;
          }).toList();

          widget.onEquipmentChanged(updatedEquipment);
        },
      ),
    );
  }

  void _showAlternativeSuggestions() async {
    final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

    try {
      List<OccasionEquipment> conflictedEquipment = _conflicts
          .map((c) => widget.selectedEquipment.firstWhere(
            (eq) => eq.equipmentId == c['equipmentId'],
      ))
          .toList();

      List<Map<String, dynamic>> suggestions = await bookingProvider
          .getAlternativeEquipmentSuggestions(
        conflictedEquipment: conflictedEquipment,
        occasionDate: widget.occasionDate,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _AlternativeSuggestionsDialog(
          suggestions: suggestions,
          onSelectAlternative: (original, alternative) {
            List<OccasionEquipment> updatedEquipment = widget.selectedEquipment.map((eq) {
              if (eq.equipmentId == original.equipmentId) {
                return OccasionEquipment(
                  equipmentId: alternative.id,
                  equipmentName: alternative.name,
                  quantity: eq.quantity,
                  status: 'assigned',
                );
              }
              return eq;
            }).toList();

            widget.onEquipmentChanged(updatedEquipment);
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading alternatives: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _QuantityAdjustDialog extends StatefulWidget {
  final OccasionEquipment equipment;
  final int maxAvailable;
  final Function(int) onAdjust;

  const _QuantityAdjustDialog({
    required this.equipment,
    required this.maxAvailable,
    required this.onAdjust,
  });

  @override
  State<_QuantityAdjustDialog> createState() => _QuantityAdjustDialogState();
}

class _QuantityAdjustDialogState extends State<_QuantityAdjustDialog> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.maxAvailable.clamp(0, widget.equipment.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust ${widget.equipment.equipmentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Only ${widget.maxAvailable} items are available on this date.\n'
                'Please adjust the quantity.',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _quantity > 0 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _quantity.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _quantity < widget.maxAvailable
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdjust(_quantity);
            Navigator.pop(context);
          },
          child: const Text('Adjust'),
        ),
      ],
    );
  }
}

class _AlternativeSuggestionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(OccasionEquipment, EquipmentModel) onSelectAlternative;

  const _AlternativeSuggestionsDialog({
    required this.suggestions,
    required this.onSelectAlternative,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alternative Equipment'),
      content: suggestions.isEmpty
          ? const Text('No alternative equipment found.')
          : SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            final original = suggestion['original'] as OccasionEquipment;
            final alternative = suggestion['alternative'] as EquipmentModel;

            return Card(
              child: ListTile(
                title: Text(alternative.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Replaces: ${original.equipmentName}'),
                    Text('Available: ${suggestion['availableQuantity']}'),
                    Text('Category: ${suggestion['category']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => onSelectAlternative(original, alternative),
                  child: const Text('Use This'),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}