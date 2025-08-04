import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/models/category_model.dart';

import '../../models/article_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

import 'image_picker_widget.dart'; // Import localization

class AddEditArticleDialog extends StatefulWidget {
  final ArticleModel? article;

  const AddEditArticleDialog({super.key, this.article});

  @override
  State<AddEditArticleDialog> createState() => _AddEditArticleDialogState();
}

class _AddEditArticleDialogState extends State<AddEditArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedUnit = 'pieces';
  String _selectedCategory = 'Autre';
  bool _isLoading = false;

  final List<String> _units = [
    'pieces', 'kg', 'grams', 'liters', 'ml', 'boxes', 'packets', 'bottles'
  ];
  //
  // final List<String> _categories = [
  //   'vegetables', 'fruits', 'meat', 'dairy', 'grains', 'spices',
  //   'beverages', 'desserts', 'frozen', 'canned', 'other'
  // ];

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _nameController.text = widget.article!.name;
      _priceController.text = widget.article!.price.toString();
      _quantityController.text = widget.article!.quantity.toString();
      _descriptionController.text = widget.article!.description ?? '';
      _imageUrlController.text = widget.article!.imagePath ?? '';
      _selectedUnit = widget.article!.unit;
      _selectedCategory = widget.article!.category;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final articleCategories = categoryProvider.getCategoriesByType('article');

    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.article == null ? l10n.addArticle : l10n.editArticle), // Localized title
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.8,
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
                    labelText: l10n.articleNameRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value
                        .trim()
                        .isEmpty) {
                      return l10n.validationEnterArticleName; // Localized validation
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
                      value: 'Autre',
                      enabled: true,
                      child: Text(
                        l10n.other.toUpperCase(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    // Add actual categories
                    ...articleCategories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name.toUpperCase()),
                      );
                    }).toList(),
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

                // Price and Quantity Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: l10n.pricePerUnitRequired, // Localized label
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return l10n.validationEnterPrice; // Localized validation
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return l10n.validationEnterValidPrice; // Localized validation
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: l10n.quantityRequired, // Localized label
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return l10n.validationEnterQuantity; // Localized validation
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity < 0) {
                            return l10n.validationEnterValidQuantity; // Localized validation
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unit Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: l10n.unitRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
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
                  initialImagePath: widget.article?.imagePath,
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
          onPressed: _isLoading ? null : _saveArticle,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(widget.article == null ? l10n.add : l10n.update), // Localized
        ),
      ],
    );
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context)!;

      final article = ArticleModel(
        id: widget.article?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
        category: _selectedCategory,
        description: _descriptionController.text
            .trim()
            .isEmpty
            ? null
            : _descriptionController.text.trim(),
        imagePath: _imageUrlController.text
            .trim()
            .isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: widget.article?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.article?.isActive ?? true,
      );

      bool success;
      if (widget.article == null) {
        success = await stockProvider.addArticle(article);
      } else {
        success = await stockProvider.updateArticle(article);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.article == null
                  ? l10n.articleAddedSuccessfully
                  : l10n.articleUpdatedSuccessfully,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stockProvider.errorMessage ??
                  (widget.article == null
                      ? l10n.failedToAddArticle
                      : l10n.failedToUpdateArticle),
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
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
