import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/equipment_model.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

class AddEditEquipmentDialog extends StatefulWidget {
  final EquipmentModel? equipment;

  const AddEditEquipmentDialog({Key? key, this.equipment}) : super(key: key);

  @override
  State<AddEditEquipmentDialog> createState() => _AddEditEquipmentDialogState();
}

class _AddEditEquipmentDialogState extends State<AddEditEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalQuantityController = TextEditingController();
  final _availableQuantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'other';
  bool _isLoading = false;

  final List<String> _categories = [
    'chairs', 'tables', 'utensils', 'decorations', 'sound_equipment',
    'lighting', 'tents', 'linens', 'serving_equipment', 'other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _nameController.text = widget.equipment!.name;
      _totalQuantityController.text = widget.equipment!.totalQuantity.toString();
      _availableQuantityController.text = widget.equipment!.availableQuantity.toString();
      _descriptionController.text = widget.equipment!.description ?? '';
      _imageUrlController.text = widget.equipment!.imageUrl ?? '';
      _selectedCategory = widget.equipment!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.equipment == null ? l10n.addEquipment : l10n.editEquipment), // Localized title
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.equipmentNameRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterEquipmentName; // Localized validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.categoryRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Quantity Fields Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalQuantityController,
                        decoration: InputDecoration(
                          labelText: l10n.totalQuantityRequired, // Localized label
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationEnterTotalQuantity; // Localized validation
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return l10n.validationEnterValidQuantity; // Localized validation
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Auto-set available quantity if it's a new equipment
                          if (widget.equipment == null) {
                            _availableQuantityController.text = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _availableQuantityController,
                        decoration: InputDecoration(
                          labelText: l10n.availableQuantityRequired, // Localized label
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationEnterAvailableQuantity; // Localized validation
                          }
                          final available = int.tryParse(value);
                          final total = int.tryParse(_totalQuantityController.text);
                          if (available == null || available < 0) {
                            return l10n.validationEnterValidQuantity; // Localized validation
                          }
                          if (total != null && available > total) {
                            return l10n.validationCannotExceedTotalQuantity; // Localized validation
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptional, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Image URL Field
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: l10n.imageUrlOptional, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel), // Localized
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEquipment,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(widget.equipment == null ? l10n.add : l10n.update), // Localized
        ),
      ],
    );
  }

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context)!;

      final equipment = EquipmentModel(
        id: widget.equipment?.id ?? '',
        name: _nameController.text.trim(),
        totalQuantity: int.parse(_totalQuantityController.text),
        availableQuantity: int.parse(_availableQuantityController.text),
        category: _selectedCategory,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: widget.equipment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.equipment?.isActive ?? true,
      );

      bool success;
      if (widget.equipment == null) {
        success = await stockProvider.addEquipment(equipment);
      } else {
        success = await stockProvider.updateEquipment(equipment);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.equipment == null
                  ? l10n.equipmentAddedSuccessfully
                  : l10n.equipmentUpdatedSuccessfully,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stockProvider.errorMessage ??
                  (widget.equipment == null
                      ? l10n.failedToAddEquipment
                      : l10n.failedToUpdateEquipment),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'), // Localized error message
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalQuantityController.dispose();
    _availableQuantityController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
