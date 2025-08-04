import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/employee_provider.dart';
import '../../../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeAnalyticsWidget extends StatelessWidget {
  const EmployeeAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        final stats = employeeProvider.getEmployeeStatistics();
        final topPerformers = employeeProvider.getTopPerformingEmployees(limit: 5);
        final alerts = employeeProvider.getEmployeesRequiringAttention();

        return AlertDialog(
          title: Text(l10n.employeeAnalytics),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Overview Stats
                  _buildOverviewSection(l10n, stats),
                  const SizedBox(height: 24),

                  // Top Performers
                  if (topPerformers.isNotEmpty) ...[
                    _buildTopPerformersSection(l10n, topPerformers),
                    const SizedBox(height: 24),
                  ],

                  // Alerts
                  if (alerts.isNotEmpty)
                    _buildAlertsSection(l10n, alerts),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
            ElevatedButton(
              onPressed: () => _exportReport(context, l10n),
              child: Text(l10n.exportReport),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewSection(AppLocalizations l10n, Map stats) {
    return _buildAnalyticsSection(
      l10n.overview,
      [
        _buildAnalyticsGrid([
          _buildAnalyticsCard(
            l10n.totalEmployees,
            stats['totalEmployees'].toString(),
            Icons.people,
            AppColors.primary,
          ),
          _buildAnalyticsCard(
            l10n.activeEmployees,
            stats['activeEmployees'].toString(),
            Icons.check_circle,
            AppColors.success,
          ),
          _buildAnalyticsCard(
            l10n.activeCheckouts,
            stats['totalActiveCheckouts'].toString(),
            Icons.inventory,
            AppColors.info,
          ),
          _buildAnalyticsCard(
            l10n.overdueItems,
            stats['totalOverdueCheckouts'].toString(),
            Icons.warning,
            AppColors.error,
          ),
        ]),
      ],
    );
  }

  Widget _buildTopPerformersSection(AppLocalizations l10n, List topPerformers) {
    return _buildAnalyticsSection(
      l10n.topPerformingEmployees,
      [
        ...topPerformers.take(3).map((performer) {
          final employee = performer['employee'] as UserModel;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success,
                child: Text(
                  employee.fullName[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
              title: Text(employee.fullName),
              subtitle: Text('${l10n.reliability}: ${performer['reliabilityScore'].toStringAsFixed(1)}%'),
              trailing: Text(l10n.totalCheckoutsCount(performer['totalCheckouts'])),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAlertsSection(AppLocalizations l10n, List alerts) {
    return _buildAnalyticsSection(
      l10n.employeesRequiringAttention,
      [
        ...alerts.take(5).map((alert) {
          final employee = alert['employee'] as UserModel;
          return Card(
            color: alert['priority'] == 'high'
                ? AppColors.error.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            child: ListTile(
              leading: Icon(
                alert['type'] == 'overdue_equipment'
                    ? Icons.warning
                    : Icons.info,
                color: alert['priority'] == 'high'
                    ? AppColors.error
                    : AppColors.warning,
              ),
              title: Text(employee.fullName),
              subtitle: Text(alert['message']),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: alert['priority'] == 'high'
                      ? AppColors.error
                      : AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert['priority'].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalyticsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildAnalyticsGrid(List<Widget> cards) {
    return GridView.count(
      crossAxisCount: 2, // Or 3/4 depending on screen size
      childAspectRatio: 0.9, // Adjust for your card proportions
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Added for better alignment
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            // Constrained value text
            SizedBox(
              width: double.infinity, // Take full width
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 1, // Single line
              ),
            ),
            const SizedBox(height: 4),
            // Constrained title text
            SizedBox(
              width: double.infinity, // Take full width
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 2, // Allow two lines for title
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _exportReport(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.detailedAnalyticsExportComingSoon),
      ),
    );
  }
}