// lib/screens/admin/dashboard_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/stock_provider.dart';

class DashboardNotificationsScreen extends StatefulWidget {
  const DashboardNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<DashboardNotificationsScreen> createState() => _DashboardNotificationsScreenState();
}

class _DashboardNotificationsScreenState extends State<DashboardNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);

      // Load all alerts
      final occasionAlerts = occasionProvider.getOccasionsRequiringAttention();
      final equipmentAlerts = await bookingProvider.getEquipmentAlerts();
      final stockAlerts = _generateStockAlerts(stockProvider);

      setState(() {
        _allAlerts = [...occasionAlerts, ...equipmentAlerts, ...stockAlerts];
        _allAlerts.sort((a, b) => _getPriorityOrder(b['priority']).compareTo(_getPriorityOrder(a['priority'])));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading alerts: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _generateStockAlerts(StockProvider stockProvider) {
    List<Map<String, dynamic>> alerts = [];

    // Low stock alerts
    final lowStockArticles = stockProvider.getLowStockArticles();
    for (var article in lowStockArticles) {
      alerts.add({
        'type': 'low_stock',
        'title': 'Low Stock Alert',
        'message': '${article.name} is running low (${article.quantity} ${article.unit} remaining)',
        'priority': 'medium',
        'data': article,
        'category': 'inventory',
      });
    }

    // Equipment maintenance alerts (if any equipment needs attention)
    final fullyCheckedOut = stockProvider.getFullyCheckedOutEquipment();
    for (var equipment in fullyCheckedOut) {
      alerts.add({
        'type': 'equipment_unavailable',
        'title': 'Equipment Fully Booked',
        'message': '${equipment.name} is fully checked out',
        'priority': 'low',
        'data': equipment,
        'category': 'equipment',
      });
    }

    return alerts;
  }

  int _getPriorityOrder(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 3;
      case 'high':
        return 2;
      case 'medium':
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Alerts',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Mark All as Read'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All (${_allAlerts.length})'),
            Tab(text: 'Urgent (${_getAlertsByPriority('urgent').length})'),
            Tab(text: 'Events (${_getAlertsByCategory('events').length})'),
            Tab(text: 'Equipment (${_getAlertsByCategory('equipment').length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAllAlertsTab(),
          _buildUrgentAlertsTab(),
          _buildEventsAlertsTab(),
          _buildEquipmentAlertsTab(),
        ],
      ),
    );
  }

  Widget _buildAllAlertsTab() {
    if (_allAlerts.isEmpty) {
      return _buildNoAlertsView();
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allAlerts.length,
        itemBuilder: (context, index) {
          return _buildAlertCard(_allAlerts[index], index);
        },
      ),
    );
  }

  Widget _buildUrgentAlertsTab() {
    final urgentAlerts = _getAlertsByPriority('urgent');

    if (urgentAlerts.isEmpty) {
      return _buildNoAlertsView(message: 'No urgent alerts at the moment');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: urgentAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(urgentAlerts[index], index);
      },
    );
  }

  Widget _buildEventsAlertsTab() {
    final eventAlerts = _getAlertsByCategory('events');

    if (eventAlerts.isEmpty) {
      return _buildNoAlertsView(message: 'No event alerts');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(eventAlerts[index], index);
      },
    );
  }

  Widget _buildEquipmentAlertsTab() {
    final equipmentAlerts = _getAlertsByCategory('equipment');

    if (equipmentAlerts.isEmpty) {
      return _buildNoAlertsView(message: 'No equipment alerts');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equipmentAlerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(equipmentAlerts[index], index);
      },
    );
  }

  Widget _buildNoAlertsView({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No alerts at the moment',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    Color alertColor = _getAlertColor(alert['priority']);
    IconData alertIcon = _getAlertIcon(alert['type']);

    return Dismissible(
      key: Key('alert_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _allAlerts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert dismissed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _allAlerts.insert(index, alert);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _handleAlertTap(alert),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: alertColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                // Alert icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(alertIcon, color: alertColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Alert content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: alertColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: alertColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert['priority'].toUpperCase(),
                              style: TextStyle(
                                color: alertColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['message'],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getAlertTimeText(alert),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          if (_hasQuickAction(alert))
                            _buildQuickActionButton(alert),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(Map<String, dynamic> alert) {
    String actionText = _getQuickActionText(alert['type']);

    return CustomButton(
      text: actionText,
      onPressed: () => _handleQuickAction(alert),
      height: 28,
      fontSize: 10,
      backgroundColor: _getAlertColor(alert['priority']),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getAlertsByPriority(String priority) {
    return _allAlerts.where((alert) => alert['priority'].toLowerCase() == priority.toLowerCase()).toList();
  }

  List<Map<String, dynamic>> _getAlertsByCategory(String category) {
    return _allAlerts.where((alert) {
      switch (category) {
        case 'events':
          return ['today', 'overdue', 'upcoming'].contains(alert['type']);
        case 'equipment':
          return ['urgent_checkout', 'upcoming_checkout', 'equipment_unavailable'].contains(alert['type']);
        case 'inventory':
          return ['low_stock'].contains(alert['type']);
        default:
          return true;
      }
    }).toList();
  }

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
        return Icons.pending_actions;
      case 'upcoming':
        return Icons.upcoming;
      case 'urgent_checkout':
        return Icons.priority_high;
      case 'upcoming_checkout':
        return Icons.schedule;
      case 'low_stock':
        return Icons.inventory_2;
      case 'equipment_unavailable':
        return Icons.block;
      default:
        return Icons.notification_important;
    }
  }

  String _getAlertTimeText(Map<String, dynamic> alert) {
    switch (alert['type']) {
      case 'today':
        return 'Today';
      case 'overdue':
        return 'Overdue';
      case 'upcoming':
        if (alert['data'] != null && alert['data'] is Map) {
          final occasion = alert['data']['occasion'] as OccasionModel?;
          if (occasion != null) {
            return 'In ${occasion.daysUntil} day(s)';
          }
        }
        return 'Upcoming';
      case 'urgent_checkout':
        if (alert['data'] != null && alert['data']['hoursUntil'] != null) {
          return 'In ${alert['data']['hoursUntil']} hour(s)';
        }
        return 'Soon';
      case 'upcoming_checkout':
        return 'Tomorrow';
      default:
        return 'Now';
    }
  }

  bool _hasQuickAction(Map<String, dynamic> alert) {
    return ['urgent_checkout', 'upcoming_checkout', 'low_stock'].contains(alert['type']);
  }

  String _getQuickActionText(String type) {
    switch (type) {
      case 'urgent_checkout':
      case 'upcoming_checkout':
        return 'Checkout';
      case 'low_stock':
        return 'Restock';
      default:
        return 'Action';
    }
  }

  // Action handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        setState(() {
          _allAlerts.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All alerts marked as read'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case 'settings':
        _showNotificationSettings();
        break;
    }
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    switch (alert['type']) {
      case 'today':
      case 'overdue':
      case 'upcoming':
        if (alert['occasion'] != null) {
          // Navigate to occasion details
          _navigateToOccasionDetails(alert['occasion']);
        }
        break;
      case 'urgent_checkout':
      case 'upcoming_checkout':
        if (alert['occasionId'] != null) {
          // Navigate to equipment checkout screen
          _navigateToEquipmentCheckout(alert['occasionId']);
        }
        break;
      case 'low_stock':
        if (alert['data'] != null) {
          // Navigate to inventory management
          _navigateToInventoryManagement(alert['data']);
        }
        break;
      case 'equipment_unavailable':
        if (alert['data'] != null) {
          // Navigate to equipment management
          _navigateToEquipmentManagement(alert['data']);
        }
        break;
    }
  }

  void _handleQuickAction(Map<String, dynamic> alert) {
    switch (alert['type']) {
      case 'urgent_checkout':
      case 'upcoming_checkout':
        _showEquipmentCheckoutDialog(alert);
        break;
      case 'low_stock':
        _showRestockDialog(alert);
        break;
    }
  }

  void _showEquipmentCheckoutDialog(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipment Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checkout equipment for this event?'),
            const SizedBox(height: 8),
            if (alert['data'] != null && alert['data']['occasion'] != null) ...[
              Text(
                'Event: ${alert['data']['occasion'].title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Equipment Items: ${alert['data']['equipmentCount']}'),
              Text('Total Quantity: ${alert['data']['totalItems']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performEquipmentCheckout(alert);
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(Map<String, dynamic> alert) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restock Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alert['data'] != null) ...[
              Text('Item: ${alert['data'].name}'),
              Text('Current Stock: ${alert['data'].quantity} ${alert['data'].unit}'),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Add Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (quantityController.text.isNotEmpty) {
                Navigator.pop(context);
                await _performRestock(alert, int.parse(quantityController.text));
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Event Reminders'),
              subtitle: const Text('Get notified about upcoming events'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Equipment Alerts'),
              subtitle: const Text('Equipment checkout and availability alerts'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Stock Alerts'),
              subtitle: const Text('Low stock and inventory alerts'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToOccasionDetails(OccasionModel occasion) {
    Navigator.pushNamed(
      context,
      '/occasion-details',
      arguments: occasion,
    );
  }

  void _navigateToEquipmentCheckout(String occasionId) {
    Navigator.pushNamed(
      context,
      '/equipment-checkout',
      arguments: occasionId,
    );
  }

  void _navigateToInventoryManagement(dynamic articleData) {
    Navigator.pushNamed(
      context,
      '/inventory-management',
      arguments: articleData,
    );
  }

  void _navigateToEquipmentManagement(dynamic equipmentData) {
    Navigator.pushNamed(
      context,
      '/equipment-management',
      arguments: equipmentData,
    );
  }

  // Action performers
  Future<void> _performEquipmentCheckout(Map<String, dynamic> alert) async {
    try {
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

      // Simulate equipment checkout
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment checked out successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      // Remove alert from list
      setState(() {
        _allAlerts.removeWhere((a) => a == alert);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to checkout equipment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _performRestock(Map<String, dynamic> alert, int quantity) async {
    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);

      if (alert['data'] != null) {
        final article = alert['data'];
        final newQuantity = article.quantity + quantity;

        bool success = await stockProvider.updateArticleQuantity(
          article.id,
          newQuantity,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $quantity ${article.unit} to ${article.name}'),
              backgroundColor: AppColors.success,
            ),
          );

          // Remove alert if stock is no longer low
          if (newQuantity >= 10) {
            setState(() {
              _allAlerts.removeWhere((a) => a == alert);
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restock: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// Notification Badge Widget for AppBar
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    Key? key,
    required this.count,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}