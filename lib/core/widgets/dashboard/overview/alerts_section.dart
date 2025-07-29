import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../providers/occasion_provider.dart';
import '../../../../providers/equipment_booking_provider.dart';
import '../../../constants/app_colors.dart';
import '../common/section_header.dart';

/// Alerts and notifications section for the dashboard overview
/// Displays important alerts, notifications, and system warnings
class AlertsSection extends StatelessWidget {
  final VoidCallback? onViewAllPressed;
  final Function(Map<String, dynamic>)? onAlertTapped;

  const AlertsSection({
    super.key,
    this.onViewAllPressed,
    this.onAlertTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<OccasionProvider, EquipmentBookingProvider>(
      builder: (context, occasionProvider, bookingProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadAlerts(occasionProvider, bookingProvider),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoAlertsCard(l10n);
            }

            final alerts = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: '${l10n.notifications} & ${l10n.lowStockAlerts.split(' ')[0]}',
                  actionText: l10n.viewAll,
                  onActionPressed: onViewAllPressed,
                ),
                const SizedBox(height: 16),
                ...alerts.take(3).map((alert) => _buildAlertCard(alert, l10n)),
              ],
            );
          },
        );
      },
    );
  }

  /// Loads alerts from both occasion and equipment booking providers
  Future<List<Map<String, dynamic>>> _loadAlerts(
      OccasionProvider occasionProvider,
      EquipmentBookingProvider bookingProvider,
      ) async {
    final results = await Future.wait([
      Future.value(occasionProvider.getOccasionsRequiringAttention()),
      bookingProvider.getEquipmentAlerts(),
    ]);

    return [...results[0], ...results[1]];
  }

  /// Builds the no alerts card when there are no alerts to display
  Widget _buildNoAlertsCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allGood,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    l10n.noAlertsMessage,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single alert card
  Widget _buildAlertCard(Map<String, dynamic> alert, AppLocalizations l10n) {
    final alertColor = _getAlertColor(alert['priority']);
    final alertIcon = _getAlertIcon(alert['type']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: alertColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(alertIcon, color: alertColor, size: 24),
        ),
        title: Text(
          alert['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: alertColor,
          ),
        ),
        subtitle: Text(alert['message']),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onAlertTapped?.call(alert),
      ),
    );
  }

  /// Gets the appropriate color for different alert priorities
  Color _getAlertColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Gets the appropriate icon for different alert types
  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'today':
        return Icons.today;
      case 'overdue':
        return Icons.pending;
      case 'upcoming':
        return Icons.upcoming;
      case 'urgent_checkout':
        return Icons.priority_high;
      case 'upcoming_checkout':
        return Icons.schedule;
      default:
        return Icons.notification_important;
    }
  }
}