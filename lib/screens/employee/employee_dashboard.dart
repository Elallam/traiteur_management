// lib/screens/employee/enhanced_employee_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'equipment_checkout.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  List<EquipmentCheckout> _myCheckouts = [];
  List<Map<String, dynamic>> _recentActivity = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel? currentUser = authProvider.currentUser;

      if (currentUser != null) {
        await Future.wait([
          _loadMyCheckouts(currentUser.id),
          _loadRecentActivity(currentUser.id),
          _loadStats(currentUser.id),
        ]);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load dashboard data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadMyCheckouts(String employeeId) async {
    _myCheckouts = await _firestoreService.getEmployeeCheckouts(employeeId);
    // Only show active checkouts (not returned)
    _myCheckouts = _myCheckouts.where((checkout) => checkout.status == 'checked_out').toList();
    _myCheckouts.sort((a, b) => b.checkoutDate.compareTo(a.checkoutDate));
  }

  Future<void> _loadRecentActivity(String employeeId) async {
    List<EquipmentCheckout> allCheckouts = await _firestoreService.getEmployeeCheckouts(employeeId);

    // Create activity entries from checkouts
    _recentActivity = allCheckouts.take(10).map((checkout) {
      return {
        'type': checkout.status == 'returned' ? 'return' : 'checkout',
        'equipmentName': 'Loading...', // Will be loaded separately
        'equipmentId': checkout.equipmentId,
        'quantity': checkout.quantity,
        'date': checkout.status == 'returned' ? checkout.returnDate ?? checkout.checkoutDate : checkout.checkoutDate,
        'status': checkout.status,
      };
    }).toList();

    // Load equipment names for activities
    for (var activity in _recentActivity) {
      try {
        EquipmentModel equipment = await _firestoreService.getEquipmentById(activity['equipmentId']);
        activity['equipmentName'] = equipment.name;
      } catch (e) {
        activity['equipmentName'] = 'Unknown Equipment';
      }
    }

    _recentActivity.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  Future<void> _loadStats(String employeeId) async {
    Map<String, dynamic> summary = await _firestoreService.getEmployeeCheckoutSummary(employeeId);
    _stats = summary;
  }

  Future<void> _returnEquipment(EquipmentCheckout checkout) async {
    try {
      // Update checkout status
      EquipmentCheckout updatedCheckout = checkout.copyWith(
        status: 'returned',
        returnDate: DateTime.now(),
      );
      await _firestoreService.updateEquipmentCheckout(updatedCheckout);

      // Get current equipment data
      EquipmentModel equipment = await _firestoreService.getEquipmentById(checkout.equipmentId);

      // Update equipment availability
      EquipmentModel updatedEquipment = equipment.copyWith(
        availableQuantity: equipment.availableQuantity + checkout.quantity,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateEquipment(updatedEquipment);

      // Refresh dashboard data
      await _loadDashboardData();

      _showSuccessSnackBar('Equipment returned successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to return equipment: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? const LoadingWidget() : _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Employee Dashboard'),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (_stats['overdueItems'] != null && _stats['overdueItems'] > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_stats['overdueItems']}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _showNotifications,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(authProvider),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildActiveCheckouts(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'E',
                style: const TextStyle(
                  color: Colors.white,
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
                    'Welcome back,',
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
                    'Ready to manage equipment',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_stats['overdueItems'] != null && _stats['overdueItems'] > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  '${_stats['overdueItems']} overdue',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Checkouts',
            value: '${_stats['activeCheckouts'] ?? 0}',
            icon: Icons.shopping_cart,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Returns',
            value: '${_stats['returnedItems'] ?? 0}',
            icon: Icons.assignment_return,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Checkouts',
            value: '${_stats['totalCheckouts'] ?? 0}',
            icon: Icons.history,
            color: AppColors.info,
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
    return Card(
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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
                icon: Icons.add_shopping_cart,
                color: AppColors.primary,
                onTap: _navigateToCheckout,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Quick Return',
                subtitle: 'Return multiple items',
                icon: Icons.assignment_return,
                color: AppColors.success,
                onTap: _showQuickReturnDialog,
                enabled: _myCheckouts.isNotEmpty,
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
    bool enabled = true,
  }) {
    return Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
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
                  child: Icon(icon, size: 28, color: color),
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
      ),
    );
  }

  Widget _buildActiveCheckouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Checkouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_myCheckouts.isNotEmpty)
              TextButton(
                onPressed: _showAllCheckouts,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_myCheckouts.isEmpty)
          _buildEmptyCheckouts()
        else
          _buildCheckoutsList(),
      ],
    );
  }

  Widget _buildEmptyCheckouts() {
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
              'No active checkouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All equipment has been returned.',
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

  Widget _buildCheckoutsList() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _myCheckouts.take(5).length, // Show only first 5
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final checkout = _myCheckouts[index];
          return FutureBuilder<EquipmentModel>(
            future: _firestoreService.getEquipmentById(checkout.equipmentId),
            builder: (context, snapshot) {
              String equipmentName = snapshot.data?.name ?? 'Loading...';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: checkout.isOverdue
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  child: Icon(
                    Icons.inventory,
                    color: checkout.isOverdue ? AppColors.error : AppColors.warning,
                    size: 20,
                  ),
                ),
                title: Text(equipmentName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${checkout.quantity}'),
                    Text(
                      'Checked out ${_formatDuration(checkout.checkoutDate)}',
                      style: TextStyle(
                        color: checkout.isOverdue ? AppColors.error : AppColors.textSecondary,
                        fontWeight: checkout.isOverdue ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (checkout.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.assignment_return),
                      onPressed: () => _showReturnConfirmation(checkout),
                      tooltip: 'Return equipment',
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
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
        if (_recentActivity.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivity.take(5).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = _recentActivity[index];
                final isReturn = activity['type'] == 'return';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReturn
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      isReturn ? Icons.assignment_return : Icons.shopping_cart,
                      color: isReturn ? AppColors.success : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${isReturn ? 'Returned' : 'Checked out'} ${activity['equipmentName']}',
                  ),
                  subtitle: Text('Quantity: ${activity['quantity']}'),
                  trailing: Text(
                    _formatDuration(activity['date']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCheckout,
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Checkout'),
      backgroundColor: AppColors.primary,
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'E',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.currentUser?.fullName ?? 'Employee',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Checkout Equipment'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCheckout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_return),
                title: const Text('Return Equipment'),
                onTap: () {
                  Navigator.pop(context);
                  _showQuickReturnDialog();
                },
                enabled: _myCheckouts.isNotEmpty,
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('My Activity'),
                onTap: () {
                  Navigator.pop(context);
                  _showAllCheckouts();
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
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
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

  // Navigation and dialog methods
  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EquipmentCheckoutScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadDashboardData(); // Refresh data after successful checkout
      }
    });
  }

  void _showQuickReturnDialog() {
    if (_myCheckouts.isEmpty) {
      _showErrorSnackBar('No equipment to return');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Return'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _myCheckouts.length,
            itemBuilder: (context, index) {
              final checkout = _myCheckouts[index];
              return FutureBuilder<EquipmentModel>(
                future: _firestoreService.getEquipmentById(checkout.equipmentId),
                builder: (context, snapshot) {
                  String equipmentName = snapshot.data?.name ?? 'Loading...';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(equipmentName),
                      subtitle: Text('Quantity: ${checkout.quantity}'),
                      trailing: checkout.isOverdue
                          ? const Icon(Icons.warning, color: AppColors.error)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _showReturnConfirmation(checkout);
                      },
                    ),
                  );
                },
              );
            },
          ),
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

  void _showReturnConfirmation(EquipmentCheckout checkout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Return'),
        content: FutureBuilder<EquipmentModel>(
          future: _firestoreService.getEquipmentById(checkout.equipmentId),
          builder: (context, snapshot) {
            String equipmentName = snapshot.data?.name ?? 'Loading...';

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to return this equipment?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Equipment: $equipmentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Quantity: ${checkout.quantity}'),
                      Text('Checked out: ${_formatDuration(checkout.checkoutDate)}'),
                      if (checkout.isOverdue)
                        const Text('Status: OVERDUE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _returnEquipment(checkout);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _showAllCheckouts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('My Equipment History')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recentActivity.length,
            itemBuilder: (context, index) {
              final activity = _recentActivity[index];
              final isReturn = activity['type'] == 'return';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReturn
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      isReturn ? Icons.assignment_return : Icons.shopping_cart,
                      color: isReturn ? AppColors.success : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(activity['equipmentName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${isReturn ? 'Returned' : 'Checked out'} • Quantity: ${activity['quantity']}'),
                      Text(_formatDateTime(activity['date'])),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    List<Map<String, dynamic>> notifications = [];

    // Add overdue notifications
    for (var checkout in _myCheckouts.where((c) => c.isOverdue)) {
      notifications.add({
        'type': 'overdue',
        'title': 'Equipment Overdue',
        'message': 'Equipment checked out ${_formatDuration(checkout.checkoutDate)} ago',
        'checkout': checkout,
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: notifications.isEmpty
            ? const Text('No new notifications')
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: AppColors.error),
                  title: Text(notification['title']),
                  subtitle: Text(notification['message']),
                  onTap: () {
                    Navigator.pop(context);
                    if (notification['checkout'] != null) {
                      _showReturnConfirmation(notification['checkout']);
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inMinutes}m ago';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}