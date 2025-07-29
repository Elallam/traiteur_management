import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:traiteur_management/screens/admin/profit_analytics_screen.dart';
import 'package:traiteur_management/screens/admin/stock_management.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/equipment_booking_calendar_widget.dart';
import '../../core/widgets/language_selector.dart';
import '../../generated/l10n/app_localizations.dart'; // Ensure this import is correct
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
    // Initialize TabController with 4 tabs for Dashboard, Analytics, Calendar, Reports
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Asynchronously loads all necessary dashboard data from providers
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Wait for all data loading operations to complete
      await Future.wait([
        Provider.of<OccasionProvider>(context, listen: false).loadOccasions(),
        Provider.of<StockProvider>(context, listen: false).loadAllStockData(),
        Provider.of<EmployeeProvider>(context, listen: false).loadEmployees(),
      ]);
    } catch (e) {
      // Handle any errors during data loading and show a SnackBar
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n!.error}: $e'), // Localized error message
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false once data is loaded or error occurs
      });
    }

    // Load equipment booking calendar for the current month
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
    final l10n = AppLocalizations.of(context); // Access localized strings
    final Size screenSize = MediaQuery.of(context).size;
    Offset fabOffset = Offset(
      MediaQuery.of(context).size.width - 150, // Default FAB position (right)
      MediaQuery.of(context).size.height - 200, // Default FAB position (bottom)
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.adminDashboard), // Localized app bar title
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh, // Localized tooltip
          ),
          // Notifications button with badge
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
            tooltip: l10n.notifications, // Localized tooltip
          ),
          // Language selector button
          const LanguageSelector(showAsDialog: true),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.dashboard), // Localized tab title
            Tab(text: l10n.analytics), // Localized tab title
            Tab(text: l10n.equipmentBooking), // Localized tab title for Calendar
            Tab(text: l10n.exportReports), // Localized tab title for Reports
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: Text(l10n.loading)) // Localized loading message
          : TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildAnalyticsTab(),
              _buildCalendarTab(),
              _buildReportsTab(),
            ],
          ),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }

  // Builds the navigation drawer for the dashboard
  Widget _buildDrawer() {
    final l10n = AppLocalizations.of(context);

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
                      authProvider.currentUser?.fullName ?? l10n!.admin, // Localized default name
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
              // Drawer items with localized titles and navigation
              _buildDrawerItem(Icons.dashboard, l10n!.dashboard, () => Navigator.pop(context)),
              _buildDrawerItem(Icons.people, l10n.employees, () {
                Navigator.pop(context);
                _navigateToSection(0); // Navigate to Employee Management
              }),
              _buildDrawerItem(Icons.inventory, l10n.stock, () {
                Navigator.pop(context);
                _navigateToSection(1); // Navigate to Stock Management
              }),
              _buildDrawerItem(Icons.event, l10n.occasions, () {
                Navigator.pop(context);
                _navigateToSection(2); // Navigate to Occasion Management
              }),
              _buildDrawerItem(Icons.analytics, l10n.analytics, () {
                Navigator.pop(context);
                _navigateToSection(3); // Navigate to Profit Analytics
              }),
              const Divider(),
              _buildDrawerItem(Icons.settings, l10n.settings, () => Navigator.pop(context)),
              _buildDrawerItem(Icons.logout, l10n.logout, () async {
                Navigator.pop(context);
                await authProvider.signOut(); // Sign out the user
              }),
            ],
          );
        },
      ),
    );
  }

  // Helper method to build a single drawer item
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, size: 20),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }

  // Navigates to different sections of the app based on index
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

  // Builds the Overview tab content
  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _loadDashboardData, // Allow refreshing data
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

  // Builds the Key Metrics section with localized titles and subtitles
  Widget _buildKeyMetricsSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer3<OccasionProvider, StockProvider, EmployeeProvider>(
      builder: (context, occasionProvider, stockProvider, employeeProvider, child) {
        final occasionStats = occasionProvider.getOccasionStatistics();
        final stockSummary = stockProvider.getStockSummary();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n!.keyMetrics, // Localized "Key Metrics"
              style: const TextStyle(
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
                    l10n.totalRevenue, // Localized "Total Revenue"
                    '\$${occasionStats['totalRevenue'].toStringAsFixed(0)}',
                    Icons.attach_money,
                    AppColors.success,
                    l10n.thisMonth, // Localized "This Month"
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    l10n.activeEvents, // Localized "Active Events"
                    occasionStats['upcomingOccasions'].toString(),
                    Icons.event,
                    AppColors.primary,
                    l10n.upcoming, // Localized "Upcoming"
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '${l10n.equipment} ${l10n.itemsCount(0).split(' ')[1]}', // Localized "Equipment Items"
                    stockSummary['totalEquipment'].toString(),
                    Icons.inventory,
                    AppColors.info,
                    '${stockSummary['availableEquipment']} ${l10n.available}', // Localized "Available"
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    l10n.stockValue, // Localized "Stock Value"
                    '\$${stockSummary['totalStockValue'].toStringAsFixed(0)}',
                    Icons.assessment,
                    AppColors.warning,
                    '${stockSummary['lowStockArticles']} ${l10n.lowStock}', // Localized "Low Stock"
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper method to build a single metric card
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

  // Builds the Alerts and Notifications section
  Widget _buildAlertsSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer2<OccasionProvider, EquipmentBookingProvider>(
      builder: (context, occasionProvider, bookingProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait([
            Future.value(occasionProvider.getOccasionsRequiringAttention()),
            bookingProvider.getEquipmentAlerts(),
          ]).then((results) => [...results[0], ...results[1]]),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoAlertsCard(); // Show card for no alerts
            }

            final alerts = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${l10n!.notifications} & ${l10n.lowStockAlerts.split(' ')[0]}', // Localized "Notifications & Alerts"
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showAllAlerts,
                      child: Text('${l10n.view} ${l10n.viewAll.split(' ')[1]}'), // Localized "View All"
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...alerts.take(3).map((alert) => _buildAlertCard(alert)), // Display top 3 alerts
              ],
            );
          },
        );
      },
    );
  }

  // Builds the card displayed when there are no alerts
  Widget _buildNoAlertsCard() {
    final l10n = AppLocalizations.of(context);

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
                    l10n!.allGood, // Localized "All Good!"
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    l10n.noAlertsMessage, // Localized "No alerts or notifications at the moment"
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

  // Builds a single alert card
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

  // Builds the Today's Events section
  Widget _buildTodaysEventsSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final todaysEvents = provider.getTodaysOccasions();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n!.todaysEvents, // Localized "Today's Events"
                  style: const TextStyle(
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
                      Text(
                        l10n.noEventsToday, // Localized "No Events Today"
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        l10n.enjoyFreeDay, // Localized "Enjoy your free day!"
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todaysEvents.map((event) => _buildEventCard(event)), // Display today's events
          ],
        );
      },
    );
  }

  // Builds a single event card for today's events
  Widget _buildEventCard(OccasionModel event) {
    final l10n = AppLocalizations.of(context);

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
            Text('${event.clientName} • ${l10n!.guestsCount(event.expectedGuests)}'), // Localized guests count
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
            _getLocalizedStatus(event.status, l10n).toUpperCase(),
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

  // Helper to get localized status string
  String _getLocalizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.active;
      case 'inactive':
        return l10n.inactive;
      case 'available':
        return l10n.available;
      case 'unavailable':
        return l10n.unavailable;
      case 'booked':
        return l10n.booked;
      case 'pending':
        return l10n.pending;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  // Builds the Quick Stats section
  Widget _buildQuickStatsSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer2<OccasionProvider, StockProvider>(
      builder: (context, occasionProvider, stockProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n!.quickStats, // Localized "Quick Stats"
                  style: const TextStyle(
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
                        l10n.equipmentUtilization, // Localized "Equipment Utilization"
                        '${stockProvider
                            .getEquipmentUtilizationRate()
                            .toStringAsFixed(1)}%',
                        Icons.trending_up,
                        AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStatItem(
                        l10n.averageOrderValue, // Localized "Avg Order Value"
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

  // Helper method to build a single quick stat item
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

  // Builds the Recent Activities section
  Widget _buildRecentActivitiesSection() {
    final l10n = AppLocalizations.of(context);

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
            Text(
              l10n!.recentActivities, // Localized "Recent Activities"
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            if (recentOccasions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noRecentActivities, // Localized "No recent activities"
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...recentOccasions.map((occasion) =>
                  _buildActivityItem(occasion)), // Display recent activities
          ],
        );
      },
    );
  }

  // Builds a single activity item for recent activities
  Widget _buildActivityItem(OccasionModel occasion) {
    final l10n = AppLocalizations.of(context);

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
          l10n!.updatedAgo(
              _getTimeAgo(occasion.updatedAt)), // Localized "Updated X ago"
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          _getLocalizedStatus(occasion.status, l10n).toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: _getStatusColor(occasion.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Builds the Analytics tab content
  Widget _buildAnalyticsTab() {
    final l10n = AppLocalizations.of(context);

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

  // Builds the Monthly Revenue Chart
  Widget _buildRevenueChart() {
    final l10n = AppLocalizations.of(context);

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final monthlyRevenue = provider.getMonthlyRevenue(DateTime.now().year);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n!.monthlyRevenue, // Localized "Monthly Revenue"
                  style: const TextStyle(
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
                              final months = [
                                l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
                                l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december
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

  // Generates FlSpot data for the revenue chart
  List<FlSpot> _generateRevenueSpots(Map<String, double> monthlyRevenue) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 12; i++) {
      String monthKey = '${DateTime.now().year}-${(i + 1).toString().padLeft(2, '0')}';
      double revenue = monthlyRevenue[monthKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), revenue));
    }
    return spots;
  }

  // Builds the Equipment Utilization section
  Widget _buildEquipmentUtilizationSection() {
    final l10n = AppLocalizations.of(context);

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
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text(l10n!.loading)), // Localized loading message
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
                    Row(
                      children: [
                        Text(
                          l10n!.equipmentUtilization, // Localized "Equipment Utilization"
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.thisMonth, // Localized "This Month"
                          style: const TextStyle(
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
                            l10n.average, // Localized "Average"
                            '${stats['averageUtilization'].toStringAsFixed(1)}%',
                            AppColors.info,
                          ),
                        ),
                        Expanded(
                          child: _buildUtilizationStat(
                            l10n.fullyBooked, // Localized "Fully Booked"
                            '${stats['fullyBookedTypes']}',
                            AppColors.error,
                          ),
                        ),
                        Expanded(
                          child: _buildUtilizationStat(
                            l10n.available, // Localized "Available"
                            '${stats['totalEquipmentTypes'] - stats['fullyBookedTypes']}',
                            AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Top utilized equipment
                    Text(
                      l10n.mostUtilizedEquipment, // Localized "Most Utilized Equipment:"
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...report.take(3).map((item) => _buildUtilizationItem(item)),

                    if (report.length > 3)
                      TextButton(
                        onPressed: () => _showFullUtilizationReport(report),
                        child: Text('${l10n.view} ${l10n.allGood.split(' ')[1]} ${l10n.itemsCount(report.length)}'), // Localized "View All X Items"
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

  // Helper method to build a single utilization stat item
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

  // Builds a single utilization item with a progress bar
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

  // Builds the Popular Items section
  Widget _buildPopularItemsSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        final meals = provider.meals.take(5).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n!.popular} ${l10n.meals}', // Localized "Popular Meals"
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...meals.map((meal) => _buildPopularMealItem(meal)), // Display popular meals
              ],
            ),
          ),
        );
      },
    );
  }

  // Builds a single popular meal item
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

  // Builds the Calendar tab content (Equipment Booking Calendar)
  Widget _buildCalendarTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: EquipmentBookingCalendarWidget(),
    );
  }

  // Builds the Reports tab content
  Widget _buildReportsTab() {
    final l10n = AppLocalizations.of(context);

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

  // Builds the Report Filters section
  Widget _buildReportFilters() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n!.reportFilters, // Localized "Report Filters"
              style: const TextStyle(
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
                    text: l10n.thisWeek, // Localized "This Week"
                    onPressed: () => _generateReport('week'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: l10n.thisMonth, // Localized "This Month"
                    onPressed: () => _generateReport('month'),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: l10n.thisYear, // Localized "This Year"
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

  // Builds the Financial Report section
  Widget _buildFinancialReportSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        return FutureBuilder<Map<String, dynamic>>(
          future: provider.getProfitReport(startOfMonth, endOfMonth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text(l10n!.loading)), // Localized loading message
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
                    Text(
                      '${l10n!.financialReport} - ${l10n.thisMonth}', // Localized "Financial Report - This Month"
                      style: const TextStyle(
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
                            l10n.totalRevenue, // Localized "Total Revenue"
                            '${report['totalRevenue'].toStringAsFixed(2)}',
                            Icons.trending_up,
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildFinancialMetric(
                            l10n.totalCost, // Localized "Total Cost"
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
                            '${l10n.netProfit}', // Localized "Net Profit"
                            '${report['totalProfit'].toStringAsFixed(2)}',
                            Icons.attach_money,
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildFinancialMetric(
                            l10n.profitMargin, // Localized "Profit Margin"
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
                      l10n.basedOnEvents(report['totalOccasions']), // Localized "Based on X completed events"
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

  // Helper method to build a single financial metric card
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

  // Builds the Equipment Status Report section
  Widget _buildEquipmentReportSection() {
    final l10n = AppLocalizations.of(context);

    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n!.equipmentStatusReport, // Localized "Equipment Status Report"
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                _buildEquipmentStatusOverview(provider),

                const SizedBox(height: 16),

                Text(
                  l10n.lowStockAlerts, // Localized "Low Stock Alerts:"
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ...provider.getLowStockArticles().take(3).map((article) =>
                    _buildLowStockItem(article)), // Display top 3 low stock items

                if (provider.getLowStockArticles().length > 3)
                  TextButton(
                    onPressed: _showAllLowStockItems,
                    child: Text('${l10n.view} ${l10n.allGood.split(' ')[1]} ${l10n.itemsCount(provider.getLowStockArticles().length)}'), // Localized "View All X Items"
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Builds the equipment status overview cards
  Widget _buildEquipmentStatusOverview(StockProvider provider) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildEquipmentStatusCard(
            '${l10n!.total} ${l10n.equipment}', // Localized "Total Equipment"
            provider.equipment.length.toString(),
            Icons.inventory,
            AppColors.info,
          ),
        ),
        Expanded(
          child: _buildEquipmentStatusCard(
            l10n.available, // Localized "Available"
            provider.getAvailableEquipment().length.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        Expanded(
          child: _buildEquipmentStatusCard(
            l10n.checkedOut, // Localized "Checked Out"
            provider.getFullyCheckedOutEquipment().length.toString(),
            Icons.output,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  // Helper method to build a single equipment status card
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

  // Builds a single low stock item
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

  // Builds the Export Reports section
  Widget _buildExportSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n!.exportReports, // Localized "Export Reports"
              style: const TextStyle(
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
                    text: l10n.exportPdf, // Localized "Export PDF"
                    onPressed: _exportPDF,
                    icon: Icons.picture_as_pdf,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: l10n.exportExcel, // Localized "Export Excel"
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

  // Helper methods for colors, icons, and time formatting
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
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays > 0) {
      return l10n.updatedAgo('${difference.inDays}${l10n.dayAbbreviation}'); // Example: "2d ago"
    } else if (difference.inHours > 0) {
      return l10n.updatedAgo('${difference.inHours}${l10n.hourAbbreviation}'); // Example: "3h ago"
    } else if (difference.inMinutes > 0) {
      return l10n.updatedAgo('${difference.inMinutes}${l10n.minuteAbbreviation}'); // Example: "5m ago"
    } else {
      return l10n.justNow; // Localized "Just now"
    }
  }

  // Action methods for various interactions
  void _showNotifications() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n!.notifications), // Localized title
        content: Text(l10n.noAlertsMessage), // Using an existing localized string for content
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close), // Localized "Close"
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n!.quickActions, // Localized "Quick Actions"
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: Text(l10n.createNewEvent), // Localized "Create New Event"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OccasionManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: Text(l10n.addEquipment), // Localized "Add Equipment"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(l10n.addMeal), // Localized "Add Meal"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(l10n.addArticle), // Localized "Add Article"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.addEmployee), // Localized "Add Employee"
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllAlerts() {
    // Implement navigation to full alerts screen
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n!.viewAll} ${l10n.notifications}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    // Handle alert tap based on type, navigate to specific details
    if (alert['occasionId'] != null) {
      // Example: Navigate to occasion details
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n!.occasionDetails}: ${alert['occasionId']}'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  void _navigateToEventDetails(OccasionModel event) {
    // Implement navigation to event details screen
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n!.occasionDetails}: ${event.title}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showFullUtilizationReport(List<Map<String, dynamic>> report) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n!.equipment} ${l10n.utilizationReport}'), // Localized title
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
            child: Text(l10n.close), // Localized "Close"
          ),
        ],
      ),
    );
  }

  void _showAllLowStockItems() {
    // Implement navigation to inventory management for low stock items
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n!.viewAll} ${l10n.lowStockAlerts}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _generateReport(String period) {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n!.generatingReport(period)), // Localized report generation message
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportPDF() {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n!.exportingToPdf), // Localized PDF export message
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportExcel() {
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n!.exportingToExcel), // Localized Excel export message
        backgroundColor: AppColors.info,
      ),
    );
  }
}
