import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/admin/employee/equipment_requests_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/dashboard/analytics/revenue_chart_widget.dart';
import '../../core/widgets/dashboard/common/equipment_utilization_widget.dart';
import '../../core/widgets/dashboard/common/popular_items_widget.dart';
import '../../core/widgets/dashboard/reports/equipment_report_widget.dart';
import '../../core/widgets/dashboard/reports/export_section_widget.dart';
import '../../core/widgets/dashboard/reports/financial_report_widget.dart';
import '../../core/widgets/dashboard/reports/report_filters_widget.dart';
import '../../core/widgets/equipment_booking_calendar_widget.dart';
import '../../core/widgets/language_selector.dart';
import '../../core/widgets/dashboard/dashboard_drawer.dart';
import '../../core/widgets/dashboard/overview/key_metrics_section.dart';
import '../../core/widgets/dashboard/overview/alerts_section.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/occasion_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/notification_provider.dart';
import 'employee_management.dart';
import 'occasion_management.dart';
import 'stock_management.dart';
import 'profit_analytics_screen.dart';
import 'equipment_approval_screen.dart';

/// Enhanced Admin Dashboard - Refactored version
/// Main dashboard coordinator that manages state and orchestrates components
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads all necessary dashboard data from providers
  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

      await Future.wait([
        occasionProvider.loadOccasions(),
        stockProvider.loadAllStockData(),
        employeeProvider.loadEmployees(),
      ]);

      final now = DateTime.now();
      await bookingProvider.loadBookingCalendar(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      );
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(l10n),
      body: _isLoading
          ? _buildLoadingState(l10n)
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildCalendarTab(),
          _buildReportsTab(),
        ],
      ),
      drawer: const DashboardDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar with tabs and actions
  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.adminDashboard),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _loadDashboardData,
          icon: const Icon(Icons.refresh),
          tooltip: l10n.refresh,
        ),
        _buildNotificationBadge(l10n),
        const LanguageSelector(showAsDialog: true),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: l10n.dashboard),
          Tab(text: l10n.analytics),
          Tab(text: l10n.equipmentBooking),
          Tab(text: l10n.exportReports),
        ],
      ),
    );
  }

  /// Builds the notification icon with badge
  Widget _buildNotificationBadge(AppLocalizations l10n) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return IconButton(
          onPressed: _showNotifications,
          icon: Badge(
            label: Text(
                notificationProvider.unreadCount > 99
                    ? '99+'
                    : notificationProvider.unreadCount.toString()
            ),
            child: const Icon(Icons.notifications),
          ),
          tooltip: l10n.notifications,
        );
      },
    );
  }

  /// Builds the loading state widget
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.loading),
        ],
      ),
    );
  }

  /// Builds the floating action button for quick actions
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showQuickActions,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
    );
  }

  /// Builds the Overview tab with all dashboard sections
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics Section
            const KeyMetricsSection(),
            const SizedBox(height: 24),

            // Equipment Requests Card - NEW ADDITION
            const EquipmentRequestsCard(),
            const SizedBox(height: 24),

            // Alerts and Notifications Section
            AlertsSection(
              onViewAllPressed: _showAllAlerts,
              onAlertTapped: _handleNotificationTap,
            ),
            const SizedBox(height: 24),

            // Today's Events Section
            _buildTodaysEventsSection(),
            const SizedBox(height: 24),

            // Quick Stats Section
            _buildQuickStatsSection(),
            const SizedBox(height: 24),

            // Recent Activities Section
            _buildRecentActivitiesSection(),
          ],
        ),
      ),
    );
  }

  /// Builds Today's Events section
  Widget _buildTodaysEventsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final todaysEvents = provider.getTodaysOccasions();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.todaysEvents,
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
              _buildNoEventsCard(l10n)
            else
              ...todaysEvents.map((event) => _buildEventCard(event, l10n)),
          ],
        );
      },
    );
  }

  /// Builds the no events card
  Widget _buildNoEventsCard(AppLocalizations l10n) {
    return Card(
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
              l10n.noEventsToday,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              l10n.enjoyFreeDay,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single event card
  Widget _buildEventCard(OccasionModel event, AppLocalizations l10n) {
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
            Text('${event.clientName} • ${l10n.guestsCount(event.expectedGuests)}'),
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

  /// Builds Quick Stats section
  Widget _buildQuickStatsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<OccasionProvider, StockProvider>(
      builder: (context, occasionProvider, stockProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quickStats,
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
                        l10n.equipmentUtilization,
                        '${stockProvider.getEquipmentUtilizationRate().toStringAsFixed(1)}%',
                        Icons.trending_up,
                        AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStatItem(
                        l10n.averageOrderValue,
                        '${occasionProvider.getOccasionStatistics()['averageOrderValue'].toStringAsFixed(0)}',
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

  /// Builds a single quick stat item
  Widget _buildQuickStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18), // Smaller icon
        const SizedBox(width: 6), // Reduced spacing
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14, // Smaller font
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9, // Smaller font
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  /// Builds Recent Activities section
  Widget _buildRecentActivitiesSection() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OccasionProvider>(
      builder: (context, provider, child) {
        final recentOccasions = provider.occasions
            .where((o) => o.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recentActivities,
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
                    l10n.noRecentActivities,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...recentOccasions.map((occasion) => _buildActivityItem(occasion, l10n)),
          ],
        );
      },
    );
  }

  /// Builds a single activity item
  Widget _buildActivityItem(OccasionModel occasion, AppLocalizations l10n) {
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
          l10n.updatedAgo(_getTimeAgo(occasion.updatedAt)),
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

  /// Builds the Analytics tab content
  Widget _buildAnalyticsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          RevenueChartWidget(),
          SizedBox(height: 24),
          EquipmentUtilizationWidget(),
          SizedBox(height: 24),
          PopularItemsWidget(),
        ],
      ),
    );
  }

  /// Builds the Calendar tab content
  Widget _buildCalendarTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: EquipmentBookingCalendarWidget(),
    );
  }

  /// Builds the Reports tab content
  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ReportFiltersWidget(
            onFilterSelected: (period) {
              // Handle filter selection
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('generating report'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const FinancialReportWidget(),
          const SizedBox(height: 24),
          const EquipmentReportWidget(),
          const SizedBox(height: 24),
          const ExportSectionWidget(),
        ],
      ),
    );
  }

  // Helper methods and utilities

  /// Gets localized status string
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

  /// Gets status color for different states
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

  /// Formats time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays > 0) {
      return l10n.updatedAgo('${difference.inDays}${l10n.dayAbbreviation}');
    } else if (difference.inHours > 0) {
      return l10n.updatedAgo('${difference.inHours}${l10n.hourAbbreviation}');
    } else if (difference.inMinutes > 0) {
      return l10n.updatedAgo('${difference.inMinutes}${l10n.minuteAbbreviation}');
    } else {
      return l10n.justNow;
    }
  }

  // Action handlers

  /// Shows error snackbar
  void _showErrorSnackBar(String error) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.error}: $error'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Shows notifications dialog
  void _showNotifications() {
    final l10n = AppLocalizations.of(context)!;
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final notifications = notificationProvider.notifications;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.notifications),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notificationProvider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: notifications.isEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noAlertsMessage,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification, l10n);
            },
          ),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await notificationProvider.markAllAsRead(authProvider.currentUser!.id);
              },
              child: Text('Mark All Read'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAllAlerts();
              },
              child: Text(l10n.viewAll),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Builds a single notification item
  Widget _buildNotificationItem(Map<String, dynamic> notification, AppLocalizations l10n) {
    Color priorityColor = _getPriorityColor(notification['priority'] ?? 'medium');
    IconData priorityIcon = _getNotificationTypeIcon(notification['type'] ?? 'general');
    bool isRead = notification['isRead'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? null : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            priorityIcon,
            color: priorityColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'] ?? '',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification['createdAt']),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: priorityColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            (notification['priority'] ?? 'medium').toString().toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () async {
          if (!isRead) {
            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
            await notificationProvider.markAsRead(notification['id']);
          }
          Navigator.pop(context);
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  /// Gets priority color
  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  /// Gets priority icon
  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'equipment_checkout_request':
        return Icons.build_outlined;
      case 'today':
        return Icons.today;
      case 'overdue':
        return Icons.warning;
      case 'upcoming':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  /// Formats notification time
  String _formatNotificationTime(dynamic createdAt) {
    if (createdAt == null) return '';

    DateTime dateTime;
    if (createdAt is Timestamp) {
      dateTime = createdAt.toDate();
    } else if (createdAt is DateTime) {
      dateTime = createdAt;
    } else {
      return '';
    }

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

  /// Shows quick actions bottom sheet
  void _showQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.quickActions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionItem(Icons.event_note, l10n.createNewEvent, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OccasionManagementScreen()));
            }),
            _buildQuickActionItem(Icons.build, l10n.addEquipment, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
            }),
            _buildQuickActionItem(Icons.restaurant_menu, l10n.addMeal, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
            }),
            _buildQuickActionItem(Icons.inventory_2, l10n.addArticle, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockManagementScreen()));
            }),
            _buildQuickActionItem(Icons.person_add, l10n.addEmployee, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen()));
            }),
            _buildQuickActionItem(Icons.approval, l10n.reviewRequests, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EquipmentApprovalScreen()));
            }),
          ],
        ),
      ),
    );
  }

  /// Builds a quick action item
  Widget _buildQuickActionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  /// Shows all alerts
  void _showAllAlerts() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.viewAll} ${l10n.notifications}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// Handles alert tap
  void _handleNotificationTap(Map<String, dynamic> notification) {
    String? type = notification['type'];

    switch (type) {
      case 'equipment_checkout_request':
      // Navigate to equipment approval screen
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EquipmentApprovalScreen())
        );
        break;
      default:
        if (notification['occasionId'] != null) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.occasionDetails}: ${notification['occasionId']}'),
              backgroundColor: AppColors.info,
            ),
          );
        }
    }
  }

  /// Navigates to event details
  void _navigateToEventDetails(OccasionModel event) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.occasionDetails}: ${event.title}'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}