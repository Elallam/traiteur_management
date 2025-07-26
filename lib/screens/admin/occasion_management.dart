import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/stock_provider.dart';

class OccasionManagementScreen extends StatefulWidget {
  const OccasionManagementScreen({Key? key}) : super(key: key);

  @override
  State<OccasionManagementScreen> createState() => _OccasionManagementScreenState();
}

class _OccasionManagementScreenState extends State<OccasionManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    await Future.wait([
      occasionProvider.loadOccasions(),
      stockProvider.loadMeals(),
      stockProvider.loadEquipment(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Occasion Management',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'Dashboard'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Consumer<OccasionProvider>(
        builder: (context, occasionProvider, child) {
          if (occasionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (occasionProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${occasionProvider.errorMessage}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    onPressed: _loadData,
                    width: 120,
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOccasionsTab(occasionProvider),
              _buildDashboardTab(occasionProvider),
              _buildAnalyticsTab(occasionProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOccasionDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'New Event',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOccasionsTab(OccasionProvider occasionProvider) {
    return Column(
      children: [
        _buildSearchAndFilter(occasionProvider),
        Expanded(
          child: _buildOccasionsList(occasionProvider),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(OccasionProvider occasionProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search occasions...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', occasionProvider.occasions.length),
                _buildFilterChip('planned', 'Planned',
                    occasionProvider.getOccasionsByStatus('planned').length),
                _buildFilterChip('confirmed', 'Confirmed',
                    occasionProvider.getOccasionsByStatus('confirmed').length),
                _buildFilterChip('in_progress', 'In Progress',
                    occasionProvider.getOccasionsByStatus('in_progress').length),
                _buildFilterChip('completed', 'Completed',
                    occasionProvider.getOccasionsByStatus('completed').length),
                _buildFilterChip('upcoming', 'Upcoming',
                    occasionProvider.getUpcomingOccasions().length),
                _buildFilterChip('today', 'Today',
                    occasionProvider.getTodaysOccasions().length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        checkmarkColor: AppColors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildOccasionsList(OccasionProvider occasionProvider) {
    List<OccasionModel> filteredOccasions = _getFilteredOccasions(occasionProvider);

    if (filteredOccasions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No occasions found for "$_searchQuery"'
                  : 'No occasions found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add First Event',
              onPressed: () => _showAddOccasionDialog(context),
              width: 160,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOccasions.length,
      itemBuilder: (context, index) {
        final occasion = filteredOccasions[index];
        return _buildOccasionCard(occasion, occasionProvider);
      },
    );
  }

  List<OccasionModel> _getFilteredOccasions(OccasionProvider occasionProvider) {
    List<OccasionModel> occasions = [];

    switch (_selectedFilter) {
      case 'all':
        occasions = occasionProvider.occasions;
        break;
      case 'upcoming':
        occasions = occasionProvider.getUpcomingOccasions();
        break;
      case 'today':
        occasions = occasionProvider.getTodaysOccasions();
        break;
      default:
        occasions = occasionProvider.getOccasionsByStatus(_selectedFilter);
    }

    if (_searchQuery.isNotEmpty) {
      occasions = occasionProvider.searchOccasions(_searchQuery);
    }

    return occasions;
  }

  Widget _buildOccasionCard(OccasionModel occasion, OccasionProvider occasionProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOccasionDetails(occasion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      occasion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusChip(occasion.status),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleOccasionAction(value, occasion, occasionProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date and Client
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(occasion.date),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      occasion.clientName,
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Location and Guests
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      occasion.address,
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.group, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${occasion.expectedGuests} guests',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Total Price',
                      '\$${occasion.totalPrice.toStringAsFixed(2)}',
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Profit',
                      '\$${occasion.profit.toStringAsFixed(2)}',
                      occasion.profit >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Margin',
                      '${occasion.profitPercentage.toStringAsFixed(1)}%',
                      occasion.profitPercentage >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              if (occasion.isToday || occasion.isUpcoming || occasion.isOverdue) ...[
                const SizedBox(height: 8),
                _buildAlertBanner(occasion),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'planned':
        color = AppColors.warning;
        label = 'Planned';
        break;
      case 'confirmed':
        color = AppColors.info;
        label = 'Confirmed';
        break;
      case 'in_progress':
        color = AppColors.primary;
        label = 'In Progress';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'Completed';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(OccasionModel occasion) {
    Color color;
    String message;
    IconData icon;

    if (occasion.isToday) {
      color = AppColors.info;
      message = 'Event is today!';
      icon = Icons.today;
    } else if (occasion.isOverdue) {
      color = AppColors.error;
      message = 'Overdue by ${occasion.daysUntil.abs()} days';
      icon = Icons.warning;
    } else if (occasion.isUpcoming) {
      color = AppColors.warning;
      message = 'In ${occasion.daysUntil} days';
      icon = Icons.schedule;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(OccasionProvider occasionProvider) {
    final stats = occasionProvider.getOccasionStatistics();
    final alerts = occasionProvider.getOccasionsRequiringAttention();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Overview
          _buildStatsGrid(stats),
          const SizedBox(height: 24),
          // Alerts
          if (alerts.isNotEmpty) ...[
            _buildSectionHeader('Requires Attention', alerts.length),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertCard(alert)),
            const SizedBox(height: 24),
          ],
          // Quick Actions
          _buildSectionHeader('Quick Actions', null),
          const SizedBox(height: 12),
          _buildQuickActions(occasionProvider),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Total Events', stats['totalOccasions'].toString(),
            Icons.event, AppColors.primary),
        _buildStatCard('Upcoming', stats['upcomingOccasions'].toString(),
            Icons.schedule, AppColors.warning),
        _buildStatCard('Today', stats['todaysOccasions'].toString(),
            Icons.today, AppColors.info),
        _buildStatCard('Completed', stats['completedOccasions'].toString(),
            Icons.check_circle, AppColors.success),
        _buildStatCard('Total Revenue', '\$${stats['totalRevenue'].toStringAsFixed(0)}',
            Icons.attach_money, AppColors.success),
        _buildStatCard('Total Profit', '\$${stats['totalProfit'].toStringAsFixed(0)}',
            Icons.trending_up, AppColors.success),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color color;
    switch (alert['priority']) {
      case 'urgent':
        color = AppColors.error;
        break;
      case 'high':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showOccasionDetails(alert['occasion']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      alert['message'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(OccasionProvider occasionProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'New Event',
                Icons.add_circle,
                AppColors.primary,
                    () => _showAddOccasionDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'View Calendar',
                Icons.calendar_view_month,
                AppColors.info,
                    () {
                  // TODO: Navigate to calendar view
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Export Report',
                Icons.file_download,
                AppColors.success,
                    () {
                  // TODO: Export functionality
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Settings',
                Icons.settings,
                AppColors.textSecondary,
                    () {
                  // TODO: Navigate to settings
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(OccasionProvider occasionProvider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _handleOccasionAction(String action, OccasionModel occasion, OccasionProvider occasionProvider) {
    switch (action) {
      case 'view':
        _showOccasionDetails(occasion);
        break;
      case 'edit':
        _showAddOccasionDialog(context, occasion: occasion);
        break;
      case 'duplicate':
        _duplicateOccasion(occasion);
        break;
      case 'delete':
        _showDeleteConfirmation(occasion, occasionProvider);
        break;
    }
  }

  void _showOccasionDetails(OccasionModel occasion) {
    // TODO: Navigate to occasion details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening details for ${occasion.title}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAddOccasionDialog(BuildContext context, {OccasionModel? occasion}) {
    // TODO: Show add/edit occasion dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(occasion == null ? 'Opening new event form' : 'Opening edit form'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _duplicateOccasion(OccasionModel occasion) {
    // TODO: Implement duplication logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating ${occasion.title}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteConfirmation(OccasionModel occasion, OccasionProvider occasionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${occasion.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await occasionProvider.deleteOccasion(occasion.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}