// equipment_report_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/stock_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';

class EquipmentReportWidget extends StatelessWidget {
  const EquipmentReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.equipmentStatusReport,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEquipmentStatusOverview(provider, l10n),
                const SizedBox(height: 16),
                _buildLowStockSection(provider, l10n, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentStatusOverview(StockProvider provider, AppLocalizations l10n) {
    return Row(
      children: [
        _buildEquipmentStatusCard(
          '${l10n.total} ${l10n.equipment}',
          provider.equipment.length.toString(),
          Icons.inventory,
          AppColors.info,
        ),
        _buildEquipmentStatusCard(
          l10n.available,
          provider.getAvailableEquipment().length.toString(),
          Icons.check_circle,
          AppColors.success,
        ),
        _buildEquipmentStatusCard(
          l10n.checkedOut,
          provider.getFullyCheckedOutEquipment().length.toString(),
          Icons.output,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildEquipmentStatusCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(StockProvider provider, AppLocalizations l10n, BuildContext context) {
    final lowStockItems = provider.getLowStockArticles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lowStockAlerts,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...lowStockItems.take(3).map((article) => _buildLowStockItem(article)),
        if (lowStockItems.length > 3)
          TextButton(
            onPressed: () => _showAllLowStockItems(context, lowStockItems, l10n),
            child: Text('${l10n.viewAll} ${l10n.itemsCount(lowStockItems.length)}'),
          ),
      ],
    );
  }

  Widget _buildLowStockItem(article) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              article.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${article.quantity} ${article.unit}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllLowStockItems(BuildContext context, List lowStockItems, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lowStockAlerts),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: lowStockItems.length,
            itemBuilder: (context, index) => _buildLowStockItem(lowStockItems[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}