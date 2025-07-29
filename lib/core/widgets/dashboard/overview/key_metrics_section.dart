import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../providers/occasion_provider.dart';
import '../../../../providers/stock_provider.dart';
import '../../../../providers/employee_provider.dart';
import '../../../constants/app_colors.dart';
import '../common/metric_card.dart';
import '../common/section_header.dart';

/// Key metrics section for the admin dashboard overview
/// Displays revenue, events, equipment, and stock value metrics
class KeyMetricsSection extends StatelessWidget {
  const KeyMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer3<OccasionProvider, StockProvider, EmployeeProvider>(
      builder: (context, occasionProvider, stockProvider, employeeProvider, child) {
        final occasionStats = occasionProvider.getOccasionStatistics();
        final stockSummary = stockProvider.getStockSummary();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.keyMetrics),
            const SizedBox(height: 16),

            // First row of metrics
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: l10n.totalRevenue,
                    value: '\$${occasionStats['totalRevenue'].toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                    subtitle: l10n.thisMonth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: l10n.activeEvents,
                    value: occasionStats['upcomingOccasions'].toString(),
                    icon: Icons.event,
                    color: AppColors.primary,
                    subtitle: l10n.upcoming,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Second row of metrics
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: '${l10n.equipment} ${l10n.itemsCount(0).split(' ')[1]}',
                    value: stockSummary['totalEquipment'].toString(),
                    icon: Icons.inventory,
                    color: AppColors.info,
                    subtitle: '${stockSummary['availableEquipment']} ${l10n.available}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: l10n.stockValue,
                    value: '\$${stockSummary['totalStockValue'].toStringAsFixed(0)}',
                    icon: Icons.assessment,
                    color: AppColors.warning,
                    subtitle: '${stockSummary['lowStockArticles']} ${l10n.lowStock}',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}