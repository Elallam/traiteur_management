import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../../providers/employee_provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeStatisticsWidget extends StatelessWidget {
  final EmployeeProvider employeeProvider;

  const EmployeeStatisticsWidget({
    Key? key,
    required this.employeeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = employeeProvider.getEmployeeStatistics();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              l10n.totalEmployees,
              stats['totalEmployees'].toString(),
              Icons.people,
              AppColors.primary,
              context,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l10n.active,
              stats['activeEmployees'].toString(),
              Icons.check_circle,
              AppColors.success,
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}