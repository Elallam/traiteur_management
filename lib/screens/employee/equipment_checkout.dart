// lib/screens/employee/equipment_checkout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stock_provider.dart';
import '../../services/firestore_service.dart';

class EquipmentCheckoutScreen extends StatefulWidget {
  final String? occasionId;
  final String? occasionTitle;

  const EquipmentCheckoutScreen({
    Key? key,
    this.occasionId,
    this.occasionTitle,
  }) : super(key: key);

  @override
  State<EquipmentCheckoutScreen> createState() => _EquipmentCheckoutScreenState();
}

class _EquipmentCheckoutScreenState extends State<EquipmentCheckoutScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<EquipmentModel> _allEquipment = [];
  List<EquipmentModel> _filteredEquipment = [];
  Map<String, int> _checkoutQuantities = {};
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isCheckingOut = false;

  late TabController _tabController;
  final List<String> _categories = ['All', 'chairs', 'tables', 'utensils', 'decorations', 'other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadEquipment();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipment() async {
    setState(() => _isLoading = true);
    try {
      _allEquipment = await _firestoreService.getEquipment();
      _filterEquipment();
    } catch (e) {
      _showErrorSnackBar('Failed to load equipment: $e');
    }
    setState(() => _isLoading = false);
  }

  void _filterEquipment() {
    setState(() {
      _filteredEquipment = _allEquipment.where((equipment) {
        // Filter by active status
        if (!equipment.isActive) return false;

        // Filter by category
        if (_selectedCategory != 'All' && equipment.category != _selectedCategory) {
          return false;
        }

        // Filter by search query
        if (_searchController.text.isNotEmpty) {
          return equipment.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }

        return true;
      }).toList();

      // Sort by availability (available first) then by name
      _filteredEquipment.sort((a, b) {
        if (a.isAvailable != b.isAvailable) {
          return a.isAvailable ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    });
  }

  void _updateQuantity(String equipmentId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _checkoutQuantities.remove(equipmentId);
      } else {
        _checkoutQuantities[equipmentId] = quantity;
      }
    });
  }

  int _getTotalSelectedItems() {
    return _checkoutQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double _getTotalSelectedTypes() {
    return _checkoutQuantities.length.toDouble();
  }

  Future<void> _performCheckout() async {
    if (_checkoutQuantities.isEmpty) {
      _showErrorSnackBar('Please select equipment to checkout');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      // Validate availability for all selected equipment
      bool allAvailable = true;
      List<String> unavailableItems = [];

      for (String equipmentId in _checkoutQuantities.keys) {
        EquipmentModel equipment = _allEquipment.firstWhere((eq) => eq.id == equipmentId);
        int requestedQuantity = _checkoutQuantities[equipmentId]!;

        if (equipment.availableQuantity < requestedQuantity) {
          allAvailable = false;
          unavailableItems.add('${equipment.name} (requested: $requestedQuantity, available: ${equipment.availableQuantity})');
        }
      }

      if (!allAvailable) {
        _showUnavailabilityDialog(unavailableItems);
        return;
      }

      // Process checkout for each selected equipment
      List<EquipmentCheckout> checkouts = [];

      for (String equipmentId in _checkoutQuantities.keys) {
        EquipmentModel equipment = _allEquipment.firstWhere((eq) => eq.id == equipmentId);
        int quantity = _checkoutQuantities[equipmentId]!;

        // Create checkout record
        EquipmentCheckout checkout = EquipmentCheckout(
          id: '', // Will be generated by Firestore
          equipmentId: equipmentId,
          employeeId: currentUser.id,
          employeeName: currentUser.fullName,
          quantity: quantity,
          checkoutDate: DateTime.now(),
          occasionId: widget.occasionId,
          status: 'checked_out',
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        // Add checkout to Firestore
        await _firestoreService.addEquipmentCheckout(checkout);

        // Update equipment availability using your existing method
        await _firestoreService.updateEquipmentAvailability(
            equipmentId,
            equipment.availableQuantity - quantity
        );

        checkouts.add(checkout);
      }

      // Show success and navigate back
      _showSuccessDialog(checkouts.length, _getTotalSelectedItems().toInt());

    } catch (e) {
      _showErrorSnackBar('Checkout failed: $e');
    } finally {
      setState(() => _isCheckingOut = false);
    }
  }

  void _showSuccessDialog(int itemTypes, int totalQuantity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('Checkout Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Successfully checked out:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$itemTypes equipment types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '$totalQuantity total items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (widget.occasionTitle != null) ...[
              const SizedBox(height: 12),
              Text(
                'For: ${widget.occasionTitle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          CustomButton(
            text: 'Done',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous screen with success
            },
          ),
        ],
      ),
    );
  }

  void _showUnavailabilityDialog(List<String> unavailableItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_outlined,
          color: AppColors.warning,
          size: 64,
        ),
        title: const Text('Equipment Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following equipment is not available in the requested quantity:'),
            const SizedBox(height: 12),
            ...unavailableItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: const TextStyle(color: AppColors.error)),
            )),
            const SizedBox(height: 12),
            const Text('Please adjust quantities or remove unavailable items.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? const LoadingWidget() : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equipment Checkout'),
          if (widget.occasionTitle != null)
            Text(
              widget.occasionTitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (_checkoutQuantities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_getTotalSelectedTypes().toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        onTap: (index) {
          setState(() {
            _selectedCategory = _categories[index];
            _filterEquipment();
          });
        },
        tabs: _categories.map((category) => Tab(
          text: category == 'All' ? 'All' : category.capitalize(),
        )).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomTextField(
            controller: _searchController,
            label: 'Search equipment...',
            prefixIcon: Icons.search,
            onChanged: (_) => _filterEquipment(),
          ),
        ),

        // Equipment list
        Expanded(
          child: _filteredEquipment.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredEquipment.length,
            itemBuilder: (context, index) {
              return _buildEquipmentCard(_filteredEquipment[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No equipment found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'No equipment available in this category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    final isSelected = _checkoutQuantities.containsKey(equipment.id);
    final selectedQuantity = _checkoutQuantities[equipment.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Equipment image/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(equipment.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: equipment.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      equipment.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _getCategoryIcon(equipment.category),
                        color: _getCategoryColor(equipment.category),
                        size: 28,
                      ),
                    ),
                  )
                      : Icon(
                    _getCategoryIcon(equipment.category),
                    color: _getCategoryColor(equipment.category),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Equipment details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment.category.capitalize(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getCategoryColor(equipment.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            equipment.isAvailable ? Icons.check_circle : Icons.error,
                            size: 16,
                            color: equipment.isAvailable ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${equipment.availableQuantity}/${equipment.totalQuantity} available',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: equipment.isAvailable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Availability indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: equipment.isAvailable
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${equipment.availabilityPercentage.toInt()}%',
                    style: TextStyle(
                      color: equipment.isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            if (equipment.description != null) ...[
              const SizedBox(height: 12),
              Text(
                equipment.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity to checkout:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: equipment.isAvailable && selectedQuantity > 0
                          ? () => _updateQuantity(equipment.id, selectedQuantity - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          selectedQuantity.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: equipment.isAvailable && selectedQuantity < equipment.availableQuantity
                          ? () => _updateQuantity(equipment.id, selectedQuantity + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_checkoutQuantities.isEmpty) return const SizedBox.shrink();

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Notes field
          CustomTextField(
            controller: _notesController,
            label: 'Notes (optional)',
            maxLines: 2,
            prefixIcon: Icons.note_alt_outlined,
          ),
          const SizedBox(height: 16),

          // Summary and checkout button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getTotalSelectedTypes().toInt()} types selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_getTotalSelectedItems()} total items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 140,
                child: CustomButton(
                  text: _isCheckingOut ? 'Processing...' : 'Checkout',
                  onPressed: _isCheckingOut ? null : _performCheckout,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}