import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/screens/admin/cash_registering_screen.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/admin/category_management_screen.dart';
import '../../../screens/admin/employee_management.dart';
import '../../../screens/admin/stock_management.dart';
import '../../../screens/admin/occasion_management.dart';
import '../../../screens/admin/profit_analytics_screen.dart';
import '../../constants/app_colors.dart';

/// Dashboard navigation drawer widget
/// Handles user profile display and navigation menu
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(authProvider, l10n),
              _buildDrawerItem(
                Icons.dashboard,
                l10n.dashboard,
                    () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                Icons.people,
                l10n.employees,
                    () => _navigateToSection(context, 0),
              ),
              _buildDrawerItem(
                Icons.inventory,
                l10n.stock,
                    () => _navigateToSection(context, 1),
              ),
              _buildDrawerItem(
                Icons.event,
                l10n.occasions,
                    () => _navigateToSection(context, 2),
              ),
              _buildDrawerItem(
                Icons.analytics,
                l10n.analytics,
                    () => _navigateToSection(context, 3),
              ),
              _buildDrawerItem(
                Icons.account_balance_wallet,
                l10n.cashRegister,
                    () => _navigateToSection(context, 5),
              ),
              const Divider(),
              _buildDrawerItem(
                Icons.settings,
                l10n.settings,
                    () => _navigateToSection(context, 4),
              ),
              _buildDrawerItem(
                Icons.logout,
                l10n.logout,
                    () => _handleSignOut(context, authProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the drawer header with user profile information
  Widget _buildDrawerHeader(AuthProvider authProvider, AppLocalizations l10n) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.white,
            child: Text(
              authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'A',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.currentUser?.fullName ?? l10n.admin,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            authProvider.currentUser?.email ?? '',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds a single drawer item with icon, title, and onTap action
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Builder(
      builder: (context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, size: 20),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        onTap: onTap,
      ),
    );
  }

  /// Navigates to different sections based on index
  void _navigateToSection(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer first

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StockManagementScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OccasionManagementScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfitAnalyticsScreen()),
        );
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CashRegisterScreen()),
        );
        break;
    }
  }

  /// Handles user sign out
  Future<void> _handleSignOut(BuildContext context, AuthProvider authProvider) async {
    Navigator.pop(context); // Close drawer first
    await authProvider.signOut();
  }
}