// lib/screens/employee/equipment_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class EquipmentActivityScreen extends StatefulWidget {
  final String? employeeId;
  final String? employeeName;

  const EquipmentActivityScreen({
    Key? key,
    this.employeeId,
    this.employeeName,
  }) : super(key: key);

  @override
  State<EquipmentActivityScreen> createState() => _EquipmentActivityScreenState();
}

class _EquipmentActivityScreenState extends State<EquipmentActivityScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  List<EquipmentCheckout> _allCheckouts = [];
  List<EquipmentCheckout> _filteredCheckouts = [];
  Map<String, EquipmentModel> _equipmentCache = {};

  bool _isLoading = true;
  String _selectedFilter = 'All';
  DateTimeRange? _dateRange;

  final List<String> _filterOptions = ['All', 'Active', 'Returned', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterOptions.length, vsync: this);
    _loadActivityData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivityData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel? currentUser = authProvider.currentUser;

      String employeeId = widget.employeeId ?? currentUser?.id ?? '';

      if (employeeId.isNotEmpty) {
        _allCheckouts = await _firestoreService.getEmployeeCheckouts(employeeId);
        await _loadEquipmentDetails();
        _applyFilters();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load activity data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadEquipmentDetails() async {
    Set<String> equipmentIds = _allCheckouts.map((c) => c.equipmentId).toSet();

    for (String equipmentId in equipmentIds) {
      if (!_equipmentCache.containsKey(equipmentId)) {
        try {
          EquipmentModel equipment = await _firestoreService.getEquipmentById(equipmentId);
          _equipmentCache[equipmentId] = equipment;
        } catch (e) {
          // Handle missing equipment gracefully
          _equipmentCache[equipmentId] = EquipmentModel(
            id: equipmentId,
            name: 'Unknown Equipment',
            totalQuantity: 0,
            availableQuantity: 0,
            category: 'unknown',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCheckouts = _allCheckouts.where((checkout) {
        // Filter by status
        bool matchesStatus = true;
        switch (_selectedFilter) {
          case 'Active':
            matchesStatus = checkout.status == 'checked_out';
            break;
          case 'Returned':
            matchesStatus = checkout.status == 'returned';
            break;
          case 'Overdue':
            matchesStatus = checkout.isOverdue;
            break;
          case 'All':
          default:
            matchesStatus = true;
        }

        // Filter by date range
        bool matchesDateRange = true;
        if (_dateRange != null) {
          matchesDateRange = checkout.checkoutDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              checkout.checkoutDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }

        // Filter by search query
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          String query = _searchController.text.toLowerCase();
          EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];
          matchesSearch = equipment?.name.toLowerCase().contains(query) ?? false ||
              checkout.employeeName.toLowerCase().contains(query) ||
              checkout.notes!.toLowerCase().contains(query) ?? false;
        }

        return matchesStatus && matchesDateRange && matchesSearch;
      }).toList();

      // Sort by checkout date (newest first)
      _filteredCheckouts.sort((a, b) => b.checkoutDate.compareTo(a.checkoutDate));
    });
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _dateRange = null;
      _applyFilters();
    });
  }

  Future<void> _returnEquipment(EquipmentCheckout checkout) async {
    try {
      // Update checkout status using your existing method
      await _firestoreService.returnEquipment(checkout.id);

      // Get current equipment data and update availability
      EquipmentModel equipment = _equipmentCache[checkout.equipmentId]!;
      await _firestoreService.updateEquipmentAvailability(
          checkout.equipmentId,
          equipment.availableQuantity + checkout.quantity
      );

      // Update local cache
      _equipmentCache[checkout.equipmentId] = equipment.copyWith(
        availableQuantity: equipment.availableQuantity + checkout.quantity,
        updatedAt: DateTime.now(),
      );

      // Refresh data
      await _loadActivityData();
      _showSuccessSnackBar('Equipment returned successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to return equipment: $e');
    }
  }

  void _showReturnConfirmation(EquipmentCheckout checkout) {
    EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to return this equipment?'),
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
                  Text('Equipment: ${equipment?.name ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Quantity: ${checkout.quantity}'),
                  Text('Checked out: ${_formatDateTime(checkout.checkoutDate)}'),
                  Text('Duration: ${_formatDuration(checkout.checkoutDate)}'),
                  if (checkout.isOverdue)
                    const Text('Status: OVERDUE',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  if (checkout.notes != null && checkout.notes!.isNotEmpty)
                    Text('Notes: ${checkout.notes}'),
                ],
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

  void _showCheckoutDetails(EquipmentCheckout checkout) {
    EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              checkout.status == 'returned'
                  ? Icons.assignment_return
                  : Icons.shopping_cart,
              color: checkout.status == 'returned'
                  ? AppColors.success
                  : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                equipment?.name ?? 'Unknown Equipment',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', equipment?.category.toUpperCase() ?? 'UNKNOWN'),
              _buildDetailRow('Quantity', '${checkout.quantity}'),
              _buildDetailRow('Status', checkout.status.toUpperCase()),
              _buildDetailRow('Checkout Date', _formatDateTime(checkout.checkoutDate)),
              if (checkout.returnDate != null)
                _buildDetailRow('Return Date', _formatDateTime(checkout.returnDate!)),
              _buildDetailRow('Duration',
                  checkout.returnDate != null
                      ? _formatDurationBetween(checkout.checkoutDate, checkout.returnDate!)
                      : _formatDuration(checkout.checkoutDate)),
              if (checkout.occasionId != null)
                _buildDetailRow('Occasion ID', checkout.occasionId!),
              if (checkout.notes != null && checkout.notes!.isNotEmpty)
                _buildDetailRow('Notes', checkout.notes!),
              if (checkout.isOverdue && checkout.status == 'checked_out')
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This equipment is overdue for return',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (checkout.status == 'checked_out')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showReturnConfirmation(checkout);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('Return'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equipment Activity'),
          if (widget.employeeName != null)
            Text(
              widget.employeeName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.date_range),
              if (_dateRange != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _selectDateRange,
          tooltip: 'Filter by date range',
        ),
        if (_dateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearDateRange,
            tooltip: 'Clear date filter',
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadActivityData,
          tooltip: 'Refresh',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedFilter = _filterOptions[index];
            _applyFilters();
          });
        },
        tabs: _filterOptions.map((filter) {
          int count = _getFilterCount(filter);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filter),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getFilterColor(filter),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search and filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomTextField(
                controller: _searchController,
                label: 'Search equipment or notes...',
                prefixIcon: Icons.search,
                onChanged: (_) => _applyFilters(),
              ),
              if (_dateRange != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing ${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _clearDateRange,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Activity list
        Expanded(
          child: _filteredCheckouts.isEmpty
              ? _buildEmptyState()
              : _buildActivityList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    IconData icon;
    String title;
    String subtitle;

    switch (_selectedFilter) {
      case 'Active':
        icon = Icons.check_circle_outline;
        title = 'No active checkouts';
        subtitle = 'All equipment has been returned.';
        break;
      case 'Returned':
        icon = Icons.assignment_return_outlined;
        title = 'No returned items';
        subtitle = 'No equipment has been returned yet.';
        break;
      case 'Overdue':
        icon = Icons.schedule;
        title = 'No overdue items';
        subtitle = 'Great! All equipment is returned on time.';
        break;
      default:
        icon = Icons.history;
        title = 'No activity found';
        subtitle = 'No equipment activity matches your search.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredCheckouts.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(_filteredCheckouts[index]);
      },
    );
  }

  Widget _buildActivityCard(EquipmentCheckout checkout) {
    EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];
    bool isActive = checkout.status == 'checked_out';
    bool isOverdue = checkout.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCheckoutDetails(checkout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Equipment icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(equipment?.category ?? 'other').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(equipment?.category ?? 'other'),
                      color: _getCategoryColor(equipment?.category ?? 'other'),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Equipment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment?.name ?? 'Unknown Equipment',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${equipment?.category.toUpperCase() ?? 'UNKNOWN'} • ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(equipment?.category ?? 'other'),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Qty: ${checkout.quantity}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.error.withOpacity(0.1)
                          : isActive
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverdue
                          ? 'OVERDUE'
                          : checkout.status.toUpperCase(),
                      style: TextStyle(
                        color: isOverdue
                            ? AppColors.error
                            : isActive
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dates and duration
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.login, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Out: ${_formatDate(checkout.checkoutDate)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (checkout.returnDate != null)
                          Row(
                            children: [
                              const Icon(Icons.logout, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'In: ${_formatDate(checkout.returnDate!)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        checkout.returnDate != null
                            ? _formatDurationBetween(checkout.checkoutDate, checkout.returnDate!)
                            : _formatDuration(checkout.checkoutDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 2),
                        Text(
                          'ongoing',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Notes (if any)
              if (checkout.notes != null && checkout.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    checkout.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],

              // Action buttons for active checkouts
              if (isActive) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCheckoutDetails(checkout),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showReturnConfirmation(checkout),
                      icon: const Icon(Icons.assignment_return, size: 16),
                      label: const Text('Return'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _getFilterCount(String filter) {
    switch (filter) {
      case 'Active':
        return _allCheckouts.where((c) => c.status == 'checked_out').length;
      case 'Returned':
        return _allCheckouts.where((c) => c.status == 'returned').length;
      case 'Overdue':
        return _allCheckouts.where((c) => c.isOverdue).length;
      case 'All':
      default:
        return _allCheckouts.length;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Active':
        return AppColors.warning;
      case 'Returned':
        return AppColors.success;
      case 'Overdue':
        return AppColors.error;
      case 'All':
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chairs':
        return Colors.blue;
      case 'tables':
        return Colors.green;
      case 'utensils':
        return Colors.orange;
      case 'decorations':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chairs':
        return Icons.chair;
      case 'tables':
        return Icons.table_restaurant;
      case 'utensils':
        return Icons.restaurant;
      case 'decorations':
        return Icons.celebration;
      default:
        return Icons.inventory;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDuration(DateTime startDate) {
    Duration duration = DateTime.now().difference(startDate);
    return _formatDurationFromDuration(duration);
  }

  String _formatDurationBetween(DateTime startDate, DateTime endDate) {
    Duration duration = endDate.difference(startDate);
    return _formatDurationFromDuration(duration);
  }

  String _formatDurationFromDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}