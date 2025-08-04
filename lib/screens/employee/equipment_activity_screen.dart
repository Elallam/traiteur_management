// lib/screens/employee/equipment_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class EquipmentActivityScreen extends StatefulWidget {
  final String? employeeId;
  final String? employeeName;

  const EquipmentActivityScreen({
    super.key,
    this.employeeId,
    this.employeeName,
  });

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

  // These filter options will be localized in the TabBar builder
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
      _showErrorSnackBar(AppLocalizations.of(context)!.failedToLoadActivityData(e.toString())); // Localized error message
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
            name: AppLocalizations.of(context)!.unknownEquipment, // Localized
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
          matchesDateRange = checkout.checkoutDate!.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              checkout.checkoutDate!.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }

        // Filter by search query
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          String query = _searchController.text.toLowerCase();
          EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];
          matchesSearch = (equipment?.name.toLowerCase().contains(query) ?? false) ||
              checkout.employeeName.toLowerCase().contains(query) ||
              (checkout.notes?.toLowerCase().contains(query) ?? false);
        }

        return matchesStatus && matchesDateRange && matchesSearch;
      }).toList();

      // Sort by checkout date (newest first)
      _filteredCheckouts.sort((a, b) => b.checkoutDate!.compareTo(a.checkoutDate ?? DateTime.now()));
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
      _showSuccessSnackBar(AppLocalizations.of(context)!.equipmentReturnedSuccessfully); // Localized
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.failedToReturnEquipment); // Localized
    }
  }

  void _showReturnConfirmation(EquipmentCheckout checkout) {
    EquipmentModel? equipment = _equipmentCache[checkout.equipmentId];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmReturn), // Localized
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.confirmReturnEquipment), // Localized
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
                  Text(
                    '${AppLocalizations.of(context)!.equipment}: ${equipment?.name ?? AppLocalizations.of(context)!.unkown}', // Localized
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${AppLocalizations.of(context)!.quantity}: ${checkout.quantity}'), // Localized
                  Text('${AppLocalizations.of(context)!.checkedOut}: ${_formatDateTime(checkout.checkoutDate ?? DateTime.now())}'), // Localized
                  Text('${AppLocalizations.of(context)!.duration}: ${_formatDuration(checkout.checkoutDate ?? DateTime.now())}'), // Localized
                  if (checkout.isOverdue)
                    Text(
                      '${AppLocalizations.of(context)!.status}: ${AppLocalizations.of(context)!.overdue.toUpperCase()}', // Localized
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  if (checkout.notes != null && checkout.notes!.isNotEmpty)
                    Text('${AppLocalizations.of(context)!.notes}: ${checkout.notes}'), // Localized
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _returnEquipment(checkout);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(AppLocalizations.of(context)!.returnText), // Localized
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
                equipment?.name ?? AppLocalizations.of(context)!.unknownEquipment, // Localized
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
              _buildDetailRow(AppLocalizations.of(context)!.category, equipment?.category.toUpperCase() ?? AppLocalizations.of(context)!.unkown), // Localized
              _buildDetailRow(AppLocalizations.of(context)!.quantity, '${checkout.quantity}'), // Localized
              _buildDetailRow(AppLocalizations.of(context)!.status, checkout.status.toUpperCase()), // Localized
              _buildDetailRow(AppLocalizations.of(context)!.checkoutDate, _formatDateTime(checkout.checkoutDate ?? DateTime.now())), // Localized
              if (checkout.returnDate != null)
                _buildDetailRow(AppLocalizations.of(context)!.returnDate, _formatDateTime(checkout.returnDate!)), // Localized
              _buildDetailRow(
                  AppLocalizations.of(context)!.duration, // Localized
                  checkout.returnDate != null
                      ? _formatDurationBetween(checkout.checkoutDate ?? DateTime.now(), checkout.returnDate!)
                      : _formatDuration(checkout.checkoutDate ?? DateTime.now())),
              if (checkout.occasionId != null)
                _buildDetailRow(AppLocalizations.of(context)!.occasionId, checkout.occasionId!), // Localized
              if (checkout.notes != null && checkout.notes!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.notes, checkout.notes!), // Localized
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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.equipmentOverdueForReturn, // Localized
                          style: const TextStyle(
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
            child: Text(AppLocalizations.of(context)!.close), // Localized
          ),
          if (checkout.status == 'checked_out')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showReturnConfirmation(checkout);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: Text(AppLocalizations.of(context)!.returnText), // Localized
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
      body: _isLoading ? LoadingWidget(message: AppLocalizations.of(context)!.loadingMessage) : _buildBody(), // Localized
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.equipmentActivity), // Localized
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
          tooltip: AppLocalizations.of(context)!.filterByDateRange, // Localized
        ),
        if (_dateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearDateRange,
            tooltip: AppLocalizations.of(context)!.clearDateFilter, // Localized
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadActivityData,
          tooltip: AppLocalizations.of(context)!.refresh, // Localized
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
                Text(_getFilterText(filter, context)), // Localized tab text
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

  // Helper function to get localized filter text
  String _getFilterText(String filter, BuildContext context) {
    switch (filter) {
      case 'All':
        return AppLocalizations.of(context)!.all;
      case 'Active':
        return AppLocalizations.of(context)!.active;
      case 'Returned':
        return AppLocalizations.of(context)!.returned;
      case 'Overdue':
        return AppLocalizations.of(context)!.overdue;
      default:
        return filter;
    }
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
                label: AppLocalizations.of(context)!.searchEquipmentOrNotes, // Localized
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
                          AppLocalizations.of(context)!.showingDateRange(_formatDate(_dateRange!.start), _formatDate(_dateRange!.end)), // Localized
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
        title = AppLocalizations.of(context)!.noActiveCheckouts; // Localized
        subtitle = AppLocalizations.of(context)!.allEquipmentReturned; // Localized
        break;
      case 'Returned':
        icon = Icons.assignment_return_outlined;
        title = AppLocalizations.of(context)!.noReturnedItems; // Localized
        subtitle = AppLocalizations.of(context)!.noEquipmentReturnedYet; // Localized
        break;
      case 'Overdue':
        icon = Icons.schedule;
        title = AppLocalizations.of(context)!.noOverdueItems; // Localized
        subtitle = AppLocalizations.of(context)!.allEquipmentReturnedOnTime; // Localized
        break;
      default:
        icon = Icons.history;
        title = AppLocalizations.of(context)!.noActivityFound; // Localized
        subtitle = AppLocalizations.of(context)!.noEquipmentActivityMatchesSearch; // Localized
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
                          equipment?.name ?? AppLocalizations.of(context)!.unknownEquipment, // Localized
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${equipment?.category.toUpperCase() ?? AppLocalizations.of(context)!.unkown} • ', // Localized
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(equipment?.category ?? 'other'),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.quantity}: ${checkout.quantity}', // Localized
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
                          ? AppLocalizations.of(context)!.overdue.toUpperCase() // Localized
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
                              '${AppLocalizations.of(context)!.out}: ${_formatDate(checkout.checkoutDate ?? DateTime.now())}', // Localized
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
                                '${AppLocalizations.of(context)!.inText}: ${_formatDate(checkout.returnDate!)}', // Localized
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
                            ? _formatDurationBetween(checkout.checkoutDate ?? DateTime.now(), checkout.returnDate!)
                            : _formatDuration(checkout.checkoutDate ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.ongoing, // Localized
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
                      label: Text(AppLocalizations.of(context)!.details), // Localized
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showReturnConfirmation(checkout),
                      icon: const Icon(Icons.assignment_return, size: 16),
                      label: Text(AppLocalizations.of(context)!.returnText), // Localized
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
    // Using AppLocalizations for "at"
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${AppLocalizations.of(context)!.atText} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
      return AppLocalizations.of(context)!.durationDaysHours(duration.inDays, duration.inHours % 24); // Localized
    } else if (duration.inHours > 0) {
      return AppLocalizations.of(context)!.durationHoursMinutes(duration.inHours, duration.inMinutes % 60); // Localized
    } else {
      return AppLocalizations.of(context)!.durationMinutes(duration.inMinutes); // Localized
    }
  }
}
