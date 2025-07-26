import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/article_model.dart';
import '../../providers/stock_provider.dart';
import '../constants/app_colors.dart';
import 'add_article_dialog.dart';

class ArticleDetailsDialog extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsDialog({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Article image or icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: article.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.inventory_2,
                            color: AppColors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                        : Icon(
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
                          article.category.toUpperCase(),
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
                            article.isLowStock ? 'Low Stock' : 'In Stock',
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
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Price per unit', '\$${article.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Total value', '\$${article.totalValue.toStringAsFixed(2)}'),
                    _buildDetailRow('Unit', article.unit),
                    _buildDetailRow('Category', article.category),

                    // Description if available
                    if (article.description != null && article.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
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
                          _buildDetailRow('Created', _formatDate(article.createdAt)),
                          _buildDetailRow('Last updated', _formatDate(article.updatedAt)),
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
                      label: const Text('Edit'),
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
                      label: const Text('Update Qty'),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${article.name} quantity'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New quantity (${article.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    const SnackBar(
                      content: Text('Quantity updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stockProvider.errorMessage ?? 'Failed to update quantity',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}