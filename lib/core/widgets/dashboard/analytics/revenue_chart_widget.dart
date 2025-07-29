import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../providers/occasion_provider.dart';
import '../../../constants/app_colors.dart';

/// Revenue chart widget for analytics dashboard
/// Displays monthly revenue data as a line chart
class RevenueChartWidget extends StatelessWidget {
  const RevenueChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final monthlyRevenue = provider.getMonthlyRevenue(DateTime.now().year);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthlyRevenue,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => _buildMonthLabel(value, l10n),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateRevenueSpots(monthlyRevenue),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds month label for chart x-axis
  Widget _buildMonthLabel(double value, AppLocalizations l10n) {
    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december
    ];

    final index = value.toInt();
    if (index >= 0 && index < months.length) {
      return Text(
        months[index],
        style: const TextStyle(fontSize: 10),
      );
    }
    return const SizedBox.shrink();
  }

  /// Generates FlSpot data for the revenue chart
  List<FlSpot> _generateRevenueSpots(Map<String, double> monthlyRevenue) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 12; i++) {
      String monthKey = '${DateTime.now().year}-${(i + 1).toString().padLeft(2, '0')}';
      double revenue = monthlyRevenue[monthKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), revenue));
    }
    return spots;
  }
}