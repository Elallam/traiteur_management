// lib/core/widgets/equipment_availability_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/equipment_model.dart';
import '../../models/occasion_model.dart';
import '../../providers/equipment_booking_provider.dart';

class EquipmentAvailabilityWidget extends StatefulWidget {
  final DateTime occasionDate;
  final List<OccasionEquipment> selectedEquipment;
  final Function(List<OccasionEquipment>) onEquipmentChanged;
  final String? excludeOccasionId;

  const EquipmentAvailabilityWidget({
    super.key,
    required this.occasionDate,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    this.excludeOccasionId,
  });

  @override
  State<EquipmentAvailabilityWidget> createState() => _EquipmentAvailabilityWidgetState();
}

class _EquipmentAvailabilityWidgetState extends State<EquipmentAvailabilityWidget> {
  Map<String, int> _availableQuantities = {};
  List<Map<String, dynamic>> _conflicts = [];
  bool _isValidating = false;
  bool _showDetails = false; // Changed to false by default to save space

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateEquipmentAvailability());
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

    setState(() => _isValidating = true);

    try {
      final bookingProvider = context.read<EquipmentBookingProvider>();

      final validation = await bookingProvider.validateEquipmentBooking(
        equipment: widget.selectedEquipment,
        occasionDate: widget.occasionDate,
        excludeOccasionId: widget.excludeOccasionId,
      );

      final availableQuantities = <String, int>{};
      for (var eq in widget.selectedEquipment) {
        availableQuantities[eq.equipmentId] = await bookingProvider.getAvailableQuantity(
          equipmentId: eq.equipmentId,
          startDate: widget.occasionDate,
          endDate: widget.occasionDate,
          excludeOccasionId: widget.excludeOccasionId,
        );
      }

      setState(() {
        _conflicts = List<Map<String, dynamic>>.from(validation['conflicts'] ?? []);
        _availableQuantities = availableQuantities;
        _isValidating = false;
      });
    } catch (e) {
      setState(() => _isValidating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasConflicts = _conflicts.isNotEmpty;
    final hasEquipment = widget.selectedEquipment.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hasConflicts
              ? theme.colorScheme.error
              : hasEquipment
              ? theme.colorScheme.primary
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with toggle - Always visible
          InkWell(
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: hasConflicts
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equipment Availability',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd - hh:mm a').format(widget.occasionDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isValidating)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasConflicts)
                    Icon(Icons.warning, color: theme.colorScheme.error, size: 14)
                  else if (hasEquipment)
                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 14),
                  const SizedBox(width: 4),
                  Icon(
                    _showDetails ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Details section - Collapsible and scrollable
          if (_showDetails) ...[
            const Divider(height: 1),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isValidating)
                      _buildStatusIndicator(
                        icon: Icons.hourglass_top,
                        color: Colors.blue,
                        message: 'Checking availability...',
                      )
                    else if (hasConflicts)
                      _buildConflictSection()
                    else if (hasEquipment)
                        _buildSuccessIndicator()
                      else
                        _buildEmptyState(),

                    if (hasEquipment) ...[
                      const SizedBox(height: 8),
                      _buildEquipmentList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIndicator(
          icon: Icons.warning,
          color: Theme.of(context).colorScheme.error,
          message: '${_conflicts.length} conflict(s) found',
        ),
        const SizedBox(height: 6),
        // Limit the conflicts list height
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 80),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _conflicts.length,
            itemBuilder: (context, index) => _buildConflictItem(_conflicts[index]),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _showAlternativeSuggestions,
            icon: const Icon(Icons.find_replace, size: 12),
            label: const Text('Find Alternatives', style: TextStyle(fontSize: 10)),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: const Size(0, 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConflictItem(Map<String, dynamic> conflict) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conflict['equipmentName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Req: ${conflict['requested']} • Avail: ${conflict['available']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _adjustQuantity(
              widget.selectedEquipment.firstWhere(
                      (e) => e.equipmentId == conflict['equipmentId']),
              conflict['available'],
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: const Size(0, 20),
            ),
            child: const Text('Fix', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

Widget _buildSuccessIndicator() {
  return _buildStatusIndicator(
    icon: Icons.check_circle,
    color: Theme.of(context).colorScheme.primary,
    message: 'All ${widget.selectedEquipment.length} items available',
  );
}

Widget _buildEmptyState() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Icon(Icons.inventory_2_outlined, size: 24, color: Colors.grey.shade400),
        const SizedBox(height: 4),
        Text(
          'No Equipment Selected',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        Text(
          'Add equipment to check availability',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEquipmentList() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: widget.selectedEquipment.map((eq) {
      final available = _availableQuantities[eq.equipmentId] ?? 0;
      final hasConflict = _conflicts.any((c) => c['equipmentId'] == eq.equipmentId);
      return _buildEquipmentItem(eq, available, hasConflict);
    }).toList(),
  );
}

Widget _buildEquipmentItem(OccasionEquipment eq, int available, bool hasConflict) {
  final theme = Theme.of(context);
  final isAvailable = available >= eq.quantity;

  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: hasConflict
            ? theme.colorScheme.error.withOpacity(0.3)
            : isAvailable
            ? theme.colorScheme.primary.withOpacity(0.3)
            : Colors.grey.shade300,
      ),
      color: hasConflict
          ? theme.colorScheme.error.withOpacity(0.05)
          : isAvailable
          ? theme.colorScheme.primary.withOpacity(0.05)
          : Colors.grey.shade50,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              hasConflict ? Icons.warning : Icons.check_circle,
              color: hasConflict ? theme.colorScheme.error : theme.colorScheme.primary,
              size: 12,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                eq.equipmentName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasConflict)
              TextButton(
                onPressed: () => _adjustQuantity(eq, available),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  minimumSize: const Size(0, 16),
                ),
                child: const Text('Fix', style: TextStyle(fontSize: 9)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildAvailabilityPill('Req', eq.quantity.toString()),
            const SizedBox(width: 4),
            _buildAvailabilityPill(
              'Avail',
              available.toString(),
              isError: hasConflict,
            ),
          ],
        ),
        if (hasConflict) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: available > 0 ? eq.quantity / available : 1.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
          ),
        ],
      ],
    ),
  );
}

Widget _buildAvailabilityPill(String label, String value, {bool isError = false}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: isError
          ? theme.colorScheme.error.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: isError ? theme.colorScheme.error : theme.colorScheme.primary,
          fontSize: 10,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

void _adjustQuantity(OccasionEquipment eq, int maxAvailable) {
  showDialog(
    context: context,
    builder: (context) => _QuantityAdjustDialog(
      equipment: eq,
      maxAvailable: maxAvailable,
      onAdjust: (newQuantity) {
        final updated = widget.selectedEquipment.map((e) =>
        e.equipmentId == eq.equipmentId ? e.copyWith(quantity: newQuantity) : e
        ).toList();
        widget.onEquipmentChanged(updated);
      },
    ),
  );
}

void _showAlternativeSuggestions() async {
  final bookingProvider = context.read<EquipmentBookingProvider>();

  try {
    final conflictedItems = _conflicts.map((c) =>
        widget.selectedEquipment.firstWhere((e) => e.equipmentId == c['equipmentId'])
    ).toList();

    final suggestions = await bookingProvider.getAlternativeEquipmentSuggestions(
      conflictedEquipment: conflictedItems,
      occasionDate: widget.occasionDate,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) => _AlternativeSuggestionsView(
        suggestions: suggestions,
        onSelect: (original, alternative) {
          final updated = widget.selectedEquipment.map((e) =>
          e.equipmentId == original.equipmentId
              ? OccasionEquipment(
            equipmentId: alternative.id,
            equipmentName: alternative.name,
            quantity: e.quantity,
            status: 'assigned',
          )
              : e
          ).toList();
          widget.onEquipmentChanged(updated);
          Navigator.pop(context);
        },
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading alternatives: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.equipment.quantity.clamp(0, widget.maxAvailable);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust ${widget.equipment.equipmentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Only ${widget.maxAvailable} available on selected date'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: quantity > 0
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: quantity < widget.maxAvailable
                    ? () => setState(() => quantity++)
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
        FilledButton(
          onPressed: () {
            widget.onAdjust(quantity);
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _AlternativeSuggestionsView extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(OccasionEquipment, EquipmentModel) onSelect;

  const _AlternativeSuggestionsView({
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Alternative Equipment',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No alternatives found',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final original = suggestion['original'] as OccasionEquipment;
                  final alternative = suggestion['alternative'] as EquipmentModel;
                  final available = suggestion['availableQuantity'] as int;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alternative.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$available available'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Replaces: ${original.equipmentName}',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (alternative.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              alternative.description!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => onSelect(original, alternative),
                              child: const Text('Use This Instead'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}