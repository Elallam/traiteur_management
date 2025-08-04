import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/article_model.dart';
import '../../models/meal_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

import 'image_picker_widget.dart'; // Import localization

class AddEditMealDialog extends StatefulWidget {
  final MealModel? meal;

  const AddEditMealDialog({Key? key, this.meal}) : super(key: key);

  @override
  State<AddEditMealDialog> createState() => _AddEditMealDialogState();
}

class _AddEditMealDialogState extends State<AddEditMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _servingsController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Autre';
  bool _isLoading = false;
  List<MealIngredient> _ingredients = [];

  final List<String> _categories = [
    'appetizer', 'main', 'dessert', 'drink', 'snack'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      _nameController.text = widget.meal!.name;
      _descriptionController.text = widget.meal!.description;
      _sellingPriceController.text = widget.meal!.sellingPrice.toString();
      _servingsController.text = widget.meal!.servings.toString();
      _preparationTimeController.text = widget.meal!.preparationTime.toString();
      _imageUrlController.text = widget.meal!.imagePath ?? '';
      _selectedCategory = widget.meal!.category;
      _ingredients = List.from(widget.meal!.ingredients);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final calculatedPrice = _calculateTotalCost();
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final mealsCategories = categoryProvider.getCategoriesByType('meal');

    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.meal == null ? l10n.addMeal : l10n.editMeal), // Localized title
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
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
                    labelText: l10n.mealNameRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterMealName; // Localized validation
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
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    // Add actual categories
                    ...mealsCategories.map((category) {
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

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterDescription; // Localized validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price and Servings Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: InputDecoration(
                          labelText: l10n.sellingPriceRequired, // Localized label
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                        controller: _servingsController,
                        decoration: InputDecoration(
                          labelText: l10n.servingsRequired, // Localized label
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationEnterServings; // Localized validation
                          }
                          final servings = int.tryParse(value);
                          if (servings == null || servings <= 0) {
                            return l10n.validationEnterValidServings; // Localized validation
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preparation Time
                TextFormField(
                  controller: _preparationTimeController,
                  decoration: InputDecoration(
                    labelText: l10n.preparationTimeMinutesRequired, // Localized label
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationEnterPreparationTime; // Localized validation
                    }
                    final time = int.tryParse(value);
                    if (time == null || time <= 0) {
                      return l10n.validationEnterValidTime; // Localized validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL Field
                ImagePickerWidget(
                  initialImagePath: widget.meal?.imagePath,
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

                // Ingredients Section
                Text(
                  l10n.ingredients, // Localized
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // Ingredients List
                if (_ingredients.isNotEmpty)
                  Column(
                    children: _ingredients.map((ingredient) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ingredient.articleName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${ingredient.quantity} ${ingredient.unit} - \$${ingredient.totalCost.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () {
                                  setState(() {
                                    _ingredients.remove(ingredient);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // Add Ingredient Button
                ElevatedButton.icon(
                  onPressed: () => _showAddIngredientDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addIngredient), // Localized
                ),
                const SizedBox(height: 16),

                // Pricing Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildPriceRow(l10n.totalCost, calculatedPrice), // Localized
                        _buildPriceRow(l10n.sellingPrice, double.tryParse(_sellingPriceController.text) ?? 0), // Localized
                        const Divider(),
                        _buildPriceRow(
                          l10n.profit, // Localized
                          (double.tryParse(_sellingPriceController.text) ?? 0) - calculatedPrice,
                          isBold: true,
                        ),
                      ],
                    ),
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
          onPressed: _isLoading ? null : _saveMeal,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(widget.meal == null ? l10n.add : l10n.update), // Localized
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddIngredientDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final article = await showDialog<ArticleModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectArticle), // Localized title
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              return Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.searchArticles, // Localized label
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // Implement search if needed
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: stockProvider.articles.length,
                      itemBuilder: (context, index) {
                        final article = stockProvider.articles[index];
                        return ListTile(
                          title: Text(article.name),
                          subtitle: Text(
                              '${article.quantity} ${article.unit} - \$${article.price.toStringAsFixed(2)}'),
                          onTap: () {
                            Navigator.pop(context, article);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
        ],
      ),
    );

    if (article != null) {
      final quantityController = TextEditingController();
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.addArticleName(article.name)), // Localized title with parameter
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.quantityUnit(article.unit), // Localized label with parameter
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.availableQuantityUnit(article.quantity, article.unit), // Localized text with parameters
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel), // Localized
            ),
            ElevatedButton(
              onPressed: () {
                if (quantityController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(l10n.add), // Localized
            ),
          ],
        ),
      );

      if (result == true) {
        final quantity = double.tryParse(quantityController.text) ?? 0;
        if (quantity > 0) {
          setState(() {
            _ingredients.add(MealIngredient(
              articleId: article.id,
              articleName: article.name,
              quantity: quantity,
              unit: article.unit,
              pricePerUnit: article.price,
            ));
          });
        }
      }
    }
  }

  double _calculateTotalCost() {
    return _ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.totalCost);
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context)!;

      final meal = MealModel(
        id: widget.meal?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredients,
        calculatedPrice: _calculateTotalCost(),
        sellingPrice: double.parse(_sellingPriceController.text),
        category: _selectedCategory,
        servings: int.parse(_servingsController.text),
        preparationTime: int.parse(_preparationTimeController.text),
        imagePath: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: widget.meal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.meal?.isActive ?? true,
        isAvailable: widget.meal?.isAvailable ?? true,
      );

      bool success;
      if (widget.meal == null) {
        success = await stockProvider.addMeal(meal);
      } else {
        success = await stockProvider.updateMeal(meal);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.meal == null
                  ? l10n.mealAddedSuccessfully
                  : l10n.mealUpdatedSuccessfully,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stockProvider.errorMessage ??
                  (widget.meal == null
                      ? l10n.failedToAddMeal
                      : l10n.failedToUpdateMeal),
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
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    _servingsController.dispose();
    _preparationTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
