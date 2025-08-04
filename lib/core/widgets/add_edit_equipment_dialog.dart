import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/equipment_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

import 'image_picker_widget.dart'; // Import localization

class AddEditEquipmentDialog extends StatefulWidget {
  final EquipmentModel? equipment;

  const AddEditEquipmentDialog({super.key, this.equipment});

  @override
  State<AddEditEquipmentDialog> createState() => _AddEditEquipmentDialogState();
}

class _AddEditEquipmentDialogState extends State<AddEditEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalQuantityController = TextEditingController();
  final _availableQuantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Autre';
  bool _isLoading = false;

  // final List<String> _categories = [
  //   'chairs', 'tables', 'utensils', 'decorations', 'sound_equipment',
  //   'lighting', 'tents', 'linens', 'serving_equipment', 'other'
  // ];

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _nameController.text = widget.equipment!.name;
      _totalQuantityController.text = widget.equipment!.totalQuantity.toString();
      _availableQuantityController.text = widget.equipment!.availableQuantity.toString();
      _descriptionController.text = widget.equipment!.description ?? '';
      _imageUrlController.text = widget.equipment!.imagePath ?? '';
      _selectedCategory = widget.equipment!.category;
      _priceController.text = widget.equipment!.price.toString() ?? '0.0';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final equipmentCategories = categoryProvider.getCategoriesByType('equipment');

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
                    labelText: l10n.categoryRequired,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    // Add a disabled default item
                    DropdownMenuItem<String>(
                      value: l10n.other,
                      enabled: true,
                      child: Text(
                        l10n.other.toUpperCase(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    // Add actual categories

                    ...equipmentCategories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationSelectCategory;
                    }
                    return null;
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
                // Price Field
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.price, // Make sure to add this in your ARB files
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterPrice; // Add this in ARB files
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return l10n.validationEnterValidPrice; // Add this in ARB files
                    }
                    return null;
                  },
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
                ImagePickerWidget(
                  initialImagePath: widget.equipment?.imagePath,
                  onImageSelected: (path) {
                    setState(() {
                      _imageUrlController.text = path ?? '';
                    });
                  },
                  width: double.infinity,
                  height: 150,
                  placeholder: l10n.selectImageSource,
                ),
                const SizedBox(height: 16),
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
        imagePath: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: widget.equipment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.equipment?.isActive ?? true,
        price: double.tryParse(_priceController.text) ?? 0.0,
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
