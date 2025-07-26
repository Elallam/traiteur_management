import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:traiteur_management/screens/admin/profit_analytics_screen.dart';
import 'package:traiteur_management/screens/admin/stock_management.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/equipment_booking_calendar_widget.dart';
import '../../models/occasion_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/employee_provider.dart';
import 'employee_management.dart';
import 'occasion_management.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        Provider.of<OccasionProvider>(context, listen: false).loadOccasions(),
        Provider.of<StockProvider>(context, listen: false).loadAllStockData(),
        Provider.of<EmployeeProvider>(context, listen: false).loadEmployees(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading dashboard: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Load equipment booking calendar for current month
    final bookingProvider = Provider.of<EquipmentBookingProvider>(
        context, listen: false);
    final now = DateTime.now();
    await bookingProvider.loadBookingCalendar(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    Offset fabOffset = Offset(
      MediaQuery.of(context).size.width - 150, // Default FAB position (right)
      MediaQuery.of(context).size.height - 200, // Default FAB position (bottom)
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            onPressed: _showNotifications,
            icon: Badge(
              label: Consumer<OccasionProvider>(
                builder: (context, provider, child) {
                  final alertCount = provider.getAlertCount();
                  return Text(alertCount > 99 ? '99+' : alertCount.toString());
                },
              ),
              child: const Icon(Icons.notifications),
            ),
            tooltip: 'Notifications',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Calendar'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildAnalyticsTab(),
                  _buildCalendarTab(),
                  _buildReportsTab(),
                ],
              ),

              Positioned(
                left: fabOffset.dx,
                top: fabOffset.dy,
                child: Draggable(
                  // The data payload for the draggable (can be anything)
                  data: 'draggable-fab',
                  // What the user sees while dragging
                  feedback: FloatingActionButton.extended(
                    onPressed: () {}, // onPressed is typically disabled in feedback
                    backgroundColor: AppColors.primary.withOpacity(0.7), // Slightly transparent
                    icon: const Icon(Icons.add),
                    label: const Text('Quick Actions'),
                  ),
                  // What remains in place of the original when dragging
                  childWhenDragging: Container(), // Hides the original during drag
                  // The actual widget that is being dragged
                  child: FloatingActionButton.extended(
                    onPressed: _showQuickActions,
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add),
                    label: const Text('Quick Actions'),
                  ),
                  onDragEnd: (details) {
                    setState(() {
                      double fabWidth = 160.0; // Approximate width of FAB.extended
                      double fabHeight = 56.0; // Approximate height of FAB.extended
                      double newDx = details.offset.dx;
                      double newDy = details.offset.dy - AppBar().preferredSize.height; // Subtract app bar height if Stack is under app bar
                      // Ensure the FAB stays within screen bounds (optional, but good UX)
                      newDx = newDx.clamp(0.0, screenSize.width - fabWidth);
                      newDy = newDy.clamp(0.0, screenSize.height - fabHeight - AppBar().preferredSize.height);
                      fabOffset = Offset(newDx, newDy);
                    });
                  },
                ),
              ),
            ],
          ),
      drawer: _buildDrawer(),
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

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics Cards
            _buildKeyMetricsSection(),
            const SizedBox(height: 24),

            // Alerts and Notifications
            _buildAlertsSection(),
            const SizedBox(height: 24),

            // Today's Events
            _buildTodaysEventsSection(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStatsSection(),
            const SizedBox(height: 24),

            // Recent Activities
            _buildRecentActivitiesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Consumer3<OccasionProvider, StockProvider, EmployeeProvider>(
      builder: (context, occasionProvider, stockProvider, employeeProvider,
          child) {
        final occasionStats = occasionProvider.getOccasionStatistics();
        final stockSummary = stockProvider.getStockSummary();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Revenue',
                    '\$${occasionStats['totalRevenue'].toStringAsFixed(0)}',
                    Icons.attach_money,
                    AppColors.success,
                    'This Month',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Active Events',
                    occasionStats['upcomingOccasions'].toString(),
                    Icons.event,
                    AppColors.primary,
                    'Upcoming',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Equipment Items',
                    stockSummary['totalEquipment'].toString(),
                    Icons.inventory,
                    AppColors.info,
                    '${stockSummary['availableEquipment']} Available',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Stock Value',
                    '\$${stockSummary['totalStockValue'].toStringAsFixed(0)}',
                    Icons.assessment,
                    AppColors.warning,
                    '${stockSummary['lowStockArticles']} Low Stock',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Consumer2<OccasionProvider, EquipmentBookingProvider>(
      builder: (context, occasionProvider, bookingProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait([
            Future.value(occasionProvider.getOccasionsRequiringAttention()),
            bookingProvider.getEquipmentAlerts(),
          ]).then((results) => [...results[0], ...results[1]]),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoAlertsCard();
            }

            final alerts = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Alerts & Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showAllAlerts,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...alerts.take(3).map((alert) => _buildAlertCard(alert)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNoAlertsCard() {
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Good!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'No alerts or notifications at the moment',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color alertColor = _getAlertColor(alert['priority']);
    IconData alertIcon = _getAlertIcon(alert['type']);

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
        onTap: () => _handleAlertTap(alert),
      ),
    );
  }

  Widget _buildTodaysEventsSection() {
    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final todaysEvents = provider.getTodaysOccasions();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Today\'s Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (todaysEvents.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Events Today',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        'Enjoy your free day!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todaysEvents.map((event) => _buildEventCard(event)),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(OccasionModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(event.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event,
            color: _getStatusColor(event.status),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${event.clientName} • ${event.expectedGuests} guests'),
            Text(
              DateFormat('HH:mm').format(event.date),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(event.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _navigateToEventDetails(event),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Consumer2<OccasionProvider, StockProvider>(
      builder: (context, occasionProvider, stockProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatItem(
                        'Equipment Utilization',
                        '${stockProvider
                            .getEquipmentUtilizationRate()
                            .toStringAsFixed(1)}%',
                        Icons.trending_up,
                        AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStatItem(
                        'Avg Order Value',
                        '\$${occasionProvider
                            .getOccasionStatistics()['averageOrderValue']
                            .toStringAsFixed(0)}',
                        Icons.monetization_on,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon,
      Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final recentOccasions = provider.occasions
            .where((o) =>
            o.updatedAt.isAfter(
                DateTime.now().subtract(const Duration(days: 7))))
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            if (recentOccasions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent activities',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...recentOccasions.map((occasion) =>
                  _buildActivityItem(occasion)),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(OccasionModel occasion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(occasion.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          occasion.title,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          'Updated ${_getTimeAgo(occasion.updatedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          occasion.status.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: _getStatusColor(occasion.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Revenue Chart
          _buildRevenueChart(),
          const SizedBox(height: 24),

          // Equipment Utilization
          _buildEquipmentUtilizationSection(),
          const SizedBox(height: 24),

          // Popular Items
          _buildPopularItemsSection(),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final monthlyRevenue = provider.getMonthlyRevenue(DateTime
            .now()
            .year);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Revenue',
                  style: TextStyle(
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
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec'
                              ];
                              return Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            },
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

  List<FlSpot> _generateRevenueSpots(Map<String, double> monthlyRevenue) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 12; i++) {
      String monthKey = '${DateTime
          .now()
          .year}-${(i + 1).toString().padLeft(2, '0')}';
      double revenue = monthlyRevenue[monthKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), revenue));
    }
    return spots;
  }


  Widget _buildEquipmentUtilizationSection() {
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
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
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
                    const Row(
                      children: [
                        Text(
                          'Equipment Utilization',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'This Month',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Summary stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildUtilizationStat(
                            'Average',
                            '${stats['averageUtilization'].toStringAsFixed(1)}%',
                            AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: _buildUtilizationStat(
                            'Fully Booked',
                            '${stats['fullyBookedTypes']}',
                            AppColors.error,
                          ),
                        ),
                        Expanded(
                          child: _buildUtilizationStat(
                            'Available',
                            '${stats['totalEquipmentTypes'] - stats['fullyBookedTypes']}',
                            AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Top utilized equipment
                    const Text(
                      'Most Utilized Equipment:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...report.take(3).map((item) => _buildUtilizationItem(item)),

                    if (report.length > 3)
                      TextButton(
                        onPressed: () => _showFullUtilizationReport(report),
                        child: Text('View All ${report.length} Items'),
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

  Widget _buildPopularItemsSection() {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        final meals = provider.meals.take(5).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Meals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...meals.map((meal) => _buildPopularMealItem(meal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularMealItem(meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  meal.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${meal.sellingPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: EquipmentBookingCalendarWidget(),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Filters
          _buildReportFilters(),
          const SizedBox(height: 24),

          // Financial Report
          _buildFinancialReportSection(),
          const SizedBox(height: 24),

          // Equipment Report
          _buildEquipmentReportSection(),
          const SizedBox(height: 24),

          // Export Options
          _buildExportSection(),
        ],
      ),
    );
  }

  Widget _buildReportFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'This Week',
                    onPressed: () => _generateReport('week'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'This Month',
                    onPressed: () => _generateReport('month'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'This Year',
                    onPressed: () => _generateReport('year'),
                    outlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialReportSection() {
    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getProfitReport(startOfMonth, endOfMonth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final report = snapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Report - This Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialMetric(
                            'Total Revenue',
                            '${report['totalRevenue'].toStringAsFixed(2)}',
                            Icons.trending_up,
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildFinancialMetric(
                            'Total Cost',
                            '${report['totalCost'].toStringAsFixed(2)}',
                            Icons.trending_down,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialMetric(
                            'Net Profit',
                            '${report['totalProfit'].toStringAsFixed(2)}',
                            Icons.attach_money,
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildFinancialMetric(
                            'Profit Margin',
                            '${report['profitMargin'].toStringAsFixed(1)}%',
                            Icons.percent,
                            AppColors.info,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Profit trend indicator
                    LinearProgressIndicator(
                      value: (report['profitMargin'] / 100).clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        report['profitMargin'] > 20 ? AppColors.success :
                        report['profitMargin'] > 10 ? AppColors.warning : AppColors.error,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Based on ${report['totalOccasions']} completed events',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _buildFinancialMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentReportSection() {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Equipment Status Report',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                _buildEquipmentStatusOverview(provider),

                const SizedBox(height: 16),

                const Text(
                  'Low Stock Alerts:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ...provider.getLowStockArticles().take(3).map((article) =>
                    _buildLowStockItem(article)),

                if (provider.getLowStockArticles().length > 3)
                  TextButton(
                    onPressed: _showAllLowStockItems,
                    child: Text('View All ${provider.getLowStockArticles().length} Items'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentStatusOverview(StockProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildEquipmentStatusCard(
            'Total Equipment',
            provider.equipment.length.toString(),
            Icons.inventory,
            AppColors.info,
          ),
        ),
        Expanded(
          child: _buildEquipmentStatusCard(
            'Available',
            provider.getAvailableEquipment().length.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        Expanded(
          child: _buildEquipmentStatusCard(
            'Checked Out',
            provider.getFullyCheckedOutEquipment().length.toString(),
            Icons.output,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentStatusCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(article) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              article.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${article.quantity} ${article.unit}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Export PDF',
                    onPressed: _exportPDF,
                    icon: Icons.picture_as_pdf,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Export Excel',
                    onPressed: _exportExcel,
                    icon: Icons.table_chart,
                    outlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return AppColors.info;
      case 'confirmed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Action methods
  void _showNotifications() {
    // Navigate to notifications screen
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Notifications'),
        content: Text('Full notifications screen would be implemented here'),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Create New Event'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to create event
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OccasionManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Add Equipment'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add equipment
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Add Meal'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add meal
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Add Articles'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add meal
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Employee'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add employee
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllAlerts() {
    // Navigate to full alerts screen
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    // Handle alert tap based on type
    if (alert['occasionId'] != null) {
      // Navigate to occasion details
    }
  }

  void _navigateToEventDetails(OccasionModel event) {
    // Navigate to event details screen
  }

  void _showFullUtilizationReport(List<Map<String, dynamic>> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipment Utilization Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: report.length,
            itemBuilder: (context, index) {
              return _buildUtilizationItem(report[index]);
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

  void _showAllLowStockItems() {
    // Navigate to inventory management
  }

  void _generateReport(String period) {
    // Generate report for the specified period
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $period report...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportPDF() {
    // Export current reports to PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting to PDF...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportExcel() {
    // Export current reports to Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting to Excel...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

