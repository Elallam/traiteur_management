import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final List<EquipmentItem> _checkedOutEquipment = [
    EquipmentItem(name: 'Chairs', quantity: 10, checkedOut: DateTime.now().subtract(const Duration(hours: 2))),
    EquipmentItem(name: 'Tables', quantity: 5, checkedOut: DateTime.now().subtract(const Duration(hours: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Employee Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Implement notifications
          },
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
              // Welcome Section
              _buildWelcomeSection(authProvider),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Current Checkout Status
              _buildCheckoutStatus(),

              const SizedBox(height: 24),

              // Recent Activity
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.secondary,
              child: Text(
                authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'E',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    authProvider.currentUser?.fullName ?? 'Employee',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ready to serve excellence',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Checkout Equipment',
                subtitle: 'Take items for event',
                icon: Icons.shopping_cart,
                color: AppColors.primary,
                onTap: () {
                  _showCheckoutDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Return Equipment',
                subtitle: 'Return used items',
                icon: Icons.assignment_return,
                color: AppColors.success,
                onTap: () {
                  _showReturnDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Currently Checked Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_checkedOutEquipment.isNotEmpty)
              Chip(
                label: Text('${_checkedOutEquipment.length} items'),
                backgroundColor: AppColors.warning.withOpacity(0.2),
                labelStyle: const TextStyle(color: AppColors.warning),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_checkedOutEquipment.isEmpty)
          _buildEmptyCheckout()
        else
          _buildEquipmentList(),
      ],
    );
  }

  Widget _buildEmptyCheckout() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No equipment checked out',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All clear! You have no items currently checked out.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _checkedOutEquipment.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _checkedOutEquipment[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.warning.withOpacity(0.1),
              child: Icon(
                Icons.inventory,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            title: Text(item.name),
            subtitle: Text('Quantity: ${item.quantity} • ${_formatDuration(item.checkedOut)}'),
            trailing: IconButton(
              icon: const Icon(Icons.assignment_return),
              onPressed: () {
                _returnItem(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Icon(
                    index == 0 ? Icons.shopping_cart : Icons.assignment_return,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                title: Text(index == 0 ? 'Checked out 5 tables' : 'Returned 10 chairs'),
                subtitle: Text('${index + 1}h ago'),
                trailing: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 16,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCheckoutDialog,
      child: const Icon(Icons.add_shopping_cart),
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
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Text(
                        authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'E',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.currentUser?.fullName ?? 'Employee',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Checkout Equipment'),
                onTap: () {
                  Navigator.pop(context);
                  _showCheckoutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_return),
                title: const Text('Return Equipment'),
                onTap: () {
                  Navigator.pop(context);
                  _showReturnDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('My Activity'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to activity history
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Equipment'),
        content: const Text('Equipment checkout functionality will be implemented in Phase 4.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog() {
    if (_checkedOutEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No equipment to return'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select equipment to return:'),
            const SizedBox(height: 16),
            ..._checkedOutEquipment.asMap().entries.map((entry) {
              int index = entry.key;
              EquipmentItem item = entry.value;
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _returnItem(index);
                  },
                  child: const Text('Return'),
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _returnItem(int index) {
    setState(() {
      _checkedOutEquipment.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipment returned successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatDuration(DateTime checkedOut) {
    final duration = DateTime.now().difference(checkedOut);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inMinutes}m ago';
    }
  }
}

class EquipmentItem {
  final String name;
  final int quantity;
  final DateTime checkedOut;

  EquipmentItem({
    required this.name,
    required this.quantity,
    required this.checkedOut,
  });
}