import 'package:flutter/material.dart';

import '../../models/equipment_model.dart';
import '../constants/app_colors.dart';
import 'add_edit_equipment_dialog.dart';

class EquipmentDetailsDialog extends StatelessWidget {
  final EquipmentModel equipment;

  const EquipmentDetailsDialog({Key? key, required this.equipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: equipment.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        equipment.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.build,
                            color: AppColors.white,
                            size: 24,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.build,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          equipment.category.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Availability Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: equipment.isAvailable
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: equipment.isAvailable
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            equipment.isAvailable ? Icons.check_circle : Icons.block,
                            color: equipment.isAvailable ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            equipment.isAvailable ? 'Available' : 'All Checked Out',
                            style: TextStyle(
                              color: equipment.isAvailable ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${equipment.availableQuantity}/${equipment.totalQuantity}',
                            style: TextStyle(
                              color: equipment.isAvailable ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Availability Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Availability',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${equipment.availabilityPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: equipment.availabilityPercentage > 50
                                    ? AppColors.success
                                    : equipment.availabilityPercentage > 20
                                    ? AppColors.warning
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: equipment.availabilityPercentage / 100,
                          backgroundColor: AppColors.greyLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            equipment.availabilityPercentage > 50
                                ? AppColors.success
                                : equipment.availabilityPercentage > 20
                                ? AppColors.warning
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Details Grid
                    _buildDetailRow('Total Quantity', equipment.totalQuantity.toString()),
                    _buildDetailRow('Available', equipment.availableQuantity.toString()),
                    _buildDetailRow('Checked Out', equipment.checkedOutQuantity.toString()),
                    _buildDetailRow('Category', equipment.category.replaceAll('_', ' ').toUpperCase()),

                    if (equipment.description != null && equipment.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        equipment.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Timestamps
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Created',
                            _formatDateTime(equipment.createdAt),
                          ),
                          _buildDetailRow(
                            'Last Updated',
                            _formatDateTime(equipment.updatedAt),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: equipment.isAvailable ? () {
                        Navigator.pop(context);
                        _showCheckoutDialog(context);
                      } : null,
                      icon: const Icon(Icons.output),
                      label: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditEquipmentDialog(equipment: equipment),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    // TODO: Implement checkout dialog functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipment checkout functionality - Coming soon'),
      ),
    );
  }
}
