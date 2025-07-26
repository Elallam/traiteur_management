// lib/screens/admin/enhanced_occasion_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../models/equipment_model.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../providers/auth_provider.dart';

class EnhancedOccasionDetailsScreen extends StatefulWidget {
  final OccasionModel occasion;

  const EnhancedOccasionDetailsScreen({
    Key? key,
    required this.occasion,
  }) : super(key: key);

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
              tooltip: 'Checkout Equipment',
            ),
          if (widget.occasion.status == 'completed' && _hasCheckedOutEquipment())
            IconButton(
              onPressed: _showEquipmentReturnDialog,
              icon: const Icon(Icons.assignment_return),
              tooltip: 'Return Equipment',
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Event'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate Event'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (widget.occasion.status != 'completed')
                const PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(
                    leading: Icon(Icons.cancel, color: AppColors.error),
                    title: Text('Cancel Event'),
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
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Meals'),
            Tab(text: 'Equipment'),
            Tab(text: 'Timeline'),
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
    Color statusColor = _getStatusColor(widget.occasion.status);
    IconData statusIcon = _getStatusIcon(widget.occasion.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.occasion.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    _getStatusDescription(widget.occasion.status),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (widget.occasion.isUpcoming)
                    Text(
                      'In ${widget.occasion.daysUntil} day(s)',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.occasion.status != 'completed' && widget.occasion.status != 'cancelled')
              _buildStatusChangeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.event, 'Date & Time',
                DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.date)),
            _buildDetailRow(Icons.location_on, 'Address', widget.occasion.address),
            _buildDetailRow(Icons.group, 'Expected Guests',
                widget.occasion.expectedGuests.toString()),
            _buildDetailRow(Icons.description, 'Description',
                widget.occasion.description),
            if (widget.occasion.notes != null)
              _buildDetailRow(Icons.note, 'Notes', widget.occasion.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person, 'Name', widget.occasion.clientName),
            _buildDetailRow(Icons.phone, 'Phone', widget.occasion.clientPhone),
            _buildDetailRow(Icons.email, 'Email', widget.occasion.clientEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
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
                  child: _buildFinancialItem(
                    'Total Cost',
                    '\$${widget.occasion.totalCost.toStringAsFixed(2)}',
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    'Total Price',
                    '\$${widget.occasion.totalPrice.toStringAsFixed(2)}',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildFinancialItem(
                    'Profit',
                    '\$${widget.occasion.profit.toStringAsFixed(2)}',
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
              'Profit Margin: ${widget.occasion.profitPercentage.toStringAsFixed(1)}%',
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
            const Text(
              'Equipment Status',
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
                  child: _buildEquipmentStatusItem(
                    'Total Items',
                    totalItems.toString(),
                    AppColors.info,
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildEquipmentStatusItem(
                    'Checked Out',
                    checkedOutItems.toString(),
                    AppColors.warning,
                    Icons.output,
                  ),
                ),
                Expanded(
                  child: _buildEquipmentStatusItem(
                    'Returned',
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
            subtitle: Text('Quantity: ${meal.quantity}'),
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
                  'Total: \$${meal.totalPrice.toStringAsFixed(2)}',
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
                Text('Quantity: ${equipment.quantity}'),
                Text(
                  'Status: ${equipment.status.toUpperCase()}',
                  style: TextStyle(
                    color: _getEquipmentStatusColor(equipment.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (equipment.checkoutDate != null)
                  Text(
                    'Checked out: ${DateFormat('MMM dd, HH:mm').format(equipment.checkoutDate!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (equipment.returnDate != null)
                  Text(
                    'Returned: ${DateFormat('MMM dd, HH:mm').format(equipment.returnDate!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: equipment.status == 'checked_out'
                ? IconButton(
              onPressed: () => _returnSingleEquipment(equipment),
              icon: const Icon(Icons.assignment_return, color: AppColors.success),
              tooltip: 'Return Equipment',
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
    List<Map<String, dynamic>> events = [];

    // Event created
    events.add({
      'title': 'Event Created',
      'description': 'Event was created in the system',
      'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.createdAt),
      'color': AppColors.info,
    });

    // Equipment assignments
    if (widget.occasion.equipment.isNotEmpty) {
      events.add({
        'title': 'Equipment Assigned',
        'description': '${widget.occasion.equipment.length} equipment items assigned',
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
        'title': 'Equipment Checked Out',
        'description': '${checkedOutEquipment.length} items checked out',
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(checkoutDate),
        'color': AppColors.error,
      });
    }

    // Event scheduled
    if (widget.occasion.date.isAfter(DateTime.now())) {
      events.add({
        'title': 'Event Scheduled',
        'description': 'Event is scheduled to take place',
        'time': DateFormat('MMM dd, yyyy • HH:mm').format(widget.occasion.date),
        'color': AppColors.primary,
      });
    } else {
      events.add({
        'title': 'Event Completed',
        'description': 'Event took place',
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
        'title': 'Equipment Returned',
        'description': '${returnedEquipment.length} items returned',
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
    String nextStatus = _getNextStatus(widget.occasion.status);
    if (nextStatus.isEmpty) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () => _changeStatus(nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getStatusColor(nextStatus),
      ),
      child: Text('Mark as ${nextStatus.toUpperCase()}'),
    );
  }

  Widget _buildBottomActions() {
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
                text: 'Checkout Equipment',
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
                text: 'Return Equipment',
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
    switch (status.toLowerCase()) {
      case 'planned':
        return 'Event is being planned';
      case 'confirmed':
        return 'Event is confirmed and ready';
      case 'in_progress':
        return 'Event is currently happening';
      case 'completed':
        return 'Event has been completed';
      case 'cancelled':
        return 'Event has been cancelled';
      default:
        return 'Unknown status';
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
    setState(() {
      _isLoading = true;
    });

    try {
      final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
      bool success = await occasionProvider.updateOccasionStatus(widget.occasion.id, newStatus);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return with result
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Equipment'),
        content: const Text(
          'This will check out all assigned equipment for this event. '
              'Make sure the equipment is ready for pickup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkoutEquipment();
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkoutEquipment() async {
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
          const SnackBar(
            content: Text('Equipment checked out successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to checkout equipment: $e'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Equipment'),
        content: const Text(
          'This will return all checked out equipment for this event. '
              'Make sure all equipment has been collected and is in good condition.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _returnEquipment();
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnEquipment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);

      bool success = await bookingProvider.autoReturnEquipment(widget.occasion.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment returned successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to return equipment: $e'),
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