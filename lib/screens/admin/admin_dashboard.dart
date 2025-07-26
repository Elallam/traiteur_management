import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/screens/admin/occasion_management.dart';
import 'package:traiteur_management/screens/admin/profit_analytics_screen.dart';
import 'package:traiteur_management/screens/admin/stock_management.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'employee_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      title: 'Employee',
      subtitle: 'Manage staff',
      icon: Icons.people,
      color: AppColors.primary,
    ),
    DashboardItem(
      title: 'Stock',
      subtitle: 'Inventory',
      icon: Icons.inventory,
      color: AppColors.secondary,
    ),
    DashboardItem(
      title: 'Occasions',
      subtitle: 'Events',
      icon: Icons.event,
      color: AppColors.success,
    ),
    DashboardItem(
      title: 'Analytics',
      subtitle: 'Reports',
      icon: Icons.analytics,
      color: AppColors.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(authProvider),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 16),
              _buildManagementCards(),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    authProvider.currentUser?.fullName ?? 'Admin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Admin Panel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                title: 'Employees',
                value: '12',
                icon: Icons.people,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Events',
                value: '5',
                icon: Icons.event,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                title: 'Revenue',
                value: '\$2,400',
                icon: Icons.attach_money,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            return _buildManagementCard(_dashboardItems[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildManagementCard(DashboardItem item, int index) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToSection(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 24, color: item.color),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.info, color: AppColors.primary, size: 16),
                ),
                title: Text(
                  'Activity ${index + 1}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Description here',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '2h ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
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
                      authProvider.currentUser?.fullName ?? 'Admin',
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
              ),
              _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
              _buildDrawerItem(Icons.people, 'Employees', () {
                Navigator.pop(context);
                _navigateToSection(0);
              }),
              _buildDrawerItem(Icons.inventory, 'Stock', () {
                Navigator.pop(context);
                _navigateToSection(1);
              }),
              _buildDrawerItem(Icons.event, 'Occasions', () {
                Navigator.pop(context);
                _navigateToSection(2);
              }),
              _buildDrawerItem(Icons.analytics, 'Analytics', () {
                Navigator.pop(context);
                _navigateToSection(3);
              }),
              const Divider(),
              _buildDrawerItem(Icons.settings, 'Settings', () => Navigator.pop(context)),
              _buildDrawerItem(Icons.logout, 'Sign Out', () async {
                Navigator.pop(context);
                await authProvider.signOut();
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, size: 20),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OccasionManagementScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitAnalyticsScreen()));
        break;
    }
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}