import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/providers/category_provider.dart';
import '../../models/article_model.dart';
import '../../models/category_model.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'add_article_dialog.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

class ArticleDetailsDialog extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsDialog({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhere(
          (c) => c.id == article.category,
      orElse: () => CategoryModel(
        id: '',
        name: l10n.uncategorized,
        type: 'article',
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
            // Header with article info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Article image or icon
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: article.imagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(article.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2,
                            color: AppColors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.inventory_2,
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
                          article.name,
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
                    // Stock status card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: article.isLowStock
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: article.isLowStock
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            article.isLowStock ? Icons.warning : Icons.check_circle,
                            color: article.isLowStock ? AppColors.error : AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.isLowStock ? l10n.lowStock : l10n.inStock, // Localized
                            style: TextStyle(
                              color: article.isLowStock ? AppColors.error : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${article.quantity} ${article.unit}',
                            style: TextStyle(
                              color: article.isLowStock ? AppColors.error : AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Details section
                    Text(
                      l10n.details, // Localized
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(l10n.pricePerUnit, '\$${article.price.toStringAsFixed(2)}'), // Localized
                    _buildDetailRow(l10n.totalValue, '\$${article.totalValue.toStringAsFixed(2)}'), // Localized
                    _buildDetailRow(l10n.unit, article.unit), // Localized
                    _buildDetailRow(l10n.category, category.name), // Localized

                    // Description if available
                    if (article.description != null && article.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.description, // Localized
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],

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
                          _buildDetailRow(l10n.created, _formatDate(article.createdAt)), // Localized
                          _buildDetailRow(l10n.lastUpdated, _formatDate(article.updatedAt)), // Localized
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
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle),
                      label: Text(l10n.updateQuantity), // Localized
                      onPressed: () {
                        Navigator.pop(context);
                        _showUpdateQuantityDialog(context);
                      },
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
      builder: (context) => AddEditArticleDialog(article: article),
    );
  }

  void _showUpdateQuantityDialog(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final quantityController = TextEditingController(text: article.quantity.toString());
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateArticleQuantityTitle(article.name)), // Localized title
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.newQuantityUnit(article.unit), // Localized label
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity >= 0) {
                Navigator.pop(context);
                final success = await stockProvider.updateArticleQuantity(
                  article.id,
                  newQuantity,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.quantityUpdatedSuccess), // Localized
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stockProvider.errorMessage ?? l10n.failedToUpdateQuantity, // Localized fallback
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.update), // Localized
          ),
        ],
      ),
    );
  }
}
