// equipment_utilization_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../providers/equipment_booking_provider.dart';
import '../../../constants/app_colors.dart';

class EquipmentUtilizationWidget extends StatelessWidget {
  const EquipmentUtilizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<EquipmentBookingProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);

        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getEquipmentUtilizationStats(
            startDate: startDate,
            endDate: endDate,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(l10n);
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final stats = snapshot.data!;
            final report = stats['report'] as List<Map<String, dynamic>>;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.equipmentUtilization,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.thisMonth,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUtilizationStats(stats, l10n),
                    const SizedBox(height: 16),
                    Text(
                      l10n.mostUtilizedEquipment,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...report.take(3).map((item) => _buildUtilizationItem(item)),
                    if (report.length > 3)
                      TextButton(
                        onPressed: () => _showFullReport(context, report, l10n),
                        child: Text('${l10n.viewAll} ${l10n.itemsCount(report.length)}'),
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

  Widget _buildUtilizationStats(Map<String, dynamic> stats, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildUtilizationStat(
            l10n.average,
            '${stats['averageUtilization'].toStringAsFixed(1)}%',
            AppColors.info,
          ),
        ),
        Expanded(
          child: _buildUtilizationStat(
            l10n.fullyBooked,
            '${stats['fullyBookedTypes']}',
            AppColors.error,
          ),
        ),
        Expanded(
          child: _buildUtilizationStat(
            l10n.available,
            '${stats['totalEquipmentTypes'] - stats['fullyBookedTypes']}',
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizationStat(String label, String value, Color color) {
    return Column(
      children: [
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
        ),
      ],
    );
  }

  Widget _buildUtilizationItem(Map<String, dynamic> item) {
    final utilizationRate = item['utilizationRate'] as double;
    Color utilizationColor = AppColors.success;
    if (utilizationRate >= 100) {
      utilizationColor = AppColors.error;
    } else if (utilizationRate >= 70) {
      utilizationColor = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item['equipment'].name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: utilizationRate / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${utilizationRate.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: utilizationColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullReport(BuildContext context, List<Map<String, dynamic>> report, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.equipment} ${l10n.utilizationReport}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: report.length,
            itemBuilder: (context, index) => _buildUtilizationItem(report[index]),
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