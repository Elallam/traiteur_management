import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../screens/admin/employee_management.dart';
import '../../../../screens/admin/occasion_management.dart';
import '../../../../screens/admin/stock_management.dart';

/// Quick actions bottom sheet widget
/// Provides quick access to common admin actions
class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key});

  /// Shows the quick actions bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const QuickActionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            l10n.quickActions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Quick action items
          _buildQuickActionItem(
            context,
            icon: Icons.event_note,
            title: l10n.createNewEvent,
            subtitle: l10n.addOccasion ?? 'Add a new occasion or event',
            onTap: () => _navigateToScreen(context, const OccasionManagementScreen()),
          ),

          _buildQuickActionItem(
            context,
            icon: Icons.build,
            title: l10n.addEquipment,
            subtitle: l10n.addEquipment ?? 'Add new equipment to inventory',
            onTap: () => _navigateToScreen(context, const StockManagementScreen()),
          ),

          _buildQuickActionItem(
            context,
            icon: Icons.restaurant_menu,
            title: l10n.addMeal,
            subtitle: l10n.addMeal ?? 'Add new meal to menu',
            onTap: () => _navigateToScreen(context, const StockManagementScreen()),
          ),

          _buildQuickActionItem(
            context,
            icon: Icons.inventory_2,
            title: l10n.addArticle,
            subtitle: l10n.addArticle ?? 'Add new article to stock',
            onTap: () => _navigateToScreen(context, const StockManagementScreen()),
          ),

          _buildQuickActionItem(
            context,
            icon: Icons.person_add,
            title: l10n.addEmployee,
            subtitle: l10n.addEmployee ?? 'Add new team member',
            onTap: () => _navigateToScreen(context, const EmployeeManagementScreen()),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds a single quick action item
  Widget _buildQuickActionItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Navigates to a screen and closes the bottom sheet
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}