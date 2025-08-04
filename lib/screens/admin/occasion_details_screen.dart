import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../providers/occasion_provider.dart';
import 'add_edit_occaion_screen.dart';

class OccasionDetailsScreen extends StatefulWidget {
  final OccasionModel occasion;

  const OccasionDetailsScreen({Key? key, required this.occasion}) : super(key: key);

  @override
  State<OccasionDetailsScreen> createState() => _OccasionDetailsScreenState();
}

class _OccasionDetailsScreenState extends State<OccasionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OccasionModel _occasion;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _occasion = widget.occasion;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverFillRemaining(
            child: Column(
              children: [
                _buildStatusBar(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _occasion.title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                bottom: 80,
                child: Icon(
                  Icons.event,
                  size: 80,
                  color: AppColors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) =>
          [
            const PopupMenuItem(value: 'edit', child: Text('Edit Event')),
            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            const PopupMenuItem(value: 'share', child: Text('Share Details')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'delete', child: Text('Delete Event')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
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
          // Event Date & Time
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(
                      _occasion.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusChip(_occasion.status),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Info
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoItem(
                  Icons.group,
                  'Guests',
                  _occasion.expectedGuests.toString(),
                ),
              ),
              Expanded(
                child: _buildQuickInfoItem(
                  Icons.attach_money,
                  'Total Price',
                  '\${_occasion.totalPrice.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildQuickInfoItem(
                  Icons.trending_up,
                  'Profit',
                  '\${_occasion.profit.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),

          // Alert Banner
          if (_occasion.isToday || _occasion.isUpcoming ||
              _occasion.isOverdue) ...[
            const SizedBox(height: 12),
            _buildAlertBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildAlertBanner() {
    Color color;
    String message;
    IconData icon;

    if (_occasion.isToday) {
      color = AppColors.info;
      message = '🎉 Event is today!';
      icon = Icons.today;
    } else if (_occasion.isOverdue) {
      color = AppColors.error;
      message = '⚠️ Event is overdue by ${_occasion.daysUntil.abs()} days';
      icon = Icons.warning;
    } else if (_occasion.isUpcoming) {
      color = AppColors.warning;
      message = '📅 Event is in ${_occasion.daysUntil} days';
      icon = Icons.schedule;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Meals'),
          Tab(text: 'Equipment'),
          Tab(text: 'Client'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildMealsTab(),
        _buildEquipmentTab(),
        _buildClientTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSectionCard(
            'Event Description',
            Icons.description,
            child: Text(
              _occasion.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Location
          _buildSectionCard(
            'Location',
            Icons.location_on,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _occasion.address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Open in Maps',
                  onPressed: _openInMaps,
                  icon: Icons.map,
                  outlined: true,
                  width: 150,
                  height: 40,
                ),
              ],
            ),
          ),

          // Financial Summary
          _buildSectionCard(
            'Financial Summary',
            Icons.account_balance_wallet,
            child: Column(
              children: [
                _buildFinancialRow(
                    'Total Cost', _occasion.totalCost, AppColors.error),
                const SizedBox(height: 8),
                _buildFinancialRow(
                    'Total Price', _occasion.totalPrice, AppColors.success),
                const Divider(),
                _buildFinancialRow('Profit', _occasion.profit,
                    _occasion.profit >= 0 ? AppColors.success : AppColors
                        .error),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profit Margin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_occasion.profit.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _occasion.profit >= 0 ? AppColors
                            .success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notes
          if (_occasion.notes != null && _occasion.notes!.isNotEmpty) ...[
            _buildSectionCard(
              'Notes',
              Icons.note,
              child: Text(
                _occasion.notes!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu, color: AppColors.primary,
                      size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_occasion.meals.length} Meal(s) Selected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Total: \${_occasion.meals.fold(0.0, (sum, meal) => sum + meal.totalPrice).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Meals List
          ..._occasion.meals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildMealCard(OccasionMeal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.mealName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${meal.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Unit Price: \${meal.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\${meal.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: AppColors.info, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_occasion.equipment.length} Equipment Item(s)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Total Quantity: ${_occasion.equipment.fold(0, (sum,
                              eq) => sum + eq.quantity)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Equipment List
          ..._occasion.equipment.map((equipment) =>
              _buildEquipmentCard(equipment)),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(OccasionEquipment equipment) {
    Color statusColor;
    String statusLabel;

    switch (equipment.status) {
      case 'assigned':
        statusColor = AppColors.warning;
        statusLabel = 'Assigned';
        break;
      case 'checked_out':
        statusColor = AppColors.info;
        statusLabel = 'Checked Out';
        break;
      case 'returned':
        statusColor = AppColors.success;
        statusLabel = 'Returned';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = equipment.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.equipmentName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${equipment.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (equipment.checkoutDate != null) ...[
                    Text(
                      'Checked out: ${DateFormat('MMM dd, HH:mm').format(
                          equipment.checkoutDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Information
          _buildSectionCard(
            'Client Information',
            Icons.person,
            child: Column(
              children: [
                _buildClientInfoRow('Name', _occasion.clientName, Icons.person),
                const SizedBox(height: 12),
                _buildClientInfoRow('Phone', _occasion.clientPhone, Icons.phone,
                    onTap: () => _launchPhone(_occasion.clientPhone)),
                const SizedBox(height: 12),
                _buildClientInfoRow('Email', _occasion.clientEmail, Icons.email,
                    onTap: () => _launchEmail(_occasion.clientEmail)),
              ],
            ),
          ),

          // Contact Actions
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Call Client',
                  onPressed: () => _launchPhone(_occasion.clientPhone),
                  icon: Icons.phone,
                  backgroundColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Send Email',
                  onPressed: () => _launchEmail(_occasion.clientEmail),
                  icon: Icons.email,
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon,
      {required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '\${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoRow(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: onTap != null ? AppColors.primary : AppColors
                          .textPrimary,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              Icon(Icons.launch, color: AppColors.primary, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Edit Event',
              onPressed: _editOccasion,
              outlined: true,
              icon: Icons.edit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: _getStatusActionText(),
              onPressed: _handleStatusAction,
              backgroundColor: _getStatusActionColor(),
              icon: _getStatusActionIcon(),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusActionText() {
    switch (_occasion.status) {
      case 'planned':
        return 'Confirm';
      case 'confirmed':
        return 'Start Event';
      case 'in_progress':
        return 'Complete';
      case 'completed':
        return 'Completed';
      default:
        return 'Update Status';
    }
  }

  Color _getStatusActionColor() {
    switch (_occasion.status) {
      case 'planned':
        return AppColors.info;
      case 'confirmed':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusActionIcon() {
    switch (_occasion.status) {
      case 'planned':
        return Icons.check;
      case 'confirmed':
        return Icons.play_arrow;
      case 'in_progress':
        return Icons.flag;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.update;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editOccasion();
        break;
      case 'duplicate':
        _duplicateOccasion();
        break;
      case 'share':
        _shareOccasion();
        break;
      case 'delete':
        _deleteOccasion();
        break;
    }
  }

  void _editOccasion() {
    showDialog(
      context: context,
      builder: (context) => AddOccasionDialog(occasion: _occasion),
    ).then((result) {
      if (result == true) {
        // Refresh the occasion data
        Navigator.pop(context, true);
      }
    });
  }

  void _duplicateOccasion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duplicating event...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _shareOccasion() {
    final shareText = '''
Event: ${_occasion.title}
Date: ${DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(_occasion.date)}
Location: ${_occasion.address}
Client: ${_occasion.clientName}
Guests: ${_occasion.expectedGuests}
Total: ${_occasion.totalPrice.toStringAsFixed(2)}
''';

    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _deleteOccasion() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Event'),
            content: Text('Are you sure you want to delete "${_occasion
                .title}"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final occasionProvider = Provider.of<OccasionProvider>(
                      context, listen: false);
                  final success = await occasionProvider.deleteOccasion(
                      _occasion.id);

                  if (success) {
                    Navigator.pop(context, true);
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

  void _handleStatusAction() {
    if (_occasion.status == 'completed') return;

    String nextStatus;
    String message;

    switch (_occasion.status) {
      case 'planned':
        nextStatus = 'confirmed';
        message = 'Event confirmed successfully';
        break;
      case 'confirmed':
        nextStatus = 'in_progress';
        message = 'Event started successfully';
        break;
      case 'in_progress':
        nextStatus = 'completed';
        message = 'Event completed successfully';
        break;
      default:
        return;
    }

    _updateStatus(nextStatus, message);
  }

  Future<void> _updateStatus(String newStatus, String message) async {
    final occasionProvider = Provider.of<OccasionProvider>(
        context, listen: false);
    final success = await occasionProvider.updateOccasionStatus(
        _occasion.id, newStatus);

    if (success) {
      setState(() {
        _occasion = _occasion.copyWith(status: newStatus);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              occasionProvider.errorMessage ?? 'Failed to update status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openInMaps() async {
    final url = 'https://maps.google.com/?q=${Uri.encodeComponent(
        _occasion.address)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone app'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email?subject=${Uri.encodeComponent(
        "Regarding: ${_occasion.title}")}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch email app'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}