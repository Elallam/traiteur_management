import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/article_model.dart';
import '../../models/meal_model.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';

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

  String _selectedCategory = 'main';
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
      _imageUrlController.text = widget.meal!.imageUrl ?? '';
      _selectedCategory = widget.meal!.category;
      _ingredients = List.from(widget.meal!.ingredients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final calculatedPrice = _calculateTotalCost();

    return AlertDialog(
      title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal'),
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
                  decoration: const InputDecoration(
                    labelText: 'Meal Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter meal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
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
                        decoration: const InputDecoration(
                          labelText: 'Selling Price *',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Servings *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter servings';
                          }
                          final servings = int.tryParse(value);
                          if (servings == null || servings <= 0) {
                            return 'Enter valid servings';
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
                  decoration: const InputDecoration(
                    labelText: 'Preparation Time (minutes) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter preparation time';
                    }
                    final time = int.tryParse(value);
                    if (time == null || time <= 0) {
                      return 'Enter valid time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL Field
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredients Section
                const Text(
                  'Ingredients',
                  style: TextStyle(
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
                  label: const Text('Add Ingredient'),
                ),
                const SizedBox(height: 16),

                // Pricing Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildPriceRow('Total Cost', calculatedPrice),
                        _buildPriceRow('Selling Price', double.tryParse(_sellingPriceController.text) ?? 0),
                        const Divider(),
                        _buildPriceRow(
                          'Profit',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMeal,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(widget.meal == null ? 'Add' : 'Update'),
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
    final article = await showDialog<ArticleModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Article'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              return Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Articles',
                      prefixIcon: Icon(Icons.search),
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (article != null) {
      final quantityController = TextEditingController();
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add ${article.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity (${article.unit})',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available: ${article.quantity} ${article.unit}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (quantityController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Add'),
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
        imageUrl: _imageUrlController.text.trim().isEmpty
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
                  ? 'Meal added successfully'
                  : 'Meal updated successfully',
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
                      ? 'Failed to add meal'
                      : 'Failed to update meal'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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