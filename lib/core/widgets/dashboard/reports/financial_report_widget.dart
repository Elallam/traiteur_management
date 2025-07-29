// financial_report_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/occasion_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';

class FinancialReportWidget extends StatelessWidget {
  const FinancialReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getProfitReport(startOfMonth, endOfMonth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(l10n);
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final report = snapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.financialReport} - ${l10n.thisMonth}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFinancialMetrics(report, l10n),
                    const SizedBox(height: 16),
                    _buildProfitTrendIndicator(report),
                    const SizedBox(height: 8),
                    Text(
                      l10n.basedOnEvents(report['totalOccasions']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(l10n.loading)),
      ),
    );
  }

  Widget _buildFinancialMetrics(Map<String, dynamic> report, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFinancialMetric(
                l10n.totalRevenue,
                '\$${report['totalRevenue'].toStringAsFixed(2)}',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
            Expanded(
              child: _buildFinancialMetric(
                l10n.totalCost,
                '\$${report['totalCost'].toStringAsFixed(2)}',
                Icons.trending_down,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFinancialMetric(
                l10n.netProfit,
                '\$${report['totalProfit'].toStringAsFixed(2)}',
                Icons.attach_money,
                AppColors.primary,
              ),
            ),
            Expanded(
              child: _buildFinancialMetric(
                l10n.profitMargin,
                '${report['profitMargin'].toStringAsFixed(1)}%',
                Icons.percent,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTrendIndicator(Map<String, dynamic> report) {
    return LinearProgressIndicator(
      value: (report['profitMargin'] / 100).clamp(0.0, 1.0),
      backgroundColor: AppColors.border,
      valueColor: AlwaysStoppedAnimation<Color>(
        report['profitMargin'] > 20
            ? AppColors.success
            : report['profitMargin'] > 10
            ? AppColors.warning
            : AppColors.error,
      ),
    );
  }
}