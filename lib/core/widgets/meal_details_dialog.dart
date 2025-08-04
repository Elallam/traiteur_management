import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/core/utils/helpers.dart';
import '../../models/article_model.dart';
import '../../models/category_model.dart';
import '../../models/meal_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'add_edit_meal_dialog.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

class MealDetailsDialog extends StatelessWidget {
  final MealModel meal;

  const MealDetailsDialog({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final canBePrepared = stockProvider.canMealBePrepared(meal);
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhere(
          (c) => c.id == meal.category,
      orElse: () => CategoryModel(
        id: '',
        name: l10n.uncategorized,
        type: 'meal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with meal info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Meal image or icon
                  Container(
                    width: 60,
                    height: 60,
                    child: meal.imagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(meal.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            color: AppColors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.restaurant,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category.name.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (meal.isAvailable && canBePrepared)
                            ? AppColors.success.withOpacity(0.1)
                            : !meal.isAvailable
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (meal.isAvailable && canBePrepared)
                              ? AppColors.success.withOpacity(0.3)
                              : !meal.isAvailable
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (meal.isAvailable && canBePrepared)
                                ? Icons.check_circle
                                : !meal.isAvailable
                                ? Icons.block
                                : Icons.warning,
                            color: (meal.isAvailable && canBePrepared)
                                ? AppColors.success
                                : !meal.isAvailable
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              (meal.isAvailable && canBePrepared)
                                  ? l10n.available
                                  : !meal.isAvailable
                                  ? l10n.disabled
                                  : l10n.ingredientsLow,
                              style: TextStyle(
                                color: (meal.isAvailable && canBePrepared)
                                    ? AppColors.success
                                    : !meal.isAvailable
                                    ? AppColors.error
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pricing info - Made scrollable horizontally
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildInfoChip(l10n.cost, Helpers.formatMAD(meal.calculatedPrice)),
                          const SizedBox(width: 8),
                          _buildInfoChip(l10n.price, Helpers.formatMAD(meal.sellingPrice)),
                          const SizedBox(width: 8),
                          _buildInfoChip(l10n.profit, Helpers.formatMAD(meal.profitMargin)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Servings and prep time - Made scrollable horizontally
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildInfoChip(l10n.servings, meal.servings.toString()),
                          const SizedBox(width: 8),
                          _buildInfoChip(l10n.prepTime, l10n.minutes(meal.preparationTime)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ingredients section
                    Text(
                      l10n.ingredients,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...meal.ingredients.map((ingredient) {
                      final article = stockProvider.articles.firstWhere(
                            (a) => a.id == ingredient.articleId,
                        orElse: () => ArticleModel(
                          id: '',
                          name: '',
                          price: 0,
                          quantity: 0,
                          unit: '',
                          category: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );

                      final hasEnough = article.id.isNotEmpty &&
                          article.quantity >= ingredient.quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              hasEnough ? Icons.check_circle : Icons.warning,
                              color: hasEnough ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.ingredientDetails(ingredient.articleName, ingredient.quantity, ingredient.unit),
                                style: TextStyle(
                                  color: hasEnough ? AppColors.textPrimary : AppColors.error,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (article.id.isNotEmpty)
                              Text(
                                l10n.availableQuantityUnit(article.quantity, article.unit),
                                style: TextStyle(
                                  color: hasEnough ? AppColors.textSecondary : AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Description
                    const SizedBox(height: 20),
                    Text(
                      l10n.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meal.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Timestamps
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(l10n.created, _formatDate(meal.createdAt)),
                          _buildDetailRow(l10n.lastUpdated, _formatDate(meal.updatedAt)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.edit), // Localized
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: meal.isAvailable ? AppColors.error : AppColors.success,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleAvailability(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            meal.isAvailable ? Icons.visibility_off : Icons.visibility,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(meal.isAvailable ? l10n.disable : l10n.enable), // Localized
                        ],
                      ),
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

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${label}: ${value}',
        style: const TextStyle(
          fontSize: 14,
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
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditMealDialog(meal: meal),
    );
  }

  void _toggleAvailability(BuildContext context) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final success = await stockProvider.updateMealAvailability(
        meal.id,
        !meal.isAvailable
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            meal.isAvailable ? l10n.mealDisabledSuccess : l10n.mealEnabledSuccess, // Localized
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stockProvider.errorMessage ?? l10n.failedToUpdateMealAvailability, // Localized fallback
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
