// lib/screens/admin/enhanced_occasion_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:traiteur_management/core/utils/helpers.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../models/equipment_model.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

class EnhancedOccasionDetailsScreen extends StatefulWidget {
  final OccasionModel occasion;

  const EnhancedOccasionDetailsScreen({
    super.key,
    required this.occasion,
  });

  @override
  State<EnhancedOccasionDetailsScreen> createState() => _EnhancedOccasionDetailsScreenState();
}

class _EnhancedOccasionDetailsScreenState extends State<EnhancedOccasionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.occasion.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Equipment checkout/return actions
          if (widget.occasion.status == 'confirmed' && _canCheckoutEquipment())
            IconButton(
              onPressed: _showEquipmentCheckoutDialog,
              icon: const Icon(Icons.inventory),
              tooltip: l10n.checkoutEquipment, // Localized
            ),
          if (widget.occasion.status == 'completed' && _hasCheckedOutEquipment())
            IconButton(
              onPressed: _showEquipmentReturnDialog,
              icon: const Icon(Icons.assignment_return),
              tooltip: l10n.returnEquipment, // Localized
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.editEvent), // Localized
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(l10n.duplicateEvent), // Localized
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (widget.occasion.status != 'completed')
                PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(
                    leading: const Icon(Icons.cancel, color: AppColors.error),
                    title: Text(l10n.cancelEvent), // Localized
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
            Tab(text: l10n.overview), // Localized
            Tab(text: l10n.meals), // Localized
            Tab(text: l10n.equipment), // Localized
            Tab(text: l10n.timeline), // Localized
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMealsTab(),
          _buildEquipmentTab(),
          _buildTimelineTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(),
          const SizedBox(height: 16),

          // Event Details
          _buildEventDetailsCard(),
          const SizedBox(height: 16),

          // Client Information
          _buildClientInfoCard(),
          const SizedBox(height: 16),

          // Financial Summary
          _buildFinancialSummaryCard(),
          const SizedBox(height: 16),

          // Equipment Status Summary
          _buildEquipmentStatusCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor = _getStatusColor(widget.occasion.status);
    IconData statusIcon = _getStatusIcon(widget.occasion.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24), // Reduced size
                ),
                const SizedBox(width: 12), // Reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatus(widget.occasion.status.toUpperCase()),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Prevent overflow
                        overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                      ),
                      const SizedBox(height: 4), // Added spacing
                      Text(
                        _getStatusDescription(widget.occasion.status),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2, // Allow for longer descriptions
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.occasion.isUpcoming) ...[
                        const SizedBox(height: 4), // Added spacing
                        Text(
                          l10n.inDays(widget.occasion.daysUntil),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            if (widget.occasion.status != 'completed' &&
                widget.occasion.status != 'cancelled')
              _buildStatusChangeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailsCard() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.eventDetails, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.event, l10n.dateTime, // Localized
                DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.date)),
            _buildDetailRow(Icons.location_on, l10n.address, widget.occasion.address), // Localized
            _buildDetailRow(Icons.group, l10n.expectedGuests, // Localized
                widget.occasion.expectedGuests.toString()),
            _buildDetailRow(Icons.description, l10n.description, // Localized
                widget.occasion.description),
            if (widget.occasion.notes != null)
              _buildDetailRow(Icons.note, l10n.notes, widget.occasion.notes!), // Localized
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.clientInformation, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person, l10n.name, widget.occasion.clientName), // Localized
            _buildDetailRow(Icons.phone, l10n.phone, widget.occasion.clientPhone), // Localized
            _buildDetailRow(Icons.email, l10n.email, widget.occasion.clientEmail), // Localized
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financialSummary, // Localized
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
                  child: _buildFinancialItem(
                    l10n.totalCost, // Localized
                    Helpers.formatMAD(widget.occasion.totalCost),
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    l10n.totalPrice, // Localized
                    Helpers.formatMAD(widget.occasion.totalPrice),
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    l10n.profit, // Localized
                    Helpers.formatMAD(widget.occasion.profit),
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.occasion.totalPrice > 0
                  ? widget.occasion.profit / widget.occasion.totalPrice
                  : 0,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.occasion.profit > 0 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.profitMarginValue(widget.occasion.profit.toStringAsFixed(1)), // Localized
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

  Widget _buildEquipmentStatusCard() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    final totalItems = widget.occasion.equipment.fold(0, (sum, eq) => sum + eq.quantity);
    final checkedOutItems = widget.occasion.equipment
        .where((eq) => eq.status == 'checked_out')
        .fold(0, (sum, eq) => sum + eq.quantity);
    final returnedItems = widget.occasion.equipment
        .where((eq) => eq.status == 'returned')
        .fold(0, (sum, eq) => sum + eq.quantity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.equipmentStatus, // Localized
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
                  child: _buildEquipmentStatusItem(
                    l10n.totalItems, // Localized
                    totalItems.toString(),
                    AppColors.info,
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildEquipmentStatusItem(
                    l10n.checkedOut, // Localized
                    checkedOutItems.toString(),
                    AppColors.warning,
                    Icons.output,
                  ),
                ),
                Expanded(
                  child: _buildEquipmentStatusItem(
                    l10n.returned, // Localized
                    returnedItems.toString(),
                    AppColors.success,
                    Icons.assignment_return,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsTab() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.occasion.meals.length,
      itemBuilder: (context, index) {
        final meal = widget.occasion.meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.restaurant, color: Colors.white),
            ),
            title: Text(meal.mealName),
            subtitle: Text(l10n.quantityValue(meal.quantity)), // Localized
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${meal.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.totalPriceValue(meal.totalPrice.toStringAsFixed(2)), // Localized
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
  }

  Widget _buildEquipmentTab() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.occasion.equipment.length,
      itemBuilder: (context, index) {
        final equipment = widget.occasion.equipment[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEquipmentStatusColor(equipment.status),
              child: Icon(
                _getEquipmentStatusIcon(equipment.status),
                color: Colors.white,
              ),
            ),
            title: Text(equipment.equipmentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.quantityValue(equipment.quantity)), // Localized
                Text(
                  l10n.statusValue(equipment.status.toUpperCase()), // Localized
                  style: TextStyle(
                    color: _getEquipmentStatusColor(equipment.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (equipment.checkoutDate != null)
                  Text(
                    l10n.checkedOutDate(DateFormat('MMM dd, HH:mm').format(equipment.checkoutDate!)), // Localized
                    style: const TextStyle(fontSize: 12),
                  ),
                if (equipment.returnDate != null)
                  Text(
                    l10n.returnedDate(DateFormat('MMM dd, HH:mm').format(equipment.returnDate!)), // Localized
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: equipment.status == 'checked_out'
                ? IconButton(
              onPressed: () => _returnSingleEquipment(equipment),
              icon: const Icon(Icons.assignment_return, color: AppColors.success),
              tooltip: l10n.returnEquipment, // Localized
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    List<Map<String, dynamic>> timelineEvents = _buildTimelineEvents();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timelineEvents.length,
      itemBuilder: (context, index) {
        final event = timelineEvents[index];
        final isLast = index == timelineEvents.length - 1;

        return _buildTimelineItem(event, isLast);
      },
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event, bool isLast) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: event['color'],
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (event['description'] != null)
                Text(
                  event['description'],
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              Text(
                event['time'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildTimelineEvents() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    List<Map<String, dynamic>> events = [];

    // Event created
    events.add({
      'title': l10n.eventCreated, // Localized
      'description': l10n.eventCreatedSystem, // Localized
      'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.createdAt),
      'color': AppColors.info,
    });

    // Equipment assignments
    if (widget.occasion.equipment.isNotEmpty) {
      events.add({
        'title': l10n.equipmentAssigned, // Localized
        'description': l10n.equipmentItemsAssigned(widget.occasion.equipment.length), // Localized
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.createdAt),
        'color': AppColors.warning,
      });
    }

    // Equipment checkouts
    final checkedOutEquipment = widget.occasion.equipment
        .where((eq) => eq.checkoutDate != null)
        .toList();

    if (checkedOutEquipment.isNotEmpty) {
      final checkoutDate = checkedOutEquipment.first.checkoutDate!;
      events.add({
        'title': l10n.equipmentCheckedOut, // Localized
        'description': l10n.itemsCheckedOut(checkedOutEquipment.length), // Localized
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(checkoutDate),
        'color': AppColors.error,
      });
    }

    // Event scheduled
    if (widget.occasion.date.isAfter(DateTime.now())) {
      events.add({
        'title': l10n.eventScheduled, // Localized
        'description': l10n.eventScheduledToTakePlace, // Localized
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.date),
        'color': AppColors.primary,
      });
    } else {
      events.add({
        'title': l10n.eventCompleted, // Localized
        'description': l10n.eventTookPlace, // Localized
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.date),
        'color': widget.occasion.status == 'completed' ? AppColors.success : AppColors.primary,
      });
    }

    // Equipment returns
    final returnedEquipment = widget.occasion.equipment
        .where((eq) => eq.returnDate != null)
        .toList();

    if (returnedEquipment.isNotEmpty) {
      final returnDate = returnedEquipment.first.returnDate!;
      events.add({
        'title': l10n.equipmentReturned, // Localized
        'description': l10n.itemsReturned(returnedEquipment.length), // Localized
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(returnDate),
        'color': AppColors.success,
      });
    }

    // Sort by time
    events.sort((a, b) {
      final aTime = DateFormat('MMM dd, yyyy • HH:mm').parse(a['time']);
      final bTime = DateFormat('MMM dd, yyyy • HH:mm').parse(b['time']);
      return aTime.compareTo(bTime);
    });

    return events;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
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

  Widget _buildEquipmentStatusItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
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
    );
  }

  Widget _buildStatusChangeButton() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    String nextStatus = _getNextStatus(widget.occasion.status);
    if (nextStatus.isEmpty) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () => _changeStatus(nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getStatusColor(nextStatus),
      ),
      child: Text(l10n.markAsStatus(_getStatus(nextStatus.toUpperCase()))), // Localized
    );
  }

  Widget _buildBottomActions() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    if (widget.occasion.status == 'cancelled' || widget.occasion.status == 'completed') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
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
          if (_canCheckoutEquipment())
            Expanded(
              child: CustomButton(
                text: l10n.checkoutEquipment, // Localized
                onPressed: _showEquipmentCheckoutDialog,
                backgroundColor: AppColors.warning,
                isLoading: _isLoading,
              ),
            ),
          if (_canCheckoutEquipment() && _hasCheckedOutEquipment())
            const SizedBox(width: 16),
          if (_hasCheckedOutEquipment())
            Expanded(
              child: CustomButton(
                text: l10n.returnEquipment, // Localized
                onPressed: _showEquipmentReturnDialog,
                backgroundColor: AppColors.success,
                isLoading: _isLoading,
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    switch (status.toLowerCase()) {
      case 'planned':
        return l10n.eventStatusPlanned; // Localized
      case 'confirmed':
        return l10n.eventStatusConfirmed; // Localized
      case 'in_progress':
        return l10n.eventStatusInProgress; // Localized
      case 'completed':
        return l10n.eventStatusCompleted; // Localized
      case 'cancelled':
        return l10n.eventStatusCancelled; // Localized
      default:
        return l10n.unknownStatus; // Localized
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'planned':
        return 'confirmed';
      case 'confirmed':
        return 'in_progress';
      case 'in_progress':
        return 'completed';
      default:
        return '';
    }
  }

  String _getStatus(String status) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    switch (status.toLowerCase()) {
      case 'planned':
        return l10n.planned; // Localized
      case 'confirmed':
        return l10n.confirmed; // Localized
      case 'in_progress':
        return l10n.inProgress; // Localized
      case 'completed':
        return l10n.completed; // Localized
      case 'cancelled':
        return l10n.cancelled; // Localized
      default:
        return l10n.unkown; // Localized
    }
  }


  Color _getEquipmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return AppColors.info;
      case 'checked_out':
        return AppColors.warning;
      case 'returned':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getEquipmentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Icons.assignment;
      case 'checked_out':
        return Icons.output;
      case 'returned':
        return Icons.assignment_return;
      default:
        return Icons.help;
    }
  }

  bool _canCheckoutEquipment() {
    return widget.occasion.equipment.any((eq) => eq.status == 'assigned');
  }

  bool _hasCheckedOutEquipment() {
    return widget.occasion.equipment.any((eq) => eq.status == 'checked_out');
  }

  // Action methods
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
      // Navigate to edit screen
        break;
      case 'duplicate':
        _duplicateOccasion();
        break;
      case 'cancel':
        _cancelOccasion();
        break;
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    setState(() {
      _isLoading = true;
    });

    try {
      final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
      bool success = await occasionProvider.updateOccasionStatus(widget.occasion.id, newStatus);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.statusUpdatedTo(newStatus.toUpperCase())), // Localized
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return with result
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToUpdateStatus}: $e'), // Localized
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEquipmentCheckoutDialog() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.checkoutEquipment), // Localized
        content: Text(
          l10n.checkoutEquipmentConfirmation, // Localized
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkoutEquipment();
            },
            child: Text(l10n.checkout), // Localized
          ),
        ],
      ),
    );
  }

  Future<void> _checkoutEquipment() async {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await bookingProvider.autoCheckoutEquipment(
        occasionId: widget.occasion.id,
        employeeId: authProvider.currentUser?.id ?? '',
        employeeName: authProvider.currentUser?.fullName ?? 'Admin',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.equipmentCheckedOutSuccessfully), // Localized
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToCheckoutEquipment}: $e'), // Localized
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEquipmentReturnDialog() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.returnEquipment), // Localized
        content: Text(
          l10n.returnEquipmentConfirmation, // Localized
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _returnEquipment();
            },
            child: Text(l10n.returnText), // Localized
          ),
        ],
      ),
    );
  }

  Future<void> _returnEquipment() async {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

      bool success = await bookingProvider.autoReturnEquipment(widget.occasion.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.equipmentReturnedSuccessfully), // Localized
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToReturnEquipment}: $e'), // Localized
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _returnSingleEquipment(OccasionEquipment equipment) async {
    // Implementation for returning single equipment item
    // This would need additional service methods
  }

  void _duplicateOccasion() {
    // Implementation for duplicating occasion
  }

  void _cancelOccasion() {
    // Implementation for cancelling occasion
  }
}
